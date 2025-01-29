#!/bin/bash

chmod +x cargo.sh
chmod +x brew.sh

./cargo.sh
./brew.sh

ln -s ./.config ~/

ln ./.gitignore_global ~/
git config --global core.excludesfile ~/.gitignore_global

source .zshrc
