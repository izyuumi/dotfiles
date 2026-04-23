#!/bin/sh

set -eu

current_session=${1:-$(tmux display-message -p '#{session_name}')}
current_pane=${2:-$(tmux display-message -p '#{pane_id}')}

dead_panes=$(
  tmux list-panes -s -t "$current_session" -F '#{pane_dead} #{pane_id} #{pane_start_command}' |
    grep -E -o '^1 %.+maximized.+$' || true
)

restore=$(
  printf "%s" "$dead_panes" | sed -n -E \
    -e "s/^1 $current_pane .+maximized.+'(%[0-9]+)'\"?$/tmux swap-pane -s \1 -t $current_pane \\; kill-pane -t $current_pane/p" \
    -e "s/^1 (%[0-9]+) .+maximized.+'$current_pane'\"?$/tmux swap-pane -s \1 -t $current_pane \\; kill-pane -t \1/p"
)

if [ -z "$restore" ]; then
  pane_count=$(tmux list-panes -t "$current_session:" | wc -l | tr -d ' ')
  if [ "$pane_count" -eq 1 ]; then
    tmux display-message "Can't maximize with only one pane"
    exit 0
  fi

  info=$(
    tmux new-window -t "$current_session:" -F "#{session_name}:#{window_index}.#{pane_id}" -P \
      "maximized... 2>/dev/null & tmux setw -t \"$current_session:\" remain-on-exit on; printf \"\\033[\$(tput lines);0fPane has been maximized, press <prefix>+ to restore\n\" '$current_pane'"
  )
  session_window=${info%.*}
  new_pane=${info#*.}

  retry=20
  while [ "$(tmux list-panes -t "$session_window" -F '#{session_name}:#{window_index}.#{pane_id} #{pane_dead}' 2>/dev/null)" != "$info 1" ] && [ "$retry" -ne 0 ]; do
    sleep 0.1
    retry=$((retry - 1))
  done

  if [ "$retry" -eq 0 ]; then
    tmux display-message 'Unable to maximize pane'
    exit 1
  fi

  tmux setw -t "$session_window" remain-on-exit off \; swap-pane -s "$current_pane" -t "$new_pane"
else
  sh -c "$restore" || tmux kill-pane
fi
