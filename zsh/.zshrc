# ==============================================================================
# 1. Core Shell Environment & Core Paths
# ==============================================================================
export ZSH="$HOME/.oh-my-zsh"
export SDKMAN_DIR="$HOME/.sdkman"
export NVM_DIR="$HOME/.nvm"
export LD_PRELOAD=$LD_PRELOAD:/usr/lib/libgamemode.so

# System Default Editors
export EDITOR="nvim"
export VISUAL="nvim"

# ==============================================================================
# 2. Oh My Zsh Framework Settings
# ==============================================================================
# Empty quotes mean theme handling is managed by an external prompt engine (Starship)
ZSH_THEME=""

# Framework Extensions
plugins=(git docker zsh-autosuggestions zsh-syntax-highlighting)

# Initialize Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# ==============================================================================
# 3. External Tool Integrations
# ==============================================================================
# Runtime Version Managers (NVM)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Smart Directory Navigation Tracker
eval "$(zoxide init zsh)"

# ==============================================================================
# 4. Command Aliases & Custom Functions
# ==============================================================================
# Core Terminal Overrides
alias bat="bat"
alias ls='eza --icons --color=always'
alias c='clear'

# Spring Boot Development Layouts
alias spring-run='./mvnw spring-boot:run'
alias spring-dev='./mvnw spring-boot:run -Dspring-boot.run.profiles=dev'

# Interactive Fuzzy Previewer (Handles standard targets and paths safely)
fp() {
    local target_dir="${1:-.}"
    find "$target_dir" -type f 2>/dev/null | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
}

# ==============================================================================
# 5. Visual Shell Interface Elements
# ==============================================================================
# Custom Prompt Engine Initialization
eval "$(starship init zsh)"

# Display System Technical Profile Overview
fastfetch

# ==============================================================================
# 6. Legacy Hooks (CRITICAL: MUST REMAIN AT THE ABSOLUTE BOTTOM)
# ==============================================================================
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
