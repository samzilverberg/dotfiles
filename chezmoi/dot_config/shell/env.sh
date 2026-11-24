# Shared environment for ALL shells (fish, zsh, bash), incl. non-interactive ones (agents, IDEs).
#
# Sourced as-is by fish AND by POSIX shells, so keep to one syntax both understand:
#   export NAME="value"      ($HOME is fine; no $(...), no [ ], no if/fi, no PATH here)
# PATH entries go in ./paths*. OS specific vars in ./env.<os>.sh. Profile vars in ./profile-<name>/env.sh

export EDITOR="nvim"
export VISUAL="nvim"
export LANG="en_US.UTF-8"

export BAT_THEME="Monokai Extended"
export EZA_COLORS="da=1;34:di=1;34"

export BUN_INSTALL="$HOME/.bun"
