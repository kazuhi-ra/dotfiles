autoload -Uz compinit && compinit
autoload -Uz colors && colors
autoload -Uz add-zsh-hook

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=$HOME/.zsh_history
setopt append_history
setopt share_history
setopt hist_ignore_all_dups

bindkey -e

alias r="exec \$SHELL -l"
alias b="batcat"
alias t="tree -ACL 2 -I node_modules"
alias tt="tree -aACL 2 -I node_modules"
alias f="fg"
alias g="grep"
alias h="herdr"
alias ll="ls -alF -G"
alias v="nvim"
alias vi="nvim"
alias ..="cd .."
alias ...="cd ../.."

function chpwd() {
  tree -ACL 1
}

# when enter
function do_enter() {
  zle accept-line
  if [ -z "$BUFFER" ]; then
    tree -ACL 1
  fi
}

zle -N do_enter
bindkey '^m' do_enter
bindkey '^j' do_enter

typeset -g HERDR_LAST_TAB_LABEL=""

function herdr-rename-tab() {
  [[ -n ${HERDR_TAB_ID:-} ]] || return
  command -v herdr >/dev/null || return

  local label="$1"
  [[ -n $label ]] || return
  [[ $HERDR_LAST_TAB_LABEL == "$label" ]] && return

  HERDR_LAST_TAB_LABEL="$label"
  herdr tab rename "$HERDR_TAB_ID" "$label" >/dev/null 2>&1 &!
}

function herdr-rename-tab-for-command() {
  local words command_name
  words=("${(z)1}")

  if [[ ${words[1]:-} == cd ]]; then
    local i
    for i in {1..${#words[@]}}; do
      if [[ ${words[$i]} == "&&" ]]; then
        words=("${words[@]:$i}")
        break
      fi
    done
  fi

  while [[ ${#words[@]} -gt 0 ]]; do
    command_name=${words[1]}
    case "$command_name" in
      command|exec|env|noglob|time|sudo)
        words=("${words[@]:1}")
        ;;
      *=*)
        words=("${words[@]:1}")
        ;;
      *)
        break
        ;;
    esac
  done

  [[ -n ${command_name:-} ]] || return
  if [[ -n ${aliases[$command_name]:-} ]]; then
    words=("${(z)aliases[$command_name]}")
    command_name=${words[1]}
  fi
  command_name=${command_name:t}
  herdr-rename-tab "$command_name"
}
add-zsh-hook preexec herdr-rename-tab-for-command

function herdr-rename-tab-for-prompt() {
  herdr-rename-tab "${SHELL:t}"
}
add-zsh-hook precmd herdr-rename-tab-for-prompt

# ghq
function peco-ghq-look() {
  local project dir repository workspace workspace_id created pane_id tab_id response pane current_label
  project=$(ghq list -p | peco --prompt='Project >')

  if [[ $project == "" ]]; then
    return 1
  else
    dir=$project
  fi

  if [[ -n ${HERDR_ENV:-} ]] && command -v herdr >/dev/null && command -v jq >/dev/null; then
    repository=${dir##*/}
    workspace=${repository//./-}
    workspace_id=$(herdr workspace list \
      | jq -r --arg label "$workspace" '.result.workspaces[]? | select(.label == $label) | .workspace_id' \
      | head -n 1)

    if [[ -n $workspace_id ]]; then
      herdr workspace focus "$workspace_id" >/dev/null
    else
      created=1
      current_label=$(herdr workspace get "${HERDR_WORKSPACE_ID:-}" 2>/dev/null \
        | jq -r '.result.workspace.label // empty')
      # home workspace (Cmd+Shift+T) は cwd=$HOME なので label が "~" になる
      if [[ -n ${HERDR_WORKSPACE_ID:-} && ( -z $current_label || $current_label == "~" ) ]]; then
        # 現在の workspace が未バインド(home)なら新規作成せず今の workspace を上書きする
        workspace_id=$HERDR_WORKSPACE_ID
        herdr workspace rename "$workspace_id" "$workspace" >/dev/null
      else
        response=$(herdr workspace create --cwd "$dir" --label "$workspace" --focus)
        workspace_id=$(printf '%s' "$response" | jq -r '.result.workspace.workspace_id // empty')
      fi
    fi

    if [[ -n ${created:-} ]]; then
      pane=$(herdr pane list --workspace "$workspace_id" \
        | jq -c '.result.panes | (map(select(.focused == true))[0] // .[0]) // empty')
      pane_id=$(printf '%s' "$pane" | jq -r '.pane_id // empty')
      tab_id=$(printf '%s' "$pane" | jq -r '.tab_id // empty')
      if [[ -n $pane_id ]]; then
        herdr pane run "$pane_id" "cd ${(q)dir} && nvim" >/dev/null
        [[ -n $tab_id ]] && herdr tab rename "$tab_id" "nvim" >/dev/null 2>&1
      fi
    fi
  else
    cd $dir
  fi
}
zle -N peco-ghq-look
bindkey '^G' peco-ghq-look


eval "$(starship init zsh)"

zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions"
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi
bindkey '^[OA' history-substring-search-up
bindkey '^P' history-substring-search-up
bindkey '^[OB' history-substring-search-down
bindkey '^N' history-substring-search-down

zplug load

source $HOME/.cargo/env

# マシンローカル設定(git 管理外)
if [ -f $HOME/.zshrc.local ]; then
  source $HOME/.zshrc.local
fi
