#!/bin/sh


if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

if [ -f $(brew --prefix)/etc/bash_completion ]; then
   . $(brew --prefix)/etc/bash_completion
fi

[ -f ~/.aliases ] && source "$HOME/.aliases"

export LC_ALL=en_US.UTF-8

