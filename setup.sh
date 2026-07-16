#!/bin/bash

set -e

current="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Setting up dotfiles..."

backup_dir=""

ensure_macos() {
  echo "🍎 Checking macOS environment..."

  if [ "$(uname -s)" != "Darwin" ]; then
    echo "  ! This setup script is intended for macOS"
    exit 1
  fi

  echo "  ✓ Running on macOS"
}

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

ensure_xcode_command_line_tools() {
  local developer_dir

  echo "🧰 Checking Xcode Command Line Tools..."

  if ! command -v xcode-select >/dev/null 2>&1; then
    echo "  ! xcode-select is not available on this machine"
    echo "    Install Xcode Command Line Tools, then re-run ./setup.sh"
    exit 1
  fi

  if developer_dir="$(xcode-select -p 2>/dev/null)" && [ -d "$developer_dir" ] && xcrun --find clang >/dev/null 2>&1; then
    echo "  ✓ Found developer tools at $developer_dir"
    return 0
  fi

  echo "  ! Xcode Command Line Tools are missing or not ready"
  echo "    Opening the installer. Re-run ./setup.sh after it finishes."
  xcode-select --install 2>/dev/null || true
  exit 1
}

setup_karabiner() {
  local config_dir="$HOME/.config/karabiner"
  local config="$HOME/.config/karabiner/karabiner.json"
  local complex_modifications="$HOME/.config/karabiner/assets/complex_modifications/*.json"
  local attempt

  echo "⌨️ Setting up Karabiner-Elements..."

  if [ -L "$config_dir" ] && [ "$(readlink "$config_dir")" = "${current}/.config/karabiner" ]; then
    echo "  ✓ Karabiner config directory is linked"
  else
    echo "  ! Karabiner config directory is not linked to dotfiles"
  fi

  if [ ! -d "/Applications/Karabiner-Elements.app" ]; then
    echo "  ! Karabiner-Elements.app is missing; run ./brew.sh and re-run ./setup.sh"
    return 0
  fi

  if command -v jq >/dev/null 2>&1; then
    jq empty "$config"
    echo "  ✓ Karabiner config JSON is valid"
  else
    echo "  ! jq missing; skipping Karabiner config JSON validation"
  fi

  if command -v karabiner_cli >/dev/null 2>&1; then
    karabiner_cli --lint-complex-modifications "$complex_modifications" >/dev/null
    echo "  ✓ Karabiner complex modifications are valid"
  else
    echo "  ! karabiner_cli missing; skipping Karabiner CLI setup"
    return 0
  fi

  if open -g -a "Karabiner-Elements" >/dev/null 2>&1; then
    echo "  ✓ Opened Karabiner-Elements in the background"
  else
    echo "  ! Could not open Karabiner-Elements"
  fi

  if launchctl kickstart -k "gui/$(id -u)/org.pqrs.service.agent.karabiner_console_user_server" >/dev/null 2>&1; then
    echo "  ✓ Restarted Karabiner user server"
  else
    echo "  ! Could not restart Karabiner user server"
  fi

  for attempt in 1 2 3 4 5; do
    if karabiner_cli --select-profile "Default profile" >/dev/null 2>&1; then
      echo "  ✓ Selected Karabiner Default profile"
      return 0
    fi

    sleep 1
  done

  echo "  ! Open Karabiner-Elements and approve Background Items, Accessibility, and Driver Extensions, then re-run ./setup.sh"
}

ensure_macos
ensure_xcode_command_line_tools

# Install package managers and packages
echo "📦 Installing Rust toolchain and cargo packages..."
chmod +x "${current}/cargo.sh"
"${current}/cargo.sh"

echo "🍺 Installing Homebrew packages..."
chmod +x "${current}/brew.sh"
"${current}/brew.sh"

echo "🖥️ Applying macOS defaults..."
chmod +x "${current}/macos/defaults.sh"
chmod +x "${current}/macos/finder.sh"
"${current}/macos/defaults.sh"

# Create symlinks
echo "🔗 Creating symlinks..."

# Cross-client Agent Skills
link_item "${current}/.agents" "$HOME/.agents"

# Create .config directory if it doesn't exist
mkdir -p ~/.config

# Config directories that should stay fully managed
link_item "${current}/.config/karabiner" "$HOME/.config/karabiner"
link_item "${current}/.config/nvim" "$HOME/.config/nvim"
link_item "${current}/.config/starship.toml" "$HOME/.config/starship.toml"

# Config directories that mix managed files with local state
ensure_real_directory "$HOME/.config/atuin"
link_item "${current}/.config/atuin/config.toml" "$HOME/.config/atuin/config.toml"

ensure_real_directory "$HOME/.config/gh"
link_item "${current}/.config/gh/config.yml" "$HOME/.config/gh/config.yml"

ensure_real_directory "$HOME/.config/git"
link_item "${current}/.config/git/ignore" "$HOME/.config/git/ignore"

setup_karabiner

ensure_real_directory "$HOME/.config/mise"
link_item "${current}/.config/mise/config.toml" "$HOME/.config/mise/config.toml"

ensure_real_directory "$HOME/.config/uv"

ensure_real_directory "$HOME/.config/yazi"
link_item "${current}/.config/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"

ensure_real_directory "$HOME/.config/yt-dlp"

ensure_real_directory "$HOME/.config/zed"
link_item "${current}/.config/zed/keymap.json" "$HOME/.config/zed/keymap.json"
link_item "${current}/.config/zed/settings.json" "$HOME/.config/zed/settings.json"

# Claude Code (~/.claude mixes managed files with local state)
ensure_real_directory "$HOME/.claude"
link_item "${current}/.claude/settings.json" "$HOME/.claude/settings.json"
link_item "${current}/.claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"

# Codex (config.toml mixes managed keys with machine state; merged, not linked)
chmod +x "${current}/bin/dotfiles-codex-config"
"${current}/bin/dotfiles-codex-config"

# Git global ignore
link_item "${current}/.gitignore_global" "$HOME/.gitignore_global"
link_item "${current}/.gitconfig" "$HOME/.gitconfig"

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
link_item "${current}/.tmux.conf.plugins" "$HOME/.tmux.conf.plugins"
link_item "${current}/.tmux.conf.native" "$HOME/.tmux.conf.native"
link_item "${current}/.tmux.conf.local" "$HOME/.tmux.conf.local"
mkdir -p "$HOME/.tmux/scripts"
for tmux_script in edit-local-config.sh maximize-pane.sh window-name.sh rename-window.sh; do
  link_item "${current}/.tmux/scripts/$tmux_script" "$HOME/.tmux/scripts/$tmux_script"
done


echo "✅ Dotfiles setup complete!"
echo "💡 Run 'source ~/.zshrc' to reload your shell configuration"
echo "💡 Run './post-setup.sh' to finish CLI tool setup"
