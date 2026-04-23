#!/bin/sh

set -eu

pane_id=${1:?pane id required}
window_id=${2:-$(tmux display-message -p -t "$pane_id" '#{window_id}')}
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
name=$("$script_dir/window-name.sh" "$pane_id")

if [ -n "$name" ]; then
  tmux rename-window -t "$window_id" "$name"
fi
