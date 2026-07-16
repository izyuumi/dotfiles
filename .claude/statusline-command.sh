#!/usr/bin/env bash
# statusline-command.sh — wraps ccusage statusline + caveman badge

input=$(cat)

ccusage_output=$(echo "$input" | bun x ccusage statusline 2>/dev/null)

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

if [ -n "$ccusage_output" ] && [ -n "$caveman_badge" ]; then
  printf "%s  %b" "$ccusage_output" "$caveman_badge"
elif [ -n "$ccusage_output" ]; then
  printf "%s" "$ccusage_output"
elif [ -n "$caveman_badge" ]; then
  printf "%b" "$caveman_badge"
fi
