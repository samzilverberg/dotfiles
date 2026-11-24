# Loads the shared shell layer (~/.config/shell, also used by zsh/bash) into fish.
# Runs for every fish, incl. non-interactive. POSIX twin: ~/.config/shell/load-env.sh

set -l shell_dir ~/.config/shell
set -l os (uname -s | string lower)

for f in $shell_dir/env.sh $shell_dir/env.$os.sh $shell_dir/profile-*/env.sh $shell_dir/profile-*/env.$os.sh
    test -f $f; and source $f
end

# PATH: collect dirs in priority order, prepend in reverse so the first listed ends up first
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
