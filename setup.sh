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

ensure_real_directory() {
  local dir="$1"
  local temp_dir

  if [ -L "$dir" ] && [ -d "$dir" ]; then
    temp_dir="$(mktemp -d)"
    cp -R "$dir/." "$temp_dir/" 2>/dev/null || true
    rm "$dir"
    mkdir -p "$dir"
    cp -R "$temp_dir/." "$dir/" 2>/dev/null || true
    rm -rf "$temp_dir"
    echo "  ✓ Migrated $(basename "$dir") to a real directory"
    return 0
  fi

  mkdir -p "$dir"
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

# Config directories that should stay fully managed
link_item "${current}/.config/nvim" "$HOME/.config/nvim"
link_item "${current}/.config/starship.toml" "$HOME/.config/starship.toml"

# Config directories that mix managed files with local state
ensure_real_directory "$HOME/.config/atuin"
link_item "${current}/.config/atuin/config.toml" "$HOME/.config/atuin/config.toml"

ensure_real_directory "$HOME/.config/gh"
link_item "${current}/.config/gh/config.yml" "$HOME/.config/gh/config.yml"

ensure_real_directory "$HOME/.config/karabiner"
link_item "${current}/.config/karabiner/assets" "$HOME/.config/karabiner/assets"
link_item "${current}/.config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

ensure_real_directory "$HOME/.config/mise"
link_item "${current}/.config/mise/config.toml" "$HOME/.config/mise/config.toml"

ensure_real_directory "$HOME/.config/uv"

ensure_real_directory "$HOME/.config/yazi"
link_item "${current}/.config/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"

ensure_real_directory "$HOME/.config/yt-dlp"

ensure_real_directory "$HOME/.config/zed"
link_item "${current}/.config/zed/keymap.json" "$HOME/.config/zed/keymap.json"
link_item "${current}/.config/zed/settings.json" "$HOME/.config/zed/settings.json"

# Git global ignore
link_item "${current}/.gitignore_global" "$HOME/.gitignore_global"
git config --global core.excludesfile ~/.gitignore_global

# Ghostty config
mkdir -p ~/Library/Application\ Support/com.mitchellh.ghostty
link_item "${current}/ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

# Shell config
link_item "${current}/.profile" "$HOME/.profile"
link_item "${current}/.zprofile" "$HOME/.zprofile"
link_item "${current}/.zshenv" "$HOME/.zshenv"

# Zsh config
link_item "${current}/.zshrc" "$HOME/.zshrc"

# Tmux config
link_item "${current}/.tmux.conf" "$HOME/.tmux.conf"
link_item "${current}/.tmux.conf.local" "$HOME/.tmux.conf.local"
mkdir -p "$HOME/.tmux/scripts"
for tmux_script in edit-local-config.sh maximize-pane.sh window-name.sh rename-window.sh; do
  link_item "${current}/.tmux/scripts/$tmux_script" "$HOME/.tmux/scripts/$tmux_script"
done


echo "✅ Dotfiles setup complete!"
echo "💡 Run 'source ~/.zshrc' to reload your shell configuration"
