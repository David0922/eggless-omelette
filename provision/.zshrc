export WORK_DIR=/work-dir
export BIN=$WORK_DIR/bin
export SETTINGS_DIR=$WORK_DIR/settings

export PATH=$PATH:$BIN

export EDITOR=/usr/bin/vim

# powerlevel10k

# enable powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source $SETTINGS_DIR/powerlevel10k/powerlevel10k.zsh-theme
source $SETTINGS_DIR/.p10k.zsh

# brew

if [[ "$(uname -s)" == 'Darwin' ]]; then
  export HOMEBREW_NO_AUTO_UPDATE=1
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# zsh

setopt AUTOCD
setopt HIST_IGNORE_SPACE
setopt NOBEEP

typeset -U path fpath PATH FPATH
autoload -Uz compinit
() {
  emulate -L zsh -o extended_glob
  if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+48) ]]; then
    # dump is >48h old: full rescan, picks up new tools
    compinit
    touch ${ZDOTDIR:-$HOME}/.zcompdump
  else
    # recent: trust it, skip all checks
    compinit -C
  fi
}

bindkey -e

WORDCHARS=''

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

source "$SETTINGS_DIR/zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"

# alias

# alias c='clang -Wall -Wextra -Werror -std=c17 -pedantic'
# alias cpp='clang++ -Wall -Wextra -Werror -std=c++20 -pedantic'
# alias cpp2='clang++ -O2 -std=c++20'
alias cls=clear
alias diff=colordiff
alias grep='grep --color=always'
alias l='ls -aFhl --color=always'
alias ll='ls -aFhl --color=always'
alias less='less -r'
alias shutdown='sudo shutdown now'

alias g='git --no-pager'
alias gb='git --no-pager branch'
alias gch='git checkout'
alias gdh='git diff HEAD'

alias tmux="tmux -f $SETTINGS_DIR/tmux.conf"
alias tma='tmux a -t'
alias tmn='tmux new -s'

if [[ "$(uname -s)" == 'Darwin' ]]; then
  alias brave='open -a "Brave Browser" -n --args --incognito --new-window'
  alias chrome='open -a "Google Chrome" -n --args --incognito --new-window'
fi

function dt() {
  echo "sunnyvale    $(TZ='America/Los_Angeles' date '+%z    %Y-%m-%d    %H:%M:%S')"
  echo "chicago      $(TZ='America/Chicago' date '+%z    %Y-%m-%d    %H:%M:%S')"
  echo "new york     $(TZ='America/New_York' date '+%z    %Y-%m-%d    %H:%M:%S')"
  echo "UTC                   $(TZ=UTC date '+%Y-%m-%d    %H:%M:%S')"
  echo "taipei       $(TZ='Asia/Taipei' date '+%z    %Y-%m-%d    %H:%M:%S')"
}

# cmake

export PATH=$PATH:$BIN/cmake/bin

# go

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

export PIPX_HOME=$BIN/pipx_home
export PIPX_BIN_DIR=$BIN/pipx_bin

export PATH=$PATH:$PIPX_BIN_DIR

src_py() {
  if [[ "$(uname -s)" == 'Darwin' ]]; then
    source $BIN/py3.14/bin/activate
  elif [[ "$(uname -s)" == 'Linux' ]]; then
    case $(lsb_release -a | grep -i release | awk '{print $2}') in
      26.04)
        source $BIN/py3.14/bin/activate
        ;;
      *)
        echo 'requires ubuntu 26.04'
        return 1
        ;;
    esac
  fi
}

py() {
  if [[ -z "$VIRTUAL_ENV" && -z "$CONDA_PREFIX" ]]; then
    src_py
  fi
  ipython
}

# # micromamba

# # >>> mamba initialize >>>
# # !! Contents within this block are managed by 'micromamba shell init' !!
# export MAMBA_EXE=$BIN/micromamba
# export MAMBA_ROOT_PREFIX=$BIN/micromamba_root
# __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__mamba_setup"
# else
#     alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
# fi
# unset __mamba_setup
# # <<< mamba initialize <<<

# uv

export UV_PYTHON_BIN_DIR=$BIN/uv/python_bin
export UV_PYTHON_INSTALL_DIR=$BIN/uv/python_install
export UV_TOOL_BIN_DIR=$BIN/uv/tool_bin
export UV_TOOL_DIR=$BIN/uv/tool

export PATH=$PATH:$UV_PYTHON_BIN_DIR
export PATH=$PATH:$UV_TOOL_BIN_DIR

# if command -v uv &> /dev/null; then
#   eval "$(uv generate-shell-completion zsh)"
# fi

# if command -v uvx &> /dev/null; then
#   eval "$(uvx --generate-shell-completion zsh)"
# fi

# node.js

export NPM_CONFIG_PREFIX=$BIN/npm-global
export PATH=$PATH:$NPM_CONFIG_PREFIX/bin

export PATH=$PATH:$BIN/pnpm

# # starfish
# export STARSHIP_CONFIG=$SETTINGS_DIR/starship.toml
# eval "$(starship init zsh)"
