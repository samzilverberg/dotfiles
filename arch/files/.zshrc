
echo "$(date -Ins) .zshrc $0" >> ~/testing

[ -f ~/.aliases ] && source "$HOME/.aliases"
[ -f ~/.myprofile ] && source "$HOME/.myprofile"

# save each command's beginning timestamp and the duration to the history file
setopt extended_history

#zplugin plugin manager
ZPLG_HOME=~/.zplugin
if [[ ! -f $ZPLG_HOME/bin/zplugin.zsh ]]; then
  mkdir -p $ZPLG_HOME
	git clone --depth 10 https://github.com/zdharma/zplugin.git $ZPLG_HOME/bin
	zcompile $ZPLG_HOME/bin/zplugin.zsh
fi
source ~/.zplugin/bin/zplugin.zsh


HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

bindkey -e
bindkey "^[[1;5C"    forward-word # Ctrl+Right
bindkey "^[[1;5D"    backward-word # Ctrl+Left
bindkey "^[[3~"      delete-char #fn + backspace = delete forward
bindkey "^[3;5~"     delete-char #fn + backspace


zplugin light zsh-users/zsh-autosuggestions
zplugin light zsh-users/zsh-completions

zstyle ":history-search-multi-word" page-size "11"
zplugin ice silent wait'1'; zplugin load zdharma/history-search-multi-word
zplugin ice silent wait'!1'; zplugin light zdharma/fast-syntax-highlighting


AGKOZAK_FORCE_ASYNC_METHOD=subst-async
AGKOZAK_MULTILINE=0
zplugin load agkozak/agkozak-zsh-theme

#zstyle :compinstall filename '/home/samz/.zshrc'
zstyle ':completion:*' menu select
autoload -Uz compinit
compinit

zplugin cdreplay -q