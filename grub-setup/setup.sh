#!/usr/bin/env bash
set -e

echo "=== Fully Automatic GRUB Installer / Dual Boot Updater ==="

# Detect if system is UEFI or BIOS
if [ -d /sys/firmware/efi ]; then
    echo "System detected: UEFI"
    sys_type=UEFI
else
    echo "System detected: BIOS (Legacy)"
    sys_type=BIOS
fi

# Ensure required packages are installed
echo "Installing GRUB packages..."
sudo pacman -S --noconfirm grub efibootmgr dosfstools os-prober

# Enable os-prober to detect other OSes (like Windows)
if ! grep -q "^GRUB_DISABLE_OS_PROBER=false" /etc/default/grub 2>/dev/null; then
    echo "Enabling os-prober in /etc/default/grub..."
    sudo sed -i '/^GRUB_DISABLE_OS_PROBER=/d' /etc/default/grub
    echo 'GRUB_DISABLE_OS_PROBER=false' | sudo tee -a /etc/default/grub
fi

# Detect EFI partition automatically (UEFI only)
efi_mount=""
if [ "$sys_type" = "UEFI" ]; then
    efi_mount=$(lsblk -o MOUNTPOINT,FSTYPE | grep -i vfat | awk '{print $1}' | head -n1)
    if [ -z "$efi_mount" ]; then
        echo "No EFI partition found. Exiting."
        exit 1
    fi
    echo "Detected EFI mount point: $efi_mount"
fi

# Detect target disk (for BIOS) automatically: root disk
target_disk=""
if [ "$sys_type" = "BIOS" ]; then
    target_disk=$(df / | tail -1 | awk '{print $1}' | sed 's/[0-9]*$//')
    echo "Detected target disk for GRUB (BIOS): $target_disk"
fi

# Install GRUB only if not already installed
grub_installed=false
if command -v grub-install &> /dev/null && [ -f /boot/grub/grub.cfg ]; then
    echo "GRUB appears to be already installed. Skipping installation."
    grub_installed=true
fi

if [ "$grub_installed" = false ]; then
    echo "Installing GRUB..."
    if [ "$sys_type" = "UEFI" ]; then
        sudo grub-install --target=x86_64-efi --efi-directory="$efi_mount" --bootloader-id=GRUB
    else
        sudo grub-install --target=i386-pc "$target_disk"
    fi
fi

# Always regenerate GRUB configuration (detects other OSes)
echo "Generating GRUB configuration..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "GRUB installation/update completed successfully!"
echo "You should now see Linux and other OSes (like Windows) in the GRUB menu on next boot."
