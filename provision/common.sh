export BIN=/david/bin

export PATH=$PATH:$BIN

export EDITOR=/usr/bin/vim

alias cls=clear
alias cpp='g++ -Wall -Wextra -Werror -std=c++20 -pedantic'
alias diff=colordiff
alias grep='grep --color=always'
alias less='less -r'
alias ll='ls -aFhl --color=always'
alias lsl='ls -aFhl --color=always | less -r'
alias shutdown='sudo shutdown now'

alias g='git --no-pager'
alias gb='git --no-pager branch'
alias gch='git checkout'

alias k=microk8s.kubectl
alias kubectl=microk8s.kubectl
alias k-all='microk8s.kubectl get all --all-namespaces'

alias tmux='tmux -f /david/settings/tmux.conf'
alias tma='tmux a -t'
alias tmn='tmux new -s'

if [ "$PWD" = "$HOME" ] || [ "$PWD" = "$HOME/david" ]; then
  cd /david
fi

# go

export PATH=$PATH:$BIN/go/bin
export PATH=$PATH:/david/projects/go/bin

export GO111MODULE=auto
export GOPATH=/david/projects/go

# python

alias py=ipython
alias python=python3

source /david/py3.8_env/bin/activate

# ruby

export PATH=$PATH:$BIN/rbenv/bin
export PATH=$PATH:$BIN/rbenv/plugins/ruby-build/bin

eval "$(rbenv init -)"
