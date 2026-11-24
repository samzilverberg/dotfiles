# fish config. Shared env / PATH / aliases (also used by zsh & bash) come from ~/.config/shell,
# loaded by conf.d/00-shared-shell.fish before this file. Profile extras: ~/.config/shell/profile-*/

# cancel the fish greeting
function fish_greeting
end

if not command -q bat; and command -q batcat # Debian/Ubuntu name
    alias bat=batcat
end
if command -q bat
    function cat --wraps=bat --description 'bat wrapper for cat'
        bat $argv
    end
end

alias gcm="git checkout (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"

# abbreviations: after pressing enter or space it expands to the full text of the abbr
# https://fishshell.com/docs/current/interactive.html#abbreviations
abbr -a gd git diff
abbr -a gf git fetch
abbr -a gp "git pull --prune"
abbr -a gpu "git push -u origin (git branch --show-current)"
abbr -a gpud "git push -d origin"

# https://github.com/ryoppippi/fish-na
# if interactively writing npm, will correct to the package manager detected in PWD
abbr -a npm -f _na
abbr -a pnpm -f _na
alias npmm="npm" #in case you actually want to force run npm
alias pnpmm="pnpm" #in case you actually want to force run pnpm

# ni: fisher alternatitve for @antfu/ni, detects package manager to use
# https://github.com/Karibash/ni.fish
abbr -a nrtit "ni run test ./test/it"
abbr -a nrte "ni run test ./test/e2e"
abbr -a nrb "ni run build"
abbr -a nrt "ni run test"
abbr -a nrbt "ni run build && ni run test"
abbr -a nribt "ni ci && ni run build && ni run test"
abbr -a nibt "ni ci && ni run build && ni run test"
abbr -a npmv "npm version"

# mise: update env on prompt render only (after cd), not on every PWD-variable touch.
# keeps auto directory-switching, drops the redundant per-startup hook-env calls.
set -gx mise_fish_mode disable_arrow

# cache a tool's init script; regenerate only when the binary is newer than the cache.
# avoids spawning the tool (slow) on every shell start.
function __cached_init --description 'cache tool init script; regen when binary newer'
    set -l name $argv[1]
    set -l cmd $argv[2..-1]
    set -l binpath (command -v $cmd[1])
    test -z "$binpath"; and return
    set -l cachefile ~/.cache/fish/$name.init.fish
    if not test -f $cachefile; or test $binpath -nt $cachefile
        mkdir -p (path dirname $cachefile)
        $cmd >$cachefile
    end
    source $cachefile
end

if status is-interactive
    # zoxide is a smarter cd command, inspired by z and autojump.
    __cached_init zoxide zoxide init --cmd=cd fish

    # mise: brew's fish package auto-activates it (vendor_conf.d); elsewhere activate here
    if not functions -q __mise_env_eval; and command -q mise
        __cached_init mise mise activate fish
    end

    # helps gpg understand what the interactive terminal is so ncurses properly comes up for password prompts
    set -gx GPG_TTY (tty)

    # https://starship.rs/config/  config is in ~/.config/starship.toml
    __cached_init starship starship init fish --print-full-init
end
