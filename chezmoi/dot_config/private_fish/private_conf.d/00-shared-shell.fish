# Loads the shared shell layer (~/.config/shell, also used by zsh/bash) into fish.
# Runs for every fish, incl. non-interactive. POSIX twin: ~/.config/shell/load-env.sh

# mise (must be set before brew's vendor_conf.d/mise-activate.fish, which sorts after this file):
# - interactive: update env on prompt render only (after cd), not on every PWD change
# - non-interactive (`fish -c`, scripts, agents): no activation; the shims dir on PATH is enough
set -g mise_fish_mode disable_arrow
status is-interactive; or set -g MISE_FISH_AUTO_ACTIVATE 0

set -l shell_dir ~/.config/shell
set -l os (uname -s | string lower)

# env vars: once per session; child shells inherit the exported values
if not set -q DOTFILES_ENV_LOADED
    for f in $shell_dir/env.sh $shell_dir/env.$os.sh $shell_dir/profile-*/env.sh $shell_dir/profile-*/env.$os.sh
        test -f $f; and source $f
    end
    set -gx DOTFILES_ENV_LOADED 1
end

# PATH (every shell: login shells / path_helper may have reordered it):
# collect dirs in priority order, prepend in reverse so the first listed ends up first
set -l dirs
for f in $shell_dir/paths $shell_dir/paths.$os
    test -f $f; or continue
    for line in (string match -rv '^\s*(#|$)' <$f)
        set -a dirs (string replace -r '^~/' "$HOME/" -- (string trim -- $line))
    end
end
set -a dirs $shell_dir/bin $shell_dir/profile-*/bin
for d in $dirs[-1..1]
    test -d $d; and fish_add_path --global --move --path $d
end

if status is-interactive
    for f in $shell_dir/aliases.sh $shell_dir/profile-*/aliases.sh $shell_dir/profile-*/config.fish
        source $f
    end
end
