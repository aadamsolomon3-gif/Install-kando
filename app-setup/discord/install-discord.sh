#!/usr/bin/env bash
set -e

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    echo "yay is not installed. Please install yay first."
    exit 1
fi

# Check if Discord is already installed
if command -v discord &> /dev/null; then
    echo "Discord is already installed. Skipping installation."
    exit 0
fi

echo "Installing Discord via yay..."
yay -S --noconfirm discord

echo "Discord installation complete!"
