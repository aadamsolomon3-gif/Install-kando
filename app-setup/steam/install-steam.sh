#!/usr/bin/env bash
set -e

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    echo "yay is not installed. Please install yay first."
    exit 1
fi

# Check if Steam is already installed
if command -v steam &> /dev/null; then
    echo "Steam is already installed. Skipping installation."
    exit 0
fi

echo "Installing Steam via yay..."
yay -S --noconfirm steam

echo "Steam installation complete!"
