

# Load Antigen
source /usr/local/share/antigen/antigen.zsh

# Load Antigen configurations
antigen init ~/.zshrc_antigen

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# load helper aliases and functions
[ -f ~/.functions ] && source "$HOME/.functions"
[ -f ~/.aliases ] && source "$HOME/.aliases"


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

# conditionaly add postgresql@9.6 to path
if [ -d "/usr/local/opt/postgresql@9.6/" ]; then
  export PATH="/usr/local/opt/postgresql@9.6/bin:$PATH"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
