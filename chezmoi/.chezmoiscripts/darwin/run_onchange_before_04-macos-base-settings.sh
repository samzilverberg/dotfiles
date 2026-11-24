#!/usr/bin/env bash

# skip if not mac
if [[ "$(uname)" != "Darwin" ]]; then
  exit 0
fi

# basic mac settings that are not related to any app installs

echo "applying basic mac settings"
# Close System Settings so it doesn't override the settings we're about to change
osascript -e 'if application id "com.apple.systempreferences" is running then tell application id "com.apple.systempreferences" to quit'

# Show battery percentage (menu bar / Control Center)
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true

# date/time/locale settings
#   use 24h digital clock showing the date
defaults write com.apple.menuextra.clock IsAnalog -bool false
defaults write com.apple.menuextra.clock ShowAMPM -bool false
defaults write com.apple.menuextra.clock ShowDate -bool true
defaults write com.apple.menuextra.clock Show24Hour -bool true
##  NOTE: if  "write -g" doesnt work then can replace with "write NSGlobalDomain ...:
defaults write -g AppleICUForce24HourTime -bool true
#   language and measurement units
defaults write -g AppleLanguages -array "en-US" "he-GB"
defaults write -g AppleLocale -string "en_US@currency=EUR"
defaults write -g AppleMeasurementUnits -string "Centimeters"
defaults write -g AppleMetricUnits -bool true
defaults write -g AppleTemperatureUnit -string "Celsius"
#  date format (general, not clock)
defaults write -g AppleICUDateFormatStrings -dict-add "1" "d/M/yy"
defaults write -g AppleICUDateFormatStrings -dict-add "2" "d MMM yy"
defaults write -g AppleICUDateFormatStrings -dict-add "3" "dd MMMM y"
defaults write -g AppleICUDateFormatStrings -dict-add "4" "EEEE, d MMMM y"
# menu bar clock + battery are drawn by ControlCenter
killall ControlCenter 2>/dev/null || true

# dont close windows when quitting an app
# exampele effectt: when iTerm2 updates its windows will preserve
defaults write -g NSQuitAlwaysKeepsWindows -bool true

# Disable automatic capitalization, smart dashes, automatic period,
# smart quotes, auto-correct
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g NSAutomaticTextCompletionEnabled -bool false
defaults write com.apple.TextEdit NSAutomaticTextCompletionEnabled -bool false
# ^^ to undo
# defaults delete com.apple.TextEdit NSAutomaticCapitalizationEnabled

# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
defaults write -g AppleKeyboardUIMode -int 3

# Trackpad (built-in = AppleMultitouchTrackpad, Magic Trackpad = AppleBluetoothMultitouch.trackpad)
# tap to click, for this user and the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# map bottom right corner to right-click
for d in com.apple.driver.AppleBluetoothMultitouch.trackpad com.apple.AppleMultitouchTrackpad; do
  defaults write "$d" TrackpadCornerSecondaryClick -int 2
  defaults write "$d" TrackpadRightClick -bool true
done
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# apple magic mouse: right click when clicking the right side
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode TwoButton
defaults write com.apple.AppleMultitouchMouse.plist MouseButtonMode TwoButton
# can try the following if above doesnt work (default is 1 if need to undo)
# defaults write com.apple.driver.AppleHIDMouse.plist Button2 -int 2

# Disable "natural"  scrolling
defaults write -g com.apple.swipescrolldirection -bool false

# disable notification center gesture
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0

# Disable the "Are you sure you want to open this application?" dialog.
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Fast keyboard repeat. Units of 15ms: KeyRepeat 2 (30ms) and InitialKeyRepeat 15 (225ms) are the
# fastest the System Settings sliders go (KeyRepeat 1 felt too fast). Takes effect after re-login.
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
# press-and-hold shows the accent picker (and then doesn't repeat letters in Cocoa apps)
defaults write -g ApplePressAndHoldEnabled -bool true

# disable Services shortcuts that collide with app shortcuts. Services are configured in the
# pbs domain (key: "<bundle id> - <menu title> - <message>"), not in symbolic hotkeys.
disable_service() {
  defaults write pbs NSServicesStatus -dict-add "$1" "<dict><key>enabled_context_menu</key><false/><key>enabled_services_menu</key><false/><key>presentation_modes</key><dict><key>ContextMenu</key><false/><key>ServicesMenu</key><false/></dict></dict>"
}
# "Open man page in terminal" & "Search word in terminal man page index"
disable_service "com.apple.Terminal - Open man Page in Terminal - openManPage"
disable_service "com.apple.Terminal - Search man Page Index in Terminal - searchManPages"
# Chinese text conversion (ctrl+shift+cmd+C, ctrl+opt+shift+cmd+C)
disable_service "com.apple.ChineseTextConverterService - Convert Text from Simplified to Traditional Chinese - convertTextToTraditionalChinese"
disable_service "com.apple.ChineseTextConverterService - Convert Text from Traditional to Simplified Chinese - convertTextToSimplifiedChinese"

# Show language menu in the top right corner of the boot screen (sudo only if not set yet,
# so re-runs need no password)
if [ "$(defaults read /Library/Preferences/com.apple.loginwindow showInputMenu 2>/dev/null)" != 1 ]; then
  sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true
fi

# Enable selecting input source by shortcut (Ctrl + Alt(option) + Spacebar)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>786432</integer></array><key>type</key><string>standard</string></dict></dict>"

# apply symbolic hotkey changes without logout
# https://apple.stackexchange.com/questions/405937/how-can-i-enable-keyboard-shortcut-preference-after-modifying-it-through-defaul
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

# reduce padding and spacing on top bar items (e.g. wifi, battery, clock)
defaults -currentHost write -globalDomain NSStatusItemSpacing -int 10
defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 10

############
### dock
###########
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -int 50

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# onlt show open apps in dock
defaults write com.apple.dock static-only -bool true

# defaults write com.apple.dock persistent-apps -array    # Delete all apps from dock.

killall Dock

##########
# Finder stuff
##########

# Show the /Volumes folder (sudo only if still hidden)
if [[ "$(stat -f %Sf /Volumes)" == *hidden* ]]; then
  sudo chflags nohidden /Volumes
fi
# show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write -g AppleShowAllExtensions -bool true

# show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Allow quitting finder via ⌘ + Q
defaults write com.apple.finder QuitMenuItem -bool true

killall Finder

# Use plain text mode for new TextEdit documents.
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit.
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Automatically quit printer app once the print jobs complete.
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Prevent Photos from opening automatically when devices are plugged in.
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# Stop the Music app (rcd) from grabbing the keyboard media keys.
launchctl disable "gui/$(id -u)/com.apple.rcd" 2>/dev/null || true

echo "done applying basic mac settings"
