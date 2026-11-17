#!/bin/bash

set -euo pipefail

# Public-safe preferences only. Run with these apps closed so they do not
# overwrite the values while cfprefsd is updating them. License, account,
# device, display, network, history, window-state, and updater-state keys are
# intentionally excluded.

app_installed() {
  local app_path

  for app_path in "$@"; do
    [ -d "$app_path" ] && return 0
  done

  return 1
}

if app_installed "/Applications/Rectangle Pro.app"; then
  echo "Applying Rectangle Pro defaults..."
  domain="com.knollsoft.Hookshot"

  defaults write "$domain" allowAnyShortcut -bool false
  defaults write "$domain" applyGapToEdges -int 2
  defaults write "$domain" autoRestartOnWake -int 1
  defaults write "$domain" footprintAnimationDurationMultiplier -float 0.75
  defaults write "$domain" gestures -string '[11,{"trail":1,"flags":0},0,{"trail":3,"flags":0},10,{"trail":2,"flags":0},1,{"trail":4,"flags":0},35,{"trail":0,"flags":0}]'
  defaults write "$domain" hideMenubarIcon -bool true
  defaults write "$domain" launchOnLogin -bool true
  defaults write "$domain" modifierUpCancelsRepetition -int 1
  defaults write "$domain" quickActionMinDist -float 50
  defaults write "$domain" quickActions -int 1
  defaults write "$domain" selectedCycleSizes -int 0
  defaults write "$domain" stashEnabled -int 1
  defaults write "$domain" subsequentExecutionMode -int 2
  defaults write "$domain" windowSnapping -int 1

  defaults write "$domain" center -dict keyCode -int 8 modifierFlags -int 786432
  defaults write "$domain" larger -dict keyCode -int 24 modifierFlags -int 786432
  defaults write "$domain" nextDisplay -dict keyCode -int 124 modifierFlags -int 1835008
  defaults write "$domain" previousDisplay -dict keyCode -int 123 modifierFlags -int 1835008
  defaults write "$domain" restore -dict keyCode -int 51 modifierFlags -int 786432
  defaults write "$domain" smaller -dict keyCode -int 27 modifierFlags -int 786432

fi

if app_installed "/Applications/Rex.app" "/Applications/Rex Beta.app"; then
  echo "Applying Rex defaults..."
  domain="com.superlogical.rex"

  defaults write "$domain" Workspace.darkThemeID -string "merino-dark"
  defaults write "$domain" Workspace.inactivePaneFadeMode -string "both"
  defaults write "$domain" Workspace.interfaceStyle -string "blendTheme"
  defaults write "$domain" Workspace.lightThemeID -string "merino-light"
  defaults write "$domain" Workspace.playsProgramActivitySounds -bool false
  defaults write "$domain" Workspace.sidebarPosition -string "left"
  defaults write "$domain" Workspace.sidebarShowsActivity -bool false
  defaults write "$domain" Workspace.tabIconTintMode -string "off"
  defaults write "$domain" Workspace.tabStyle -string "vertical"
  defaults write "$domain" Workspace.usesPaneGlass -bool true
  defaults write "$domain" Workspace.usesStandardInactiveWindowPaneStyles -bool true
  defaults write "$domain" rex.agents.names-sessions -bool true
  defaults write "$domain" rex.developer-mode-enabled -bool true
  defaults write "$domain" rex.server.automatic-restart-enabled -bool true
  defaults write "$domain" rex.server.block-plugin-reload-enabled -bool false
  defaults write "$domain" rex.server.run-mode -string "bundled"
fi

