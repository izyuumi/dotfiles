#!/bin/bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

regular_packages=(
	"deno"
	"node"
	"docker"
	"ollama"
	"starship"
	"atuin"
	"gh"
	"font-hack-nerd-font"
  "prettierd"
)

cask_packages=(
	"alt-tab"
	"signal"
	"ghostty"
	"raycast"
	"screen-studio"
	"legcord"
	"postman"
	"nextdns"
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
