

# Load Antigen
source /usr/local/share/antigen/antigen.zsh

# Load Antigen configurations
antigen init ~/.zshrc_antigen

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# load aliases
[ -f ~/.aliases ] && source "$HOME/.aliases"

alias cflogin-gcp-qa='cflogin-gcp natcar-qa'
alias cflogin-gcp-live='cflogin-gcp natcar-live'

function cflogin-gcp {
    local VAULT_LOGGEDIN="$(vault print token)"
    if [[ -z "$VAULT_LOGGEDIN" ]]; then
      echo "login to vault first via: vault login -method=github"
      return 1
    fi

    local TEAM="nature-careers"
    local API_URL=$(vault read -field=api-snpaas springernature/$TEAM/cloudfoundry)
    local CF_USER=$(vault read -field=username-snpaas springernature/$TEAM/cloudfoundry)
    local CF_PASS=$(vault read -field=password-snpaas springernature/$TEAM/cloudfoundry)
    local CF_ORG=$(vault read -field=org-snpaas springernature/$TEAM/cloudfoundry)
    local CF_SPACE=$1

    echo "cf login to $API_URL with $CF_ORG $CF_SPACE"
    cf login -a "$API_URL" -u "$CF_USER" -p "$CF_PASS" -o "$CF_ORG" -s "$CF_SPACE"
}

# nvm
export NVM_DIR="$HOME/.nvm"
. "/usr/local/opt/nvm/nvm.sh"

export VAULT_ADDR=https://vault.halfpipe.io


# make sure gpg-agent is running, depends on pinetry-mac as well
if [ ! -f "~/.gnupg/S.gpg-agent" ]; then
  gpgconf --launch gpg-agent
fi
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export GPG_TTY=$(tty)

eval "$(jenv init -)"
export JAVA_HOME=`jenv javahome`

eval "$(rbenv init -)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
