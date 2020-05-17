# enable misc color support
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# chromebook crouton shortcuts
if [ ! -v $CHROMEBOOK ]; then
  alias code="sudo startxiwi -n bionic code"
  alias bish="sudo enter-chroot -n bionic"
  alias bixi="sudo startxiwi -n bionic"
  alias biki="sudo unmount-chroot -f bionic"
fi

# ls aliases
alias la='ls -CaFlh'

# misc
alias g="git"
alias cdgit="cd ~/git"
alias cdbin="cd ~/bin"
alias cdgo="cd $GOPATH"
alias pg_init="sudo service postgresql start"
alias redis_init="sudo service redis-server start"
alias screen_attach="screen -r"
alias screen_list="screen -ls"
alias screen_clean="screen -ls | grep Detached | cut -d. -f1 | awk '{print $1}' | xargs kill"