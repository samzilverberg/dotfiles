if status is-interactive
    # Commands to run in interactive sessions can go here
end

# cancel the fish greeting
function fish_greeting
end

# added "a" flag, fish default to just "lh"
# function ll --wraps=ls --description 'List contents of directory using long format'
#     ls -lhaG $argv
# end

set -Ux EZA_COLORS "da=1;34:di=1;34"
set -Ux AWS_ECR_REGISTRY "936143655872.dkr.ecr.us-east-1.amazonaws.com"
set -Ux AWS_CDN_BUCKET "staging.static.payzen.com"
set -Ux BAT_THEME "Monokai Extended"

alias gst="git status"
alias gds="git diff --staged"
#alias gd="git diff"
alias gcm="git checkout (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"
alias gcb="git checkout -b"
alias gl="git log"
alias gl.="git log ."

alias dev="cd ~/dev"
alias mono="cd ~/dev/mono/packages"
alias pzs="cd ~/dev/payzen_server"
alias servicing="cd ~/dev/payzen_servicing_server/packages"

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

abbr -a nrtit "npm t ./test/it"
abbr -a nrte "npm t ./test/e2e"
abbr -a nrb "npm run build"
abbr -a nrt "npm t"
abbr -a nrbt "npm run build && npm t"
abbr -a nribt "npm ci && npm run build && npm t"

abbr -a npmv "npm version"

abbr -a upzcli "npm i -g @payzen/payzen-cli"

abbr -a pzp "pz publish"
abbr -a pzpp "pz publish -r patch"
abbr -a pzpm "pz publish -r minor"
abbr -a pzpb "pz publish -r beta -f"
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

fnm env | source
[ -f /usr/local/opt/asdf/libexec/asdf.fish ] && source /usr/local/opt/asdf/libexec/asdf.fish
[ -f ~/.asdf/plugins/java/set-java-home.fish ] && source ~/.asdf/plugins/java/set-java-home.fish

# android sdk
set -Ux ANDROID_SDK_ROOT "/Users/samz/.android/sdk_root"


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

function __check_buildkit_flag --on-variable PWD --description 'SET FORCE_LEGACY_BUILDKIT=1 on lambda and migration dirs'
  status --is-command-substitution; and return
  # if $FORCE_LEGACY_BUILDKIT is empty
  # if test -z "$FORCE_LEGACY_BUILDKIT"
  if test -e 'package.json'
    if string match -rq '(lambda|image|migration|app)$' $PWD
      # echo "setting FORCE_LEGACY_BUILDKIT to 1 for this folder"
      set -gx FORCE_LEGACY_BUILDKIT "1"
      set -gx FORCE_OFFLINE_BUILDKIT "1"
    end
  else
    set -e FORCE_LEGACY_BUILDKIT
    set -e FORCE_OFFLINE_BUILDKIT
  end
end

__check_buildkit_flag

ssh-add -l | grep -q 'The agent has no identities' && ssh-add  --apple-load-keychain

#zoxide is a smarter cd command, inspired by z and autojump. 
zoxide init --cmd=cd fish | source

# helps gpg understand what the interactive terminal is so ncurses properly comes up for password prompts
export GPG_TTY=$(tty)

# https://starship.rs/config/
# config is in ~/.config/starship.toml
starship init fish | source
