setopt no_nomatch

eval "$(starship init zsh)"

alias lg="lazygit"

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
    nvim .
  else
    nvim "$@"
  fi
}

hx() {
  if [ $# -eq 0 ]; then
    command hx .
  else
    command hx "$@"
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
