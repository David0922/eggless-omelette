export WORK_DIR=/work-dir
export BIN=$WORK_DIR/bin

export PATH=$PATH:$BIN

export EDITOR=/usr/bin/vim

alias b=bazelisk
alias bazel=bazelisk
alias cls=clear
# alias cp='cp --no-preserve=all'
alias cpp='clang++ -Wall -Wextra -Werror -std=c++20 -pedantic'
alias cpp2='clang++ -O2 -std=c++20'
alias diff=colordiff
alias grep='grep --color=always'
# alias json=jq
alias less='less -r'
alias ll='ls -aFhl --color=always'
alias lsl='ls -aFhl --color=always | less -r'
alias rsync='rsync --human-readable --progress --recursive --verbose'
alias serve-http='busybox httpd -f -h . -p 0.0.0.0:8080 -v'
alias shutdown='sudo shutdown now'

alias g='git --no-pager'
alias gb='git --no-pager branch'
alias gch='git checkout'
alias gdh='git diff HEAD'

# alias k=microk8s.kubectl
# alias kubectl=microk8s.kubectl
# alias k-all='microk8s.kubectl get all --all-namespaces'

# alias mp='sudo -E multipass'

alias tmux="tmux -f $WORK_DIR/settings/tmux.conf"
alias tma='tmux a -t'
alias tmn='tmux new -s'

# alias vagrant-destroy='vagrant destroy -f'
# alias vagrant-status='vagrant global-status --prune'

# go

export GO111MODULE=auto
export GOPATH=$BIN/gopath
export PATH=$PATH:$BIN/go/bin:$GOPATH/bin

# rust

export RUSTUP_HOME=$BIN/rust/.rustup
export CARGO_HOME=$BIN/rust/.cargo
export PATH=$PATH:$CARGO_HOME/bin

# vcpkg

export VCPKG_DISABLE_METRICS=1

export VCPKG_ROOT=$BIN/vcpkg
export PATH=$PATH:$VCPKG_ROOT

# python

# venv / virtualenv

src_py() {
  case $(lsb_release -a | grep -i release | awk '{print $2}') in
    20.04)
      source $BIN/py3.9/bin/activate
      ;;
    22.04)
      source $BIN/py3.10/bin/activate
      ;;
    24.04)
      source $BIN/py3.12/bin/activate
      ;;
  esac
}

py() {
  if [[ -z "$VIRTUAL_ENV" && -z "$CONDA_PREFIX" ]]; then
    src_py
  fi
  ipython
}

# micromamba

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
export MAMBA_EXE=$BIN/micromamba
export MAMBA_ROOT_PREFIX=$BIN/micromamba_root
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

# uv

export UV_PYTHON_BIN_DIR=$BIN/uv/python_bin
export UV_PYTHON_INSTALL_DIR=$BIN/uv/python_install
export UV_TOOL_BIN_DIR=$BIN/uv/tool_bin
export UV_TOOL_DIR=$BIN/uv/tool

export PATH=$PATH:$UV_PYTHON_BIN_DIR
export PATH=$PATH:$UV_TOOL_BIN_DIR

if command -v uv &> /dev/null; then
  eval "$(uv generate-shell-completion zsh)"
fi

if command -v uvx &> /dev/null; then
  eval "$(uvx --generate-shell-completion zsh)"
fi

# node.js

export NPM_CONFIG_PREFIX=$BIN/npm-global
export PATH=$PATH:$NPM_CONFIG_PREFIX/bin

# # ruby

# export PATH=$PATH:$BIN/rbenv/bin
# export PATH=$PATH:$BIN/rbenv/plugins/ruby-build/bin

# eval "$(rbenv init -)"

# alias rb=irb
