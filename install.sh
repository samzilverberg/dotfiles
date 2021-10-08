#!/bin/sh

readonly arch=$(uname)
if [ "$arch" = "Darwin" ]; then
  echo "setting up mac"
  mac/install.sh
elif [ "$arch" = "Linux" ]; then
  echo "setting up linux"
  arch/install.sh
else
  echo "unknown arch: \"$arch\" , check uname output and correct script."
fi