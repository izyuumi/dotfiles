#!/bin/bash

set -e

current="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Setting up dotfiles..."

backup_dir=""
backup_if_needed() {
  if [ -z "$backup_dir" ]; then
    backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
  fi
}

link_item() {
  local src="$1"
  local dest="$2"
  local dest_dir

  if [ ! -e "$src" ]; then
    echo "  ! Skipped missing $(basename "$src")"
    return 0
  fi

  if [ -L "$dest" ]; then
    if [ "$(readlink "$dest")" = "$src" ]; then
      echo "  ✓ Already linked $(basename "$dest")"
      return 0
    fi
    backup_if_needed
    mv "$dest" "$backup_dir/"
  elif [ -e "$dest" ]; then
    backup_if_needed
    mv "$dest" "$backup_dir/"
  fi

  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"
  ln -s "$src" "$dest"
  echo "  ✓ Linked $(basename "$dest")"
}

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

# Individual config directories/files
for config_dir in atuin gh karabiner mise nvim starship.toml uv yazi yt-dlp zed zellij; do
  link_item "${current}/.config/$config_dir" "$HOME/.config/$config_dir"
done

# Git global ignore
link_item "${current}/.gitignore_global" "$HOME/.gitignore_global"
git config --global core.excludesfile ~/.gitignore_global

# Ghostty config
mkdir -p ~/Library/Application\ Support/com.mitchellh.ghostty
link_item "${current}/ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

# Zsh config
link_item "${current}/.zshrc" "$HOME/.zshrc"

# Tmux config
link_item "${current}/.tmux.conf" "$HOME/.tmux.conf"


echo "✅ Dotfiles setup complete!"
echo "💡 Run 'source ~/.zshrc' to reload your shell configuration"
