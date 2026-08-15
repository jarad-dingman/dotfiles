#!/bin/bash

# uncomment if something explodes
# set -euxo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure brew is installed
if ! type "brew" > /dev/null; then
  echo "Installing brew..."
  sleep 5
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Brew is already installed"
fi

# Install all applications in the Brewfile
echo "Installing packages from Brewfile"
brew bundle install -q --file="$DOTFILES_DIR/Brewfile"

if [ "$1" = "--personal" ]; then
  echo "Installing personal-machine-only packages from Brewfile.personal"
  brew bundle install -q --file="$DOTFILES_DIR/Brewfile.personal"
fi

# zsh plugins (sourced directly by .zshrc from ~/.zsh/plugins, no oh-my-zsh)
echo "Installing zsh plugins"
ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"
mkdir -p "$ZSH_PLUGIN_DIR"

clone_plugin() {
  local name="$1" url="$2"
  if [ -d "$ZSH_PLUGIN_DIR/$name" ]; then
    echo "$name already installed"
  else
    git clone --depth 1 "$url" "$ZSH_PLUGIN_DIR/$name"
  fi
}

# Just oh-my-zsh's single-file git plugin, not the whole framework
if [ -f "$ZSH_PLUGIN_DIR/git/git.plugin.zsh" ]; then
  echo "git plugin already installed"
else
  mkdir -p "$ZSH_PLUGIN_DIR/git"
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh \
    -o "$ZSH_PLUGIN_DIR/git/git.plugin.zsh"
fi
clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
clone_plugin zsh-autocomplete https://github.com/marlonrichert/zsh-autocomplete.git

echo "Running stow on config files"
stow -d "$DOTFILES_DIR" -t ~ home
stow -d "$DOTFILES_DIR" -t ~/.config .config

echo "Configure neovim"
if [ -d "$HOME/.config/nvim" ]; then
    echo "neovim already configured"
else
    git clone --depth 1 https://github.com/AstroNvim/template "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
fi

echo ""
echo "------------------------------------------------------------"
echo "MANUAL STEPS REQUIRED"
echo "------------------------------------------------------------"
echo "The following tools must be installed manually:"
echo ""
echo "  mise  — runtime version manager"
echo "          https://mise.jdx.dev/getting-started.html"
echo ""
echo "  atuin — shell history manager"
echo "          https://docs.atuin.sh/guide/installation/"
echo "------------------------------------------------------------"
echo ""
echo "Done. Run macos/defaults.sh and (with sudo) macos/sudo-defaults.sh to finish macOS system setup."
