# t [name] -> attach/create session (outside tmux)
t() {
  local name="${1:-yumi}"

  if [[ -n "$TMUX" ]]; then
    local current
    current="$(tmux display-message -p '#S' 2>/dev/null)"
    if [[ -n "$current" && "$name" == "$current" ]]; then
      return 0
    fi

    echo "Already inside tmux (${current:-unknown}); open a new terminal to attach to '$name'."
    return 1
  fi

  tmux new-session -A -s "$name"
}

tls() {
  tmux list-sessions 2>/dev/null || echo "(no sessions)"
}

tk() {
  if [[ -z "$1" ]]; then
    echo "Usage: tk <session>"
    return 1
  fi

  if [[ -n "$TMUX" ]]; then
    local current
    current="$(tmux display-message -p '#S' 2>/dev/null)"
    if [[ -n "$current" && "$1" == "$current" ]]; then
      echo "Refusing to kill current tmux session '$1'."
      return 1
    fi
  fi

  tmux kill-session -t "$1" 2>/dev/null
}

_t_complete_sessions() {
  if [[ $CURRENT -ne 2 ]]; then
    return
  fi

  local -a sessions
  sessions=(${(f)"$(tmux list-sessions -F '#S' 2>/dev/null)"})
  if [[ ${#sessions[@]} -gt 0 ]]; then
    _describe "tmux session" sessions
  fi
}
