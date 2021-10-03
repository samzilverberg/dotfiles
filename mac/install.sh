#!/bin/sh

if [[ $(id -u) -eq 0 ]] ; then echo "Please DONT run as root, no SUDO" ; exit 1 ; fi

username=$(logname) || $(whoami)
echo "running as: $username"


xcode-select --install

if command -v "brew" >/dev/null 2>&1; then
  echo "updating brew"
  brew update
  brew doctor
else
  echo "installing brew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi



brew install git
brew install gnupg2
brew install wget
brew install httpie
brew install jq
brew install youtube-dl
brew install zsh
brew install antigen
brew install fzf
$(brew --prefix)/opt/fzf/install

brew install cloudfoundry/tap/cf-cli

brew install pinentry-mac
brew install gopass

brew install sbt
brew install ruby-build
brew install rbenv
brew install gradle
brew install maven
brew install jenv
brew install nvm

mkdir -p ~/.nvm

brew install java8 --cask
brew install java11 --cask
brew install iterm2 --cask
brew install firefox-developer-edition --cask

brew install android-platform-tools --cask
brew install google-chrome-dev --cask

brew install docker --cask
brew install dropbox --cask
brew install jing --cask
brew install lastpass --cask
brew install rambox --cask
brew install spotify --cask
brew install qlmarkdown --cask
brew install qlstephen --cask
brew install veracrypt --cask
brew install virtualbox --cask

brew install visual-studio-code --cask
brew install intellij-idea-ce --cask


# bitdefender! from site? pkg? cask?


# can i remove apps from dock that i never use?


# set zsh as shell default shell, need to logout -> login after
echo $SHELL | grep -v zsh && chsh -s $(which zsh)

## symlinks files
cd files 
THISDIR=$(pwd)
cd $THISDIR; find . -type d | cut -c 3- | xargs -n1 -I{} mkdir -p $HOME/{}
cd $THISDIR; find . -type f | cut -c 3- | xargs -n1 -I{} ln -svf $(pwd)/{} $HOME/{}
cd $THISDIR; find . -type l | cut -c 3- | xargs -n1 -I{} ln -svf $(pwd)/{} $HOME/{}
echo "finished symlinking config"
cd -