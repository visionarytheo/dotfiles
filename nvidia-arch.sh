#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Visual formatting configurations
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CLEAR='\033[0m'

# ------------------------------------------------------------------------------
# 1. Core Package Installation (Skipped automatically by pacman if present)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}Checking proprietary NVIDIA toolchains...${CLEAR}"
sudo pacman -S --needed --noconfirm linux-headers nvidia nvidia-utils

# ------------------------------------------------------------------------------
# 2. Force Direct Rendering Manager Modesetting Variables
# ------------------------------------------------------------------------------
sudo mkdir -p /etc/modprobe.d
if [ ! -f /etc/modprobe.d/nvidia.conf ] || ! grep -q "options nvidia_drm modeset=1" /etc/modprobe.d/nvidia.conf; then
    echo "Configuring kernel hardware graphics parameters..."
    sudo sh -c 'echo "options nvidia_drm modeset=1" > /etc/modprobe.d/nvidia.conf'
    NEEDS_REBUILD=true
else
    echo -e "${GREEN}✓ Kernel graphics modesetting parameters are already set.${CLEAR}"
fi

# ------------------------------------------------------------------------------
# 3. Inject Modules Aggressively into System Ramdisk Configuration
# ------------------------------------------------------------------------------
if [ -f /etc/mkinitcpio.conf ]; then
    if ! grep -q "nvidia nvidia_modeset" /etc/mkinitcpio.conf; then
        echo "Injecting modules into /etc/mkinitcpio.conf..."
        sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
        NEEDS_REBUILD=true
    else
        echo -e "${GREEN}✓ Early-boot kernel modules are already injected.${CLEAR}"
    fi
fi

# ------------------------------------------------------------------------------
# 4. Conditional Initramfs Rebuild
# ------------------------------------------------------------------------------
if [ "$NEEDS_REBUILD" = true ]; then
    echo "Regenerating primary kernel boot images..."
    sudo mkinitcpio -P
else
    echo -e "${GREEN}✓ Ramdisk configurations match specifications. Rebuild skipped.${CLEAR}"
fi
