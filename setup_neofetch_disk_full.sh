#!/bin/bash

echo "[*] Checking Neofetch..."

# Try to find neofetch binary
NEOFETCH_BIN="$(command -v neofetch)"

if [ -z "$NEOFETCH_BIN" ]; then
    echo "[+] Neofetch not found, installing..."

    if [ "$EUID" -ne 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y neofetch
        else
            echo "[!] Please run this script as root or install sudo."
            exit 1
        fi
    else
        apt update && apt install -y neofetch
    fi

    # Re-detect after install
    NEOFETCH_BIN="$(command -v neofetch)"

    if [ -z "$NEOFETCH_BIN" ]; then
        echo "[!] Failed to locate neofetch after installation."
        exit 1
    fi

    echo "[✓] Installed Neofetch at: $NEOFETCH_BIN"
else
    echo "[✓] Neofetch found at: $NEOFETCH_BIN"
fi

# Define config path (based on current user)
CONFIG_FILE="$HOME/.config/neofetch/config.conf"

# Ensure config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[+] Generating default Neofetch config..."
    mkdir -p "$HOME/.config/neofetch"
    "$NEOFETCH_BIN" --config none --generate "$CONFIG_FILE"
fi

# Modify config safely
if grep -q '^[#]*\s*info "Disk" disk' "$CONFIG_FILE"; then
    if grep -q '^#.*info "Disk" disk' "$CONFIG_FILE"; then
        echo "[*] Found commented 'info \"Disk\" disk'. Uncommenting..."
        sed -i 's/^#\s*info "Disk" disk/info "Disk" disk/' "$CONFIG_FILE"
        echo "[✓] Uncommented line successfully."
    else
        echo "[✓] 'info \"Disk\" disk' line already active."
    fi
else
    echo "[*] Adding 'info \"Disk\" disk' after 'info \"Memory\" memory'..."
    sed -i '/info "Memory" memory/a info "Disk" disk' "$CONFIG_FILE"
    echo "[✓] Line added successfully."
fi

echo "[✓] All done! Run '$NEOFETCH_BIN' to see the changes."
