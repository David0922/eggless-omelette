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

export PATH=$PATH:$BIN

# -------------------------------------------------- #

reset_dir() {
  rm -rf $WORK_DIR $HOME/.oh-my-zsh || true

  mkdir $WORK_DIR

  mkdir \
    $BIN \
    $WORK_DIR/downloads \
    $WORK_DIR/settings \
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
  GO_VER=1.24.2
  OS=linux
  GO_TAR=go$GO_VER.$OS-$ARCH.tar.gz

  curl -O https://dl.google.com/go/$GO_TAR
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

install_python_virtualenv() {
  case $(lsb_release -a | grep -i release | awk '{print $2}') in
    20.04)
      PY_VER=3.9
      ;;
    22.04)
      PY_VER=3.10
      ;;
    24.04)
      PY_VER=3.12
      ;;
    *)
      echo 'this script is expected to be run in ubuntu 20.04 / 22.04 / 24.04'
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
}

install_rust() {
  mkdir -p $BIN/rust

  export RUSTUP_HOME=$BIN/rust/.rustup
  export CARGO_HOME=$BIN/rust/.cargo

  export PATH=$PATH:$CARGO_HOME/bin

  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
}

install_uv() {
  # https://docs.astral.sh/uv/getting-started/installation/#cargo
  # requires rust

  export UV_PYTHON_BIN_DIR=$BIN/uv/python_bin
  export UV_PYTHON_INSTALL_DIR=$BIN/uv/python_install
  export UV_TOOL_BIN_DIR=$BIN/uv/tool_bin
  export UV_TOOL_DIR=$BIN/uv/tool

  export PATH=$PATH:$UV_PYTHON_BIN_DIR
  export PATH=$PATH:$UV_TOOL_BIN_DIR

  cargo install --locked uv
}

install_conan() {
  # requires uv
  uv tool install conan
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

install_zsh() {
  $INSTALL zsh

  sed -i 's/auth\(.*\)pam_shells.so/auth sufficient pam_shells.so/' /etc/pam.d/chsh

  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  sed -i 's/ZSH_THEME="\(.*\)"/ZSH_THEME="candy"/' $HOME/.zshrc

  chsh -s $(which zsh)

  printf "\nsource $WORK_DIR/settings/common.sh\n" | tee -a $HOME/.zshrc
}

clean_up() {
  $UPDATE
  $UPGRADE

  apt-get clean -qq
  apt-get autoclean -qq
  apt-get autoremove -qq
}

# -------------------------------------------------- #

$UPDATE
$UPGRADE

reset_dir
enable_ssh_pw_auth
set_pw

cd $WORK_DIR/downloads

curl https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/common.sh -o $WORK_DIR/settings/common.sh

curl https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/tmux.conf -o $WORK_DIR/settings/tmux.conf

install_essentials

install_clang
install_git
install_go
install_bazel # requires go
install_nodejs
install_python_virtualenv
install_rust
install_uv # requires rust
install_conan # requires uv
install_vcpkg
install_zsh

clean_up

echo 'done!'
echo 'manually configure: git rsa'
