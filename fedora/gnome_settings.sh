#!/bin/sh

set -euo pipefail

if [[ "$DESKTOP_SESSION" != "gnome" ]] || ! command -v "gsettings" >/dev/null 2>&1; then
  echo "gnome desktop environment not detected"
  exit 1
fi

# enable all keyboard inputs (otheruse EurKey layout is not available)
# requires logout + login to show EU layout in layout indicator
gsettings set org.gnome.desktop.input-sources show-all-sources true
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'eu'),  ('xkb', 'il')]"

# disable caps lock from doing caps!
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier']"

# keyboard key repeat speed
gsettings set org.gnome.desktop.peripherals.keyboard delay 250
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 25  


# lock after 10 mins, sleep (on power) after 15 mins
gsettings set org.gnome.desktop.session idle-delay 600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 900

# night light settings
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 21.0
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 6.0
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4500
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

# workspaces: 3 horizontal & keyboard shortcuts to move between
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 3

# wsmatrix takes care of the workspaces horizontal layout + preview
curl -L -o /tmp/gnome-shell-wsmatrix.zip "https://github.com/mzur/gnome-shell-wsmatrix/releases/download/v6.2/wsmatrix@martin.zurowietz.de.zip"
sudo mkdir -p /usr/share/gnome-shell/extensions/wsmatrix@martin.zurowietz.de
sudo unzip /tmp/gnome-shell-wsmatrix.zip -d /usr/share/gnome-shell/extensions/wsmatrix@martin.zurowietz.de
rm -f /tmp/gnome-shell-wsmatrix.zip

gnome-extensions enable wsmatrix@martin.zurowietz.de
gsettings set org.gnome.shell.extensions.wsmatrix-settings num-rows 1
gsettings set org.gnome.shell.extensions.wsmatrix-settings num-columns 3
# turn off super+w that shows workspace picker popup
gsettings --schemadir /usr/share/gnome-shell/extensions/wsmatrix@martin.zurowietz.de/schemas/ set org.gnome.shell.extensions.wsmatrix-keybindings workspace-overview-toggle "[]"

# workspaces indicator in top panel
# dnf install needed? or already available?
# dnf install gnome-shell-extension-workspace-indicator
gnome-extensions enable workspace-indicator@gnome-shell-extensions.gcampax.github.com



# keyboard bindings
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-down "[]"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-up "[]"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "[]"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left "[]"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['XF86Eject','XF86Launch9','XF86Launch8', 'Pause']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-last "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-last "[]"

gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "[]"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "[]"


gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Ctrl><Super><Shift>Right']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Ctrl><Super><Shift>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Ctrl><Super>Right']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Ctrl><Super>Left']"

gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab', '<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Super>Tab', '<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab', '<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Alt>Above_Tab']"
gsettings set org.gnome.desktop.wm.keybindings begin-move "[]"
gsettings set org.gnome.desktop.wm.keybindings begin-resize "[]"
gsettings set org.gnome.desktop.wm.keybindings toggle-maximize d "[]"
gsettings set org.gnome.desktop.wm.keybindings cycle-group "[]"
gsettings set org.gnome.desktop.wm.keybindings cycle-group-backward "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "[]"
gsettings set org.gnome.desktop.wm.keybindings cycle-panels-backward "[]"
gsettings set org.gnome.desktop.wm.keybindings activate-window-menu "['<Ctrl><Alt>space']"
gsettings set org.gnome.desktop.wm.keybindings minimize "[]"

gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Alt><Super>space', '<Ctrl><Alt>k', 'Caps_Lock', 'XF86Keyboard']"

gsettings set org.gnome.desktop.wm.keybindings panel-main-menu "['XF86LaunchA']"
 
#   XF86Eject (above delete)
# 197 NoSymbol    (F19)
# 196 XF86Launch9 (F18)
# 195 XF86Launch8 (F17)
# 194 XF86Launch7 (F16)
# 193 XF86Launch6 (F15)
# 192 XF86Launch5 (F14)
# 127 Pause 

gsettings set org.gnome.desktop.interface text-scaling-factor 1.2

# gsettings list-recursively org.gnome.settings-daemon.plugins.media-keys

# dont use left super to show activities overview
# instead use super + space
# 
gsettings set org.gnome.mutter overlay-key ''
gsettings set org.gnome.shell.keybindings toggle-overview "['<Alt>F1', '<Super>Space', 'Menu']"
  
gsettings set org.gnome.mutter auto-maximize false
gsettings set org.gnome.shell.keybindings toggle-application-view "[]"
gsettings set org.gnome.shell.keybindings focus-active-notification "[]"

gsettings set org.gnome.shell.keybindings switch-to-application-1 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-2 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-3 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-4 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-5 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-6 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-7 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-8 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-9 "[]"
