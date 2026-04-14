#!/bin/bash
set -e

echo "[*] Checking Neofetch..."

NEOFETCH_BIN="$(command -v neofetch 2>/dev/null || true)"

# Install if missing
if [ -z "$NEOFETCH_BIN" ]; then
    echo "[+] Installing neofetch..."
    apt update && apt install -y neofetch
    NEOFETCH_BIN="$(command -v neofetch)"
fi

echo "[✓] Using Neofetch at: $NEOFETCH_BIN"

apply_config() {
    USER_HOME="$1"
    USER_NAME="$2"

    CONFIG_FILE="$USER_HOME/.config/neofetch/config.conf"

    echo "[*] Processing $USER_NAME"

    # ✅ If config doesn't exist → create it naturally
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "[*] No config → running neofetch once for $USER_NAME"
        sudo -u "$USER_NAME" "$NEOFETCH_BIN" >/dev/null 2>&1 || true
    fi

    # Still no config → skip
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "[!] Failed to get config for $USER_NAME"
        return
    fi

    # ✅ Fix permissions (important)
    chown "$USER_NAME:$USER_NAME" "$CONFIG_FILE"

    # ✅ Uncomment Disk if exists
    if grep -q '# info "Disk" disk' "$CONFIG_FILE"; then
        sed -i 's/# info "Disk" disk/info "Disk" disk/' "$CONFIG_FILE"
        echo "[✓] Enabled Disk for $USER_NAME"
        return
    fi

    # ✅ If missing → insert after Memory
    if ! grep -q 'info "Disk" disk' "$CONFIG_FILE"; then
        sed -i '/info "Memory" memory/a\    info "Disk" disk' "$CONFIG_FILE"
        echo "[✓] Added Disk for $USER_NAME"
        return
    fi

    echo "[=] Already configured for $USER_NAME"
}

echo "[*] Applying config..."

# Normal users
awk -F: '$3 >= 1000 && $6 ~ /^\/home/ {print $1 ":" $6}' /etc/passwd | while IFS=: read user home; do
    apply_config "$home" "$user"
done

# Root
apply_config "/root" "root"

echo "[🚀] Done — works in one run, clean logic."
