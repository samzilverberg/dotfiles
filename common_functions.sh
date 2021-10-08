#!/bin/sh

ask_sudo_access() {
  echo "Please auth sudo access"
  sudo -k
  sudo echo "sudo auth success"
  while true ; do sudo -n true ; sleep 60 ; kill -0 "$$" || exit ; done 2>/dev/null &
}

clone_dotfiles_repo() {
  local readonly repository="https://github.com/samzilverberg/dotfiles.git"
  local readonly clone_target="${HOME}/dotfilestest"
  if [ -d "$clone_target" ] && [ -n '$(cat "$clone_target/.git/config" | grep "$repository")' ]; then
    cd "${clone_target}"
    git status
    cd -
  else
    git clone "${repository}" "${clone_target}"
  fi
}