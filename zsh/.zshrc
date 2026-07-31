export ZSH="$HOME/.oh-my-zsh"

# 1. ohmyzsh Theme
ZSH_THEME=""

# 2. Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# 3. Node Version Manager Layout
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 4. Global Shell Aliases
alias nvim='~/Applications/nvim-linux-x86_64.appimage'
alias ls='eza --icons --color=always'
alias spring-run='./mvnw spring-boot:run'
alias spring-dev='./mvnw spring-boot:run -Dspring-boot.run.profiles=dev'

# 5. Prompt Engine (Must stay near the end)
eval "$(starship init zsh)"

# 6. SDKMAN (THIS MUST ABSOLUTELY BE AT THE VERY END OF THE FILE!!!)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
