typeset -U path PATH

if [ -r "$HOME/.config/shell/paths.sh" ]; then
  . "$HOME/.config/shell/paths.sh"
elif [ -r "$HOME/dotfiles/shell/paths.sh" ]; then
  # Fallback until ./setup.sh has linked ~/.config/shell/paths.sh
  . "$HOME/dotfiles/shell/paths.sh"
fi
