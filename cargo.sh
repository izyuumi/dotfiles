#!/bin/bash

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

cargo_packages=(
	"eza"
	"cargo-watch"
	"cargo-generate"
)

for package in "${cargo_packages[@]}"; do
	echo "Installing $package..."
	cargo install "$package"
done
