# ==============================================================================
# 1. Core Shell Environment & Core Paths
# ==============================================================================
export ZSH="$HOME/.oh-my-zsh"
export SDKMAN_DIR="$HOME/.sdkman"
export NVM_DIR="$HOME/.config/nvm"
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
#fastfetch

# ==============================================================================
# 6. Legacy Hooks (CRITICAL: MUST REMAIN AT THE ABSOLUTE BOTTOM)
# ==============================================================================
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# bun completions
[ -s "/home/theo/.bun/_bun" ] && source "/home/theo/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# OCI Configuration Defaults
export OCI_TENANCY_OCID="ocid1.tenancy.oc1..aaaaaaaaz4vvz4nntixk6ibsc7l4ivzm6m4coxqghp3tqcb2qskaxr2vdh2a"
export OCI_USER_OCID="ocid1.user.oc1..aaaaaaaaeqc6cgdbxwetvy2yrdpr2gsguougljzj46fb3qvuhdbonaq5jehq"
export OCI_REGION="af-johannesburg-1" # Or whichever region you use

# Optional: Variables for your custom launch script
export OCI_COMPARTMENT_OCID="ocid1.tenancy.oc1..aaaaaaaaz4vvz4nntixk6ibsc7l4ivzm6m4coxqghp3tqcb2qskaxr2vdh2a"
export OCI_SUBNET_OCID="ocid1.subnet.oc1.af-johannesburg-1.aaaaaaaanaplb6rnmp2f3i6zz2julmic4p7w3fwhoylmonncbnkqwbsl6n6q"
export PATH="$HOME/bin:$PATH"

DISABLE_AUTO_TITLE="true"
