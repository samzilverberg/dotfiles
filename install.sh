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
# fresh Mac: /usr/bin/git is only a stub until the Xcode command line tools are installed
# (Homebrew's installer does that later), so clone with chezmoi's built-in git
if [ "$(uname -s)" = Darwin ] && ! xcode-select -p >/dev/null 2>&1; then
  set -- --use-builtin-git=true
fi
exec "$chezmoi" init --apply "$@" --source "$HOME/dotfiles" samzilverberg
