alias lg="lazygit"
alias yolo="claude --dangerously-skip-permissions"
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
