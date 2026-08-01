#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define colors for pretty terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting dotfiles automated setup...${NC}\n"

# 1. Ensure GNU Stow is installed
if ! command -v stow &> /dev/null; then
    echo -e "${YELLOW}📦 GNU Stow not found. Attempting to install...${NC}"
    if command -v dnf5 &> /dev/null; then
        sudo dnf5 install -y stow
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y stow
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y stow
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm stow
    else
        echo -e "${RED}❌ Could not detect package manager. Please install GNU Stow manually.${NC}"
        exit 1
    fi
fi

# 2. Navigate to the dotfiles directory location
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DOTFILES_DIR"
echo -e "📍 Working inside dotfiles directory: ${YELLOW}$DOTFILES_DIR${NC}"

# 3. Explicitly define packages to deploy (matching your exact folders)
PACKAGES=(
    "zsh"
    "starship"
    "tmux"
    "ghostty"
    "nvim"
    "fastfetch"
)

echo -e "\n${GREEN}🔗 Symlinking packages with GNU Stow...${NC}"

# 4. Loop through packages and deploy
for package in "${PACKAGES[@]}"; do
    if [ -d "$package" ]; then
        echo -e "  ↳ Stowing ${GREEN}$package${NC}..."
        
        # Run stow. If it fails due to existing files, offer to adopt them.
        if ! stow "$package" 2>/dev/null; then
            echo -e "  ${YELLOW}⚠️  Conflict detected for package '$package'.${NC}"
            read -p "     Do you want to adopt existing local files into your dotfiles? (y/N) " choice
            case "$choice" in 
                [yY][eE][sS]|[yY])
                    echo -e "     Taking over local files via --adopt..."
                    stow --adopt "$package"
                    ;;
                *)
                    echo -e "     ${RED}Skipping '$package'. Resolve conflicts manually or back up local configurations.${NC}"
                    ;;
            esac
        fi
    else
        echo -e "  ${RED}❌ Folder '$package' not found in repository. Skipping.${NC}"
    fi
done

echo -e "\n${GREEN}✨ All configurations have been successfully processed!${NC}"
echo -e "💡 Remember to run 'source ~/.zshrc' if your shell updates do not appear immediately."
