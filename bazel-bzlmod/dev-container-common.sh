export WORK_DIR=/work-dir
export BIN=$WORK_DIR/bin

export PATH=$BIN:$PATH

export EDITOR=/usr/bin/vim

alias b=bazel
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

# micromamba

alias mamba=micromamba

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
export MAMBA_EXE=$BIN/micromamba
export MAMBA_ROOT_PREFIX=$BIN/micromamba_root
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

micromamba activate $BIN/py3.12
