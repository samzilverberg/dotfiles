#!/bin/sh

ask_sudo_access() {
  echo "Please auth sudo access"
  sudo -k
  sudo echo "sudo auth success"
  while true ; do sudo -n true ; sleep 60 ; kill -0 "$$" || exit ; done 2>/dev/null &
}

clone_dotfiles_repo() {
  #todo switch to git@ based url only if private key is detected, can also tests against it "git ssh repo?"
  #todo add remove (or switch remote) if priv key is available? so we can git push without password?
  #local readonly repository="git@github.com:samzilverberg/dotfiles.git"
  local readonly repository="https://github.com/samzilverberg/dotfiles.git"
  local readonly clone_target="${HOME}/dotfiles"
  if [ -d "$clone_target" ] && [ -n '$(cat "$clone_target/.git/config" | grep "$repository")' ]; then
    cd "${clone_target}"
    git status
    cd -
  else
    git clone "${repository}" "${clone_target}"
  fi
}