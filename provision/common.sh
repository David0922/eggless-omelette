WORK_DIR=/work-dir
BIN=$WORK_DIR/bin

export PATH=$PATH:$BIN

export EDITOR=/usr/bin/vim

alias cls=clear
alias cpp='clang++ -Wall -Wextra -Werror -std=c++20 -pedantic'
alias diff=colordiff
alias grep='grep --color=always'
alias json=jq
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

alias tmux="tmux -f $WORK_DIR/settings/tmux.conf"
alias tma='tmux a -t'
alias tmn='tmux new -s'

# alias vagrant-destroy='vagrant destroy -f'
# alias vagrant-status='vagrant global-status --prune'

# go

export PATH=$PATH:$BIN/go/bin
export PATH=$PATH:$WORK_DIR/projects/go/bin

export GO111MODULE=auto
export GOPATH=$WORK_DIR/projects/go

# python

alias py=ipython
alias python=python3

source $WORK_DIR/py3.8_env/bin/activate

# ruby

export PATH=$PATH:$BIN/rbenv/bin
export PATH=$PATH:$BIN/rbenv/plugins/ruby-build/bin

eval "$(rbenv init -)"

alias rb=irb
