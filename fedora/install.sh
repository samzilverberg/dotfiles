#!/bin/sh

set -euo pipefail

THISDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$(dirname $THISDIR)/common_functions.sh"

# setup script will install all the packages & programs i like to use
# run this as sudo

if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run with sudo." >&2
   exit 1
fi

error() { clear; printf "ERROR:\\n%s\\n" "$1"; exit;}

username=$(logname) || $(who am i)
echo "====================="
echo "running as: $username"
echo "====================="
sleep 2;

dnf upgrade -y -q ||  error "could not dnf upgrade"
dnf update -y  -q ||  error "Are you sure you're running this as the root user? Are you sure you're using an Arch-based distro? ;-) Are you sure you have an internet connection?"
#pacman --noconfirm -Sy archlinux-keyring || error "Error automatically refreshing Arch keyring. Consider doing so manually."
#pacman --noconfirm -Sy base-devel


# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 30; kill -0 "$$" || exit; done 2>/dev/null &

dnf -y -q install dnf-plugins-core

dnf -y install \
  "util-linux-user"\
  "firefox"\
  "gnupg"\
  "zsh"\
  "fish"\
  "fzf"\
  "gnome-tweaks"\
  "youtube-dl"\
  "webp-pixbuf-loader"\
  "lutris"

# TODO "veracrypt"
curl -L -o /tmp/veracrypt-1.25.4-CentOS-8-x86_64.rpm https://launchpad.net/veracrypt/trunk/1.25.4/+download/veracrypt-1.25.4-CentOS-8-x86_64.rpm
sudo rpm -i /tmp/veracrypt-1.25.4-CentOS-8-x86_64.rpm

# gopass
dnf copr enable -y daftaupe/gopass
sudo dnf install gopass

# visual studio code vsc
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf check-update
sudo dnf install -y code

#docker
dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

dnf -y install docker-ce docker-ce-cli containerd.io

#^^ This command installs Docker, but it doesn’t start Docker. It also creates a docker group, however, it doesn’t add any users to the group by default.
# todo: add username to docker group

#sudo systemctl start docker

#fnm
curl -fsSL https://fnm.vercel.app/install | bash

# rpm fusion repo
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm


flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --noninteractive -y flathub md.obsidian.Obsidian

flatpak install --noninteractive -y flathub com.getferdi.Ferdi

# flat seal for managing permissions of flatpak apps
#https://flathub.org/apps/details/com.github.tchx84.Flatseal

echo "7"
#use fish and fisher (need to logout->login afterwards)
chsh -s $(which fish) "$username"
command -v fisher >/dev/null 2>&1 && {
  curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
}

echo "8"
## TODO check all this smlinking section
##   try to refacto to "common_functions.sh"
## symlinks files
cd "$THISDIR/files" 
FILESDIR=$(pwd)
cd $FILESDIR; find . -type d | cut -c 3- | xargs -n1 -I{} mkdir -p $HOME/{}
cd $FILESDIR; find . -type f | cut -c 3- | xargs -n1 -I{} ln -svf $(pwd)/{} $HOME/{}
cd $FILESDIR; find . -type l | cut -c 3- | xargs -n1 -I{} ln -svf $(pwd)/{} $HOME/{}
echo "finished symlinking config"
cd "$THISDIR"

"$THISDIR/gnome_settings.sh"

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
#localectl set-x11-keymap eu,il pc104 , grp:alt_shift_toggle

# enable automatic clock update (reboot required to take affect)
systemctl enable ntpd
systemctl enable ntpdate  
echo "9"
# printer requirements
# https://wiki.manjaro.org/index.php/Printing
gpasswd -a $username sys
sudo systemctl enable --now cups.service
sudo systemctl enable --now cups.socket
sudo systemctl enable --now cups.path
echo "10"
#source gnome_settings.sh


## shared config setup
# cd ../config
# . ./setup.sh
# cd -
