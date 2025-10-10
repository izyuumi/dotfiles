#!/bin/bash

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
  "yabai"
  "yazi"
  "yt-dlp"
  "zellij"
  "zsh-autosuggestions"
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
  echo "Installing $package..."
  brew install "$package"
done

echo "Installing cask packages..."
for package in "${cask_packages[@]}"; do
  echo "Installing $package..."
  brew install --cask "$package"
done

echo "All brew installations complete!"
