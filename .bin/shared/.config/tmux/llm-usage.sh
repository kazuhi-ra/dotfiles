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
# claude caps as ccusage COST (USD). Cost weights token types like the real rate
# limit does (output heavy, cache-read cheap), so it tracks /usage far better than
# raw token counts (which are ~97% cache-read and drift non-linearly).
# No per-plan setting exists; calibrate empirically.
# Re-calibrate when it drifts:  cap = <ccusage costUSD> / (used_fraction from /usage)
#   5h  : active block costUSD              / (5h used %)
#   week: costUSD since the weekly reset    / (weekly used %)
# 5h: fit over /usage points 22/35/53% used (origin slope $3.25/%) -> $325.
# week: must use the FIXED reset window, NOT trailing-7d (which drifts as old days
#       fall off). Least-squares over 41/72/90% used ($517/$926/$1263 since reset)
#       -> $1347. Cost is mildly convex vs the real %, so expect up to ~4pt error.
CLAUDE_5H_COST_LIMIT="${CLAUDE_5H_COST_LIMIT:-325}"
CLAUDE_WEEK_COST_LIMIT="${CLAUDE_WEEK_COST_LIMIT:-1347}"
# A known weekly-reset instant (2026-06-29 19:00 JST); the limit resets every 7
# days from here, so any past/future reset is this ± k*7d. Used to find week start.
CLAUDE_WEEK_ANCHOR="${CLAUDE_WEEK_ANCHOR:-1782727200}"

# remaining% -> tmux fg color markup (green / yellow / red)
color() {
  if   [ "$1" -ge 50 ]; then printf '#[fg=colour114]'
  elif [ "$1" -ge 20 ]; then printf '#[fg=colour179]'
  else                       printf '#[fg=colour203]'
  fi
}

# seconds -> compact eta like "1h52m" or "47m" (clamped at 0)
fmt_eta() {
  local s="$1" h m
  [ "$s" -lt 0 ] 2>/dev/null && s=0
  h=$(( s / 3600 )); m=$(( (s % 3600) / 60 ))
  if [ "$h" -gt 0 ]; then printf '%dh%02dm' "$h" "$m"; else printf '%dm' "$m"; fi
}

compute() {
  local out="" now
  now="$(date +%s)"

  # --- claude: ccusage cost (USD) for active 5h block + weekly window, vs caps ---
  local json c5 rem5 cend c7 rem7 seg diff k wkstart
  json="$("$CCUSAGE" blocks --json 2>/dev/null)"
  if [ -n "$json" ]; then
    seg=""
    # 5h: current active block cost + reset countdown (approx: block endTime,
    # which is hour-floored so it runs up to ~1h ahead of the real /usage reset)
    c5="$(printf '%s' "$json" | jq '[.blocks[]|select(.isActive==true)|.costUSD]|first // 0' 2>/dev/null)"
    if [ -n "${c5:-}" ] && [ "${CLAUDE_5H_COST_LIMIT:-0}" -gt 0 ] 2>/dev/null; then
      rem5="$(jq -n --argjson c "$c5" --argjson m "$CLAUDE_5H_COST_LIMIT" '([100-($c*100/$m),0]|max)|floor')"
      seg+=" $(color "$rem5")${rem5}%#[default]"
      cend="$(printf '%s' "$json" | jq -r 'first(.blocks[]|select(.isActive).endTime) // "" | if . == "" then "" else (sub("\\.[0-9]+Z$";"Z")|fromdateiso8601|tostring) end' 2>/dev/null)"
      [ -n "$cend" ] && [ "$(( cend - now ))" -gt 0 ] && seg+="#[fg=colour245] $(fmt_eta $(( cend - now )))#[default]"
    fi
    # weekly: cost since the current fixed weekly window's start. The window
    # resets every 7 days from CLAUDE_WEEK_ANCHOR; floor (now-anchor)/7d to find it.
    diff=$(( now - CLAUDE_WEEK_ANCHOR ))
    if [ "$diff" -ge 0 ]; then k=$(( diff / 604800 )); else k=$(( (diff - 604799) / 604800 )); fi
    wkstart=$(( CLAUDE_WEEK_ANCHOR + k * 604800 ))
    c7="$(printf '%s' "$json" | jq --argjson s "$wkstart" \
          '[.blocks[]|select(.isGap//false|not)|select((.startTime|sub("\\.[0-9]+Z$";"Z")|fromdateiso8601) >= $s)|.costUSD]|add // 0' 2>/dev/null)"
    if [ -n "${c7:-}" ] && [ "${CLAUDE_WEEK_COST_LIMIT:-0}" -gt 0 ] 2>/dev/null; then
      rem7="$(jq -n --argjson c "$c7" --argjson m "$CLAUDE_WEEK_COST_LIMIT" '([100-($c*100/$m),0]|max)|floor')"
      seg+=" w$(color "$rem7")${rem7}%#[default]"
    fi
    [ -n "$seg" ] && out+="#[fg=colour215]cc#[default]${seg}"
  fi

  # --- codex: real 5h (primary) and weekly (secondary) quota ---
  # Pick the most recent rollout that actually has a rate_limits snapshot; a
  # freshly started session has none until its first turn (would hide codex).
  local cfile rl cp cs f creset cseg
  cfile=""
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if grep -q '"rate_limits"' "$f" 2>/dev/null; then cfile="$f"; break; fi
  done < <(find "$HOME/.codex/sessions" -name 'rollout-*.jsonl' -type f -mtime -3 2>/dev/null \
            | xargs ls -t 2>/dev/null)
  if [ -n "$cfile" ]; then
    rl="$(grep '"rate_limits"' "$cfile" 2>/dev/null | tail -1 \
          | jq -c 'first(..|objects|select(has("rate_limits")).rate_limits) // empty' 2>/dev/null)"
    if [ -n "$rl" ]; then
      cp="$(printf '%s' "$rl" | jq -r '(100 - (.primary.used_percent   // 0)) | floor')"
      cs="$(printf '%s' "$rl" | jq -r '(100 - (.secondary.used_percent // 0)) | floor')"
      # 5h reset countdown from the server's exact resets_at epoch
      creset="$(printf '%s' "$rl" | jq -r '.primary.resets_at // empty')"
      cseg=" $(color "$cp")${cp}%#[default]"
      [ -n "$creset" ] && [ "$(( creset - now ))" -gt 0 ] && cseg+="#[fg=colour245] $(fmt_eta $(( creset - now )))#[default]"
      cseg+=" w$(color "$cs")${cs}%#[default]"
      [ -n "$out" ] && out+="#[fg=colour240] | #[default]"
      out+="#[fg=colour110]cdx#[default]${cseg}"
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
