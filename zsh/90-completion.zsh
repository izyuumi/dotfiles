if [[ -d "$HOME/.zsh/completions" ]]; then
  fpath=("$HOME/.zsh/completions" $fpath)
fi

if [[ -d "$HOME/.docker/completions" ]]; then
  fpath=("$HOME/.docker/completions" $fpath)
fi

autoload -Uz compinit
compinit

compdef _t_complete_sessions t
compdef _t_complete_sessions tk
