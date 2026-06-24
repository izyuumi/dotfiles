#!/bin/bash

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: finder.sh <command>

Commands:
  show-hidden-files
  hide-hidden-files
  show-desktop
  hide-desktop
USAGE
}

case "${1:-}" in
  show-hidden-files)
    defaults write com.apple.finder AppleShowAllFiles -bool true
    ;;
  hide-hidden-files)
    defaults write com.apple.finder AppleShowAllFiles -bool false
    ;;
  show-desktop)
    defaults write com.apple.finder CreateDesktop -bool true
    ;;
  hide-desktop)
    defaults write com.apple.finder CreateDesktop -bool false
    ;;
  -h | --help | help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

killall Finder >/dev/null 2>&1 || true
