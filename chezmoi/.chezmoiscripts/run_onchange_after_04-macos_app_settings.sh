#!/usr/bin/env bash

# skip if not mac
if [[ "$(uname)" != "Darwin" ]]; then
  exit 0
fi

# app specific mac settings

echo "applying mac settings: app specific"
# Close any open System Preferences panes to prevent conflicts with changes
osascript -e 'tell application "System Preferences" to quit'

# change to cmd+shift+q to quit for some apps (to avoid accidental cmd+q)
defaults write app.zen-browser.zen NSUserKeyEquivalents -dict-add 'Quit Zen' '@$q'
defaults write org.mozilla.firefox NSUserKeyEquivalents -dict-add 'Quit Firefox' '@$q'
defaults write com.google.Chrome NSUserKeyEquivalents -dict-add 'Quit Google Chrome' '@$q'
defaults write com.microsoft.VSCode NSUserKeyEquivalents -dict-add 'Quit Visual Studio Code' '@$q'

# write the above bundle ids to ~/Library/Preferences/com.apple.universalaccess so it will appear in GUI are of keyboard->shortcuts->app shortcuts
addCustomMenuEntryIfNeeded() {
  if [[ $# == 0 || $# > 1 ]]; then
      echo "usage: addCustomMenuEntryIfNeeded com.company.appname"
      return 1
  else
      local grepForEntry=`defaults read com.apple.universalaccess "com.apple.custommenu.apps" | grep "$1"`
      # if does not contain app
      if [ -z grepForEntry ]; then
          defaults write com.apple.universalaccess "com.apple.custommenu.apps" -array-add "$1"
      fi
  fi
}


# create the key if it does not exist
# defaults read com.apple.universalaccess "com.apple.custommenu.apps"
if ! defaults read com.apple.universalaccess com.apple.custommenu.apps >/dev/null 2>&1; then
    defaults write com.apple.universalaccess "com.apple.custommenu.apps" -array >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "failed to create custom apps key, you will need to manually grant full disk access to terminal apps"
        osascript -e "
tell application id \"com.apple.systempreferences\"
    activate
    delay 0.5
    reveal pane id \"com.apple.settings.PrivacySecurity.extension\"
end tell
delay 0.5
tell app \"System Events\" to display dialog \"you need to manually enable full disk access for terminal\" with title \"manual action required\" buttons {\"I Will\"} default button 1
"
    exit 1
    fi

fi

addCustomMenuEntryIfNeeded "app.zen-browser.zen"
addCustomMenuEntryIfNeeded "org.mozilla.firefox"
addCustomMenuEntryIfNeeded "com.google.Chrome"
addCustomMenuEntryIfNeeded "com.microsoft.VSCode"

# might help avoid a total restart to get changes to affect immediately
killall cfprefsd
killall Finder

# turn off "Show Spotlight search" spotlight shortcut
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>"
# turn off "Show Finder search window"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 "<dict><key>enabled</key><false/></dict>"

# run cmd to re-apply defaults so hoykeys will be updated
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u