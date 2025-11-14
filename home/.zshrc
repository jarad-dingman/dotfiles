# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && \
    builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

export ZSH="$HOME/.oh-my-zsh"

# disable automatic updates
# I use topgrade to manage this
zstyle ':omz:update' mode disabled

DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(
    git
    direnv
    fzf-tab
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

alias -- cat=bat
alias -- find=fd
alias -- vim='nvim'
alias -- la='eza -a'
alias -- ll='eza -l'
alias -- lla='eza -la'
alias -- ls='eza -lSah'
alias -- lt='eza --tree'

eval "$(starship init zsh)"

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && \
    builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
