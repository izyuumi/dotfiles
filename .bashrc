case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash)"
fi
