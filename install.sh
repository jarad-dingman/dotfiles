#!/bin/bash

# uncomment if something explodes
# set -euxo pipefail

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
brew bundle install -q

# Setup zshrc
if [ ! -d "/Users/$USER/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "oh-my-zsh already configured"
fi

# install plugins
echo "Installing plugins for zsh"
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
    echo "zsh-autosuggestions already installed"
fi

if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    echo "zsh-syntax-highlighting already installed"
fi

if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete" ]; then
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete
else
    echo "zsh-autocomplete already installed"
fi

if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab" ]; then
    git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
else
    echo "fzf-tab already installed"
fi

echo "Running stow on config files"
stow -d $PWD -t ~ home
stow -d $PWD -t ~/.config .config

echo "Configure neovim"
if [ ! -d "$HOME/.config/nvim" ]; then
    git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
    rm -rf ~/.config/nvim/.git
else
    echo "neovim already configured"
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
