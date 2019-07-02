#!/bin/sh

xcode-select --install

#/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor

brew install git
brew install gnupg2
brew cask install iterm2
brew cask install osxfuse
brew cask install qlmarkdown
brew cask install qlstephen
brew install bash-completion
echo "[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion" >> ~/.bash_profile
brew install httpie
brew install nvm
mkdir -p ~/.nvm
echo "export NVM_DIR=\"$HOME/.nvm\"" >> ~/.bash_profile
echo "source \"/usr/local/opt/nvm/nvm.sh\"" >> ~/.bash_profile
. "$HOME/.bash_profile"
nvm install node && nvm alias default node

# cf-cli needs tap added first, look online for command and add it here
#brew install cf-cli

brew tap justwatchcom/gopass
brew install justwatchcom/gopass/gopass


brew cask install google-chrome
brew cask install caskroom/versions/java8
brew install sbt
brew cask install veracrypt
brew install rbenv
brew install pass
brew cask install docker
brew cask install dropbox
brew cask install franz
brew cask install battle-net
brew cask install visual-studio-code

# bitdefender! from site? pkg? cask?


# can i remove apps from dock that i never use?
