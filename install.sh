#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Visual formatting configurations
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CLEAR='\033[0m'

echo -e "${BLUE}==================================================================${CLEAR}"
echo -e "${GREEN}      Starting Automated Workspace Provisioning Core Script       ${CLEAR}"
echo -e "${BLUE}==================================================================${CLEAR}"

# ------------------------------------------------------------------------------
# 1. Update Core System
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 1/4] Updating system database packages...${CLEAR}"
sudo pacman -Syu --noconfirm

# ------------------------------------------------------------------------------
# 2. Install Native Repository Packages via Pacman
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 2/4] Installing core native Arch packages...${CLEAR}"

PACKAGES=(
    zip
    unzip
    fzf
    zoxide
    eza
    neovim
    ghostty
    fastfetch
    tmux
    docker
    go
    gh
    stow
)

sudo pacman -S --noconfirm "${PACKAGES[@]}"

# ------------------------------------------------------------------------------
# 3. Provision Third-Party Scripts (Checking local home folders directly)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 3/4] Deploying toolchain environments...${CLEAR}"

# Install Node Version Manager (NVM) if missing from home directory
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing Node Version Manager (NVM)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh | bash
else
    echo "NVM is already configured in home, skipping."
fi

# Install SDKMAN if missing from home directory
if [ ! -d "$HOME/.sdkman" ]; then
    echo "Installing SDKMAN! manager..."
    export sdkman_auto_answer=true
    curl -s "https://get.sdkman.io" | bash
else
    echo "SDKMAN is already configured in home, skipping."
fi

# Install Starship cross-shell prompt profile engine
if ! command -v starship &> /dev/null; then
    echo "Installing Starship cross-shell prompt..."
    curl -sS https://starship.rs | sh -s -- --yes
else
    echo "Starship already installed, skipping."
fi

# ------------------------------------------------------------------------------
# 4. System Daemon Configuration & Stow Linking
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 4/4] Aligning running background daemons and symlinks...${CLEAR}"

# Enable Docker daemon sockets natively
if command -v docker &> /dev/null; then
    sudo systemctl enable --now docker.service
    if ! groups "$USER" | grep -q "\bdocker\b"; then
        sudo usermod -aG docker "$USER"
        echo -e "${YELLOW}Notice: Added user to 'docker' group. Log out and back in to apply.${CLEAR}"
    fi
fi

# Force Stow to deploy all configurations cleanly to home paths
stow --adopt *

echo -e "\n${GREEN}==================================================================${CLEAR}"
echo -e "${GREEN}  Provisioning complete! Your single ~/.zshrc file handles the rest!${CLEAR}"
echo -e "${GREEN}  Run: source ~/.zshrc                                            ${CLEAR}"
echo -e "${GREEN}==================================================================${CLEAR}"
