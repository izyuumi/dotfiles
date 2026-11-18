#!/usr/bin/env bash
# statusline-command.sh — caveman badge

cat >/dev/null

# Caveman badge from plugin's flag file
FLAG="$HOME/.claude/.caveman-active"
caveman_badge=""
if [ -f "$FLAG" ]; then
  MODE=$(cat "$FLAG" 2>/dev/null)
  if [ "$MODE" = "full" ] || [ -z "$MODE" ]; then
    caveman_badge='\033[38;5;172m[CAVEMAN]\033[0m'
  else
    SUFFIX=$(echo "$MODE" | tr '[:lower:]' '[:upper:]')
    caveman_badge=$(printf '\033[38;5;172m[CAVEMAN:%s]\033[0m' "$SUFFIX")
  fi
fi

if [ -n "$caveman_badge" ]; then
  printf "%b" "$caveman_badge"
fi
