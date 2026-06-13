if [ -f "$HOME/.profile" ]; then
  . "$HOME/.profile"
fi

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Keep mise shims on PATH for login and non-interactive shells.
if [ -x /opt/homebrew/bin/mise ]; then
  eval "$(/opt/homebrew/bin/mise activate zsh --shims)"
fi

if [ -f "$HOME/.zprofile.local" ]; then
  . "$HOME/.zprofile.local"
fi
