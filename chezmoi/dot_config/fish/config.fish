if status is-interactive
    # Commands to run in interactive sessions can go here
end

# cancel the fish greeting
function fish_greeting
end


set -Ux EZA_COLORS "da=1;34:di=1;34"
set -U -x AWS_ECR_REGISTRY "936143655872.dkr.ecr.us-east-1.amazonaws.com"
set -U -x AWS_CDN_BUCKET "staging.static.payzen.com"
set -Ux BAT_THEME "Monokai Extended"

alias vi="nvim"
alias vim="nvim"
set -gx EDITOR nvim

alias cdd="cdi"

alias gst="git status"
alias gds="git diff --staged"
alias gd.="git diff ."
alias gcm="git checkout (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"
alias gcb="git checkout -b"
alias gl="git log"
alias gl.="git log ."

alias dev="cd ~/dev"
alias mono="cd ~/dev/mono/packages"
alias pzs="cd ~/dev/payzen_server"
alias servicing="cd ~/dev/payzen_servicing_server/packages"

# krew path: plugin manager for kubectl
set -q KREW_ROOT; and set -gx PATH $PATH $KREW_ROOT/.krew/bin; or set -gx PATH $PATH $HOME/.krew/bin

function kcn -d "switch k8s namespace"
  kubectl config set-context --current --namespace "$argv"
end

function kcswitch  -d "switch k8s context, optionally also namespace (2nd arg)"
  set context $argv[1]
  set namespace $argv[2]
  kubectl config use-context "$context"
  if test ! -z "$namespace"
    echo "Switching namespace to: $namespace"
    kubectl config set-context --current --namespace "$namespace"
  end
end

function klogs -d "show k8s logs for given arg & filter out health checks"
  if [ -z "$argv" ];
    echo "No arguments supplied"
    return
  end
  set label (kubectl get deployments | grep $argv[1] | awk '{ print $1 }')
  if [ -z "$label" ];
    echo "didnt find any deployments for input: '$argv[1]', trying pods"
    set pod (kubectl get pods | grep $argv[1] | awk '{ print $1 }')
    if [ -z "$pod" ];
      echo "didnt find any pods for input: '$argv[1]'"
      return
    end
    kubectl logs $pod $argv[2..-1]| grep -v -E 'liveness|readiness'
  else
    echo "getting logs for label: $label"
    kubectl logs -l "app=$label" --tail=-1 $argv[2..-1] | grep -v -E 'liveness|readiness'
  end
  
end

function cat --wraps=bat --description 'bat wrapper for cat'
  bat $argv
end

# abbreviations: after pressing enter or space it expands to the full text of the abbr
# https://fishshell.com/docs/current/interactive.html#abbreviations
abbr -a gd git diff
abbr -a gf git fetch
abbr -a gp "git pull --prune"
abbr -a gpu "git push -u origin (git branch --show-current)"
abbr -a gpud "git push -d origin"
abbr -a kc kubectl
alias kc="kubectl"

# https://github.com/ryoppippi/fish-na
# if interactively writing npm, will correct to the package manager detected in PWD
abbr -a npm -f _na
abbr -a pnpm -f _na
alias npmm="npm" #in case you actually want to force run npm
alias pnpmm="pnpm" #in case you actually want to force run pnpm

# ni: fisher alternatitve for @antfu/ni, detects package manager to use
# https://github.com/Karibash/ni.fish
# $ fisher install Karibash/ni.fish
abbr -a nrtit "ni run test ./test/it"
abbr -a nrte "ni run test ./test/e2e"
abbr -a nrb "ni run build"
abbr -a nrt "ni run test"
abbr -a nrbt "ni run build && ni run test"
abbr -a nribt "ni ci && ni run build && ni run test"
abbr -a nibt "ni ci && ni run build && ni run test"
abbr -a npmv "npm version"

abbr -a upzcli "npm i -g @payzen/payzen-cli"

abbr -a pzp "pz publish"
abbr -a pzpp "pz publish -r patch"
abbr -a pzpm "pz publish -r minor"
abbr -a pzpmj "pz publish -r major"
abbr -a pzpb "pz publish -r beta"
abbr -a pzd "pz deploy"

# the silver searcher, ag, has no config, need to alias common options
alias ag='ag --ignore-dir node_modules --ignore-dir build --ignore tsconfig.build.tsbuildinfo'

# mass search and replace in files
function copy-pasta-file-contents --description "copy-pasta-file-contents <lookup> <replace>"
  set lookup $argv[1]
  set replace $argv[2]
  ag --ignore-dir node_modules --ignore-dir build --ignore tsconfig.build.tsbuildinfo -l $lookup | xargs sed -i '' "s/$lookup/$replace/g"
end


# mass search and replace file names
function copy-pasta-file --description "copy-pasta-file <lookup> <replace>"
  set lookup $argv[1]
  set replace $argv[2]
  ag --ignore-dir node_modules --ignore-dir build --ignore tsconfig.build.tsbuildinfo -l -g $lookup | sed -e "p;s/$lookup/$replace/g" | xargs -n2 mv
