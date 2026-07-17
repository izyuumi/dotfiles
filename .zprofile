if [ -f "$HOME/.profile" ]; then
  . "$HOME/.profile"
fi

# Full Homebrew environment (MANPATH, HOMEBREW_* vars) once per login;
# base PATH entries already come from ~/.config/shell/paths.sh.
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -x "$HOMEBREW_PREFIX/bin/brew" ]; then
  eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
fi

if [ -f "$HOME/.zprofile.local" ]; then
  . "$HOME/.zprofile.local"
fi
