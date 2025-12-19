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

# Check if Spotify is already installed
if command -v spotify &> /dev/null; then
    echo "Spotify is already installed, skipping..."
else
    echo "Installing Spotify..."
    yay -S --noconfirm spotify
fi

echo "Script finished! You can now run Spotify with the command 'spotify'."
