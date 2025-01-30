#!/bin/bash

current="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# install cargo and brew
chmod +x "${current}/cargo.sh"
chmod +x "${current}/brew.sh"

"${current}/cargo.sh"
"${current}/brew.sh"

# make symlinks
ln -s "${current}/.config" ~/

ln -s "${current}/.gitignore_global" ~/
git config --global core.excludesfile ~/.gitignore_global

ln -s "${current}/ghostty" ~/Library/Application\ Support/com.mitchellh.ghostty/config

ln -s "${current}/.zshrc" ~/

# source zshrc
source ~/.zshrc
