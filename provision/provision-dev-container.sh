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
  systemctl restart sshd || true
}

set_pw() {
  printf "$PW\n$PW\n" | passwd root
}

install_essentials() {
  $INSTALL \
    autossh \
    build-essential \
    busybox \
    cmake \
    colordiff \
    curl \
    htop \
    jq \
    libboost-all-dev \
    make \
    openjdk-21-jdk \
    openssl \
    protobuf-compiler \
    screenfetch \
    tmux \
    tree \
    unzip \
    vim \
    wget \
    zip
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
  GO_VER=1.21.5
  OS=linux
  GO_TAR=go$GO_VER.$OS-$ARCH.tar.gz

  curl -O https://dl.google.com/go/$GO_TAR
  tar --no-same-owner -xzf $GO_TAR -C $BIN

  export GOPATH=$WORK_DIR/projects/go
  export PATH=$PATH:$BIN/go/bin:$WORK_DIR/projects/go/bin

  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
}

install_bazel() {
  BAZELISK=bazelisk-linux-$ARCH

  wget https://github.com/bazelbuild/bazelisk/releases/download/v1.12.0/$BAZELISK
  chmod +x ./$BAZELISK
  mv ./$BAZELISK $BIN
  ln -s $BIN/$BAZELISK $BIN/bazel
  bazel --version

  # requires go
  go install github.com/bazelbuild/buildtools/buildifier@latest
}

install_nodejs() {
  NODE_VER=20

  # https://github.com/nodesource/distributions#nodejs
  $INSTALL ca-certificates curl gnupg
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VER.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

  $UPDATE
  $INSTALL nodejs

  npm install --global yarn

  printf "fs.inotify.max_user_watches = 1048576\n" | tee -a /etc/sysctl.conf
  sysctl -p
}

install_python_virtualenv() {
  case $(lsb_release -r -s) in
    20.04)
      PY_VER=3.9
      ;;
    22.04)
      PY_VER=3.10
      ;;
    *)
      echo 'this script is expected to be run in ubuntu 20.04 / 22.04'
      exit 1
      ;;
  esac

  PY_ENV_PREFIX=$BIN/py$PY_VER

  $INSTALL python3-pip python$PY_VER virtualenv

  virtualenv -p $(which python$PY_VER) $PY_ENV_PREFIX

  source $PY_ENV_PREFIX/bin/activate

  pip install \
    diagrams \
    grpcio \
    grpcio-tools \
    ipython \
    isort \
    jupyter \
    matplotlib \
    numpy \
    pandas \
    plotly \
    pyspark \
    pytest \
    PyYAML \
    requests \
    yapf
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
install_bazel
install_nodejs
install_python_virtualenv
install_zsh

clean_up

echo 'done!'
echo 'manually configure: git rsa'
