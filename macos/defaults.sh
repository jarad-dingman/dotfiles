#!/bin/bash
# User-level macOS preferences, replacing what nix-darwin's `darwin/settings.nix`
# used to apply declaratively. Idempotent — safe to re-run.
#
# Anything that needs root (SoftwareUpdate, loginwindow, Touch ID for sudo,
# startup chime) lives in macos/sudo-defaults.sh instead.
#
# Run this once per machine: ./macos/defaults.sh

set -euo pipefail

echo "Dock"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock showhidden -bool false
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock orientation -string left
defaults write com.apple.dock tilesize -int 40
defaults write com.apple.dock persistent-apps -array \
  '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Ghostty.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
  '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Dia.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
  '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Zed.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
  '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Obsidian.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
  '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Proton Pass.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
  '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Proton Drive.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
  '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/ProtonVPN.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

echo "Finder"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder CreateDesktop -bool false
defaults write com.apple.finder FXPreferredViewStyle -string clmv

echo "WindowManager"
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true
defaults write com.apple.WindowManager StandardHideWidgets -bool true

echo "Trackpad"
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

echo "Screensaver"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 5

echo "Menu bar clock"
defaults write com.apple.menuextra.clock Show24Hour -bool true

echo "NSGlobalDomain"
defaults write NSGlobalDomain _HIHideMenuBar -bool true
defaults write NSGlobalDomain AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

echo "Misc"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false

echo "Remap Caps Lock -> Escape (this session; the LaunchAgent makes it persist across logins)"
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}' > /dev/null
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$HOME/Library/LaunchAgents/com.jacobsin.capslock-escape.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.jacobsin.capslock-escape</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/hidutil</string>
    <string>property</string>
    <string>--set</string>
    <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF
launchctl unload "$HOME/Library/LaunchAgents/com.jacobsin.capslock-escape.plist" 2>/dev/null || true
launchctl load "$HOME/Library/LaunchAgents/com.jacobsin.capslock-escape.plist"

echo "Restarting affected apps"
killall Dock Finder SystemUIServer 2>/dev/null || true

echo "Done. Some changes (dark mode, dock icons) may need a logout/login to fully apply everywhere."
