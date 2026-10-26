#!/usr/bin/env bash
#
# Noctaelestia-Shell & Hyprland Minimal Installer Script
# Author: Chris (@Chr15zKH4x)
#

set -e

# --- COLORS & STYLES ---
BOLD='\033[1m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# --- ASCII BANNER ---
clear
echo -e "${PURPLE}${BOLD}"
cat << "EOF"
  _  _         _              _         _   _ 

 | \| |___  __| |_ __ _ ___| |___ ___| |_(_)__ _ 
 | .` / _ \/ _|  _/ _` / -_) / -_|_-<  _| / _` |
 |_|\_\___/\__|\__\__,_\___|_|\___/__/\__|_|\__,_|
                                                  
     N O C T A E L E S T I A   I N S T A L L E R
EOF
echo -e "${RESET}"
echo -e "${CYAN}:: Minimal Hyprland & Noctalia-Shell Setup${RESET}\n"

# --- CHECK ARCH LINUX ---
if [ ! -f /etc/arch-release ]; then
    echo -e "${RED}[!] This installation script is designed exclusively for Arch Linux.${RESET}"
    exit 1
fi

# Initial user confirmation
read -p "Do you want to start the Noctaelestia installation? [Y/n] " choice
case "$choice" in
  y|Y|yes|YES|"")
    echo -e "${GREEN}[+] Starting deployment...${RESET}\n"
    ;;
  *)
    echo -e "${RED}[!] Installation canceled.${RESET}"
    exit 0
    ;;
esac


# Elevate privileges early
sudo -v

# --- STEP 1: BASE DEPENDENCIES & FONTS ---
echo -e "${CYAN}==> [1/8] Installing base dependencies and required fonts...${RESET}"
sudo pacman -Sy --needed --noconfirm \
    git base-devel python wget curl \
    ttf-font-awesome noto-fonts-emoji \
    ttf-nerd-fonts-symbols-common ttf-jetbrains-mono-nerd \
    polkit-kde-agent qt5-wayland qt6-wayland pipewire wireplumber

# --- STEP 2: INSTALL YAY ---
if ! command -v yay &> /dev/null; then
    echo -e "${CYAN}==> [2/8] Installing yay-bin from AUR...${RESET}"
    cd "$HOME"
    rm -rf yay-bin
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd "$HOME"
else
    echo -e "${GREEN}[+] yay is already installed.${RESET}"
fi

# --- STEP 3: HYPRLAND, ALACRITTY, SATTY, HYPRSHOT, MPV, ETC...---
echo -e "${CYAN}==> [3/8] Installing Hyprland, Alacritty, Satty, Hyprshot, and mpv...${RESET}"
sudo pacman -S --needed --noconfirm hyprland alacritty satty hyprshot mpv thunar gvfs nano cpupower

# --- STEP 4: NOCTALIA & GREETD ---
echo -e "${CYAN}==> [4/8] Installing Noctalia-Shell and greetd display manager...${RESET}"
sudo pacman -S --needed --noconfirm noctalia greetd

echo -e "${CYAN}==> Installing Noctalia Greeter via yay...${RESET}"
yay -S --needed --noconfirm noctalia-greeter || yay -S --needed --noconfirm noctalia-greeter

# --- STEP 5: CONFIGURE GREETD VIA PYTHON ---
echo -e "${CYAN}==> [5/8] Writing /etc/greetd/config.toml...${RESET}"

sudo python3 -c '
import os

config_content = """[terminal]
vt = 1

[default_session]
command = "/usr/bin/noctalia-greeter-session"
user = "greeter"
"""

os.makedirs("/etc/greetd", exist_ok=True)
with open("/etc/greetd/config.toml", "w") as f:
    f.write(config_content)
print("[+] Updated /etc/greetd/config.toml successfully.")
'

sudo systemctl enable greetd.service

# --- STEP 6: CLI TOOLS & MEDIA ---
echo -e "${CYAN}==> [6/8] Installing CLI utilities & MPD ecosystem...${RESET}"
yay -S --needed --noconfirm yazi cmatrix-git ytfzf fzf cava cbonsai tty-clock fastfetch youtui-player mpd-mpris mpd mpc

# --- STEP 7: MPD CONFIG & MPRIS USER SERVICE ---
echo -e "${CYAN}==> [7/8] Configuring MPD and setting up mpd-mpris user service...${RESET}"

# Création des dossiers et fichiers nécessaires avec $HOME
mkdir -p "$HOME/.config/mpd/playlists"
touch "$HOME/.config/mpd/mpd.pid"
touch "$HOME/.config/mpd/mpd.db"
touch "$HOME/.config/mpd/mpdstate"

# Écriture de mpd.conf exactement selon la capture d'écran
cat << 'EOF' > "$HOME/.config/mpd/mpd.conf"
pid_file "$HOME/.config/mpd/mpd.pid"
db_file "$HOME/.config/mpd/mpd.db"
state_file "$HOME/.config/mpd/mpdstate"
playlist_directory "$HOME/.config/mpd/playlists"

audio_output {
    type "pipewire"
    name "Pipewire Sound Server"
}
EOF
echo -e "${GREEN}[+] mpd.conf written and directories/files created.${RESET}"

# Configuration du service utilisateur mpd-mpris avec host et port explicites
python3 -c '
import os

home = os.path.expanduser("~")
systemd_user_dir = os.path.join(home, ".config", "systemd", "user")
os.makedirs(systemd_user_dir, exist_ok=True)

service_content = """[Unit]
Description=MPD-to-MPRIS bridge
After=mpd.service
Requires=mpd.service

[Service]
ExecStart=/usr/bin/mpd-mpris -host 127.0.0.1 -port 6600
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
"""

with open(os.path.join(systemd_user_dir, "mpd-mpris.service"), "w") as f:
    f.write(service_content)
print("[+] Created mpd-mpris.service user file with custom host and port.")
'

# Activation des services utilisateurs
systemctl --user daemon-reload
systemctl --user enable --now mpd.service || true
systemctl --user enable --now mpd-mpris.service || true

# --- STEP 8: SYSTEM TWEAKS (SUDOERS NOPASSWD & CPUPOWER) ---
echo -e "${CYAN}==> [8/8] Applying system tweaks (NOPASSWD & cpupower performance)...${RESET}"
sudo python3 -c '
import os, getpass, re

current_user = getpass.getuser()
sudoers_file = f"/etc/sudoers.d/{current_user}"

# Configure NOPASSWD
with open(sudoers_file, "w") as f:
    f.write(f"{current_user} ALL=(ALL) NOPASSWD: ALL\\n")
os.chmod(sudoers_file, 0o440)
print(f"[+] Sudoers configured with NOPASSWD for {current_user}.")

# Configure cpupower governor & perf_bias
cpupower_path = "/etc/default/cpupower"
if os.path.exists(cpupower_path):
    with open(cpupower_path, "r") as f:
        content = f.read()
    
    content = re.sub(r"#?\\s*PERF_BIAS=.*", "PERF_BIAS=\x27performance\x27", content)
    content = re.sub(r"#?\\s*GOVERNOR=.*", "GOVERNOR=\x27performance\x27", content)
    
    with open(cpupower_path, "w") as f:
        f.write(content)
    print("[+] Updated /etc/default/cpupower to performance mode.")
else:
    print("[!] /etc/default/cpupower not found, skipping cpupower tweak.")
'

sudo systemctl enable --now cpupower.service || true

# --- STEP 9: CLONE NOCTAELESTIA & DEPLOY CONFIGURATIONS ---
echo -e "${CYAN}==> Finalizing: Cloning Noctaelestia and deploying configurations...${RESET}"

if [ -d "$HOME/Noctaelestia/.git" ]; then
    echo -e "${YELLOW}[!] Repository $HOME/Noctaelestia already exists. Pulling latest changes...${RESET}"
    git -C "$HOME/Noctaelestia" pull
else
    git clone https://github.com/Chr15zKH4x/Noctaelestia.git "$HOME/Noctaelestia"
fi

mkdir -p "$HOME/.config"

if [ -d "$HOME/Noctaelestia/hypr" ]; then
    rm -rf "$HOME/.config/hypr"
    mv "$HOME/Noctaelestia/hypr" "$HOME/.config/"
    echo -e "${GREEN}[+] Successfully moved $HOME/Noctaelestia/hypr to $HOME/.config/hypr!${RESET}"
else
    echo -e "${YELLOW}[!] Warning: $HOME/Noctaelestia/hypr directory not found.${RESET}"
fi

if [ -d "$HOME/Noctaelestia/mpv" ]; then
    rm -rf "$HOME/.config/mpv"
    mv "$HOME/Noctaelestia/mpv" "$HOME/.config/"
    echo -e "${GREEN}[+] Successfully copied $HOME/Noctaelestia/mpv to $HOME/.config/mpv!${RESET}"
else
    echo -e "${YELLOW}[!] Warning: $HOME/Noctaelestia/mpv directory not found in the repository.${RESET}"
fi

mkdir -p "$HOME/.local/state/noctalia"
cp -r "$HOME/Noctaelestia/"* "$HOME/.local/state/noctalia/"
echo -e "${GREEN}[+] Successfully copied $HOME/Noctaelestia/* to $HOME/.local/state/noctalia/${RESET}"

# --- CLEANUP (OPTIONAL) ---
echo -e "\n${YELLOW}--------------------------------------------------${RESET}"
read -p "Do you want to clean up $HOME/yay-bin and pacman/yay cache? [Y/n] " clean_choice

case "$clean_choice" in 
  [yY][eE][sS]|[yY]|"") 
    echo -e "${CYAN}==> Cleaning up temporary files...${RESET}"
    rm -rf "$HOME/yay-bin"
    yay -Scc --noconfirm
    echo -e "${GREEN}[+] Cleanup completed.${RESET}"
    ;;
  *)
    echo -e "${YELLOW}[!] Temporary files kept in $HOME${RESET}"
    ;;
esac

echo -e "\n${PURPLE}${BOLD}====================================================${RESET}"
echo -e "${GREEN}${BOLD}   HYPRLAND & NOCTAELESTIA INSTALLED SUCCESSFULLY!   ${RESET}"
echo -e "${PURPLE}${BOLD}====================================================${RESET}\n"
