
#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status or unbound variable
set -euo pipefail

# Visual formatting configurations
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CLEAR='\033[0m'

echo -e "${BLUE}==================================================================${CLEAR}"
echo -e "${GREEN}      Starting Automated Workspace Provisioning Core Script      ${CLEAR}"
echo -e "${BLUE}==================================================================${CLEAR}"

# Configure Git user details
echo -e "\n${YELLOW}[Step] Configuring Git User Details...${CLEAR}"
git config --global user.email "visionarytheo@gmail.com"
git config --global user.name "Theo"

# Enable Magic SysRq key
echo -e "\n${YELLOW}[Step] Configuring SysRq Kernel Parameters...${CLEAR}"
echo "kernel.sysrq = 1" | sudo tee /etc/sysctl.d/99-sysrq.conf > /dev/null
sudo sysctl --system > /dev/null
echo -e "${GREEN}✓ SysRq enabled.${CLEAR}"

# ------------------------------------------------------------------------------
# 0. Execute Chaotic-AUR Setup
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 1/8] Installing Chaotic-AUR via chaotic.sh...${CLEAR}"

if [ -f "./chaotic.sh" ]; then
    chmod +x chaotic.sh
    ./chaotic.sh
else
    echo -e "${RED}❌ Critical Error: chaotic.sh not found. Cannot proceed safely without repository targets.${CLEAR}"
    exit 1
fi

# ------------------------------------------------------------------------------
# 1. Update Core System
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 2/8] Updating system database packages...${CLEAR}"
sudo pacman -Syu --noconfirm

# ------------------------------------------------------------------------------
# 2. Deploy NVIDIA Drivers via Standalone Script
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 3/8] Running NVIDIA driver installation script...${CLEAR}"

if [ -f "./nvidia-arch.sh" ]; then
    chmod +x nvidia-arch.sh
    ./nvidia-arch.sh
else
    echo -e "${RED}❌ Critical Error: nvidia-arch.sh not found.${CLEAR}"
    exit 1
fi

# ------------------------------------------------------------------------------
# 3. Install GNU Stow & Zsh
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 4/8] Installing GNU Stow and Zsh...${CLEAR}"
sudo pacman -S --needed --noconfirm stow zsh curl

# ------------------------------------------------------------------------------
# 4. Deploy Shell Frameworks (Pre-empting Stow Conflicts)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 5/8] Deploying runtime shell framework tools...${CLEAR}"

# Install Oh My Zsh framework first so it does not overwrite Stow definitions later
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh framework..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already configured in home, skipping."
fi

# Aggressively delete any default stock .zshrc files to prevent symlink overlap conflicts
rm -f "$HOME/.zshrc"

# Deploy custom configurations securely via Stow wrapper
echo -e "\n${YELLOW}Cleaning and linking configuration packages via setup.sh...${CLEAR}"
if [ -f "./setup.sh" ]; then
    chmod +x setup.sh
    ./setup.sh
else
    echo -e "${RED}❌ Critical Error: setup.sh not found. Cannot proceed safely without config layout.${CLEAR}"
    exit 1
fi

# ------------------------------------------------------------------------------
# 5. Install Core Native Arch Packages
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 6/8] Installing remaining native Arch packages...${CLEAR}"

PACKAGES=(
    zip
    unzip
    fzf
    zoxide
    eza
    bat
    neovim
    ghostty
    fastfetch
    tmux
    docker
    go
    github-cli
    tree-sitter-cli
    ttf-jetbrains-mono-nerd
    wl-clipboard
    bitwarden

    # Hyprland & Desktop Core
    hyprland
    waybar
    rofi-wayland
    xdg-desktop-portal-hyprland
    qt5-wayland
    qt6-wayland
    nwg-look

    # Script Dependencies & Utilities
    imagemagick
    libnotify
    dunst
    pavucontrol
    grim
    slurp
)

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

# Handle AUR packages separately if an AUR helper exists, or prompt installation
AUR_PACKAGES=(
    google-chrome
    tableplus
    ventoy-bin
    awww
)

if command -v yay &> /dev/null; then
    echo -e "\n${YELLOW}Installing AUR packages via yay...${CLEAR}"
    yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
elif command -v paru &> /dev/null; then
    echo -e "\n${YELLOW}Installing AUR packages via paru...${CLEAR}"
    paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"
else
    echo -e "\n${YELLOW}Notice: No AUR helper (yay/paru) found. Skipping AUR packages: ${AUR_PACKAGES[*]}${CLEAR}"
fi

# ------------------------------------------------------------------------------
# 6. Provision Third-Party Scripts & Daemons
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 7/8] Deploying toolchain environments & daemons...${CLEAR}"

# Install Oh My Zsh External Plugins if missing
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Cloning zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Cloning zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi

# Install Node Version Manager (NVM) if missing from home directory
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing Node Version Manager (NVM)..."
    mkdir -p "$HOME/.nvm"
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
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
else
    echo "Starship already installed, skipping."
fi

# Enable Docker daemon sockets natively
if command -v docker &> /dev/null; then
    sudo systemctl enable --now docker.socket
    if ! groups "$USER" | grep -q "\bdocker\b"; then
        sudo usermod -aG docker "$USER"
        echo -e "${YELLOW}Notice: Added user to 'docker' group. Log out and back in to apply.${CLEAR}"
    fi
fi

# ------------------------------------------------------------------------------
# 7. Deploy Steam via Standalone Script
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 8/8] Running STEAM installation script...${CLEAR}"

if [ -f "./steam.sh" ]; then
    chmod +x steam.sh
    ./steam.sh
else
    echo -e "${RED}❌ Critical Error: steam.sh not found.${CLEAR}"
    exit 1
fi

# ------------------------------------------------------------------------------
# 8. Set Default System Shell to Zsh
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}Verifying user default login shell...${CLEAR}"
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to Zsh..."
    sudo chsh -s "$(which zsh)" "$USER"
else
    echo "Zsh is already your default system shell."
fi

echo -e "\n${GREEN}==================================================================${CLEAR}"
echo -e "${GREEN}  Provisioning complete! Your single ~/.zshrc file handles the rest! ${CLEAR}"
echo -e "${GREEN}  Run: source ~/.zshrc                                           ${CLEAR}"
echo -e "${GREEN}==================================================================${CLEAR}"
