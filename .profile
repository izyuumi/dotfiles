if [ -r "$HOME/.config/shell/paths.sh" ]; then
  . "$HOME/.config/shell/paths.sh"
elif [ -r "$HOME/dotfiles/shell/paths.sh" ]; then
  # Fallback until ./setup.sh has linked ~/.config/shell/paths.sh
  . "$HOME/dotfiles/shell/paths.sh"
fi

if [ -d "$HOME/.lmstudio/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.lmstudio/bin:"*) ;;
    *) PATH="$PATH:$HOME/.lmstudio/bin" ;;
  esac
fi

export PATH

if [ -f "$HOME/.profile.local" ]; then
  . "$HOME/.profile.local"
fi
