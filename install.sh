#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Visual formatting configurations
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CLEAR='\033[0m'

echo -e "${BLUE}==================================================================${CLEAR}"
echo -e "${GREEN}      Starting Automated Workspace Provisioning Core Script       ${CLEAR}"
echo -e "${BLUE}==================================================================${CLEAR}"

# ------------------------------------------------------------------------------
# 1. Update Core System
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 1/6] Updating system database packages...${CLEAR}"
sudo pacman -Syu --noconfirm

# ------------------------------------------------------------------------------
# 2. Install GNU Stow First
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 2/6] Installing GNU Stow...${CLEAR}"
sudo pacman -S --needed --noconfirm stow

# ------------------------------------------------------------------------------
# 3. Clean Up Existing Shell Configs & Deploy Dotfiles
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 3/6] Cleaning and linking configuration packages via setup.sh...${CLEAR}"

if [ -f "./setup.sh" ]; then
    chmod +x setup.sh
    ./setup.sh
else
    echo -e "${RED}❌ Critical Error: setup.sh not found. Cannot proceed safely without config layout.${CLEAR}"
    exit 1
fi

# ------------------------------------------------------------------------------
# 4. Install the Rest of the Core Native Arch Packages
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 4/6] Installing remaining native Arch packages...${CLEAR}"

PACKAGES=(
    curl
    zsh
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
    zen-browser-bin
)

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

# ------------------------------------------------------------------------------
# 5. Provision Third-Party Scripts & Daemons
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 5/6] Deploying toolchain environments & daemons...${CLEAR}"

# Install Oh My Zsh if missing from home directory
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh framework..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already configured in home, skipping."
fi

# Install Oh My Zsh External Plugins if missing
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Cloning zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Cloning zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

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

# Enable Docker daemon sockets natively
if command -v docker &> /dev/null; then
    sudo systemctl enable --now docker.service
    if ! groups "$USER" | grep -q "\bdocker\b"; then
        sudo usermod -aG docker "$USER"
        echo -e "${YELLOW}Notice: Added user to 'docker' group. Log out and back in to apply.${CLEAR}"
    fi
fi

# ------------------------------------------------------------------------------
# 6. Set Default System Shell to Zsh
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 6/6] Verifying user default login shell...${CLEAR}"
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to Zsh..."
    sudo chsh -s "$(which zsh)" "$USER"
else
    echo "Zsh is already your default system shell."
fi

echo -e "\n${GREEN}==================================================================${CLEAR}"
echo -e "${GREEN}  Provisioning complete! Your single ~/.zshrc file handles the rest!${CLEAR}"
echo -e "${GREEN}  Run: source ~/.zshrc                                            ${CLEAR}"
echo -e "${GREEN}==================================================================${CLEAR}"

