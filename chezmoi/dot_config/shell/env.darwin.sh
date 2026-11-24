# macOS only. Same syntax rules as env.sh (sourced by fish and POSIX shells).

# static equivalent of `brew shellenv` (no fork on every shell start)
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"

export PNPM_HOME="$HOME/Library/pnpm"
