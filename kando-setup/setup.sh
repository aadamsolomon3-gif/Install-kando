#!/usr/bin/env bash

set -e

# Install Flatpak if not installed
if ! command -v flatpak &> /dev/null; then
    echo "Installing Flatpak..."
    sudo pacman -S --noconfirm flatpak
else
    echo "Flatpak already installed."
fi

# Add Flathub repository if missing
if ! flatpak remotes | grep -q flathub; then
    echo "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
else
    echo "Flathub already added."
fi

# Install Kando Flatpak
if ! flatpak list | grep -q menu.kando.Kando; then
    echo "Installing Kando..."
    flatpak install -y flathub menu.kando.Kando
else
    echo "Kando already installed."
fi

# Add to Hyprland exec file
EXEC_FILE="$HOME/.config/hypr/hyprland/execs.conf"
mkdir -p "$(dirname "$EXEC_FILE")"
LINE="exec-once = kando"
if ! grep -Fxq "$LINE" "$EXEC_FILE" 2>/dev/null; then
    echo -e "# Kando Menu\n$LINE" >> "$EXEC_FILE"
    echo "Kando exec added."
else
    echo "Kando exec already exists."
fi

# Add keybind
KEYBIND_FILE="$HOME/.config/hypr/hyprland/keybinds.conf"
mkdir -p "$(dirname "$KEYBIND_FILE")"
KEYBIND="bind = CTRL, Space, global, :example-menu"
if ! grep -Fxq "$KEYBIND" "$KEYBIND_FILE" 2>/dev/null; then
    echo "$KEYBIND" >> "$KEYBIND_FILE"
    echo "Keybind added."
else
    echo "Keybind already exists."
fi

# Reload Hyprland if hyprctl exists
if command -v hyprctl &> /dev/null; then
    echo "Reloading Hyprland..."
    hyprctl reload
else
    echo "hyprctl not found. Please reload Hyprland manually."
fi
