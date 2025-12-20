#!/usr/bin/env bash
set -e

echo "=== Plymouth Theme Installer (Automatic Replacement) ==="

# Detect the directory where the script is running
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Variables
THEME_NAME="my-plymouth-theme"                # name of the theme folder you want to apply
THEME_BACKUP_DIR="$SCRIPT_DIR/plymouth-themes"  # relative folder containing your themes
PLYMOUTH_DIR="/usr/share/plymouth/themes"

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with sudo."
    exit 1
fi

# Remove existing theme if it exists
if [ -d "$PLYMOUTH_DIR/$THEME_NAME" ]; then
    echo "Removing existing theme: $PLYMOUTH_DIR/$THEME_NAME"
    rm -rf "$PLYMOUTH_DIR/$THEME_NAME"
fi

# Copy Plymouth theme from backup to system
echo "Copying theme from $THEME_BACKUP_DIR/$THEME_NAME to $PLYMOUTH_DIR"
cp -r "$THEME_BACKUP_DIR/$THEME_NAME" "$PLYMOUTH_DIR/"

# Set proper permissions
chmod -R 755 "$PLYMOUTH_DIR/$THEME_NAME"
chown -R root:root "$PLYMOUTH_DIR/$THEME_NAME"

# Set the theme as default
echo "Setting Plymouth theme..."
plymouth-set-default-theme -R "$THEME_NAME"

# Update initramfs
echo "Updating initramfs..."
if command -v mkinitcpio &> /dev/null; then
    mkinitcpio -P
else
    echo "Warning: mkinitcpio not found. Please update your initramfs manually."
fi

echo "Plymouth theme '$THEME_NAME' applied successfully!"
echo "Reboot to see your login screen."
