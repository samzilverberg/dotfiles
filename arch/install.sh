#!/bin/sh

# setup script will install all the packages & programs i like to use
# run this as sudo

error() { clear; printf "ERROR:\\n%s\\n" "$1"; exit;}

username=$(logname) || $(who am i)
echo "running as: $username"

# pacman -Sy ||  error "Are you sure you're running this as the root user? Are you sure you're using an Arch-based distro? ;-) Are you sure you have an internet connection? Are you sure your Arch keyring is updated?"
# pacman --noconfirm -Sy archlinux-keyring || error "Error automatically refreshing Arch keyring. Consider doing so manually."

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

# kill dropbox in case its pre-installed, otherwise install will hang
killall dropbox

sudo -u "$username" yay -Sy
sudo -u "$username" yay -S --noconfirm --sudoloop --needed -q \
  "boostnote-bin"\
  "visual-studio-code-bin" \
  "jdk11-openjdk"\
  "jdk8-openjdk"\
  "firefox-developer-edition"\
  "docker"\
  "docker-compose"\
  "dropbox"\
  "nvm"\
  "sbt"\
  "ruby-build"\
  "rbenv"\
  "gnupg"\
  "gopass"\
  "rambox-bin"\
  "intellij-idea-ultimate-edition"

  #"firefox-developer-edition-firefox-symlink-latest"\
# remove firefox?

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

## shared config setup
cd ../config
. ./setup.sh
cd -