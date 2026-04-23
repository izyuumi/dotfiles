#!/bin/sh

set -eu

config="${HOME}/.tmux.conf.local"
base="${HOME}/.tmux.conf"
editor="${VISUAL:-${EDITOR:-vim}}"

case "$editor" in
  *vim*)
    "$editor" -c ':set syntax=tmux' "$config"
    ;;
  *)
    "$editor" "$config"
    ;;
esac

tmux source-file "$base"
tmux display-message "${config} reloaded"
