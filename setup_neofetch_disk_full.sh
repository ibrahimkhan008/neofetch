#!/bin/bash

echo "[*] Checking Neofetch..."

# Detect neofetch binary
NEOFETCH_BIN="$(command -v neofetch)"

if [ -z "$NEOFETCH_BIN" ]; then
    echo "[+] Neofetch not found, installing..."

    if [ "$EUID" -ne 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y neofetch
        else
            echo "[!] Please run as root or install sudo."
            exit 1
        fi
    else
        apt update && apt install -y neofetch
    fi

    NEOFETCH_BIN="$(command -v neofetch)"

    if [ -z "$NEOFETCH_BIN" ]; then
        echo "[!] Failed to locate neofetch after install."
        exit 1
    fi
fi

echo "[✓] Using Neofetch at: $NEOFETCH_BIN"

# Function to apply config to a user
apply_config() {
    USER_HOME="$1"
    USER_NAME="$2"

    CONFIG_DIR="$USER_HOME/.config/neofetch"
    CONFIG_FILE="$CONFIG_DIR/config.conf"

    echo "[*] Processing user: $USER_NAME"

    mkdir -p "$CONFIG_DIR"

    if [ ! -f "$CONFIG_FILE" ]; then
        "$NEOFETCH_BIN" --config none --generate "$CONFIG_FILE"
    fi

    if grep -q '^[#]*\s*info "Disk" disk' "$CONFIG_FILE"; then
        if grep -q '^#.*info "Disk" disk' "$CONFIG_FILE"; then
            sed -i 's/^#\s*info "Disk" disk/info "Disk" disk/' "$CONFIG_FILE"
        fi
    else
        sed -i '/info "Memory" memory/a info "Disk" disk' "$CONFIG_FILE"
    fi

    chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.config"
    echo "[✓] Done for $USER_NAME"
}

echo "[*] Applying config to all users..."

# Loop through real users (UID >= 1000)
awk -F: '$3 >= 1000 && $6 ~ /^\/home/ {print $1 ":" $6}' /etc/passwd | while IFS=: read user home; do
    apply_config "$home" "$user"
done

# Also apply to root
apply_config "/root" "root"

# 🔥 Future users fix (auto apply)
SKEL_CONFIG="/etc/skel/.config/neofetch"
mkdir -p "$SKEL_CONFIG"

if [ ! -f "$SKEL_CONFIG/config.conf" ]; then
    "$NEOFETCH_BIN" --config none --generate "$SKEL_CONFIG/config.conf"
fi

# Ensure disk line exists in skeleton
if grep -q '^[#]*\s*info "Disk" disk' "$SKEL_CONFIG/config.conf"; then
    sed -i 's/^#\s*info "Disk" disk/info "Disk" disk/' "$SKEL_CONFIG/config.conf"
else
    sed -i '/info "Memory" memory/a info "Disk" disk' "$SKEL_CONFIG/config.conf"
fi

echo "[✓] Future users will also have this config."

# 🔥 Optional: auto-run neofetch on login
for BASHRC in /etc/skel/.bashrc /root/.bashrc; do
    if ! grep -q "neofetch" "$BASHRC"; then
        echo "$NEOFETCH_BIN" >> "$BASHRC"
    fi
done

echo "[🚀] Fully done! Neofetch configured for ALL users."
