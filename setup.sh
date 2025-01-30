#!/bin/bash

chmod +x cargo.sh
chmod +x brew.sh

./cargo.sh
./brew.sh

ln -s ./.config ~/

ln -s ./.gitignore_global ~/
git config --global core.excludesfile ~/.gitignore_global

ln -s ./ghostty ~/Library/Application\ Support/com.mitchellh.ghostty/config

source .zshrc
