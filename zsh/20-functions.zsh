# Ensure SSH agent forwarding works in shells where SSH_AUTH_SOCK is unset.
if [[ -z "$SSH_AUTH_SOCK" ]]; then
  launchd_ssh_sock="$(launchctl getenv SSH_AUTH_SOCK 2>/dev/null)"
  if [[ -n "$launchd_ssh_sock" && -S "$launchd_ssh_sock" ]]; then
    export SSH_AUTH_SOCK="$launchd_ssh_sock"
  fi
fi

nd() {
  mkdir -p -- "$1" && cd -P -- "$1"
}

fs() {
  if du -b /dev/null >/dev/null 2>&1; then
    local arg="-sbh"
  else
    local arg="-sh"
  fi

  if [[ $# -gt 0 ]]; then
    du "$arg" -- "$@"
  else
    du "$arg" .[^.]* ./*
  fi
}

o() {
  if [[ $# -eq 0 ]]; then
    open .
  else
    open "$@"
  fi
}

nv() {
  if [[ $# -eq 0 ]]; then
    command vim .
  else
    command vim "$@"
  fi
}

ww() {
  command watch -n 1 "$@"
}

shellExit() {
  if [[ ! -o login ]]; then
    . "$HOME/.zlogout"
  fi
}
