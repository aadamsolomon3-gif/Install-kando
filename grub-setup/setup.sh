#!/usr/bin/env bash
set -e

echo "=== Automatic GRUB Installer Script ==="

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

# Detect EFI partition automatically (UEFI only)
efi_mount=""
if [ "$sys_type" = "UEFI" ]; then
    # Find first mounted FAT32 partition (vfat) as EFI
    efi_mount=$(lsblk -o MOUNTPOINT,FSTYPE | grep -i vfat | awk '{print $1}' | head -n1)

    # Fallback if none found
    if [ -z "$efi_mount" ]; then
        echo "No EFI partition found. Exiting."
        exit 1
    fi
    echo "Detected EFI mount point: $efi_mount"
fi

# Detect target disk (for BIOS) automatically: root disk
target_disk=""
if [ "$sys_type" = "BIOS" ]; then
    # Get disk of the root partition
    target_disk=$(df / | tail -1 | awk '{print $1}' | sed 's/[0-9]*$//')
    echo "Detected target disk for GRUB (BIOS): $target_disk"
fi

# Install GRUB
if [ "$sys_type" = "UEFI" ]; then
    sudo grub-install --target=x86_64-efi --efi-directory="$efi_mount" --bootloader-id=GRUB
else
    sudo grub-install --target=i386-pc "$target_disk"
fi

# Generate GRUB configuration
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "GRUB installation completed successfully."
