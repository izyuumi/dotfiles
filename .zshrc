setopt no_nomatch

export TERM=xterm-256color

eval "$(starship init zsh)"

alias lg="lazygit"

#alias rm='safe-rm'

alias yolo="claude --dangerously-skip-permissions"

function nd() {
  mkdir -p -- "$1" && cd -P -- "$1"
}

function fs() {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh
  else
    local arg=-sh
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@"
  else
    du $arg .[^.]* ./*
  fi
}

export EDITOR="nvim"
export VISUAL="nvim"

function o() {
  if [ $# -eq 0 ]; then
    open .
  else
    open "$@"
  fi
}

nv() {
  if [ $# -eq 0 ]; then
    command nvim .
  else
    command nvim "$@"
  fi
}

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

# Shortcuts
alias dl="cd ~/Downloads"

alias gitcommitraycast="git diff | pbcopy; open raycast://ai-commands/git-commit-message"

# List all files colorized in long format
alias l="eza -lF ${colorflag}"

# List all files colorized in long format, excluding . and ..
alias la="eza -lAF ${colorflag}"

# List only directories
alias lsd="eza -lF ${colorflag} | grep --color=never '^d'"

# Always use color output for `ls`
alias ls='eza --icons -F -H --group-directories-first --git -1'

alias lsa='ls -a'

# Always enable colored `grep` output
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Enable aliases to be sudo’ed
alias sudo='sudo '

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

function shellExit {
  if [[ ! -o login ]]; then
    . ~/.zlogout
  fi
}

eval "$(atuin init zsh)"
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ -f "$HOME/.local/bin/env" ]; then
  . "$HOME/.local/bin/env"
fi

# bun completions
[ -s "/Users/yumiizumi/.bun/_bun" ] && source "/Users/yumiizumi/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# opencode
export PATH=/Users/yumiizumi/.opencode/bin:$PATH

# -- tmux helpers that avoid nesting and switch sessions when already inside tmux --

# t [name] -> attach/create session (outside tmux) OR switch to it (inside tmux)
t() {
  local n="${1:-$(basename "${PWD%/}")}"

  if [ -n "$TMUX" ]; then
    if tmux has-session -t "$n" 2>/dev/null; then
      tmux switch-client -t "$n"
    else
      tmux new-session -d -s "$n" && tmux switch-client -t "$n"
    fi
  else
    if tmux has-session -t "$n" 2>/dev/null; then
      tmux attach -t "$n"
    else
      tmux new-session -s "$n"
    fi
  fi
}

# tls -> list sessions
tls() {
  tmux list-sessions 2>/dev/null || echo "(no sessions)"
}

# tk <name> -> kill a session
tk() {
  if [ -z "$1" ]; then
    echo "Usage: tk <session>"
    return 1
  fi

  if [ -n "$TMUX" ]; then
    local current
    current="$(tmux display-message -p '#S')"
    if [ "$1" = "$current" ]; then
      local fallback
      fallback="$(tmux list-sessions -F '#S' 2>/dev/null | grep -v "^${current}$" | head -n1)"
      [ -n "$fallback" ] && tmux switch-client -t "$fallback"
    fi
  fi

  tmux kill-session -t "$1" 2>/dev/null
}

autoload -Uz compinit
compinit

_t_complete_sessions() {
  if [[ $CURRENT -ne 2 ]]; then
    return
  fi

  local -a sessions
  sessions=(${(f)"$(tmux list-sessions -F '#S' 2>/dev/null)"})
  if [[ ${#sessions[@]} -gt 0 ]]; then
    _describe 'tmux session' sessions
  fi
}

compdef _t_complete_sessions t
compdef _t_complete_sessions tk

alias claude-kimi="ANTHROPIC_AUTH_TOKEN=rutilea2025 ANTHROPIC_BASE_URL=http://100.100.2.65:4000 claude --model kimi-k2"
alias yolo-kimi="IS_SANDBOX=1 ANTHROPIC_AUTH_TOKEN=rutilea2025 ANTHROPIC_BASE_URL=http://100.100.2.65:4000 claude --model kimi-k2 --dangerously-skip-permissions"
alias yolo-ds="IS_SANDBOX=1 ANTHROPIC_AUTH_TOKEN=rutilea2025 ANTHROPIC_BASE_URL=http://100.100.2.65:4000 claude --model deepseek --dangerously-skip-permissions"
alias yolo-ds31="IS_SANDBOX=1 ANTHROPIC_AUTH_TOKEN=rutilea2025 ANTHROPIC_BASE_URL=http://100.100.2.65:4000 claude --model ds31 --dangerously-skip-permissions"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export PATH="$HOME/.local/bin:$PATH"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Added by Antigravity
export PATH="/Users/yumiizumi/.antigravity/antigravity/bin:$PATH"
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
