# Fix for `na`/`ni` (Karibash/ni.fish via fisher) package-manager detection.
#
# Bug: _na_get_package_manager_name in functions/_na.fish uses
#   `string match --entire -r "packageManager"` which grabs the FIRST line
#   containing "packageManager". In a package.json with a devEngines block:
#       "devEngines": { "packageManager": { "name": "pnpm" ... } }
#       ...
#       "packageManager": "pnpm@10.x"
#   it matches the devEngines `"packageManager": {` line instead of the
#   top-level string, producing: na: Unknown packageManager: ""packageManager": {
#
# This lives in conf.d/ (auto-sourced at startup) instead of functions/ so it
# is NOT clobbered by `fisher update` (which only rewrites functions/_na.fish).
# We source _na.fish first so na's helper functions exist; because _na is then
# already defined, fish never lazy-autoloads _na.fish again and our override of
# _na_get_package_manager_name stands.

set -l __na_src $__fish_config_dir/functions/_na.fish
test -f "$__na_src"; or exit 0
source "$__na_src"

function _na_get_package_manager_name --argument-names path
    set -l lock_file_path (_na_find_lock_file $path)
    set -l deno_json_path (_na_find_deno_json $path)
    set -l package_json_path (test -n "$lock_file_path" && _na_find_package_json $lock_file_path || _na_find_package_json $path)

    if test -n "$deno_json_path"
        echo deno
        return
    end

    if test -n "$package_json_path"
        set -l valid npm yarn pnpm bun
        set -l name

        # 1. top-level string form: "packageManager": "pnpm@10.x"
        #    regex requires the opening quote after the colon, so the
        #    devEngines `"packageManager": {` line never matches.
        set -l s (string match -rg '"packageManager"\s*:\s*"([^"@]+)' < $package_json_path)
        if test -n "$s"
            set name $s[1]
        else
            # 2. devEngines.packageManager.name form (no top-level string)
            set -l d (string match -rg '"name"\s*:\s*"([^"]+)"' < $package_json_path)
            if test -n "$d"
                set name $d[1]
            end
        end

        if test -n "$name"
            if contains $name $valid
                echo $name
                return 0
            end
            echo "na: Unknown packageManager: \"$name\"" >&2
            return 1
        end
    end

    if test -n "$lock_file_path"
        switch (basename $lock_file_path)
            case "deno.lock"
                echo deno
            case "bun.lockb" "bun.lock" "bunfig.toml"
                echo bun
            case "yarn.lock"
                echo yarn
            case "pnpm-lock.yaml"
                echo pnpm
            case "package-lock.json" "npm-shrinkwrap.json"
                echo npm
            case '*'
                echo "Unknown lock file: \"$lock_file_path\"" >&2
        end
        return
    end

    # No package manager detected: do NOT pop the fuzzy-finder picker, stay silent.
    return 1
end
