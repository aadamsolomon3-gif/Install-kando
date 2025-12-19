#!/usr/bin/env bash
set -e

echo "==============================="
echo " Master Installer Launcher "
echo "==============================="

# List your install scripts here in order
install_scripts=(
    "ai-setup/setup.sh"
    "kando-setup.setup.sh"
    "app-setup/setup.sh"
    "keybind-setup/setup.sh"
    "kitty-setup/setup.sh"
)

# Run each script
for script in "${install_scripts[@]}"; do
    if [[ -f "$script" ]]; then
        echo "==============================="
        echo " Running $script..."
        bash "$script"
        echo "Finished $script"
    else
        echo "Warning: $script not found, skipping..."
    fi
done

echo "All selected installations complete!"
