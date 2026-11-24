# Interactive layer for zsh / bash: shared aliases (+ profile aliases) and a few POSIX-only extras.
# Sourced from ~/.zshrc and ~/.bashrc. fish gets the same aliases via conf.d/00-shared-shell.fish.

_dotfiles_load_interactive() {
  [ -n "${ZSH_VERSION:-}" ] && setopt localoptions nullglob
  local dir f
  dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
  for f in "$dir/aliases.sh" "$dir"/profile-*/aliases.sh; do
    [ -f "$f" ] && . "$f"
  done
}
_dotfiles_load_interactive
unset -f _dotfiles_load_interactive

# POSIX-only aliases (syntax fish can't share)
alias ..='cd ..'
alias gcm='git checkout "$(git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@")"'
if ls --color=auto -d . >/dev/null 2>&1; then
  alias ls='ls -ahp --color=auto' # GNU
else
  alias ls='ls -ahGp' # BSD / macOS
fi
alias ll='ls -l'
command -v bat >/dev/null 2>&1 || { command -v batcat >/dev/null 2>&1 && alias bat='batcat'; }

[ -t 0 ] && GPG_TTY="$(tty)" && export GPG_TTY
