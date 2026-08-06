#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status or unbound variable
set -euo pipefail

# Visual formatting configurations
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CLEAR='\033[0m'

NEEDS_REBUILD=false

echo -e "${YELLOW}==================================================================${CLEAR}"
echo -e "${GREEN}      NVIDIA Wayland Driver & Environment Configuration          ${CLEAR}"
echo -e "${YELLOW}==================================================================${CLEAR}"

# ------------------------------------------------------------------------------
# 0. Ensure [multilib] Repository is Enabled
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[0/5] Checking [multilib] repository status...${CLEAR}"

if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "Enabling [multilib] repository in /etc/pacman.conf..."
    # Uncomment the [multilib] section header and its Include line
    sudo sed -i '/^#\[multilib\]/{N;s/#\[multilib\]\n#Include = \/etc\/pacman.d\/mirrorlist/\[multilib\]\nInclude = \/etc\/pacman.d\/mirrorlist/}' /etc/pacman.conf
    
    # Fallback in case spacing/formatting prevented regex match
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf > /dev/null
    fi
    
    echo "Synchronizing package databases..."
    sudo pacman -Sy
else
    echo -e "${GREEN}✓ [multilib] repository is active.${CLEAR}"
fi

# ------------------------------------------------------------------------------
# 1. Resolve Driver Branch & Install Packages
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[1/5] Checking and installing NVIDIA package set...${CLEAR}"

# Automatically determine the correct kernel headers package based on running kernel
KERNEL_RELEASE="$(uname -r)"
if [[ "$KERNEL_RELEASE" == *-lts ]]; then
    HEADERS_PKG="linux-lts-headers"
elif [[ "$KERNEL_RELEASE" == *-zen ]]; then
    HEADERS_PKG="linux-zen-headers"
elif [[ "$KERNEL_RELEASE" == *-hardened ]]; then
    HEADERS_PKG="linux-hardened-headers"
else
    HEADERS_PKG="linux-headers"
fi

# Check if 580xx branch from Chaotic-AUR is present to prevent package conflicts
if pacman -Qs nvidia-580xx-dkms &>/dev/null; then
    echo "Detected Chaotic-AUR nvidia-580xx driver branch. Using 580xx packages..."
    PKGS=(
        "$HEADERS_PKG"
        nvidia-580xx-dkms
        nvidia-580xx-utils
        nvidia-580xx-settings
        egl-wayland
        lib32-nvidia-580xx-utils
    )
else
    echo "Using standard Arch repository NVIDIA packages..."
    PKGS=(
        "$HEADERS_PKG"
        nvidia-dkms
        nvidia-utils
        nvidia-settings
        egl-wayland
        lib32-nvidia-utils
    )
fi

# --needed ensures pacman safely skips already installed packages
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

# ------------------------------------------------------------------------------
# 2. Configure DRM Modesetting & Framebuffer
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[2/5] Configuring kernel hardware graphics parameters...${CLEAR}"
sudo mkdir -p /etc/modprobe.d
MODPROBE_FILE="/etc/modprobe.d/nvidia.conf"

REQUIRED_PARAMS=(
    "options nvidia_drm modeset=1"
    "options nvidia_drm fbdev=1"
    "options nvidia NVreg_PreserveVideoMemoryAllocations=1"
)

for param in "${REQUIRED_PARAMS[@]}"; do
    if [ ! -f "$MODPROBE_FILE" ] || ! grep -qF "$param" "$MODPROBE_FILE"; then
        echo "$param" | sudo tee -a "$MODPROBE_FILE" > /dev/null
        NEEDS_REBUILD=true
    fi
done
echo -e "${GREEN}✓ Kernel graphics modesetting parameters configured.${CLEAR}"

# ------------------------------------------------------------------------------
# 3. Inject Early KMS Modules into mkinitcpio
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[3/5] Verifying initramfs module injection...${CLEAR}"
MKINIT_FILE="/etc/mkinitcpio.conf"

if [ -f "$MKINIT_FILE" ]; then
    if ! grep -q "nvidia_drm" "$MKINIT_FILE"; then
        echo "Injecting early KMS modules into $MKINIT_FILE..."
        
        # Safely insert modules inside MODULES=(...)
        sudo sed -i -E 's/MODULES=\((.*)\)/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm \1)/' "$MKINIT_FILE"
        sudo sed -i -E 's/MODULES=\(\s+/MODULES=(/' "$MKINIT_FILE"
        
        NEEDS_REBUILD=true
    else
        echo -e "${GREEN}✓ Early-boot kernel modules are already injected.${CLEAR}"
    fi
fi

# ------------------------------------------------------------------------------
# 4. System-Wide Environment Variables for Wayland
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[4/5] Setting system-wide Wayland environment variables...${CLEAR}"
ENV_FILE="/etc/environment"

declare -A WAYLAND_ENV_VARS=(
    ["LIBVA_DRIVER_NAME"]="nvidia"
    ["XDG_SESSION_TYPE"]="wayland"
    ["GBM_BACKEND"]="nvidia-drm"
    ["__GLX_VENDOR_LIBRARY_NAME"]="nvidia"
    ["NVD_BACKEND"]="direct"
    ["ELECTRON_OZONE_PLATFORM_HINT"]="auto"
)

for key in "${!WAYLAND_ENV_VARS[@]}"; do
    value="${WAYLAND_ENV_VARS[$key]}"
    entry="${key}=${value}"
    
    if grep -q "^${key}=" "$ENV_FILE" 2>/dev/null; then
        sudo sed -i "s|^${key}=.*|${entry}|" "$ENV_FILE"
    else
        echo "$entry" | sudo tee -a "$ENV_FILE" > /dev/null
    fi
done
echo -e "${GREEN}✓ Wayland environment variables applied to /etc/environment.${CLEAR}"

# ------------------------------------------------------------------------------
# 5. Enable Power Management Services & Rebuild Initramfs
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[5/5] Enabling NVIDIA systemd power management services...${CLEAR}"
sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service

if [ "$NEEDS_REBUILD" = true ]; then
    echo -e "\n${YELLOW}Regenerating initramfs boot images...${CLEAR}"
    sudo mkinitcpio -P
else
    echo -e "${GREEN}✓ Ramdisk configurations match specifications. Rebuild skipped.${CLEAR}"
fi

echo -e "\n${GREEN}==================================================================${CLEAR}"
echo -e "${GREEN}  NVIDIA Wayland setup complete! Please reboot to apply changes.   ${CLEAR}"
echo -e "${GREEN}==================================================================${CLEAR}"
