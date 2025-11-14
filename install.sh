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
if [ -d "/Users/$USER/.oh-my-zsh" ]; then
    echo "oh-my-zsh has been configured"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# install plugins
echo "Installing plugins for zsh"
if [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ];then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
    echo "installed zsh-autosuggestions"
fi

if [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ];then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    echo "installed zsh-syntax-highlighting"
fi

if [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete" ];then
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete
else
    echo "installed zsh-autocomplete"
fi

if [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab" ];then
    git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
else
    echo "installed fzf-tab"
fi

echo "Running stow on config files"
stow -d $PWD -t ~ home
stow -d $PWD -t ~/.config .config

echo "Configure neovim"
if [ -d "~/.config/nvim" ];then
    git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
    rm -rf ~/.config/nvim/.git
else
    echo "neovim already configured"
fi

echo "Now it is time to install nix..."
