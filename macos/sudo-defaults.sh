#!/bin/bash
# Root-level macOS settings that used to be applied by nix-darwin's
# system activation script. Requires sudo. Idempotent — safe to re-run.
#
# Run once per machine: sudo ./macos/sudo-defaults.sh

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this with sudo: sudo $0" >&2
  exit 1
fi

echo "Touch ID for sudo"
if ! grep -q pam_tid.so /etc/pam.d/sudo_local 2>/dev/null; then
  { echo "auth       sufficient     pam_tid.so"; cat /etc/pam.d/sudo_local 2>/dev/null || true; } > /etc/pam.d/sudo_local.tmp
  mv /etc/pam.d/sudo_local.tmp /etc/pam.d/sudo_local
  chmod 644 /etc/pam.d/sudo_local
else
  echo "already configured"
fi

echo "Startup chime"
nvram StartupMute=%01

echo "Software Update: auto-install macOS updates"
defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool true

echo "Login window"
defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText -string "Leave me be."

echo "Done."
