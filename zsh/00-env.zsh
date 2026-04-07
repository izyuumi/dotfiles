export TERM="xterm-256color"
export EDITOR="vim"
export VISUAL="vim"
export NVM_DIR="$HOME/.nvm"
export BUN_INSTALL="$HOME/.bun"
export SDKMAN_DIR="$HOME/.sdkman"

typeset -gU path fpath

path=(
  "$HOME/.local/bin"
  "$BUN_INSTALL/bin"
  "$HOME/.opencode/bin"
  "$HOME/.antigravity/antigravity/bin"
  $path
)

if [[ -n ${HOMEBREW_PREFIX:-} ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi
