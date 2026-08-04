# ~/.zshrc — hand-rolled, no oh-my-zsh
# Backup of the previous oh-my-zsh config: ~/zsh-config-backup-20260803/

# ---- environment ------------------------------------------------------
setopt extended_glob  # needed for the (#qN...) freshness checks below

export LANG=en_US.UTF-8
export PATH="/Users/jacobsin/.local/bin:$PATH"
export GPG_TTY=$(tty) # allow signing git commits

ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"
ZSH_CACHE_DIR="$HOME/.cache/zsh"
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"

# ---- completion system (compinit) --------------------------------------
zmodload -i zsh/complist
autoload -Uz compinit
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

# ---- history (same values oh-my-zsh's lib/history.zsh set) ------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt share_history

# Up/Down cycle through history entries that start with whatever you've
# already typed (e.g. type "python ", press Up, only "python ..." commands
# come back), instead of the full unfiltered history. Built into zsh,
# no plugin needed.
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end
bindkey '^[OA' history-beginning-search-backward-end
bindkey '^[OB' history-beginning-search-forward-end

# ---- terminal keys (oh-my-zsh lib/key-bindings.zsh, minus the up/down
#      rebind above which already covers that) --------------------------
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

# ---- utility functions (oh-my-zsh lib/functions.zsh + lib/clipboard.zsh,
#      trimmed to macOS-only — no need for the cross-platform detection) -
mkcd() { mkdir -p "$@" && cd "${@: -1}" }
takeurl() {
  local data thedir
  data="$(mktemp)"
  curl -L "$1" > "$data"
  tar xf "$data"
  thedir="$(tar tf "$data" | head -n 1)"
  rm "$data"
  cd "$thedir"
}
takezip() {
  local data thedir
  data="$(mktemp)"
  curl -L "$1" > "$data"
  unzip "$data" -d "./"
  thedir="$(unzip -l "$data" | awk 'NR==4 {print $4}' | sed 's/\/.*//')"
  rm "$data"
  cd "$thedir"
}
takegit() { git clone "$1" && cd "$(basename "${1%%.git}")" }
take() {
  if [[ $1 =~ ^(https?|ftp).*\.(tar\.(gz|bz2|xz)|tgz)$ ]]; then
    takeurl "$1"
  elif [[ $1 =~ ^(https?|ftp).*\.(zip)$ ]]; then
    takezip "$1"
  elif [[ $1 =~ ^([A-Za-z0-9]+@|https?|git|ssh|ftps?|rsync).*\.git/?$ ]]; then
    takegit "$1"
  else
    mkcd "$@"
  fi
}

clipcopy() { pbcopy < "${1:-/dev/stdin}" }
clippaste() { pbpaste }

# Colored grep/egrep/fgrep with common VCS/venv dirs excluded, cached so we
# only probe for flag support once (not on every shell startup). Each dir
# gets its own --exclude-dir flag — macOS's BSD grep doesn't understand a
# single brace-list value the way GNU grep does.
__grep_cache="$ZSH_CACHE_DIR/grep-alias"
if [[ -e "$__grep_cache" && -z $__grep_cache(#qN.mh+24) ]]; then
  source "$__grep_cache"
else
  __grep_exclude_dirs=(.git .hg .svn .tox .venv venv node_modules)
  __grep_exclude=(${(@)__grep_exclude_dirs/#/--exclude-dir=})
  if command grep --color=auto $__grep_exclude "" <<< "" &>/dev/null; then
    alias grep="grep --color=auto ${(j: :)__grep_exclude}"
    alias egrep='grep -E'
    alias fgrep='grep -F'
    alias -L grep egrep fgrep >| "$__grep_cache"
  fi
  unset __grep_exclude_dirs __grep_exclude
fi
unset __grep_cache

# ---- plugins ------------------------------------------------------------
# Compile a file to wordcode (.zwc) if missing or stale, then source it.
# Wordcode loads noticeably faster than parsing source text on every
# shell startup.
zcompile-many() {
  local f
  for f; do
    [[ -f "$f" && ( ! -f "$f.zwc" || "$f" -nt "$f.zwc" ) ]] && zcompile -R -- "$f.zwc" "$f"
  done
}
zcompile-many \
  "$ZSH_PLUGIN_DIR"/git/git.plugin.zsh \
  "$ZSH_PLUGIN_DIR"/zsh-autosuggestions/zsh-autosuggestions.zsh \
  "$ZSH_PLUGIN_DIR"/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /opt/homebrew/opt/fzf/shell/key-bindings.zsh
unfunction zcompile-many

source "$ZSH_PLUGIN_DIR/git/git.plugin.zsh"

# fzf's own Ctrl+R: fuzzy-search zsh history (most recent first). Only the
# key-bindings script is sourced (not completion.zsh), so Tab stays on
# zsh's normal completion. Path is hardcoded (rather than `$(brew --prefix
# fzf)`) to avoid an extra subprocess on every startup.
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"

# Skip zsh-autosuggestions' automatic widget rebinding on every keymap
# change (we don't use vi-mode) — cheap, well-known startup win.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

# syntax-highlighting must be sourced last: it wraps other widgets.
source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ---- prompt -------------------------------------------------------------
eval "$(starship init zsh)"

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
