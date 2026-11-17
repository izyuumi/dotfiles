#!/bin/bash

set -euo pipefail

# Curated, public-safe defaults only. Do not dump raw plist files here; they can
# include recent paths, text replacements, device state, and other local data.

echo "Applying global macOS defaults..."
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -bool false
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain AppleReduceDesktopTinting -bool true
defaults write NSGlobalDomain InitialKeyRepeat -int 10
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2
defaults write NSGlobalDomain _HIHideMenuBar -bool false
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool false
defaults write NSGlobalDomain com.apple.sound.beep.flash -bool false
defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -bool false
defaults write NSGlobalDomain com.apple.springing.delay -float 0.5
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool false
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3
defaults write NSGlobalDomain com.apple.mouse.scaling -float 3

echo "Applying Finder defaults..."
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder CreateDesktop -bool false
defaults write com.apple.finder FinderSounds -bool false
defaults write com.apple.finder FinderSpawnTab -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowPreviewPane -bool false
defaults write com.apple.finder ShowRecentTags -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.finder ShowSidebar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true

echo "Applying trackpad defaults..."
for trackpad_domain in \
  com.apple.AppleMultitouchTrackpad \
  com.apple.driver.AppleBluetoothMultitouch.trackpad; do
  defaults write "$trackpad_domain" Clicking -bool true
  defaults write "$trackpad_domain" TrackpadHorizScroll -bool true
  defaults write "$trackpad_domain" TrackpadMomentumScroll -bool true
  defaults write "$trackpad_domain" TrackpadPinch -bool true
  defaults write "$trackpad_domain" TrackpadRightClick -bool true
  defaults write "$trackpad_domain" TrackpadRotate -bool true
  defaults write "$trackpad_domain" TrackpadScroll -bool true
  defaults write "$trackpad_domain" TrackpadThreeFingerDrag -bool false
  defaults write "$trackpad_domain" TrackpadTwoFingerDoubleTapGesture -int 1
  defaults write "$trackpad_domain" TrackpadThreeFingerHorizSwipeGesture -int 2
  defaults write "$trackpad_domain" TrackpadThreeFingerVertSwipeGesture -int 2
  defaults write "$trackpad_domain" TrackpadFourFingerHorizSwipeGesture -int 2
  defaults write "$trackpad_domain" TrackpadFourFingerVertSwipeGesture -int 2
done

echo "Applying Magic Mouse defaults..."
for mouse_domain in \
  com.apple.AppleMultitouchMouse \
  com.apple.driver.AppleBluetoothMultitouch.mouse; do
  defaults write "$mouse_domain" MouseButtonMode -string "TwoButton"
  defaults write "$mouse_domain" MouseHorizontalScroll -bool true
  defaults write "$mouse_domain" MouseMomentumScroll -bool true
  defaults write "$mouse_domain" MouseOneFingerDoubleTapGesture -int 1
  defaults write "$mouse_domain" MouseTwoFingerDoubleTapGesture -int 3
  defaults write "$mouse_domain" MouseTwoFingerHorizSwipeGesture -int 2
  defaults write "$mouse_domain" MouseVerticalScroll -bool true
done

echo "Applying Control Center defaults..."
for control_center_item in Battery Bluetooth Clock Sound WiFi; do
  defaults write com.apple.controlcenter \
    "NSStatusItem VisibleCC $control_center_item" -bool true
done

echo "Applying Dock defaults..."
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock show-process-indicators -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock springboard-columns -int 9
defaults write com.apple.dock springboard-rows -int 6
defaults write com.apple.dock springboard-hide-duration -float 0
defaults write com.apple.dock springboard-show-duration -float 0
defaults write com.apple.dock tilesize -int 54
defaults write com.apple.dock wvous-br-corner -int 5
defaults write com.apple.dock wvous-br-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-tr-modifier -int 0

echo "Restarting Finder and Dock..."
killall Finder >/dev/null 2>&1 || true
killall Dock >/dev/null 2>&1 || true
