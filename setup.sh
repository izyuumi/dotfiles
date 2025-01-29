#!/bin/bash

chmod +x cargo.sh
chmod +x brew.sh

./cargo.sh
./brew.sh

cp ./.gitignore_global ~/
git config --global core.excludesfile ~/.gitignore_global

source .zshrc
