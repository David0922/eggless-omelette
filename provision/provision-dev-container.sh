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

  sed -i 's/^#\?AllowTcpForwarding.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config
  sed -i 's/^#\?GatewayPorts.*/GatewayPorts yes/' /etc/ssh/sshd_config
  sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

  service ssh restart || true
  systemctl restart ssh.service || true
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
  CLANG_VER=15

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
    # conan \
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
# install_bazel # requires go
# install_nodejs
install_python_virtualenv
install_zsh

clean_up

echo 'done!'
echo 'manually configure: git rsa'
