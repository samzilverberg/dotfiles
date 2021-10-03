#!/bin/sh

USER=$(logname) || $(who am i)
HOMEDIR="/home/$USER"

case "$(uname)" in
  "Linux" ) 
    ISLINUX=true
    ;;
  "Darwin" )
    ISMAC=true
    ;;
  *) 
    ISLINUX=false
    ;;
esac

echo "is linux? $ISLINUX"


# make sure to run as user and not as root
sudo -i -u $USER /bin/sh << eof
# gitconfigf file
ln -sf "$(pwd)/gitconfig" ~/.gitconfig
# git global ignore file
ln -sf "$(pwd)/.gitignore_global" ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
# git gpg sign commits
git config --global user.signingkey 161C9E16C58AC0AA
git config --global commit.gpgsign true

# gpg config (for version >= 2.1)
mkdir -p ~/.gnupg
ln -sf "$(pwd)/gpg-agent.conf" ~/.gnupg/gpg-agent.conf


if [ "$ISLINUX" = true ]; then
  # visual studio code
  mkdir -p ~/.config/Code/User
  ln -sf "$(pwd)/settings_vsc.json" ~/.config/Code/User/settings.json

  # mpv
  mkdir -p ~/.config/mpv
  ln -sf "$(pwd)/mpv.conf" ~/.config/mpv/mpv.conf
else
  # mac
  # visual studio code
  mkdir -p $HOME/Library/Application\ Support/Code/User
  ln -sf "$(pwd)/settings_vsc.json" $HOME/Library/Application\ Support/Code/User/settings.json  

  #gitaware prompt
  mkdir -p ~/.bash
  cp -r git-aware-prompt ~/.bash/
fi
eof



