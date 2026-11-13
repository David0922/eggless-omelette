#!/bin/bash

# usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/provision-dev-container.sh)"

set -e -x

export DEBIAN_FRONTEND=noninteractive

export ARCH=$(dpkg --print-architecture)

PW=0000

INSTALL='sudo apt-get install -qq -y --no-install-recommends'
UPDATE='sudo apt-get update -qq'
UPGRADE='sudo apt-get upgrade -qq'

WORK_DIR=/work-dir
BIN=$WORK_DIR/bin
SETTINGS_DIR=$WORK_DIR/settings

export PATH=$PATH:$BIN

# -------------------------------------------------- #

reset_dir() {
  sudo rm -rf $WORK_DIR || true

  sudo mkdir $WORK_DIR
  sudo chown $USER $WORK_DIR

  sudo ln -s $WORK_DIR /$USER

  mkdir \
    $BIN \
    $SETTINGS_DIR \
    $WORK_DIR/downloads \
    $WORK_DIR/tmp
}

enable_ssh_pw_auth() {
  $INSTALL openssh-server

  sudo ssh-keygen -A

  printf '%s\n' \
    'AllowTcpForwarding yes' \
    'GatewayPorts yes' \
    'PasswordAuthentication no' \
    'PermitRootLogin yes' | sudo tee /etc/ssh/sshd_config.d/devbox.conf
}

set_pw() {
  printf "$PW\n$PW\n" | sudo passwd root
  printf "$PW\n$PW\n" | sudo passwd $USER
}

install_essentials() {
  $INSTALL \
    build-essential \
    colordiff \
    curl \
    htop \
    iputils-ping \
    jq \
    lsb-release \
    tmux \
    tree \
    vim \
    wget
    # autossh \
    # busybox \
    # cmake \
    # libboost-all-dev \
    # make \
    # openjdk-21-jdk \
    # openssl \
    # protobuf-compiler \
    # screenfetch \
    # unzip \
    # zip \
}

install_clang() {
  CLANG_VER=22

  $INSTALL clang-$CLANG_VER clang-format-$CLANG_VER

  sudo mv /usr/bin/clang /usr/bin/clang_old || true
  sudo mv /usr/bin/clang++ /usr/bin/clang++_old || true
  sudo mv /usr/bin/clang-format /usr/bin/clang-format_old || true

  sudo ln -s $(realpath /usr/bin/clang-$CLANG_VER) /usr/bin/clang
  sudo ln -s $(realpath /usr/bin/clang++-$CLANG_VER) /usr/bin/clang++

  sudo ln -s $(realpath /usr/bin/clang-format-$CLANG_VER) /usr/bin/clang-format
}

install_cmake() {
  CMAKE_VER=4.4.5
  CMAKE_DIR=cmake-$CMAKE_VER-linux-$(uname -m)
  CMAKE_TAR=$CMAKE_DIR.tar.gz

  curl -fsSL -O https://github.com/Kitware/CMake/releases/download/v$CMAKE_VER/$CMAKE_TAR
  tar -xzf $CMAKE_TAR -C $BIN --no-same-owner

  mv $BIN/$CMAKE_DIR $BIN/cmake

  export PATH=$PATH:$BIN/cmake/bin
}

install_git() {
  $INSTALL git
  git config --global color.ui true
}

install_go() {
  GO_VER=1.27.4
  OS=linux
  GO_TAR=go$GO_VER.$OS-$ARCH.tar.gz

  curl -fsSL -O https://dl.google.com/go/$GO_TAR
  tar -xzf $GO_TAR -C $BIN --no-same-owner

  export GOPATH=$BIN/gopath
  export PATH=$PATH:$BIN/go/bin:$GOPATH/bin

  # go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
  # go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
}

install_bazel() {
  # requires go
  go install github.com/bazelbuild/bazelisk@latest
  go install github.com/bazelbuild/buildtools/buildifier@latest
}

install_nodejs() {
  export NPM_CONFIG_PREFIX=$BIN/npm-global
  export PATH=$PATH:$NPM_CONFIG_PREFIX/bin

  NODE_VER=26

  # https://nodesource.com/products/distributions
  $INSTALL curl
  curl -fsSL https://deb.nodesource.com/setup_$NODE_VER.x | sudo -E bash -
  $UPDATE
  $INSTALL nodejs

  PNPM_VER=v12.18.0

  if [[ "$ARCH" == 'amd64' ]]; then
    PNPM_TAR=pnpm-linux-x64.tar.gz
  elif [[ "$ARCH" == 'arm64' ]]; then
    PNPM_TAR=pnpm-linux-arm64.tar.gz
  else
    echo "unsupported architecture: $ARCH"
    exit 1
  fi

  mkdir -p $BIN/pnpm

  curl -fsSL -O https://github.com/pnpm/pnpm/releases/download/$PNPM_VER/$PNPM_TAR
  tar -xzf $PNPM_TAR -C $BIN/pnpm --no-same-owner

  export PATH=$PATH:$BIN/pnpm
}

