#!/bin/sh

echo "applying mac settings"
# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# clock settings : use 24h digital clock with format "Thu 23 Nov 13:37"
defaults write com.apple.menuextra.clock IsAnalog -bool false
defaults write com.apple.menuextra.clock Show24Hour -bool true
defaults write com.apple.menuextra.clock DateFormat "EEE d MMM HH:mm"
killall SystemUIServer

# Disable automatic capitalization, smart dashes, automatic period, 
# smart quotes, auto-correct
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false;
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false;
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false;
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false;
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false;
defaults write NSGlobalDomain NSAutomaticTextCompletionEnabled -bool false
defaults write com.apple.TextEdit NSAutomaticTextCompletionEnabled -bool false
# ^^ to undo
# defaults delete com.apple.TextEdit NSAutomaticCapitalizationEnabled

 
# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3;


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

# Disable "natural"  scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# disable notification center gesture
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0

# Disable the "Are you sure you want to open this application?" dialog.
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool true

# Keyboard shortcut Disable "Open man page in terminal" & "Search word in terminal man page index"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 123 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>22</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 124 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>22</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"

# https://apple.stackexchange.com/questions/405937/how-can-i-enable-keyboard-shortcut-preference-after-modifying-it-through-defaul
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u


# Set language and text formats
# Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, `en_GB` with `en_US`, and `true` with `false`.
defaults write NSGlobalDomain AppleLanguages -array "en-US" "he-GB"
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

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
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

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

defaults write com.apple.finder QuitMenuItem -bool true                      # Allow quitting finder via ⌘ + Q.

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

# change to cmd+shift+q to quit for some apps (to avoid accidental cmd+q)
defaults write org.mozilla.firefox NSUserKeyEquivalents -dict-add 'Quit Firefox' '@$q'
defaults write com.google.Chrome NSUserKeyEquivalents -dict-add 'Quit Google Chrome' '@$q'
defaults write com.microsoft.VSCode NSUserKeyEquivalents -dict-add 'Quit Visual Studio Code' '@$q'

# write the above to ~/Library/Preferences/com.apple.universalaccess so it will appear in GUI are of keyboard->shortcuts->app shortcuts
addCustomMenuEntryIfNeeded() {
  if [[ $# == 0 || $# > 1 ]]; then
      echo "usage: addCustomMenuEntryIfNeeded com.company.appname"
      return 1
  else
      local contents=`defaults read com.apple.universalaccess "com.apple.custommenu.apps"`
      local grepResults=`echo $contents | grep $1`
      if [ -z $grepResults ]; then
          # does not contain app
          defaults write com.apple.universalaccess "com.apple.custommenu.apps" -array-add "$1"
      fi
  fi
}

addCustomMenuEntryIfNeeded "org.mozilla.firefox"
addCustomMenuEntryIfNeeded "com.google.Chrome"
addCustomMenuEntryIfNeeded "com.microsoft.VSCode"

# might help avoid a total restart to get changes to affect immediately
killall cfprefsd
killall Finder

echo "done applying mac settings"