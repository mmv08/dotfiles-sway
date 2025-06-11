# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh setup
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-bat)

source "$ZSH/oh-my-zsh.sh"

# Alias for bare repo management
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Rust environment
[ -s "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Foundry CLI
export PATH="$PATH:$HOME/.foundry/bin"

# load zsh-autosuggestions
source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
export PATH=$HOME/.local/bin:$PATH

# Load Powerlevel10k configuration
[ -f "$HOME/.p10k.zsh" ] && source "$HOME/.p10k.zsh"

# Go toolchain
export PATH=$PATH:/usr/local/go/bin
