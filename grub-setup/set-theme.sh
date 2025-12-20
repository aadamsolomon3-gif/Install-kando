#!/usr/bin/env bash
set -e

echo "=== GRUB Theme Installer / Dual Boot Config (Relative Paths) ==="

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Variables
THEME_NAME="minegrub-world-selection"        # change to the theme you want
THEME_BACKUP_DIR="$SCRIPT_DIR/grub-themes"       # relative to script folder
GRUB_THEME_DIR="/boot/grub/themes"

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with sudo."
    exit 1
fi

# Create GRUB themes folder if it doesn't exist
mkdir -p "$GRUB_THEME_DIR"

# Copy themes from backup to /boot/grub/themes
echo "Copying themes from $THEME_BACKUP_DIR to $GRUB_THEME_DIR..."
cp -r "$THEME_BACKUP_DIR/"* "$GRUB_THEME_DIR/"

# Set proper ownership and permissions
chmod -R 755 "$GRUB_THEME_DIR"
chown -R root:root "$GRUB_THEME_DIR"

# Update /etc/default/grub to use the selected theme
GRUB_DEFAULT_FILE="/etc/default/grub"
if ! grep -q "^GRUB_THEME=" "$GRUB_DEFAULT_FILE"; then
    echo "Setting GRUB theme in $GRUB_DEFAULT_FILE..."
    echo "GRUB_THEME=\"$GRUB_THEME_DIR/$THEME_NAME/theme.txt\"" >> "$GRUB_DEFAULT_FILE"
else
    echo "Updating existing GRUB_THEME in $GRUB_DEFAULT_FILE..."
    sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$GRUB_THEME_DIR/$THEME_NAME/theme.txt\"|" "$GRUB_DEFAULT_FILE"
fi

# Enable os-prober for dual boot
if ! grep -q "^GRUB_DISABLE_OS_PROBER=false" "$GRUB_DEFAULT_FILE"; then
    echo "Enabling os-prober..."
    sed -i '/^GRUB_DISABLE_OS_PROBER=/d' "$GRUB_DEFAULT_FILE"
    echo "GRUB_DISABLE_OS_PROBER=false" >> "$GRUB_DEFAULT_FILE"
fi

# Regenerate GRUB configuration
echo "Generating GRUB configuration..."
grub-mkconfig -o /boot/grub/grub.cfg

echo "GRUB theme applied successfully!"
echo "You can reboot and see your theme in action."
