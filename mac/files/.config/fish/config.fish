if status is-interactive
    # Commands to run in interactive sessions can go here
end

# cancel the fish greeting
function fish_greeting
end

# added "a" flag, fish default to just "lh"
function ll --wraps=ls --description 'List contents of directory using long format'
    ls -lhaG $argv
end

alias gst="git status"
alias gds="git diff --staged"
#alias gd="git diff"

function kcn
  kubectl config set-context (kubectl config current-context) --namespace "$argv"
end

# abbreviations: after pressing enter or space it expands to the full text of the abbr
# https://fishshell.com/docs/current/interactive.html#abbreviations
abbr -a gd git diff
abbr -a kc kubectl

fnm env | source

# https://starship.rs/config/
# config is in ~/.config/starship.toml
starship init fish | source
