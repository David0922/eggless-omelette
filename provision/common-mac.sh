WORK_DIR=/work-dir
BIN=$WORK_DIR/bin

export PATH=$PATH:$BIN

export EDITOR=/usr/bin/vim

export HOMEBREW_NO_AUTO_UPDATE=1

eval "$(/opt/homebrew/bin/brew shellenv)"

alias b=bazelisk
alias bazel=bazelisk
alias cls=clear
alias c='clang -Wall -Wextra -Werror -std=c17 -pedantic'
alias cpp='clang++ -Wall -Wextra -Werror -std=c++20 -pedantic'
alias cpp2='clang++ -O2 -std=c++20'
alias diff=colordiff
alias grep='grep --color=always'
# alias json=jq
alias less='less -r'
alias ll='ls -aFhl --color=always'
alias lsl='ls -aFhl --color=always | less -r'
alias rsync='rsync --human-readable --progress --recursive --verbose'
alias shutdown='sudo shutdown now'

alias g='git --no-pager'
alias gb='git --no-pager branch'
alias gch='git checkout'
alias gdh='git diff HEAD'

alias tmux="tmux -f $WORK_DIR/settings/tmux.conf"
alias tma='tmux a -t'
alias tmn='tmux new -s'

alias brave='open -a "Brave Browser" -n --args --incognito --new-window'
alias chrome='open -a "Google Chrome" -n --args --incognito --new-window'
alias pdf='open -a Negative -n'

function dt() {
  echo "sunnyvale    $(TZ='America/Los_Angeles' date '+%z    %Y-%m-%d    %H:%M:%S')"
  echo "chicago      $(TZ='America/Chicago' date '+%z    %Y-%m-%d    %H:%M:%S')"
  echo "new york     $(TZ='America/New_York' date '+%z    %Y-%m-%d    %H:%M:%S')"
  echo "UTC                   $(TZ=UTC date '+%Y-%m-%d    %H:%M:%S')"
  echo "taipei       $(TZ='Asia/Taipei' date '+%z    %Y-%m-%d    %H:%M:%S')"
}

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

# virtual env

src_py() {
  source $BIN/py3.12_env/bin/activate
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
