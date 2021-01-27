# If not running interactively, don't do anything
case $- in
  *i*) ;;
    *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

prompt_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ [\1]/' -e 's/ //'
}

if [ "$color_prompt" = yes ]; then
  PS1='\[\e]0;\u@\h: \w\a\]\[\033[01;32m\][\h-${debian_chroot:+$debian_chroot}]\[\033[00m\]:\[\033[01;34m\][\w]\[\033[00m\]:\[\033[01;36m\]$(prompt_branch)\[\033[00m\] \[\033[01;33m\]>>>\[\033[00m\] '
else
  PS1='[\h-${debian_chroot:+$debian_chroot}]:[\w]:$(prompt_branch) >>> '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
  ;;
*)
  ;;
esac

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# alias definitions.
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

[ -f ~/.git-completion.bash ] && . ~/.git-completion.bash

# ssh
if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval "$(ssh-agent -s)"
  ssh-add
fi

# misc
export LS_COLORS=$LS_COLORS:'ow=1;34:'
export VISUAL=vim
export EDITOR="$VISUAL"

# utilities
export PATH="$HOME/.circleci/bin/:$PATH"
export PATH="$HOME/.terraform/bin/:$PATH"
export PATH="$HOME/.local/bin/:$PATH"
export PATH="$HOME/.bin/:$PATH"

export SCREENDIR="$HOME/.screen"

# erlang
export ERL_AFLAGS="-kernel shell_history enabled shell_history_file_bytes 1024000"

# asdf
if [ -r $HOME/.asdf ]; then
  . "$HOME/.asdf/asdf.sh"
  . "$HOME/.asdf/completions/asdf.bash"
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if hash pyenv 2> /dev/null; then
  eval "$(pyenv init -)"
fi

# go
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# direnv
if hash direnv 2> /dev/null; then
  eval "$(direnv hook bash)"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

terraform() {
  if [ "$1" = "fmt" ]
  then
    shift
    command terraform fmt --recursive "$@"
  else
    command terraform "$@"
  fi
}

git() {
  if [ "$1" = "pou" ]
  then
    shift
    command git push --set-upstream origin $(git symbolic-ref --short HEAD) "$@"
  else
    command git "$@"
  fi
}

fedit() {
  local editor target
  editor=$1
  target=$(
    fzf --height 100% --layout reverse --info inline --border \
    --preview 'head -100 {}' --preview-window right:100:border
  ) || return
  $editor $target
}

fco() {
  local branches target
  branches=$(
    git branch | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u |
    awk '{print $1}'
  ) || return
  target=$(echo "$branches" | fzf --border --no-hscroll --reverse --ansi +m -d "\t" -q "$*"
  ) || return
  git ch $target
}

fbrd() {
  local branches target
  branches=$(
    git branch | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u |
    awk '{print $1}'
  ) || return
  target=$(echo "$branches" | fzf --border --no-hscroll --reverse --ansi +m -d "\t" -q "$*"
  ) || return
  git branch -d $target
}

sls() {
  local sessions target
  sessions=$(screen -ls | grep '(Detached)') || return
  sessions=$(echo "$sessions" | awk -F "(" '{print "(" $2 $1}') || return
  target=$(echo "$sessions" | fzf --border) || return
  screen -r $(echo "$target" | awk -F ")" '{print $2}')
}

tls() {
  local sessions target
  sessions=$(tmux ls | grep -v '(attached)') || return
  target=$(echo "$sessions" | fzf --border) || return
  tmux a -t $(echo "$target" | awk -F ':' '{print $1}')
}

srm() {
  local sessions targets target
  sessions=$(screen -ls | grep '(Detached)') || return
  sessions=$(echo "$sessions" | awk -F "(" '{print "(" $2 $1}') || return
  targets=$(echo "$sessions" | fzf --multi --border) || return
  for target in $(echo "$targets" | awk -F ")" '{print $2}'); do
    screen -XS $target quit
  done
}

trm() {
  local sessions targets target
  sessions=$(tmux ls | grep -v '(attached)') || return
  targets=$(echo "$sessions" | fzf --multi --border) || return
  for target in $(echo "$targets" | awk -F ":" '{print $1}'); do
    tmux kill-ses -t $target
  done
}

fgl() {
  git rev-parse HEAD > /dev/null 2>&1 || return
  git log --date=short \
  --format="%C(blue)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf --ansi --no-sort --reverse --multi --border \
  --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -300' |
  grep -o "[a-f0-9]\{7,\}"
}