install_pipx() {
  export PIPX_HOME=$BIN/pipx_home
  export PIPX_BIN_DIR=$BIN/pipx_bin

  export PATH=$PATH:$PIPX_BIN_DIR

  mkdir -p $PIPX_HOME $PIPX_BIN_DIR

  $INSTALL pipx
}

install_conan() {
  # requires pipx
  pipx install conan
}

install_uv() {
  # requires pipx

  export UV_PYTHON_BIN_DIR=$BIN/uv/python_bin
  export UV_PYTHON_INSTALL_DIR=$BIN/uv/python_install
  export UV_TOOL_BIN_DIR=$BIN/uv/tool_bin
  export UV_TOOL_DIR=$BIN/uv/tool

  export PATH=$PATH:$UV_PYTHON_BIN_DIR
  export PATH=$PATH:$UV_TOOL_BIN_DIR

  pipx install uv
}

install_python_virtualenv() {
  case $(lsb_release -a | grep -i release | awk '{print $2}') in
    26.04)
      PY_VER=3.14
      ;;
    *)
      echo 'this script is expected to be run in ubuntu 26.04'
      exit 1
      ;;
  esac

  PY_ENV_PREFIX=$BIN/py$PY_VER

  $INSTALL python3-pip python$PY_VER virtualenv

  virtualenv -p $(which python$PY_VER) $PY_ENV_PREFIX

  source $PY_ENV_PREFIX/bin/activate

  pip install \
    ipython \
    jupyter
    # diagrams \
    # grpcio \
    # grpcio-tools \
    # isort \
    # matplotlib \
    # numpy \
    # pandas \
    # plotly \
    # pyspark \
    # pytest \
    # PyYAML \
    # requests \
    # yapf \

  deactivate
}

install_rust() {
  mkdir -p $BIN/rust

  export RUSTUP_HOME=$BIN/rust/.rustup
  export CARGO_HOME=$BIN/rust/.cargo

  export PATH=$PATH:$CARGO_HOME/bin

  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
}

install_vcpkg() {
  export VCPKG_DISABLE_METRICS=1
  export VCPKG_ROOT=$BIN/vcpkg
  export PATH=$PATH:$VCPKG_ROOT

  $INSTALL curl tar unzip zip
  $INSTALL pkg-config
  git clone --branch 2026.07.29 --depth 1 https://github.com/microsoft/vcpkg.git $VCPKG_ROOT
  bootstrap-vcpkg.sh -disableMetrics
}

install_zsh_plugin() {
  local plugin_dir="$SETTINGS_DIR/zsh_plugins"
  local plugin_path="$plugin_dir/${2}"
  local plugin_url="https://github.com/${1}/${2}"

  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$plugin_dir"
    echo "installing ${2}..."
    git clone --depth=1 "$plugin_url" "$plugin_path" \
      || { echo "ERROR: failed to install ${2}" >&2; return 1; }
  fi
}

install_zsh() {
  $INSTALL zsh

  curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/.zshrc \
    -o $HOME/.zshrc

  # # requires ubuntu 26.04 lts
  # $INSTALL starship
  # curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/starship.toml \
  #   -o $SETTINGS_DIR/starship.toml

  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $SETTINGS_DIR/powerlevel10k
  curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/.p10k.zsh \
    -o $SETTINGS_DIR/.p10k.zsh

  install_zsh_plugin zsh-users zsh-autosuggestions

  sudo sed -i 's/auth\(.*\)pam_shells.so/auth sufficient pam_shells.so/' /etc/pam.d/chsh
  chsh -s $(which zsh)
}

clean_up() {
  $UPDATE
  $UPGRADE

  sudo apt-get clean -qq
  sudo apt-get autoclean -qq
  sudo apt-get autoremove -qq

  sudo rm -rf /var/lib/apt/lists/*
}

# -------------------------------------------------- #

$UPDATE
$UPGRADE

reset_dir
enable_ssh_pw_auth
set_pw

cd $WORK_DIR/downloads

curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/tmux.conf \
  -o $SETTINGS_DIR/tmux.conf

install_essentials

install_clang
install_cmake
install_git
install_go
# install_bazel # requires go
install_nodejs
install_pipx
install_conan # requires pipx
install_uv # requires pipx
install_python_virtualenv
# install_rust
install_vcpkg
install_zsh

clean_up

echo 'done!'
echo 'manually configure: git rsa'
