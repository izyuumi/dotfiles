if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

if [ -d "/opt/homebrew/bin" ]; then
  case ":$PATH:" in
    *":/opt/homebrew/bin:"*) ;;
    *) PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH" ;;
  esac
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
