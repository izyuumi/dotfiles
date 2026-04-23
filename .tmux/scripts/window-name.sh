#!/bin/sh

set -eu

pane_id=${1:?pane id required}

pane_path=$(tmux display-message -p -t "$pane_id" '#{pane_current_path}')
pane_title=$(tmux display-message -p -t "$pane_id" '#{pane_title}')
pane_pid=$(tmux display-message -p -t "$pane_id" '#{pane_pid}')

local_name() {
  path=$1
  if [ "$path" = "$HOME" ]; then
    printf '~'
  else
    basename "$path"
  fi
}

remote_path_from_title() {
  title=$1
  title=${title## }
  title=${title%% }

  case "$title" in
    *:\ ~*|*:\ /*)
      title=${title#*: }
      ;;
  esac

  case "$title" in
    *:~*|*:/*)
      printf '%s' "${title#*:}"
      return 0
      ;;
    "~"|~/*|/*)
      printf '%s' "$title"
      return 0
      ;;
  esac

  return 1
}

remote_host_from_args() {
  command_name=$1
  args=$2

  case "$command_name" in
    mosh-client)
      printf '%s\n' "$args" | awk -F' -# | \\| ' 'NF >= 3 { gsub(/[[:space:]]+$/, "", $2); print $2; exit }'
      ;;
    ssh)
      printf '%s\n' "$args" | awk '
        NR == 1 {
          skip = 0
          for (i = 2; i <= NF; ++i) {
            tok = $i
            if (skip) {
              skip = 0
              continue
            }
            if (tok ~ /^-/) {
              if (tok ~ /^-(B|e|F|I|i|J|L|l|m|O|o|p|Q|R|S|W|w)$/) {
                skip = 1
              }
              continue
            }
            print tok
            exit
          }
        }'
      ;;
  esac
}

remote_label() {
  host=$1
  title=$2

  host=${host##*@}
  if [ -z "$host" ]; then
    return 1
  fi

  if remote_path=$(remote_path_from_title "$title"); then
    printf '%s:%s' "$host" "$remote_path"
  else
    printf '%s:~' "$host"
  fi
}

child_pid=$(pgrep -P "$pane_pid" | head -n 1 || true)
if [ -n "$child_pid" ]; then
  child_args=$(ps -o args= -p "$child_pid" 2>/dev/null | sed 's/^ *//')
  child_exec=$(printf '%s\n' "$child_args" | awk 'NR == 1 { print $1 }')
  child_name=${child_exec##*/}

  case "$child_name" in
    ssh|mosh-client)
      host=$(remote_host_from_args "$child_name" "$child_args" || true)
      if label=$(remote_label "$host" "$pane_title" 2>/dev/null); then
        printf '%s\n' "$label"
        exit 0
      fi
      ;;
  esac
fi

printf '%s\n' "$(local_name "$pane_path")"
