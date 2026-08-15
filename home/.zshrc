# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

export ZSH="$HOME/.oh-my-zsh"

# disable automatic updates
# I use topgrade to manage this
zstyle ':omz:update' mode disabled

DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(
    git
    zsh-autocomplete
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

alias -- cat=bat
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
eval "$(/Users/jarad.dingman/.local/bin/mise activate zsh)"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/jarad.dingman/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# >>> sre-kiro-toolkit secrets >>>
# Loads MCP server tokens from macOS Keychain into environment variables.
# Managed by: scripts/setup-secrets.sh — do not edit manually.
# <<< sre-kiro-toolkit secrets <<<
