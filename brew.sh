#!/bin/bash


if command -v brew >/dev/null 2>&1; then
    echo "Homebrew is already installed"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

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
	"nextdns"
)

cask_packages=(
	"alt-tab"
	"signal"
	"ghostty"
	"raycast"
	"screen-studio"
	"legcord"
	"postman"
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
