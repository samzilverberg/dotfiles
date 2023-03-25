#!/bin/sh

export EDITOR=/usr/bin/nano

echo "$0" | grep "bash$" >/dev/null && [ -f ~/.bashrc ] && source "$HOME/.bashrc"
#echo "$0" | grep "zsh$" >/dev/null && [ -f ~/.zshrc ] && source "$HOME/.zshrc"
