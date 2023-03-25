#!/bin/sh

readonly arch=$(uname)
if [ "$arch" = "Darwin" ]; then
  echo "setting up mac"
  mac/install.sh
elif [ "$arch" = "Linux" ]; then
  echo "setting up linux, checking which distro"
  if [ -f /etc/os-release ] && grep -q Fedora /etc/os-release ; then
    echo "setting up fedora"
    fedora/install.sh
  else
    echo "setting up arch/manjaro"
    arch/install.sh
  fi
  
else
  echo "unknown arch: \"$arch\" , check uname output and correct script."
fi