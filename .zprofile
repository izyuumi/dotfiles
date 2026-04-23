
eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Keep mise shims on PATH for login and non-interactive shells.
eval "$(/opt/homebrew/bin/mise activate zsh --shims)"
