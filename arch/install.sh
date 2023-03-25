#!/bin/sh

set -euo pipefail

# setup script will install all the packages & programs i like to use
# run this as sudo

if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi

error() { clear; printf "ERROR:\\n%s\\n" "$1"; exit;}

username=$(logname) || $(who am i)
echo "====================="
echo "running as: $username"
echo "====================="
sleep 2;

pacman -Sy ||  error "Are you sure you're running this as the root user? Are you sure you're using an Arch-based distro? ;-) Are you sure you have an internet connection? Are you sure your Arch keyring is updated?"
pacman --noconfirm -Sy archlinux-keyring || error "Error automatically refreshing Arch keyring. Consider doing so manually."
#pacman --noconfirm -Sy base-devel

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 30; kill -0 "$$" || exit; done 2>/dev/null &

if ! command -v "yay" >/dev/null 2>&1; then
    echo "Installing yay: the AUR package helper"
    sudo -i -u "$username" bash << EOF
mkdir /tmp/yay
cd /tmp/yay || exit
wget https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay -O PKGBUILD
makepkg --syncdeps --install --noconfirm --clean
cd -  || exit
rm -rf /tmp/yay
EOF
else
    echo "skipping: yay"
fi

if ! command -v "yay" >/dev/null 2>&1; then
    echo "failed to install yay, exiting"
    exit 1
fi

sudo -u "$username" yay -Sy
sudo -u "$username" yay -S --noconfirm --sudoloop --needed -q \
  "boostnote-bin"\
  "visual-studio-code-bin" \
  "firefox"\
  "docker"\
  "docker-compose"\
  "fnm-bin"\
  "sbt"\
  "ruby-build"\
  "rbenv"\
  "gnupg"\
  "gopass"\
  "rambox-bin"\
  "intellij-idea-ultimate-edition"\
  "zsh"\
  "fish"\
  "veracrypt"\
  "lutris"

# lutris deps for intel nuc with intel graphics
# sudo pacman -S lib32-mesa
# sudo pacman -S vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
# sudo pacman -Sy wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader cups samba

# lutris deps for intel nuc with radeon graphics
# vulkan drivers
# sudo pacman -S lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
# battle.net deps
# sudo pacman -S lib32-gnutls lib32-libldap lib32-libgpg-error lib32-sqlite lib32-libpulse
# wine deps
# sudo pacman -S wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader



if [ -f /etc/pamac.conf ]; then
  sed -i "s@RefreshPeriod = 6@RefreshPeriod = 24@" /etc/pamac.conf
  sed -i "s@#RemoveUnrequiredDeps@RemoveUnrequiredDeps@" /etc/pamac.conf
  sed -i "s@#EnableAUR@EnableAUR@" /etc/pamac.conf
  sed -i "s@#CheckAURUpdates@CheckAURUpdates@" /etc/pamac.conf
  sed -i "s@#CheckAURVCSUpdates@CheckAURVCSUpdates@" /etc/pamac.conf
fi

if command -v "archlinux-java" >/dev/null 2>&1; then
  echo "archlinux-java found, will check for missing versions"
  archlinux-java status
  archlinux-java status | [[ ! $(grep java-11) ]] && sudo -u "$username" yay -S --noconfirm "jdk11-openjdk"
  archlinux-java status | [[ ! $(grep java-8) ]] && sudo -u "$username" yay -S --noconfirm "jdk8-openjdk"
else
  echo "archlinux-java not found, installing java from scratch"
  sudo -u "$username" yay -S --noconfirm --sudoloop --needed -q \
    "jdk11-openjdk"\
    "jdk8-openjdk"
fi

#use fish and fisher (need to logout->login afterwards)
chsh -s $(which fish) "$username"
command -v fisher >/dev/null 2>&1 && {
  curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
}

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
# mkdir -p /mnt/Dropbox
# chown samz:samz /mnt/Dropbox
#append to /etc/fstab
# TODO put credentials file in gopass, use gopass to put secret to file
#//synosam/Dropbox /mnt/Dropbox cifs noauto,x-systemd.automount,x-systemd.device-timeout=30,credentials=/home/samz/shared-dir-dropbox-creds,uid=samz,gid=samz,vers=1.0,_netdev 0 0

# follow with this to remount (without rebooting)
# systemctl daemon-reload
# mount -a


# TODO bluetooth auto power on on startup
#https://wiki.archlinux.org/index.php/Bluetooth#Auto_power-on_after_boot
#/etc/bluetooth/main.conf
#[Policy]
#AutoEnable=true

# set keyboard layouts for x11 and console 
# english with euro symbols on alt-gr and hebrew
localectl set-x11-keymap eu,il pc104 , grp:alt_shift_toggle

# enable automatic clock update (reboot required to take affect)
systemctl enable ntpd
systemctl enable ntpdate  

# printer requirements
# https://wiki.manjaro.org/index.php/Printing
yay -Sy manjaro-printer
gpasswd -a $username sys
sudo systemctl enable --now cups.service
sudo systemctl enable --now cups.socket
sudo systemctl enable --now cups.path

source gnome_settings.sh


## shared config setup
# cd ../config
# . ./setup.sh
# cd -
