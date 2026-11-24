#!/bin/sh
# Bootstrap a new machine (macOS or Linux):
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/samzilverberg/dotfiles/master/install.sh)"
# Optional: DOTFILES_PROFILES=payzen to pick profiles without the prompt.
set -eu
bindir="$HOME/.local/bin"
if ! command -v chezmoi >/dev/null 2>&1 && [ ! -x "$bindir/chezmoi" ]; then
  sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$bindir"
fi
chezmoi=$(command -v chezmoi || echo "$bindir/chezmoi")
exec "$chezmoi" init --apply --source "$HOME/dotfiles" samzilverberg
