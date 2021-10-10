

# make paste instant instead of slow one by one char
# https://github.com/zsh-users/zsh-syntax-highlighting/issues/295#issuecomment-214581607
# if doesnt work try this link https://github.com/zsh-users/zsh-autosuggestions/issues/238
zstyle ':bracketed-paste-magic' active-widgets '.self-*' 

# Load and init Antigen
source /usr/local/share/antigen/antigen.zsh
antigen init ~/.zshrc_antigen


# You may need to manually set your language environment
export LANG=en_US.UTF-8

# load helper aliases and functions
[ -f ~/.functions ] && source "$HOME/.functions"
[ -f ~/.aliases ] && source "$HOME/.aliases"

# enable zsh tab completions engine 
#(-C to ignore security checks, not recommended but i share #laptop with wife and it should be safe)
autoload -Uz compinit && compinit -C

# fnm (nvm replacement)
command -v fnm >/dev/null 2>&1 && {
  eval "$(fnm env)"
  alias nvm="fnm"
}

# make sure gpg-agent is running, depends on pinetry-mac as well
# 2021-07-01 sam commenting as ssh-agent is failing to add priv keys
# TODO google how to setup gpg-agent properly so it works with ssh-add
# if [ ! -f "~/.gnupg/S.gpg-agent" ]; then
#   gpgconf --launch gpg-agent
# fi
# export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export GPG_TTY=$(tty)

# deprecated in favor of sdkman
command -v jenv >/dev/null 2>&1 && {
  eval "$(jenv init -)"
  export JAVA_HOME=`jenv javahome`
}

command -v rbenv >/dev/null 2>&1 && {
  eval "$(rbenv init -)"
}

# conditionaly add postgresql@9.6 to path
if [ -d "/usr/local/opt/postgresql@9.6/" ]; then
  export PATH="/usr/local/opt/postgresql@9.6/bin:$PATH"
fi

echo $PATH | grep -q "/usr/local/sbin" || export PATH="/usr/local/sbin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