end

function npmpzls --description "list payzen npm private packages"
  set npm_token (cat ~/.npmrc | grep -o '_authToken=.*' | sed 's/_authToken=//g')
  #echo "using token $npm_token"
  curl -H "Authorization: Bearer $npm_token" "https://registry.npmjs.org/-/org/payzen/package" | jq -S .
end

# android sdk
# set -Ux ANDROID_SDK_ROOT "/Users/samz/.android/sdk_root"


# 1password-cli signin and set session token across terminals
# function op --wraps='op' 
#   if ! command op whoami &>/dev/null
#     set token (command op signin --raw --account payzen 2>/dev/null)
#     if test -n "$token"
#       echo "watwat $status $token" 
#       # set userid (op whoami --session $token --format json | jq .user_uuid -r)
#       # echo "watwat 2 $status $userid" 
#       # set env_var_name "OP_SESSION_$userid"
#       # set -Ux "$env_var_name" $token
#       set -Ux OP_SESSION_payzen $token
#     else
#       echo "failed to login to 1password"
#     end  
#   else
#     echo "1password already signed in"
#   end
#   command op $argv
# end

function dockerpushprod --description "re-tag and push a staging docker image to prod (ecr)"
  if not test -e 'package.json'
    echo "no package.json in directory, check that you are in right place to run cmd"
    return
  end
  set pkg_version (npm pkg get version)
  set pkg_version (string trim --chars='"' "$pkg_version")
  set pkg_name (npm pkg get name)
  set pkg_name (string trim --chars='"@' "$pkg_name")
  set img "$pkg_name":"$pkg_version"
  set stg_img "936143655872.dkr.ecr.us-east-1.amazonaws.com/$img"
  set prod_img "559800918584.dkr.ecr.us-east-1.amazonaws.com/$img"
  set is_stg_img_exists (docker images -q --filter=reference="$stg_img" --format "{{.ID}}")
  # echo "is_stg_img_exists: $is_stg_img_exists"
  if test -z "$is_stg_img_exists"
    echo "image not found, pulling it first"
    echo "docker pull $stg_img"
    docker pull $stg_img
  end
  echo "going to re-tag and push $img from aws staging account to prod"
  echo "  if it fails maybe you need to docker login to aws ecr"
  echo "docker tag $stg_img $prod_img"
  docker tag $stg_img $prod_img
  echo "docker push $prod_img"
  docker push $prod_img
end

function dockerclean --description "force remove docker compose related containers"
  # docker ps -aq | xargs docker rm -f
  # was docker compose -p {} rm -f -v -s, trying down instead so it removes networks too
  docker compose ls -aq | xargs -P3 -n1 -I{} docker compose -p {} down -v -t 5
end

# function __check_buildkit_flag --on-variable PWD --description 'SET FORCE_LEGACY_BUILDKIT=1 on lambda and migration dirs'
#   status --is-command-substitution; and return
#   # if $FORCE_LEGACY_BUILDKIT is empty
#   # if test -z "$FORCE_LEGACY_BUILDKIT"
#   if test -e 'package.json'
#     if string match -rq '(lambda|image|migration|app)$' $PWD
#       # echo "setting FORCE_LEGACY_BUILDKIT to 1 for this folder"
#       set -gx FORCE_LEGACY_BUILDKIT "1"
#       set -gx FORCE_OFFLINE_BUILDKIT "1"
#     end
#   else
#     set -e FORCE_LEGACY_BUILDKIT
#     set -e FORCE_OFFLINE_BUILDKIT
#   end
# end
# 
# __check_buildkit_flag

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
    $cmd >$cachefile
  end
  source $cachefile
end

# load ssh keys from macOS keychain once at login, not on every interactive shell
if status is-login
  ssh-add -l 2>/dev/null | grep -q 'The agent has no identities' && ssh-add --apple-load-keychain 2>/dev/null
end

#zoxide is a smarter cd command, inspired by z and autojump.
__cached_init zoxide zoxide init --cmd=cd fish

# helps gpg understand what the interactive terminal is so ncurses properly comes up for password prompts
export GPG_TTY=$(tty)

# https://starship.rs/config/
# config is in ~/.config/starship.toml
__cached_init starship starship init fish --print-full-init

# Google Cloud SDK: add bin dir directly instead of sourcing the slow path.fish.inc
test -d /opt/homebrew/share/google-cloud-sdk/bin; and fish_add_path /opt/homebrew/share/google-cloud-sdk/bin

# pnpm
set -gx PNPM_HOME "/Users/samz/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# github token for gh cli — read from macOS keychain (no secret in this file)
# store/update: security add-generic-password -U -a $USER -s GITHUB_WORKFLOW_TOKEN -w <token>
set -gx GITHUB_WORKFLOW_TOKEN (security find-generic-password -w -s GITHUB_WORKFLOW_TOKEN 2>/dev/null)

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
