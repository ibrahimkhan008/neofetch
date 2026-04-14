
---

# 🧠 Neofetch Disk Display

> 🚀 Make your Neofetch complete — automatically install it (if missing) and enable disk usage display in your terminal system info.

---

## 📦 Overview

**Neofetch Disk Display** is a lightweight bash script that:
- Installs **Neofetch** automatically if not found  
- Edits your Neofetch config file (`~/.config/neofetch/config.conf`)  
- Adds or uncomments the line `info "Disk" disk`  
- Safely modifies config without overwriting anything  
- Works across **Ubuntu**, **Debian**, **Kali**, and **Termux**

Perfect for anyone who wants Neofetch to show system storage information (total, used, and percentage).

---

# 💡 What this actually does (important)

* Reads `/etc/passwd` → finds **real human users only**
* Skips system accounts (like daemon, www-data, etc.)
* Applies config safely per user
* Fixes permissions (very important 🔐)
* Updates `/etc/skel` → so **new users automatically get config**
* Optionally adds neofetch to `.bashrc` (auto-run on login)

---

# ⚠️ Pro tips

* Run this as root for full effect:

```bash
sudo bash script.sh
```

* If you *don’t* want auto-run on login, remove this part:

```bash
echo "$NEOFETCH_BIN" >> "$BASHRC"
```
---

## ⚙️ Features

✅ Auto-install Neofetch if missing  
✅ Detect and fix commented-out `info "Disk" disk` line  
✅ Add disk display safely below memory info  
✅ Works in both desktop and mobile (Termux) environments  
✅ No overwrite — modifies existing config only  

---

## 🧰 Script: `setup_neofetch_disk_full.sh`

```bash
#!/bin/bash
# Neofetch Disk Enable Script
# Author: @ibrahimkhan008
# Description: Automatically installs Neofetch (if missing) and enables disk info display in config.

CONFIG_FILE="$HOME/.config/neofetch/config.conf"

# Function to install Neofetch if missing
install_neofetch() {
    echo "[*] Checking Neofetch..."
    if ! command -v neofetch &> /dev/null; then
        echo "[+] Neofetch not found, installing..."
        if command -v apt &> /dev/null; then
            sudo apt update -y && sudo apt install neofetch -y
        elif command -v pkg &> /dev/null; then
            pkg update -y && pkg install neofetch -y
        else
            echo "[!] Package manager not found. Please install Neofetch manually."
            exit 1
        fi
    else
        echo "[✓] Neofetch is already installed."
    fi
}

# Function to ensure config file exists
ensure_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "[*] Config not found. Generating new config..."
        mkdir -p "$(dirname "$CONFIG_FILE")"
        neofetch --generate > /dev/null 2>&1
    else
        echo "[✓] Config file found at $CONFIG_FILE"
    fi
}

# Function to edit config and enable disk info
enable_disk_info() {
    if grep -q 'info "Disk" disk' "$CONFIG_FILE"; then
        if grep -q '^#.*info "Disk" disk' "$CONFIG_FILE"; then
            sed -i 's/^#.*info "Disk" disk/info "Disk" disk/' "$CONFIG_FILE"
            echo "[✓] Uncommented existing 'info \"Disk\" disk' line."
        else
            echo "[✓] 'info \"Disk\" disk' line already exists and is active."
        fi
    else
        if grep -q 'info "Memory" memory' "$CONFIG_FILE"; then
            sed -i '/info "Memory" memory/a info "Disk" disk' "$CONFIG_FILE"
            echo "[+] Added 'info \"Disk\" disk' below memory info."
        else
            echo "info \"Disk\" disk" >> "$CONFIG_FILE"
            echo "[+] Added 'info \"Disk\" disk' at end of config."
        fi
    fi
}

# Main execution flow
install_neofetch
ensure_config
enable_disk_info

echo "[✅] Setup complete! Run 'neofetch' to see disk info."

```
---

# 🧩 Installation

## One-line install command

```bash <(curl -sSL https://raw.githubusercontent.com/ibrahimkhan008/neofetch-disk-display/main/script.sh)```

## Clone the repo:

```bash
git clone https://github.com/ibrahimkhan008/neofetch-disk-display.git
```


## Make the script executable:

```chmod +x setup_neofetch_disk_full.sh```

## Run the setup:

```./setup_neofetch_disk_full.sh```

## If you get permission errors, try:

```sudo ./setup_neofetch_disk_full.sh```
# or
```su -c './setup_neofetch_disk_full.sh'```


---

# 🧠 Example Output

## Once setup is complete, run:

```neofetch```

## You’ll now see disk usage included:

Memory: 295MiB / 23470MiB \
Disk: 16G / 2000G (1%)


---

🧩 How It Works

1. Checks for Neofetch
Installs automatically if missing.


2. Verifies Config
Ensures ~/.config/neofetch/config.conf exists (creates if not).


3. Edits the Config
Adds or uncomments the info "Disk" disk line right below the memory info.


4. Done!
Just run neofetch and see your disk usage displayed.




---

🧰 Compatibility

Environment	Supported

Ubuntu / Debian	✅
Termux (Android)	✅
Kali Linux	✅
Arch / Manjaro	⚠️ Manual package install
macOS	❌ Not supported (different paths)



---

⚠️ Troubleshooting

Permission denied during install
→ Run with sudo or su.

Config file not found
→ Script will auto-generate it, or run neofetch --generate.

Disk still not showing?
→ Run:

neofetch --config ~/.config/neofetch/config.conf


---

🧑‍💻 Author

Developer: @ibrahimkhan008
Version: 1.0.0
License: MIT


---

⚙️ License

This project is licensed under the MIT License — free to use, modify, and share.


---

🪄 GitHub Tags

neofetch, bash, linux, shell, automation, termux, ubuntu, cli, dotfiles, open-source


---

💬 About

> 🧠 Auto-enable Disk info in Neofetch with one command — works on Termux, Ubuntu, and Debian.
Installs Neofetch (if missing), edits config safely, and displays disk storage in your system info.




---
