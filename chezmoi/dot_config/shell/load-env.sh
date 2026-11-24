# Loads the shared env + PATH layer into zsh / bash (fish: ~/.config/fish/conf.d/00-shared-shell.fish).
# Sourced from ~/.zshenv (every zsh, incl. non-interactive), ~/.zprofile and ~/.bashrc. Idempotent.

_dotfiles_load_env() {
  # zsh: unmatched globs (profile-*) must expand to nothing instead of erroring
  [ -n "${ZSH_VERSION:-}" ] && setopt localoptions nullglob

  local dir os f line dirs d p
  dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
  case "$(uname -s)" in
    Darwin) os=darwin ;;
    Linux) os=linux ;;
    *) os=other ;;
  esac

  for f in "$dir/env.sh" "$dir/env.$os.sh" "$dir"/profile-*/env.sh "$dir"/profile-*/env."$os".sh; do
    [ -f "$f" ] && . "$f"
  done

  # PATH: collect dirs in priority order, then prepend them in reverse
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
    p="${p//:"$d":/:}"
    p="${p#:}"
    p="${p%:}"
    PATH="$d${p:+:$p}"
  done <<EOF
$dirs
EOF
  export PATH
}
_dotfiles_load_env
unset -f _dotfiles_load_env
