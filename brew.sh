#!/bin/bash

set -euo pipefail

install_cask_if_needed() {
  local package="$1"
  local output

  if brew list --cask "$package" > /dev/null 2>&1; then
    echo "$package is already installed"
    return 0
  fi

  echo "Installing $package..."
  if output="$(brew install --cask "$package" 2>&1)"; then
    printf '%s\n' "$output"
    return 0
  fi

  printf '%s\n' "$output"
  if printf '%s\n' "$output" | grep -q "already an App at '/Applications/"; then
    echo "$package app already exists in /Applications; skipping Homebrew cask install"
    return 0
  fi

  return 1
}

if command -v brew > /dev/null 2>&1; then
  echo "Homebrew is already installed"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

regular_packages=(
  "ast-grep"
  "atuin"
  "bash"
  "cargo-binstall"
  "curl"
  "deno"
  "docker"
  "docker-completion"
  "ffmpeg"
  "font-hack-nerd-font"
  "gh"
  "git-lfs"
  "go"
  "lazygit"
  "mise"
  "mkcert"
  "mosh"
  "neovim"
  "nextdns"
  "node"
  "ollama"
  "ripgrep"
  "sevenzip"
  "starship"
  "tmux"
  "tree"
  "tree-sitter"
  "typescript"
  "uv"
  "yazi"
  "yt-dlp"
  "zoxide"
  "zsh-autosuggestions"
  "zsh-syntax-highlighting"
)

cask_packages=(
  "alt-tab"
  "chatgpt"
  "ghostty"
  "hoppscotch"
  "karabiner-elements"
  "keycastr"
  "raycast"
  "screen-studio"
  "signal"
)

echo "Installing regular packages..."
for package in "${regular_packages[@]}"; do
  if brew list "$package" > /dev/null 2>&1; then
    echo "$package is already installed"
    continue
  fi

  echo "Installing $package..."
  brew install "$package"
done

echo "Installing cask packages..."
for package in "${cask_packages[@]}"; do
  install_cask_if_needed "$package"
done

echo "All brew installations complete!"
