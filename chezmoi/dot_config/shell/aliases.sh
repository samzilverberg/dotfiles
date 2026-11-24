# Shared aliases for interactive fish, zsh and bash.
#
# Sourced as-is by fish AND POSIX shells, so only this form:   alias name='command args'
# Anything needing shell logic: a script in ./bin (works everywhere, incl. agents), or shell-specific config.

alias vi='nvim'
alias vim='nvim'
alias cdd='cdi'

alias gst='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gd.='git diff .'
alias gcb='git checkout -b'
alias gl='git log'
alias gl.='git log .'

alias kc='kubectl'

alias dev='cd ~/dev'

# the silver searcher has no config file
alias ag='ag --ignore-dir node_modules --ignore-dir build --ignore tsconfig.build.tsbuildinfo'
