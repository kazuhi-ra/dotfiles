neofetch
# tmuxが起動していないかつ、SSH接続でもない場合にのみtmuxを起動
if [[ -z "$TMUX" && -z "$SSH_CONNECTION" ]]; then
  # 既存のtmuxセッションがある場合、それに接続
  if tmux has-session 2>/dev/null; then
    exec tmux attach-session -t default
  else
    # 既存のセッションがない場合、新しいtmuxセッションを作成
    exec tmux new-session -s default
  fi
fi
