# Loads the shared env + PATH layer into zsh / bash (fish: ~/.config/fish/conf.d/00-shared-shell.fish).
# Sourced from ~/.zshenv (every zsh, incl. non-interactive), ~/.zprofile and ~/.bashrc. Idempotent.

_dotfiles_load_env() {
  # zsh: unmatched globs (profile-*) must expand to nothing instead of erroring
  [ -n "${ZSH_VERSION:-}" ] && setopt localoptions nullglob

  local dir os f line dirs d p
  dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
  case "${OSTYPE:-$(uname -s)}" in
    darwin* | Darwin*) os=darwin ;;
    linux* | Linux*) os=linux ;;
    *) os=other ;;
  esac

  # env vars: once per session; child shells inherit the exported values
  if [ -z "${DOTFILES_ENV_LOADED:-}" ]; then
    for f in "$dir/env.sh" "$dir/env.$os.sh" "$dir"/profile-*/env.sh "$dir"/profile-*/env."$os".sh; do
      [ -f "$f" ] && . "$f"
    done
    export DOTFILES_ENV_LOADED=1
  fi

  # PATH (every time: login shells / path_helper may have reordered it):
  # collect dirs in priority order, then prepend them in reverse
  dirs=""
  for f in "$dir/paths" "$dir/paths.$os"; do
    [ -f "$f" ] || continue
    while IFS= read -r line || [ -n "$line" ]; do
      case "$line" in '' | '#'*) continue ;; esac
      case "$line" in '~/'*) line="$HOME/${line#\~/}" ;; esac
      dirs="$line
$dirs"
    done < "$f"
  done
  for d in "$dir/bin" "$dir"/profile-*/bin; do
    dirs="$d
$dirs"
  done
  # dirs is now lowest priority first; prepending in that order leaves the highest first
  while IFS= read -r d; do
    [ -n "$d" ] && [ -d "$d" ] || continue
    p=":$PATH:"
    # loop: a single ${//} pass misses adjacent duplicates (:d:d:)
    while [ "$p" != "${p//:"$d":/:}" ]; do p="${p//:"$d":/:}"; done
    p="${p#:}"
    p="${p%:}"
    PATH="$d${p:+:$p}"
  done <<EOF2
$dirs
EOF2
  export PATH
}
_dotfiles_load_env
unset -f _dotfiles_load_env
