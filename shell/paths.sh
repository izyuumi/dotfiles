# shellcheck shell=sh
# shell/paths.sh — single source of truth for base PATH entries.
#
# POSIX sh; cheap enough to source from every shell. Sourced by .zshenv,
# .profile, and post-setup.sh. setup.sh symlinks this file to
# ~/.config/shell/paths.sh so rc files can find it without knowing the
# repo location.
#
# Interactive-only tools (bun, opencode, lmstudio, grok) stay in .zshrc.

__paths_prepend() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

# Homebrew — Apple Silicon or Intel prefix.
if [ -x /opt/homebrew/bin/brew ]; then
  HOMEBREW_PREFIX="/opt/homebrew"
elif [ -x /usr/local/bin/brew ]; then
  HOMEBREW_PREFIX="/usr/local"
fi

if [ -n "${HOMEBREW_PREFIX:-}" ]; then
  export HOMEBREW_PREFIX
  __paths_prepend "$HOMEBREW_PREFIX/sbin"
  __paths_prepend "$HOMEBREW_PREFIX/bin"
fi

# Rust
[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
__paths_prepend "$HOME/.cargo/bin"

# Atuin
[ -r "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"

# mise shims — keeps mise-managed tools available in login and
# non-interactive shells; interactive zsh upgrades to full
# `mise activate zsh` in .zshrc.
__paths_prepend "${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims"

__paths_prepend "$HOME/.local/bin"

export PATH
unset -f __paths_prepend
