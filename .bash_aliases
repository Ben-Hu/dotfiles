# enable misc color support
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# ls aliases
alias la='ls -CaFlh'

# misc
alias cdgit="cd ~/git"
alias cdbin="cd ~/bin"
alias cdgo="cd $GOPATH"
alias pg_init="sudo service postgresql start"