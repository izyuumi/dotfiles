if command -v brew >/dev/null 2>&1; then
  typeset -g __brew_prefix
  __brew_prefix="$(brew --prefix)"

  if [[ -f "$__brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$__brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi

  if [[ -f "$__brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$__brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  fi
fi
