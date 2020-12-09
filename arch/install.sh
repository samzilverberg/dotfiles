#!/bin/sh

# setup script will install all the packages & programs i like to use
# run this as sudo

error() { clear; printf "ERROR:\\n%s\\n" "$1"; exit;}

username=$(logname) || $(who am i)
echo "running as: $username"

pacman -Sy ||  error "Are you sure you're running this as the root user? Are you sure you're using an Arch-based distro? ;-) Are you sure you have an internet connection? Are you sure your Arch keyring is updated?"
pacman --noconfirm -Sy archlinux-keyring || error "Error automatically refreshing Arch keyring. Consider doing so manually."

# Keep-alive: update existing `sudo` time stamp until script has finished
#while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if ! command -v "yay" >/dev/null 2>&1; then
    echo "Installing yay: the AUR package helper"
    mkdir /tmp/yay
    cd /tmp/yay || exit
    wget https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay -O PKGBUILD
    makepkg --syncdeps --install --noconfirm --clean
    cd -  || exit
    rm -rf /tmp/yay
else
    echo "skipping: yay"
fi

sudo -u "$username" yay -Sy
sudo -u "$username" yay -S --noconfirm --sudoloop --needed -q \
  "boostnote-bin"\
  "visual-studio-code-bin" \
  "firefox-developer-edition"\
  "docker"\
  "docker-compose"\
  "nvm"\
  "sbt"\
  "ruby-build"\
  "rbenv"\
  "gnupg"\
  "gopass"\
  "rambox-bin"\
  "intellij-idea-ultimate-edition"\
  "zsh"\
  "veracrypt"\
  "lutris"

# lutris deps
# sudo pacman -S lib32-mesa
# sudo pacman -S vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
# sudo pacman -Sy wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader cups samba
# if you want remote access viz x2go install these:
  # "x2goserver"\
  # "xorg-host"\
  # "xorg-auth"

  #"firefox-developer-edition-firefox-symlink-latest"\
# remove firefox?

if command -v "archlinux-java" >/dev/null 2>&1; then
  echo "archlinux-java found, will check for missing versions"
  archlinux-java status
  archlinux-java status | grep java-11 && sudo -u "$username" yay -S --noconfirm "jdk11-openjdk"
  archlinux-java status | grep java-8 && sudo -u "$username" yay -S --noconfirm "jdk8-openjdk"
else
  echo "archlinux-java not found, installing java from scratch"
  sudo -u "$username" yay -S --noconfirm --sudoloop --needed -q \
    "jdk11-openjdk"\
    "jdk8-openjdk"
fi

#use zsh by default if not set already (will only work after logout->login)
sudo -i -u $username /bin/sh -c "echo \"$SHELL\" | grep -v zsh && chsh -s $(which zsh)"

#  nvm install node 10 and latest
echo "installing nvm and node for user"
NVM_DIR="/home/$username/.nvm"
. /usr/share/nvm/init-nvm.sh
nvm install v10
nvm install node
chown -R samz:samz $NVM_DIR/

## symlinks specific arch config
sudo -i -u $username /bin/sh -c "rm -rf /home/$username/configbak && mkdir -p /home/$username/configbak"
sudo -i -u $username /bin/sh -c "cp -r /home/$username/.config/* /home/$username/configbak/"
cd files 
THISDIR=$(pwd)
sudo -i -u $username /bin/sh -c "cd $THISDIR; find . -type d | cut -c 3- | xargs -n1 -I{} mkdir -p /home/$username/{}"
sudo -i -u $username /bin/sh -c "cd $THISDIR; find . -type f | cut -c 3- | xargs -n1 -I{} ln -sfv $(pwd)/{} /home/$username/{}"
sudo -i -u $username /bin/sh -c "cd $THISDIR; find . -type l | cut -c 3- | xargs -n1 -I{} ln -sfv $(pwd)/{} /home/$username/{}"
echo "finished symlinking config"
cd -

# dropbox folder from synology nas
# https://wiki.archlinux.org/index.php/Samba#Automatic_mounting
# enable some services for auto mounting after restart
# systemctl enable systemd-networkd-wait-online.service
# systemctl enable NetworkManager-wait-online.service
#append to /etc/fstab
# TODO put credentials file in gopass, use gopass to put secret to file
#//synosam/Dropbox /mnt/Dropbox cifs noauto,x-systemd.automount,x-systemd.device-timeout=30,credentials=/home/samz/shared-dir-dropbox-creds,uid=samz,gid=samz,vers=1.0,_netdev 0 0


# TODO bluetooth auto power on on startup
#https://wiki.archlinux.org/index.php/Bluetooth#Auto_power-on_after_boot
#/etc/bluetooth/main.conf
#[Policy]
#AutoEnable=true

# set keyboard layouts for x11 and console 
# english with euro symbols on alt-gr and hebrew
localectl set-x11-keymap eu,il pc104 , grp:alt_shift_toggle

# if using gnome, enable all keyboard inputs (otheruse EurKey layout is not available)
if [[ "$DESKTOP_SESSION" == "gnome" ]]; then
  gsettings set org.gnome.desktop.input-sources show-all-sources true
fi

## shared config setup
cd ../config
. ./setup.sh
cd -
