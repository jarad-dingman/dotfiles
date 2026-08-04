# Dotfiles

Source of truth for this Mac's config, managed with [GNU Stow](https://www.gnu.org/software/stow/).
No Nix, no home-manager — just Homebrew + stow.

These dotfiles are meant for a macbook since they use `brew` and install
several mac-only utilities. `little-snitch` (and anything else that
shouldn't go on a work machine) lives in `Brewfile.personal`, kept out of
the default install.

### Layout

- `home/` — stowed to `~` (`.zshrc`, `.zprofile`, `.ssh/config`, `.gnupg/gpg-agent.conf`, `.yabairc`)
- `.config/` — stowed to `~/.config` (git, ghostty, starship, bat, bottom, zellij, eza, topgrade)
- `Brewfile` — packages safe to install anywhere, including a work machine
- `Brewfile.personal` — personal-machine-only packages (e.g. little-snitch)
- `macos/defaults.sh` — user-level `defaults write` settings (dock, Finder, trackpad, dark mode, Caps Lock → Escape, ...)
- `macos/sudo-defaults.sh` — root-level settings (Touch ID for sudo, startup chime, Software Update, login window)

### Installation

```bash
chmod +x install.sh
./install.sh              # common packages + stow
./install.sh --personal   # also installs Brewfile.personal (skip this on a work machine)

./macos/defaults.sh        # user-level macOS defaults
sudo ./macos/sudo-defaults.sh   # root-level macOS defaults + Touch ID for sudo
```

All four steps are idempotent — safe to re-run on an already-configured machine.
