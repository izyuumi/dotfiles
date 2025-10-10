#!/bin/bash

set -e

current="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Setting up dotfiles..."

# Install package managers and packages
echo "📦 Installing Rust toolchain and cargo packages..."
chmod +x "${current}/cargo.sh"
"${current}/cargo.sh"

echo "🍺 Installing Homebrew packages..."
chmod +x "${current}/brew.sh"
"${current}/brew.sh"

# Create symlinks
echo "🔗 Creating symlinks..."

# Create .config directory if it doesn't exist
mkdir -p ~/.config

# Individual config directories
for config_dir in atuin gh karabiner mise nvim starship.toml uv yazi yt-dlp zed zellij; do
  if [ ! -L ~/.config/$config_dir ]; then
    if [ -e "${current}/.config/$config_dir" ]; then
      ln -s "${current}/.config/$config_dir" ~/.config/
      echo "  ✓ Linked .config/$config_dir"
    fi
  fi
done

# Git global ignore
if [ ! -L ~/.gitignore_global ]; then
  ln -s "${current}/.gitignore_global" ~/
  git config --global core.excludesfile ~/.gitignore_global
  echo "  ✓ Linked .gitignore_global"
fi

# Ghostty config
mkdir -p ~/Library/Application\ Support/com.mitchellh.ghostty
if [ ! -L ~/Library/Application\ Support/com.mitchellh.ghostty/config ]; then
  ln -s "${current}/ghostty" ~/Library/Application\ Support/com.mitchellh.ghostty/config
  echo "  ✓ Linked ghostty config"
fi

# Zsh config
if [ ! -L ~/.zshrc ]; then
  ln -s "${current}/.zshrc" ~/
  echo "  ✓ Linked .zshrc"
fi

# Tmux config
if [ ! -L ~/.tmux.conf ]; then
  ln -s "${current}/.tmux.conf" ~/
  echo "  ✓ Linked .tmux.conf"
fi

# Yabai config
if [ ! -L ~/.yabairc ]; then
  ln -s "${current}/.yabairc" ~/
  echo "  ✓ Linked .yabairc"
fi

echo "✅ Dotfiles setup complete!"
echo "💡 Run 'source ~/.zshrc' to reload your shell configuration"
