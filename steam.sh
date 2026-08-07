#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status or unbound variable
set -euo pipefail

# Visual formatting configurations
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CLEAR='\033[0m'

echo -e "${YELLOW}==================================================================${CLEAR}"
echo -e "${GREEN}           Steam & Linux Gaming Provisioning Script              ${CLEAR}"
echo -e "${YELLOW}==================================================================${CLEAR}"

# ------------------------------------------------------------------------------
# 1. Verify [multilib] Repository
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[1/4] Verifying [multilib] status in /etc/pacman.conf...${CLEAR}"

if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "Enabling [multilib] repository..."
    sudo sed -i '/^#\[multilib\]/{N;s/#\[multilib\]\n#Include = \/etc\/pacman.d\/mirrorlist/\[multilib\]\nInclude = \/etc\/pacman.d\/mirrorlist/}' /etc/pacman.conf
    sudo pacman -Sy
else
    echo -e "${GREEN}✓ [multilib] repository is active.${CLEAR}"
fi

# ------------------------------------------------------------------------------
# 2. Install Steam, Vulkan Drivers, and Optimizations
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[2/4] Installing Steam, Vulkan loaders, and Gaming utilities...${CLEAR}"

STEAM_PACKAGES=(
    steam
    vulkan-icd-loader
    lib32-vulkan-icd-loader
    gamemode
    lib32-gamemode
    mangohud
    lib32-mangohud
    protonup-qt
)

sudo pacman -S --needed --noconfirm "${STEAM_PACKAGES[@]}"

# ------------------------------------------------------------------------------
# 3. Add User to GameMode Group
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[3/4] Configuring user permissions for GameMode...${CLEAR}"
if getent group gamemode > /dev/null 2>&1; then
    sudo usermod -aG gamemode "$USER"
    echo -e "${GREEN}✓ Added $USER to 'gamemode' group.${CLEAR}"
fi

# ------------------------------------------------------------------------------
# 4. Enable Steam Play (Proton) Global Defaults
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[4/4] Setting default Steam compatibility directory structure...${CLEAR}"
mkdir -p "$HOME/.steam/root/compatibilitytools.d"

echo -e "\n${GREEN}==================================================================${CLEAR}"
echo -e "${GREEN}  Gaming Setup Complete! Next Steps:                               ${CLEAR}"
echo -e "${GREEN}  1. Launch 'protonup-qt' to download GE-Proton for maximum game compatibility.${CLEAR}"
echo -e "${GREEN}  2. Launch Steam -> Settings -> Compatibility -> Enable Steam Play for all titles.${CLEAR}"
echo -e "${GREEN}  3. Use launch option: gamemoderun %command% in Steam game properties.${CLEAR}"
echo -e "${GREEN}==================================================================${CLEAR}"
