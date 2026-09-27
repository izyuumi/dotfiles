typeset -U path PATH

path=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  $path
)

export PATH

[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -r "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"

# zoxide's hook check misfires in shells that replay a snapshot (agent tools).
export _ZO_DOCTOR=0

# Machine-local secrets and IDs, kept out of the repo.
[ -f "$HOME/.zshenv.local" ] && source "$HOME/.zshenv.local"
