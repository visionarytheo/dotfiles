#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Visual formatting configurations
YELLOW='\033[1;33m'
CLEAR='\033[0m'

# ------------------------------------------------------------------------------
# 1. Deploy NVIDIA Drivers & Explicit Early-Boot Modesetting Hook
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 2/8] Provisioning proprietary NVIDIA toolchains...${CLEAR}"

# Install drivers matching mainline kernel architecture
sudo pacman -S --needed --noconfirm linux-headers nvidia nvidia-utils

# Force direct rendering manager modesetting variables
echo "Configuring kernel hardware graphics parameters..."
sudo sh -c 'echo "options nvidia_drm modeset=1" > /etc/modprobe.d/nvidia.conf'

# Inject modules aggressively into system ramdisk configuration
if [ -f /etc/mkinitcpio.conf ]; then
    if ! grep -q "nvidia nvidia_modeset" /etc/mkinitcpio.conf; then
        echo "Injecting modules into /etc/mkinitcpio.conf..."
        sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
    fi
    echo "Regenerating primary kernel boot images..."
    sudo mkinitcpio -P
fi
