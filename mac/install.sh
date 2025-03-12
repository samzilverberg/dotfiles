#!/bin/sh

THISDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source "$(dirname $THISDIR)/common_functions.sh"

if [[ $(id -u) -eq 0 ]] ; then echo "Please DONT run as root, no SUDO" ; exit 1 ; fi

username=$(logname) || $(whoami)
echo "running as: $username"

ask_sudo_access

# installing brew. this will automatically install xcode dev tools
# xcode-select --install  
if command -v "brew" >/dev/null 2>&1; then
  echo "updating brew"
  brew update
  brew doctor
else
  echo "installing brew"
  printf "\n" | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

clone_dotfiles_repo

brew_install() {
  brew install "$1"
}

brew_cask_install() {
  brew install --cask "$1"
}

# fnm is a replacement for nvm
brew_packages="""
git
gnupg2
wget
httpie
jq
fish
fisher
starship
zoxide
zsh
mise
bat
eza
the_silver_searcher
pinentry-mac
gopass
coreutils
ffmpeg
yt-dlp
homebrew/cask-fonts/font-meslo-lg-nerd-font:homebrew/cask-fonts
kubernetes-cli
h9s
helm
awscli
"""

for PKG in $brew_packages; do {
  if echo "$PKG" | grep ":"; then
    TAP=${PKG#*:}
    PKG=${PKG%%:*}
    brew tap "$TAP"
  fi
  brew_install "$PKG"
}; done


# fzf
command -v fzf >/dev/null 2>&1 || {
  brew_install fzf
  $(brew --prefix)/opt/fzf/install
}


brew_cask_packages="""
1password
1password-cli
iterm2
firefox
google-chrome
bettertouchtool
docker
dropbox
font-hack-nerd-font
karabiner-elements
obsidian
qlmarkdown
qlstephen
qlcolorcode
quicklook-json
raycast
shottr
spotify
syncthing
veracrypt
virtualbox
visual-studio-code
webstorm
zoom
google-cloud-sdk
"""
# cscreen # if there are probs with performance on external monitor

for PKG in $brew_cask_packages; do {
  if echo "$PKG" | grep ":"; then
    TAP=${PKG#*:}
    PKG=${PKG%%:*}
    brew tap "$TAP"
  fi
  brew_cask_install "$PKG"
}; done

# java using asdf
if command -v "mise" >/dev/null 2>&1; then
  echo "using mise to install java"
  mise use -g java@openjdk-21
  sudo mkdir -p /Library/Java/JavaVirtualMachines/openjdk-21.jdk
  sudo ln -s ~/.local/share/mise/installs/java/openjdk-21/Contents /Library/Java/
fi

# set fish as shell default shell, need to logout -> login after
echo $SHELL | grep -q -v zsh && chsh -s $(which fish) && echo "LOGOUT+LOGIN is required for zsh to work"
! grep -q fish /etc/shells && echo $(which fish) | sudo tee -a /etc/shells
echo "TO finish configuring fish as default shell you will need to
goto Users and Groups -> unlock -> ctrl + click username -> advanced ->
then put the full path of fish in \"Login shell\""

## symlinks files
cd "$THISDIR/files" 
FILESDIR=$(pwd)
cd $FILESDIR; find . -type d | cut -c 3- | xargs -n1 -I{} mkdir -p $HOME/{}
cd $FILESDIR; find . -type f | cut -c 3- | xargs -n1 -I{} ln -svf $(pwd)/{} $HOME/{}
cd $FILESDIR; find . -type l | cut -c 3- | xargs -n1 -I{} ln -svf $(pwd)/{} $HOME/{}
echo "finished symlinking config"
cd "$THISDIR"


# un-quarantine quicklook plugins
xattr -cr  ~/Library/QuickLook/QL*.qlgenerator

"$THISDIR/macos_settings.sh"