if app_installed "/Applications/Alcove.app"; then
  echo "Applying Alcove defaults..."
  domain="com.henrikruscon.Alcove"

  defaults write "$domain" brightnessProgressStyle -string "stylized"
  defaults write "$domain" enableBrightness -bool true
  defaults write "$domain" enableFocus -bool false
  defaults write "$domain" enableVolume -bool true
  defaults write "$domain" expandNotchOnHover -bool false
  defaults write "$domain" forceSimulatedNotch -bool false
  defaults write "$domain" hideBrightnessLabel -bool true
  defaults write "$domain" hideFromScreenCapture -bool true
  defaults write "$domain" hideWhileInMissionControl -bool true
  defaults write "$domain" idleActivity -string "none"
  defaults write "$domain" launchAtLogin -bool true
  defaults write "$domain" musicApp -string "system"
  defaults write "$domain" naturalMovement -bool true
  defaults write "$domain" playSoundOnLowBattery -bool false
  defaults write "$domain" playSoundOnLowConnectBattery -bool true
  defaults write "$domain" playSoundOnUnlock -bool false
  defaults write "$domain" showOnScreenSaver -bool true
  defaults write "$domain" volumeProgressStyle -string "stylized"
  defaults write "$domain" warnOnLowConnectBattery -bool true
fi

if app_installed "/Applications/Antinote.app"; then
  echo "Applying Antinote defaults..."
  domain="com.chabomakers.Antinote"

  defaults write "$domain" appIconPreference -string "neither"
  defaults write "$domain" autoCopyOnSelect -bool true
  defaults write "$domain" avgMainTrigger -string "avg"
  defaults write "$domain" checkMainTrigger -string "/x"
  defaults write "$domain" codeMainTrigger -string "code"
  defaults write "$domain" countMainTrigger -string "count"
  defaults write "$domain" disableLinkHighlighting -bool false
  defaults write "$domain" disableLinkShortening -bool false
  defaults write "$domain" doubleFontSize -bool false
  defaults write "$domain" enableTexReplacements -bool true
  defaults write "$domain" fontSize -string "M"
  defaults write "$domain" listMainTrigger -string "list"
  defaults write "$domain" mathMainTrigger -string "math"
  defaults write "$domain" paperOpacity -string "clear"
  defaults write "$domain" paperType -string "dots"
  defaults write "$domain" queryUrgentAlerts -bool false
  defaults write "$domain" removeEmptyLines -bool true
  defaults write "$domain" restorePinOnOpen -bool true
  defaults write "$domain" secondaryCurrency -string "JPY"
  defaults write "$domain" sendCrashLogs -bool false
  defaults write "$domain" skipChecked -bool true
  defaults write "$domain" sumMainTrigger -string "sum"
  defaults write "$domain" timerMainTrigger -string "timer"
  defaults write "$domain" timerShowInMenuBar -bool true
  defaults write "$domain" translucentWindow -bool true
  defaults write "$domain" updateConversionRates -bool true
fi

if app_installed "/Applications/Charmstone.app"; then
  echo "Applying Charmstone defaults..."
  domain="com.knollsoft.Charmstone"

  defaults write "$domain" arrowKeysDisplays -int 1
  defaults write "$domain" background -int 2
  defaults write "$domain" farReticleSpec -string '{"id":1,"t":{"type":0,"stringValue":"com.automattic.beeper.desktop"},"tl":{"type":0,"stringValue":"com.tencent.xinWeChat"}}'
  defaults write "$domain" hideMenuBarIcon -bool true
  defaults write "$domain" launchOnLogin -bool true
  defaults write "$domain" mainReticleSpec -string '{"br":{"type":0,"stringValue":"com.apple.Notes"},"l":{"type":0,"stringValue":"com.todesktop.230313mzl4w4u92"},"tr":{"type":0,"stringValue":"com.apple.systempreferences"},"tl":{"type":0,"stringValue":"com.electron.aqua-voice"},"id":0,"r":{"type":0,"stringValue":"com.openai.codex"},"t":{"type":0,"stringValue":"com.microsoft.teams2"},"bl":{"type":0,"stringValue":"com.granola.app"},"b":{"type":0,"stringValue":"com.anthropic.claudefordesktop"}}'
  defaults write "$domain" relaunchActive -int 1
  defaults write "$domain" reticleDisplayMinDist -float 5.085827
  defaults write "$domain" reticleFlags -int 1572864
fi

unset domain
