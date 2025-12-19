#!/usr/bin/env bash
set -e

# Install prerequisites if not already installed
sudo pacman -S --needed --noconfirm git base-devel

# Check if yay is already installed
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

# Install WhatsApp from AUR
echo "Installing WhatsApp..."
yay -S --noconfirm whatsapp-linux-desktop-bin

# Optional alternative:
# yay -S --noconfirm unofficial-whatsapp

echo "Installation complete! You can now run WhatsApp."
