#!/bin/bash

# usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/provision-dev-container.sh)"

set -e -x

export DEBIAN_FRONTEND=noninteractive

export ARCH=$(dpkg --print-architecture)

PW=0000

INSTALL='apt-get install -qq'
UPDATE='apt-get update -qq'
UPGRADE='apt-get upgrade -qq'

WORK_DIR=/work-dir
BIN=$WORK_DIR/bin
SETTINGS_DIR=$WORK_DIR/settings

export PATH=$PATH:$BIN

# -------------------------------------------------- #

reset_dir() {
  rm -rf $WORK_DIR || true

  mkdir $WORK_DIR

  mkdir \
    $BIN \
    $SETTINGS_DIR \
    $WORK_DIR/downloads \
    $WORK_DIR/tmp
}

enable_ssh_pw_auth() {
  $INSTALL openssh-server

  printf '%s\n' \
    'AllowTcpForwarding yes' \
    'GatewayPorts yes' \
    'PasswordAuthentication yes' \
    'PermitRootLogin yes' | tee /etc/ssh/sshd_config.d/devbox.conf

  # service ssh restart || true
  # systemctl restart ssh.service || true
}

set_pw() {
  printf "$PW\n$PW\n" | passwd root
}

install_essentials() {
  $INSTALL \
    build-essential \
    busybox \
    cmake \
    colordiff \
    curl \
    htop \
    iputils-ping \
    jq \
    make \
    screenfetch \
    tmux \
    tree \
    vim \
    wget
    # autossh \
    # libboost-all-dev \
    # openjdk-21-jdk \
    # openssl \
    # protobuf-compiler \
    # unzip \
    # zip \
}

install_clang() {
  CLANG_VER=19

  $INSTALL clang-$CLANG_VER clang-format-$CLANG_VER

  ln -s $(realpath /usr/bin/clang-$CLANG_VER) /usr/bin/clang
  ln -s $(realpath /usr/bin/clang++-$CLANG_VER) /usr/bin/clang++

  ln -s $(realpath /usr/bin/clang-format-$CLANG_VER) /usr/bin/clang-format
}

install_git() {
  $INSTALL git
  git config --global color.ui true
}

install_go() {
  GO_VER=1.26.7
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

  NODE_VER=22

  # https://github.com/nodesource/distributions?tab=readme-ov-file#using-ubuntu-nodejs-22
  $INSTALL curl
  curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh
  sudo -E bash nodesource_setup.sh
  $UPDATE
  $INSTALL nodejs

  npm install --global pnpm@latest-10 yarn

  printf "fs.inotify.max_user_watches = 1048576\n" | tee -a /etc/sysctl.conf
  sysctl -p
}

install_pipx() {
  export PIPX_HOME=$BIN/pipx_home
  export PIPX_BIN_DIR=$BIN/pipx_bin

  export PATH=$PATH:$PIPX_BIN_DIR

  mkdir -p $PIPX_HOME $PIPX_BIN_DIR

  $INSTALL pipx
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

install_conan() {
  # requires pipx
  pipx install conan
}

install_vcpkg() {
  cd $BIN
  $INSTALL curl tar unzip zip
  $INSTALL pkg-config
  git clone --branch 2025.01.13 --depth 1 https://github.com/microsoft/vcpkg.git
  cd vcpkg
  git fetch origin tag 2025.12.12
  git checkout 2025.12.12
  ./bootstrap-vcpkg.sh -disableMetrics
  cd $WORK_DIR/downloads
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

  sed -i 's/auth\(.*\)pam_shells.so/auth sufficient pam_shells.so/' /etc/pam.d/chsh
  chsh -s $(which zsh)
}

clean_up() {
  $UPDATE
  $UPGRADE

  apt-get clean -qq
  apt-get autoremove -qq

  rm -rf /var/lib/apt/lists/*
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
install_git
install_go
# install_bazel # requires go
install_nodejs
install_pipx
install_python_virtualenv
# install_rust
install_uv # requires pipx
install_conan # requires pipx
install_vcpkg
install_zsh

clean_up

echo 'done!'
echo 'manually configure: git rsa'
