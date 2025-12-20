echo "=== Plymouth files in all initramfs ==="
for img in /boot/initramfs-*.img; do
    echo "--- $img ---"
    if command -v lsinitcpio &>/dev/null; then
        lsinitcpio "$img" | grep plymouth || echo "Plymouth not in $img"
    else
        echo "lsinitcpio not installed"
    fi
done
