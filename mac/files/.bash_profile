if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

if [ -f $(brew --prefix)/etc/bash_completion ]; then
   . $(brew --prefix)/etc/bash_completion
fi


export NODE_TEST_PARALLEL=8
export ANDROID_HOME=/usr/local/Cellar/android-sdk/24.0.2/
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH="$HOME/.node/bin:$PATH"
export NODE_PATH=.:./avb-services-shared/node_modules
export NVM_SYMLINK_CURRENT=true
alias gst='git status'
alias gpull='git pull'
alias gpush='git push'
alias gcheck='git checkout'
alias gcommit='git commit'
alias gmerge='git merge'
alias gpulls='git pull && git submodule update'
alias gspull="git submodule foreach git pull"

alias ll="ls -lah"

#export LC_ALL="C"
complete -C aws_completer aws

export GITAWAREPROMPT=~/.bash/git-aware-prompt
source $GITAWAREPROMPT/main.sh

export PS1="\[\033[32m\]\t\[\033[m\] \u@\h \w \[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]\$ "
export NVM_DIR="$HOME/.nvm"
. "/usr/local/opt/nvm/nvm.sh"

export BOOST_ROOT=/opt/local/include/boost/boost_1_62_0

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# load rbenv
eval "$(rbenv init -)"


# careers secrets stuff for pass util
export PASSWORD_STORE_DIR=/Users/samz/springernature/careers_secrets
export GPGKEY=126669FD
