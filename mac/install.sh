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
youtube-dl
fish
fisher
starship
zsh
asdf
fnm
exa
the_silver_searcher
pinentry-mac
gopass
coreutils
ffmpeg
youtube-dl
homebrew/cask-fonts/font-meslo-lg-nerd-font:homebrew/cask-fonts
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
karabiner-elements
obsidian
docker
dropbox
syncthing
qlmarkdown
qlstephen
qlcolorcode
quicklook-json
ferdium-nightly:ferdium/ferdium
veracrypt
virtualbox
visual-studio-code
intellij-idea-ce
android-commandlinetools
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
if command -v "asdf" >/dev/null 2>&1; then
  echo "using asdf to install java"
  asdf plugin add java https://github.com/halcyon/asdf-java.git
  asdf install java openjdk-17.0.2
  asdf global java openjdk-17.0.2
  ## todo add to .asdfrc java_macos_integration_enable = yes
fi

# bitdefender! from site? pkg? cask?


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