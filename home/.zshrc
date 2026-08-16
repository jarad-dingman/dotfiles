# ~/.zshrc — hand-rolled, no oh-my-zsh
# Backup of the previous oh-my-zsh config: ~/zsh-config-backup-20260803/
#
# Layout:
#   1. Kiro CLI pre block
#   2. Environment & exports
#   3. Completion system (compinit)
#   4. History
#   5. Key bindings
#   6. Shell options / misc
#   7. Directory navigation
#   8. Functions & helpers
#   9. Terminal title hooks
#  10. Aliases
#  11. Plugins & tool integrations  (all sourcing/`init` lives here)
#  12. Kiro CLI post block

# Kiro CLI pre block. Keep at the top of this file. Work laptop only.
if [[ "$(hostname -s)" == "L9HYPTQG2P" ]]; then
  [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"
fi

# ---- environment ------------------------------------------------------
setopt extended_glob  # needed for the (#qN...) freshness checks below

export LANG=en_US.UTF-8
export PATH="$HOME/.local/bin:/opt/homebrew/opt/libpq/bin:$PATH"
export GPG_TTY=$TTY # allow signing git commits (zsh sets $TTY — no subshell)

export OLLAMA_HOST=http://localhost:11434

export AWS_DEFAULT_REGION=us-west-2
export AWS_PROFILE=shared

# MCP bridge token — the value lives in the macOS Keychain (service:
# wgu-mcp-token), not in this file. Set or rotate it with:
#   security add-generic-password -a "$USER" -s wgu-mcp-token -U -w
# Exported so ~/.kiro/settings/mcp.json can expand ${WGU_MCP_TOKEN}.
export WGU_MCP_TOKEN="$(security find-generic-password -s wgu-mcp-token -w 2>/dev/null)"

ZSH_CACHE_DIR="$HOME/.cache/zsh"
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"

# ---- completion system (compinit) --------------------------------------
zmodload -i zsh/complist
autoload -Uz compinit
# Docker Desktop ships CLI completions; add them to fpath *before* compinit so
# they're picked up by the single cached init below (avoids a second compinit).
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)
# Only pay for the full (compaudit) init once a day; skip the audit the
# rest of the time and reuse the cached dump. (#qN.mh+24) matches the dump
# file only if it's older than 24h (or is missing).
if [[ -n $ZSH_CACHE_DIR/zcompdump(#qN.mh+24) ]]; then
  compinit -d "$ZSH_CACHE_DIR/zcompdump"
else
  compinit -C -d "$ZSH_CACHE_DIR/zcompdump"
fi
[[ "$ZSH_CACHE_DIR/zcompdump.zwc" -nt "$ZSH_CACHE_DIR/zcompdump" ]] || \
  zcompile -R -- "$ZSH_CACHE_DIR/zcompdump.zwc" "$ZSH_CACHE_DIR/zcompdump"

WORDCHARS=''
unsetopt menu_complete
unsetopt flowcontrol
setopt auto_menu
setopt complete_in_word
setopt always_to_end

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"
zstyle '*' single-ignored show

# ---- history ----------------------------------------------------------
# atuin (see tool-integrations below) owns history *recall* — Up and Ctrl+R
# search its SQLite DB, not $HISTFILE. So the on-disk / cross-session tuning
# oh-my-zsh used (share_history, extended_history, hist_expire_dups_first) is
# redundant here and dropped. A zsh history file is still kept because:
#   - in-memory history powers `!!`/`!$`/magic-space expansion (bound above)
#   - the file is atuin's import source and a fallback if atuin is disabled
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify

# ---- key bindings (oh-my-zsh lib/key-bindings.zsh) --------------------
# Keep the terminal in "application mode" while zle is active, so the
# terminfo values below are valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  zle-line-init() { echoti smkx }
  zle-line-finish() { echoti rmkx }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

bindkey -e  # emacs key bindings

for _key in kpp knp; do
  [[ -n "${terminfo[$_key]}" ]] || continue
  if [[ $_key = kpp ]]; then
    bindkey "${terminfo[$_key]}" up-line-or-history
  else
    bindkey "${terminfo[$_key]}" down-line-or-history
  fi
done

[[ -n "${terminfo[khome]}" ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n "${terminfo[kend]}"  ]] && bindkey "${terminfo[kend]}"  end-of-line
[[ -n "${terminfo[kcbt]}"  ]] && bindkey "${terminfo[kcbt]}"  reverse-menu-complete

if [[ -n "${terminfo[kdch1]}" ]]; then
  bindkey "${terminfo[kdch1]}" delete-char
else
  bindkey '^[[3~' delete-char
fi
bindkey '^[[3;5~' kill-word      # Ctrl+Delete
bindkey '^[[1;5C' forward-word   # Ctrl+Right
bindkey '^[[1;5D' backward-word  # Ctrl+Left

bindkey '\ew' kill-region                        # Esc-w: kill to mark
bindkey ' '   magic-space                        # Space: expand history (e.g. !!<space>)
bindkey "^[m" copy-prev-shell-word               # Esc-m: repeat previous word

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line                 # Ctrl+X Ctrl+E: edit line in $EDITOR
unset _key

# ---- shell options / misc (oh-my-zsh lib/misc.zsh, minus url-quote-magic
#      which was disabled anyway via DISABLE_MAGIC_FUNCTIONS) -----------
setopt multios
setopt long_list_jobs
setopt interactivecomments
export PAGER='less'
export LESS='-R'
alias _='sudo '

# ---- directory navigation (oh-my-zsh lib/directories.zsh, minus the ls-
#      prefixed aliases, which the eza aliases below already replace) ---
setopt auto_cd            # bare `foo` == `cd foo`
setopt auto_pushd         # cd pushes the old dir onto the stack
setopt pushd_ignore_dups
setopt pushdminus

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias -- -='cd -'
for _n in {1..9}; do alias $_n="cd -$_n"; done
unset _n

alias md='mkdir -p'
alias rd=rmdir

d() {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}
compdef _dirs d

# ---- functions & helpers (oh-my-zsh lib/clipboard.zsh, macOS-only) -----
clipcopy() { pbcopy < "${1:-/dev/stdin}" }
clippaste() { pbpaste }

# ---- terminal tab/window title (oh-my-zsh lib/termsupport.zsh, trimmed to
#      the xterm-like-terminal case, which covers Ghostty) ---------------
_title() {
  setopt localoptions nopromptsubst
  : ${2=$1}
  print -Pn "\e]2;${2:q}\a"  # window title
  print -Pn "\e]1;${1:q}\a"  # tab title
}
_termsupport_precmd() { _title "%15<..<%~%<<" "%n@%m:%~" }
_termsupport_preexec() {
  local cmd="${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}"
  local line="${2:gs/%/%%}"
  _title "$cmd" "%100>...>${line}%<<"
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _termsupport_precmd
add-zsh-hook preexec _termsupport_preexec

# Keep the terminal's own "current directory" tracking in sync (Ghostty
# uses this for opening new tabs/splits in the same directory).
_termsupport_cwd() {
  local url_path="${PWD// /%20}"
  print -Pn "\e]7;file://%m${url_path}\e\\"
}
add-zsh-hook precmd _termsupport_cwd

# ---- aliases --------------------------------------------------------------
alias -- cat=bat
alias -- vim='nvim'
alias -- la='eza -a'
alias -- ll='eza -l'
alias -- lla='eza -la'
alias -- ls='eza -lSah'
alias -- lt='eza --tree'
alias -- awsl='aws sso login --profile $AWS_PROFILE'
# Kiro expects `timeout`/`gtimeout` to exist. Map to coreutils' gtimeout when
# installed (brew install coreutils). NOT `sleep` — that silently drops the
# command being timed. Aliases are interactive-only, so this is a convenience,
# not a guarantee for non-interactive shells.
(( $+commands[gtimeout] )) && alias timeout='gtimeout'

# ---- plugins & tool integrations ------------------------------------------
# All sourcing / `init` lives here. Order matters for anything that wraps ZLE
# widgets: zsh-syntax-highlighting MUST come last so it can see every widget
# defined by autosuggestions, atuin, fzf, etc.
#
# Precompile plugin scripts to wordcode (.zwc) — loads faster than parsing
# source text on every startup. Only recompiles when the source is newer.
zcompile-many() {
  local f
  for f; do
    [[ -f "$f" && ( ! -f "$f.zwc" || "$f" -nt "$f.zwc" ) ]] && zcompile -R -- "$f.zwc" "$f"
  done
}
zcompile-many \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /opt/homebrew/opt/fzf/shell/key-bindings.zsh
unfunction zcompile-many

# mise: language runtime + tool version manager (shims, env)
eval "$(mise activate zsh)"

# --- cached tool init -------------------------------------------------------
# Cache the STATIC shell-init output of prompt/history tools so we don't spawn
# each binary on every startup. These scripts only install precmd hooks and
# keybindings, so caching them does NOT affect live rendering — starship still
# renders the prompt fresh every command; atuin still searches live. A cache
# regenerates when the tool binary (or, for atuin, its config) is newer.
_cache_init() {
  local name=$1 bin=$2; shift 2
  local cache="$ZSH_CACHE_DIR/init-$name.zsh" binpath=${commands[$bin]}
  if [[ ! -f $cache || ( -n $binpath && $binpath -nt $cache ) \
        || ( -n $_CACHE_EXTRA_DEP && $_CACHE_EXTRA_DEP -nt $cache ) ]]; then
    command "$bin" "$@" >| "$cache" 2>/dev/null
  fi
  [[ -f $cache.zwc && $cache.zwc -nt $cache ]] || zcompile -R -- "$cache.zwc" "$cache" 2>/dev/null
  source "$cache"
}

# starship: prompt
_cache_init starship starship init zsh

# fzf: Ctrl+T (paste files) and Alt+C (fuzzy cd). Only key-bindings.zsh is
# sourced (not completion.zsh), so Tab stays on zsh's normal completion.
# fzf's Ctrl+R is intentionally left to be overridden by atuin below. Path is
# hardcoded (vs `$(brew --prefix fzf)`) to avoid a subprocess on every startup.
# Use fd as fzf's source: faster, respects .gitignore, includes dotfiles (minus .git).
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"

# zsh-autosuggestions. MANUAL_REBIND skips rebinding widgets on every keymap
# change (we don't use vi-mode) — a cheap, well-known startup win.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# atuin: SQLite-backed history. Owns Up (prefix search) and Ctrl+R (full
# search). `env` puts the atuin binary on PATH before `init` runs.
. "$HOME/.atuin/bin/env"
_CACHE_EXTRA_DEP="$HOME/.config/atuin/config.toml" _cache_init atuin atuin init zsh
unset _CACHE_EXTRA_DEP

# wt: worktree helper (optional; only if installed)
(( ${+commands[wt]} )) && _cache_init wt wt config shell init zsh
unset -f _cache_init

# zsh-syntax-highlighting MUST be sourced last: it wraps every widget defined
# above (autosuggestions, atuin, fzf) to highlight the command line.
source "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Kiro CLI post block. Keep at the bottom of this file. Work laptop only.
if [[ "$(hostname -s)" == "L9HYPTQG2P" ]]; then
  [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
fi
