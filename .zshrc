setopt no_nomatch

# ---------- env ----------
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

# ---------- prompt ----------
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ---------- functions ----------
# Ensure SSH agent forwarding works in shells where SSH_AUTH_SOCK is unset.
if [[ -z "$SSH_AUTH_SOCK" ]]; then
  launchd_ssh_sock="$(launchctl getenv SSH_AUTH_SOCK 2>/dev/null)"
  if [[ -n "$launchd_ssh_sock" && -S "$launchd_ssh_sock" ]]; then
    export SSH_AUTH_SOCK="$launchd_ssh_sock"
  fi
fi

nd() {
  mkdir -p -- "$1" && cd -P -- "$1"
}

fs() {
  if du -b /dev/null >/dev/null 2>&1; then
    local arg="-sbh"
  else
    local arg="-sh"
  fi

  if [[ $# -gt 0 ]]; then
    du "$arg" -- "$@"
  else
    du "$arg" .[^.]* ./*
  fi
}

o() {
  if [[ $# -eq 0 ]]; then
    open .
  else
    open "$@"
  fi
}

nv() {
  if [[ $# -eq 0 ]]; then
    command vim .
  else
    command vim "$@"
  fi
}

ww() {
  command watch -n 1 "$@"
}

shellExit() {
  if [[ ! -o login ]]; then
    . "$HOME/.zlogout"
  fi
}

# ---------- aliases ----------
alias lg="lazygit"
alias yolo="CLAUDE_CODE_NO_FLICKER=1 claude --enable-auto-mode"
alias colo="codex --yolo"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

alias dl="cd ~/Downloads"
alias gitcommitraycast="git diff | pbcopy; open raycast://ai-commands/git-commit-message"

alias l='eza -lF'
alias la='eza -lAF'
alias lsd="eza -lF | grep --color=never '^d'"
alias ls="eza --icons -F -H --group-directories-first --git -1"
alias lsa="ls -a"

alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias sudo="sudo "

alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\\? \\(addr:\\)\\?\\s\\?\\(\\(\\([0-9]\\+\\.\\)\\{3\\}[0-9]\\+\\)\\|[a-fA-F0-9:]\\+\\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

alias reload="exec ${SHELL} -l"
alias path='printf "%s\n" $path'

# ---------- tools ----------
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  . "$NVM_DIR/nvm.sh"
fi

if [[ -s "$NVM_DIR/bash_completion" ]]; then
  . "$NVM_DIR/bash_completion"
fi

if [[ -f "$HOME/.local/bin/env" ]]; then
  . "$HOME/.local/bin/env"
fi

if [[ -s "$HOME/.bun/_bun" ]]; then
  source "$HOME/.bun/_bun"
fi

if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

if command -v ssh-add >/dev/null 2>&1; then
  /usr/bin/ssh-add --apple-load-keychain 2>/dev/null
fi

# ---------- tmux ----------
# t [name] -> attach/create session (outside tmux)
t() {
  local name="${1:-yumi}"

  if [[ -n "$TMUX" ]]; then
    local current
    current="$(tmux display-message -p '#S' 2>/dev/null)"
    if [[ -n "$current" && "$name" == "$current" ]]; then
      return 0
    fi

    echo "Already inside tmux (${current:-unknown}); open a new terminal to attach to '$name'."
    return 1
  fi

  tmux new-session -A -s "$name"
}

tls() {
  tmux list-sessions 2>/dev/null || echo "(no sessions)"
}

tk() {
  if [[ -z "$1" ]]; then
    echo "Usage: tk <session>"
    return 1
  fi

  if [[ -n "$TMUX" ]]; then
    local current
    current="$(tmux display-message -p '#S' 2>/dev/null)"
    if [[ -n "$current" && "$1" == "$current" ]]; then
      echo "Refusing to kill current tmux session '$1'."
      return 1
    fi
  fi

  tmux kill-session -t "$1" 2>/dev/null
}

_t_complete_sessions() {
  if [[ $CURRENT -ne 2 ]]; then
    return
  fi

  local -a sessions
  sessions=(${(f)"$(tmux list-sessions -F '#S' 2>/dev/null)"})
  if [[ ${#sessions[@]} -gt 0 ]]; then
    _describe "tmux session" sessions
  fi
}

# ---------- completion ----------
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

# ---------- plugins ----------
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

# ---------- zoxide ----------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi
