#!/usr/bin/env bash

# skip if not mac
if [[ "$(uname)" != "Darwin" ]]; then
  exit 0
fi

# basic mac settings that are not related to any app installs

echo "applying basic mac settings"
# Close any open System Preferences panes to prevent them from overriding settings we’re about to change 
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# date/time/locale settings
#   use 24h digital clock with format "Thu Nov 23 13:37"
defaults write com.apple.menuextra.clock IsAnalog -bool false
defaults write com.apple.menuextra.clock ShowAMPM -bool false
defaults write com.apple.menuextra.clock ShowDate -bool true
defaults write com.apple.menuextra.clock Show24Hour -bool true
defaults write com.apple.menuextra.clock DateFormat "EEE MMM d  H:mm"
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
killall SystemUIServer

# dont close windows when quitting an app
# exampele effectt: when iTerm2 updates its windows will preserve
defaults write -g NSQuitAlwaysKeepsWindows -bool true

# Disable automatic capitalization, smart dashes, automatic period, 
# smart quotes, auto-correct
defaults write -g NSAutomaticCapitalizationEnabled -bool false;
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false;
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false;
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false;
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false;
defaults write -g NSAutomaticTextCompletionEnabled -bool false
defaults write com.apple.TextEdit NSAutomaticTextCompletionEnabled -bool false
# ^^ to undo
# defaults delete com.apple.TextEdit NSAutomaticCapitalizationEnabled

 
# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
defaults write -g AppleKeyboardUIMode -int 3;


# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Trackpad: map bottom right corner to right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
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

# Set a blazingly fast keyboard repeat rate
defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 15
defaults write -g ApplePressAndHoldEnabled -bool true

# disable keyboard shortcuts
# Show in Finder, Show info in Finder 
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 95 "<dict><key>enabled</key><false/></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 96 "<dict><key>enabled</key><false/></dict>"
# "Open man page in terminal" & "Search word in terminal man page index": hotkeys and disable terminal service
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 97 "<dict><key>enabled</key><false/></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 98 "<dict><key>enabled</key><false/></dict>"
defaults write pbs NSServicesStatus -dict-add "com.apple.Terminal - Open man Page in Terminal - openManPage" "<dict><key>enabled_context_menu</key><false/><key>enabled_services_menu</key><false/><key>presentation_modes</key><dict><key>ContextMenu</key><false/><key>ServicesMenu</key><false/></dict></dict>"
defaults write pbs NSServicesStatus -dict-add "com.apple.Terminal - Search man Page Index in Terminal - searchManPages" "<dict><key>enabled_context_menu</key><false/><key>enabled_services_menu</key><false/><key>presentation_modes</key><dict><key>ContextMenu</key><false/><key>ServicesMenu</key><false/></dict></dict>"

# Show Map
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 99 "<dict><key>enabled</key><false/></dict>"
# "convert text to simplified chinese" and "convert text to traditional chinese"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 175 "<dict><key>enabled</key><false/></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 176 "<dict><key>enabled</key><false/></dict>"



# https://apple.stackexchange.com/questions/405937/how-can-i-enable-keyboard-shortcut-preference-after-modifying-it-through-defaul
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u


# Show language menu in the top right corner of the boot screen
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true

# Enable selecting input source by shortcut (Ctrl + Alt(option) + Spacebar)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>786432</integer></array><key>type</key><string>standard</string></dict></dict>"


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

# Show the /Volumes folder
sudo chflags nohidden /Volumes
# show hidden files
defaults write com.apple.Finder AppleShowAllFiles true

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

# Stop iTunes from responding to the keyboard media keys.
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

# might help avoid a total restart to get changes to affect immediately
killall cfprefsd
killall Finder

echo "done applying basic mac settings"