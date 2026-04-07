setopt no_nomatch

typeset -g DOTFILES_DIR="${${(%):-%N}:A:h}"
typeset -g DOTFILES_ZSH_DIR="$DOTFILES_DIR/zsh"

if [[ ! -d "$DOTFILES_ZSH_DIR" ]]; then
  echo "Missing zsh config directory: $DOTFILES_ZSH_DIR" >&2
  return 1
fi

for zsh_file in "$DOTFILES_ZSH_DIR"/*.zsh(N); do
  source "$zsh_file"
done
