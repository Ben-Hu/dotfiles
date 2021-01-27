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
alias ll='ls -CaFlh'
alias la='ls -CaF'

# misc
alias g="git"
alias s="screen"
alias cdgit="cd ~/git"
alias cdbin="cd ~/bin"
alias cdgo="cd $GOPATH"
alias pg_init="sudo service postgresql start"
alias redis_init="sudo service redis-server start"
alias fcode="fedit code"
alias fvim="fedit vim"
alias pip="pip3"