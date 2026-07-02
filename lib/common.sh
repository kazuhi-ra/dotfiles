# マシンプロファイルの解決を一元管理する。
# 判定結果は初回に PROFILE_FILE へ保存し、以後はそれを正とする
# (ホスト名判定のドリフトを防ぐため、判定ロジックはこのファイルにしか書かない)。

PROFILE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/machine"

detect_machine() {
  if [ "$(uname)" = "Darwin" ]; then
    echo "mac"
    return
  fi
  case "$(hostname)" in
    zunda | himari | kazuhira) echo "ubuntu-desktop" ;;
    *) echo "server" ;;
  esac
}

resolve_machine() {
  if [ -f "$PROFILE_FILE" ]; then
    cat "$PROFILE_FILE"
  else
    detect_machine
  fi
}

save_machine() {
  mkdir -p "$(dirname "$PROFILE_FILE")"
  echo "$1" >"$PROFILE_FILE"
}
