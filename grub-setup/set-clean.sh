#!/usr/bin/env bash
set -e

echo "=== Full Boot Theme Installer (GRUB + Plymouth + SDDM) ==="

# Detect script folder
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

### ------------------ Variables ------------------ ###
# GRUB
GRUB_THEME_DIR="$SCRIPT_DIR/grub-themes"   # optional: your GRUB theme folder
GRUB_THEME_NAME="my-grub-theme"            # folder name in grub-themes

# Plymouth
PLYMOUTH_THEME_DIR="$SCRIPT_DIR/plymouth-themes"
PLYMOUTH_THEME_NAME="mc"

# SDDM
SDDM_THEME_DIR="$SCRIPT_DIR/sddm-themes"
SDDM_THEME_NAME="mytheme"

# System paths
GRUB_DIR="/boot/grub"
PLYMOUTH_DIR="/usr/share/plymouth/themes"
SDDM_DIR="/usr/share/sddm/themes"
SDDM_CONF="/etc/sddm.conf"

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with sudo."
    exit 1
fi

### ------------------ GRUB Theme ------------------ ###
if [ -d "$GRUB_THEME_DIR/$GRUB_THEME_NAME" ]; then
    echo "Applying GRUB theme..."
    mkdir -p "$GRUB_DIR/themes"
    cp -r "$GRUB_THEME_DIR/$GRUB_THEME_NAME" "$GRUB_DIR/themes/"
    chmod -R 755 "$GRUB_DIR/themes/$GRUB_THEME_NAME"
    chown -R root:root "$GRUB_DIR/themes/$GRUB_THEME_NAME"

    # Set GRUB to use the theme
    GRUB_DEFAULT_FILE="/etc/default/grub"
    if grep -q "^GRUB_THEME=" "$GRUB_DEFAULT_FILE"; then
        sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$GRUB_DIR/themes/$GRUB_THEME_NAME/theme.txt\"|" "$GRUB_DEFAULT_FILE"
    else
        echo "GRUB_THEME=\"$GRUB_DIR/themes/$GRUB_THEME_NAME/theme.txt\"" >> "$GRUB_DEFAULT_FILE"
    fi
else
    echo "No GRUB theme folder found. Skipping GRUB theme."
fi

### ------------------ Plymouth Theme ------------------ ###
echo "Applying Plymouth theme..."
# Remove existing
rm -rf "$PLYMOUTH_DIR/$PLYMOUTH_THEME_NAME"
cp -r "$PLYMOUTH_THEME_DIR/$PLYMOUTH_THEME_NAME" "$PLYMOUTH_DIR/"
chmod -R 755 "$PLYMOUTH_DIR/$PLYMOUTH_THEME_NAME"
chown -R root:root "$PLYMOUTH_DIR/$PLYMOUTH_THEME_NAME"
plymouth-set-default-theme -R "$PLYMOUTH_THEME_NAME"

# Ensure Plymouth hook in mkinitcpio
MKINITCPIO_CONF="/etc/mkinitcpio.conf"
if ! grep -q "plymouth" "$MKINITCPIO_CONF"; then
    sed -i 's/\(HOOKS=.*\)filesystems/\1plymouth filesystems/' "$MKINITCPIO_CONF"
fi

# Enable Plymouth services
for svc in plymouth-start plymouth-quit plymouth-quit-wait; do
    systemctl enable "$svc.service"
done

# Regenerate initramfs
mkinitcpio -P

# Ensure GRUB kernel parameters for splash
GRUB_CONF="/etc/default/grub"
if grep -q "GRUB_CMDLINE_LINUX_DEFAULT" "$GRUB_CONF"; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash vt.global_cursor_default=0"/' "$GRUB_CONF"
else
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash vt.global_cursor_default=0"' >> "$GRUB_CONF"
fi

# Ensure GRUB graphics settings
grep -q "GRUB_GFXMODE" "$GRUB_CONF" || echo 'GRUB_GFXMODE=auto' >> "$GRUB_CONF"
grep -q "GRUB_GFXPAYLOAD_LINUX" "$GRUB_CONF" || echo 'GRUB_GFXPAYLOAD_LINUX=keep' >> "$GRUB_CONF"

### ------------------ SDDM Theme ------------------ ###
echo "Applying SDDM theme..."
# Remove existing
rm -rf "$SDDM_DIR/$SDDM_THEME_NAME"
cp -r "$SDDM_THEME_DIR/$SDDM_THEME_NAME" "$SDDM_DIR/"
chmod -R 755 "$SDDM_DIR/$SDDM_THEME_NAME"
chown -R root:root "$SDDM_DIR/$SDDM_THEME_NAME"

# Update SDDM config
if [ ! -f "$SDDM_CONF" ]; then
    echo -e "[Theme]\nCurrent=$SDDM_THEME_NAME" > "$SDDM_CONF"
else
    if grep -q "^Current=" "$SDDM_CONF"; then
        sed -i "s/^Current=.*/Current=$SDDM_THEME_NAME/" "$SDDM_CONF"
    else
        grep -q "^\[Theme\]" "$SDDM_CONF" || echo "[Theme]" >> "$SDDM_CONF"
        echo "Current=$SDDM_THEME_NAME" >> "$SDDM_CONF"
    fi
fi

# Restart SDDM
systemctl restart sddm.service

### ------------------ Finalize GRUB ------------------ ###
echo "Regenerating GRUB config..."
grub-mkconfig -o /boot/grub/grub.cfg

echo "=== All themes applied successfully! ==="
echo "Reboot your system to see seamless GRUB → Plymouth → SDDM transition."
