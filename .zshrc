# Oh My Zsh setup
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git zsh-autosuggestions zsh-bat)

source "$ZSH/oh-my-zsh.sh"

# Alias for bare repo management
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias ls='lsd'
alias lt='ls --tree'

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
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"


# Starship prompt, keep it last
eval "$(starship init zsh)"