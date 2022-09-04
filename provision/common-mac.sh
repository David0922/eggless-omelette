WORK_DIR=/work-dir
BIN=$WORK_DIR/bin

export PATH=$PATH:$BIN

export EDITOR=/usr/bin/vim

eval "$(/opt/homebrew/bin/brew shellenv)"

alias cls=clear
alias cp='cp --no-preserve=all'
alias cpp='clang++ -Wall -Wextra -Werror -std=c++20 -pedantic'
alias cpp2='clang++ -O2 -std=c++20'
alias diff=colordiff
alias grep='grep --color=always'
alias json=jq
alias less='less -r'
alias ll='ls -aFhl --color=always'
alias lsl='ls -aFhl --color=always | less -r'
alias rsync='rsync --human-readable --progress --recursive --verbose'
alias shutdown='sudo shutdown now'

alias g='git --no-pager'
alias gb='git --no-pager branch'
alias gch='git checkout'

alias tmux="tmux -f $WORK_DIR/settings/tmux.conf"
alias tma='tmux a -t'
alias tmn='tmux new -s'

# go

export PATH=$PATH:$BIN/go/bin:$WORK_DIR/projects/go/bin

export GO111MODULE=auto
export GOPATH=$WORK_DIR/projects/go

# python

alias py=ipython
alias python=python3

source $WORK_DIR/py3.8_env/bin/activate
