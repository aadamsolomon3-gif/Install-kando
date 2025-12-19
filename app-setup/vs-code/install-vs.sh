#!/usr/bin/env bash
set -e

# Install prerequisites if not already installed
sudo pacman -S --needed --noconfirm git base-devel

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    echo "Installing yay (AUR helper)..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
else
    echo "yay is already installed, skipping..."
fi

# Check if VS Code is already installed
if command -v code &> /dev/null; then
    echo "VS Code is already installed, skipping..."
else
    echo "Installing Visual Studio Code..."
    yay -S --noconfirm visual-studio-code-bin
fi

echo "Script finished! You can now run VS Code with 'code'."
