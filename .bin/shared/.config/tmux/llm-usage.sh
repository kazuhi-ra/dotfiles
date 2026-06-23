#!/usr/bin/env bash
# tmux status segment: remaining quota % for codex and claude.
#
#   codex : real server-side rate limits (5h / weekly) from the latest
#           ~/.codex/sessions/**/rollout-*.jsonl `rate_limits` snapshot.
#   claude: approximate. Claude does NOT expose a live quota %, so we use
#           ccusage's current 5h block tokens divided by a cap. The cap is
#           $CLAUDE_TOKEN_LIMIT if set, otherwise the largest historical
#           5h block (self-calibrating). Shown with a "~" to flag it.
#
# Output is cached and refreshed in the background, so tmux's 1s status
# interval never blocks on ccusage (~1.5s/run).

set -u

CACHE="${TMPDIR:-/tmp}/tmux-llm-usage.cache"
LOCK="${TMPDIR:-/tmp}/tmux-llm-usage.lock"
TTL=60 # seconds between refreshes

CCUSAGE="$(command -v ccusage 2>/dev/null || echo "$HOME/.anyenv/envs/nodenv/shims/ccusage")"
# claude caps in tokens (ccusage totalTokens, ~97% cache-read so the raw counts
# are large). No per-plan setting exists; these are calibrated empirically.
# Re-calibrate when they drift:  cap = <ccusage tokens> / (used_fraction from /usage)
#   5h  : active block totalTokens          / (5h used %)
#   week: trailing-7d sum of block tokens   / (weekly used %)
# Calibrated 2026-06-23 against /usage: 5h=14% used, week=33% used.
CLAUDE_TOKEN_LIMIT="${CLAUDE_TOKEN_LIMIT:-1190000000}"
CLAUDE_WEEKLY_TOKEN_LIMIT="${CLAUDE_WEEKLY_TOKEN_LIMIT:-14600000000}"

# remaining% -> tmux fg color markup (green / yellow / red)
color() {
  if   [ "$1" -ge 50 ]; then printf '#[fg=colour114]'
  elif [ "$1" -ge 20 ]; then printf '#[fg=colour179]'
  else                       printf '#[fg=colour203]'
  fi
}

compute() {
  local out=""

  # --- claude: ccusage 5h block + trailing-7d vs calibrated caps (approximate) ---
  local json now cur5 rem5 cur7 rem7 seg
  json="$("$CCUSAGE" blocks --json 2>/dev/null)"
  if [ -n "$json" ]; then
    seg=""
    # 5h: current active block
    cur5="$(printf '%s' "$json" | jq '[.blocks[]|select(.isActive==true)|.totalTokens]|first // 0' 2>/dev/null)"
    if [ -n "${cur5:-}" ] && [ "${CLAUDE_TOKEN_LIMIT:-0}" -gt 0 ] 2>/dev/null; then
      rem5="$(jq -n --argjson c "$cur5" --argjson m "$CLAUDE_TOKEN_LIMIT" '([100-($c*100/$m),0]|max)|floor')"
      seg+=" $(color "$rem5")${rem5}%#[default]"
    fi
    # weekly: trailing 7 days of block tokens
    now="$(date +%s)"
    cur7="$(printf '%s' "$json" | jq --argjson now "$now" \
            '[.blocks[]|select(.isGap//false|not)|select((.startTime|sub("\\.[0-9]+Z$";"Z")|fromdateiso8601) >= ($now-604800))|.totalTokens]|add // 0' 2>/dev/null)"
    if [ -n "${cur7:-}" ] && [ "${CLAUDE_WEEKLY_TOKEN_LIMIT:-0}" -gt 0 ] 2>/dev/null; then
      rem7="$(jq -n --argjson c "$cur7" --argjson m "$CLAUDE_WEEKLY_TOKEN_LIMIT" '([100-($c*100/$m),0]|max)|floor')"
      seg+=" w$(color "$rem7")${rem7}%#[default]"
    fi
    [ -n "$seg" ] && out+="#[fg=colour215]cc#[default]${seg}"
  fi

  # --- codex: real 5h (primary) and weekly (secondary) quota ---
  local cfile rl cp cs
  cfile="$(find "$HOME/.codex/sessions" -name 'rollout-*.jsonl' -type f 2>/dev/null \
            | xargs ls -t 2>/dev/null | head -1)"
  if [ -n "$cfile" ]; then
    rl="$(grep '"rate_limits"' "$cfile" 2>/dev/null | tail -1 \
          | jq -c 'first(..|objects|select(has("rate_limits")).rate_limits) // empty' 2>/dev/null)"
    if [ -n "$rl" ]; then
      cp="$(printf '%s' "$rl" | jq -r '(100 - (.primary.used_percent   // 0)) | floor')"
      cs="$(printf '%s' "$rl" | jq -r '(100 - (.secondary.used_percent // 0)) | floor')"
      [ -n "$out" ] && out+="#[fg=colour240] | #[default]"
      out+="#[fg=colour110]cdx#[default] $(color "$cp")${cp}%#[default] w$(color "$cs")${cs}%#[default]"
    fi
  fi

  printf '%s' "$out"
}

# Serve cached value immediately; refresh in the background when stale.
now=$(date +%s)
mtime=0
if [ -f "$CACHE" ]; then
  cat "$CACHE"
  mtime=$(stat -f %m "$CACHE" 2>/dev/null || echo 0)
fi

if [ $(( now - mtime )) -ge "$TTL" ]; then
  if mkdir "$LOCK" 2>/dev/null; then
    (
      trap 'rmdir "$LOCK" 2>/dev/null' EXIT
      result="$(compute)"
      printf '%s' "$result" >"$CACHE.tmp" && mv "$CACHE.tmp" "$CACHE"
    ) >/dev/null 2>&1 &
  fi
fi
