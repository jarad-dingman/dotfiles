# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

export ZSH="$HOME/.oh-my-zsh"

# disable automatic updates
# I use topgrade to manage this
zstyle ':omz:update' mode disabled

DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(
    git
    direnv
    zsh-autocomplete
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

export GPG_TTY=$(tty) # This is to allow signing git commits

eval "$(starship init zsh)"

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
