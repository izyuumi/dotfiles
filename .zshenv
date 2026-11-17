typeset -U path PATH

if [ -r "$HOME/.config/shell/paths.sh" ]; then
  . "$HOME/.config/shell/paths.sh"
elif [ -r "$HOME/dotfiles/shell/paths.sh" ]; then
  # Fallback until ./setup.sh has linked ~/.config/shell/paths.sh
  . "$HOME/dotfiles/shell/paths.sh"
fi

# zoxide's hook check misfires in shells that replay a snapshot (agent tools).
export _ZO_DOCTOR=0

# Machine-local secrets and IDs, kept out of the repo.
[ -f "$HOME/.zshenv.local" ] && source "$HOME/.zshenv.local"
