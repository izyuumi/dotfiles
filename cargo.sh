#!/bin/bash

if command -v cargo > /dev/null 2>&1; then
  echo "Cargo is already installed"
else
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  source "$HOME/.cargo/env"
fi

cargo_packages=(
  "eza"
  "cargo-watch"
  "cargo-generate"
  "cargo-bloat"
)

for package in "${cargo_packages[@]}"; do
  echo "Installing $package..."
  cargo install "$package"
done

rustup component add rust-analyzer
