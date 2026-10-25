#!/usr/bin/env sh
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
  [yY][eE][sS]|[yY]|"") 
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
echo -e "${CYAN}==> [1/7] Installing base dependencies and required fonts...${RESET}"
sudo pacman -Sy --needed --noconfirm \
    git base-devel python wget curl \
    ttf-font-awesome noto-fonts-emoji \
    ttf-nerd-fonts-symbols-common ttf-jetbrains-mono-nerd \
    polkit-kde-agent qt5-wayland qt6-wayland pipewire wireplumber

# --- STEP 2: INSTALL YAY ---
if ! command -v yay &> /dev/null; then
    echo -e "${CYAN}==> [2/7] Installing yay-bin from AUR...${RESET}"
    cd ~
    rm -rf yay-bin
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd ~
else
    echo -e "${GREEN}[+] yay is already installed.${RESET}"
fi

# --- STEP 3: HYPRLAND, ALACRITTY, SATTY, HYPRSHOT & MPV ---
echo -e "${CYAN}==> [3/7] Installing Hyprland, Alacritty, Satty, Hyprshot, and mpv...${RESET}"
sudo pacman -S --needed --noconfirm hyprland alacritty satty hyprshot mpv

# --- STEP 4: NOCTALIA & GREETD ---
echo -e "${CYAN}==> [4/7] Installing Noctalia-Shell and greetd display manager...${RESET}"
sudo pacman -S --needed --noconfirm noctalia greetd

echo -e "${CYAN}==> Installing Noctalia Greeter via yay...${RESET}"
yay -S --needed --noconfirm noctalia-greeter || yay -S --needed --noconfirm noctalia-greeter

# --- STEP 5: CONFIGURE GREETD VIA PYTHON ---
echo -e "${CYAN}==> [5/7] Writing /etc/greetd/config.toml...${RESET}"

sudo python3 -c '
import os

config_content = """[terminal]
# The VT to run the greeter on. Can be "next", "current" or a number
# designating the VT.
vt = 1

# The default session, also known as the greeter.
[default_session]

# `agreety` is the bundled agetty/login-lookalike. You can replace `/bin/sh`
# with whatever you want started, such as `sway`.
command = "/usr/bin/noctalia-greeter-session"

# The user to run the command as. The privileges this user must have depends
# on the greeter. A graphical greeter may for example require the user to be
# in the `video` group.
user = "greeter"
"""

os.makedirs("/etc/greetd", exist_ok=True)
with open("/etc/greetd/config.toml", "w") as f:
    f.write(config_content)
print("[+] Updated /etc/greetd/config.toml successfully.")
'

sudo systemctl enable greetd.service

# --- STEP 6: CLI TOOLS ---
echo -e "${CYAN}==> [6/7] Installing CLI utilities (yazi, ytfzf, fzf, cava, cbonsai, etc.)...${RESET}"
yay -S --needed --noconfirm yazi cmatrix-git ytfzf fzf cava cbonsai tty-clock fastfetch youtui-player

# --- STEP 7: CLONE NOCTAELESTIA & DEPLOY CONFIGURATIONS ---
echo -e "${CYAN}==> [7/7] Cloning Noctaelestia and deploying configurations...${RESET}"

# Clone the repository to ~/Noctaelestia
if [ -d "$HOME/Noctaelestia/.git" ]; then
    echo -e "${YELLOW}[!] Repository ~/Noctaelestia already exists. Pulling latest changes...${RESET}"
    git -C "$HOME/Noctaelestia" pull
else
    git clone https://github.com/Chr15zKH4x/Noctaelestia.git "$HOME/Noctaelestia"
fi

# Ensure ~/.config exists
mkdir -p ~/.config

# Move ~/Noctaelestia/hypr to ~/.config/hypr
if [ -d "$HOME/Noctaelestia/hypr" ]; then
    rm -rf ~/.config/hypr
    mv "$HOME/Noctaelestia/hypr" ~/.config/
    echo -e "${GREEN}[+] Successfully moved ~/Noctaelestia/hypr to ~/.config/hypr!${RESET}"
else
    echo -e "${YELLOW}[!] Warning: ~/Noctaelestia/hypr directory not found.${RESET}"
fi

# Copy ~/Noctaelestia/mpv to ~/.config/mpv
if [ -d "$HOME/Noctaelestia/mpv" ]; then
    rm -rf ~/.config/mpv
    mv "$HOME/Noctaelestia/mpv" ~/.config/
    echo -e "${GREEN}[+] Successfully copied ~/Noctaelestia/mpv to ~/.config/mpv!${RESET}"
else
    echo -e "${YELLOW}[!] Warning: ~/Noctaelestia/mpv directory not found in the repository.${RESET}"
fi

# Ensure ~/.local/state/noctalia exists and copy remaining repository files into it
mkdir -p ~/.local/state/noctalia
cp -r "$HOME/Noctaelestia/"* ~/.local/state/noctalia/
echo -e "${GREEN}[+] Successfully copied ~/Noctaelestia/* to ~/.local/state/noctalia/${RESET}"

# --- CLEANUP (OPTIONAL) ---
echo -e "\n${YELLOW}--------------------------------------------------${RESET}"
read -p "Do you want to clean up ~/yay-bin and pacman/yay cache? [Y/n] " clean_choice

case "$clean_choice" in 
  [yY][eE][sS]|[yY]|"") 
    echo -e "${CYAN}==> Cleaning up temporary files...${RESET}"
    rm -rf ~/yay-bin
    yay -Scc --noconfirm
    echo -e "${GREEN}[+] Cleanup completed.${RESET}"
    ;;
  *)
    echo -e "${YELLOW}[!] Temporary files kept in ~${RESET}"
    ;;
esac

echo -e "\n${PURPLE}${BOLD}====================================================${RESET}"
echo -e "${GREEN}${BOLD}   HYPRLAND & NOCTAELESTIA INSTALLED SUCCESSFULLY!   ${RESET}"
echo -e "${PURPLE}${BOLD}====================================================${RESET}\n"
