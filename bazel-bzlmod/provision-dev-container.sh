#!/bin/bash

set -e -x

export DEBIAN_FRONTEND=noninteractive

export ARCH=$(dpkg --print-architecture)

PW=0000

INSTALL='apt-get install -qq'
UPDATE='apt-get update -qq'
UPGRADE='apt-get upgrade -qq'

WORK_DIR=/work-dir
BIN=$WORK_DIR/bin
THIRD_PARTY=$WORK_DIR/3rd-party

mkdir -p $WORK_DIR $BIN $THIRD_PARTY $WORK_DIR/settings

export PATH=$BIN:$PATH

# -------------------------------------------------- #

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
    build-essential \
    bzip2 \
    cmake \
    colordiff \
    curl \
    git \
    jq \
    less \
    make \
    tmux \
    vim \
    wget
}

install_clang() {
  CLANG_VER=18

  $INSTALL clang-$CLANG_VER clang-format-$CLANG_VER

  ln -s $(realpath /usr/bin/clang-$CLANG_VER) $BIN/clang
  ln -s $(realpath /usr/bin/clang++-$CLANG_VER) $BIN/clang++

  ln -s $(realpath /usr/bin/clang-format-$CLANG_VER) $BIN/clang-format
}

install_go() {
  GO_VER=1.22.3
  OS=linux
  GO_TAR=go$GO_VER.$OS-$ARCH.tar.gz

  curl -O https://dl.google.com/go/$GO_TAR
  tar -xzf $GO_TAR -C $BIN --no-same-owner || true

  export GOPATH=$WORK_DIR/projects/go
  export PATH=$PATH:$BIN/go/bin:$WORK_DIR/projects/go/bin
}

install_bazel() {
  BAZELISK=bazelisk-linux-$ARCH

  wget https://github.com/bazelbuild/bazelisk/releases/download/v1.20.0/$BAZELISK
  chmod +x ./$BAZELISK
  mv ./$BAZELISK $BIN
  ln -s $BIN/$BAZELISK $BIN/bazel
  bazel --version

  # requires go
  go install github.com/bazelbuild/buildtools/buildifier@latest
}

install_python_micromamba() {
  PY_VER=3.12
  PY_ENV_PREFIX=$BIN/py$PY_VER

  curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
  mv ./bin/micromamba $BIN/micromamba
  rm -rf ./bin

  export MAMBA_ROOT_PREFIX=$BIN/micromamba_root
  eval "$(micromamba shell hook -s posix)"

  printf "channels:\n  - conda-forge\n" | tee $HOME/.condarc

  micromamba --yes create python=$PY_VER \
    --file /tmp/requirements.txt \
    --prefix $PY_ENV_PREFIX

  micromamba activate $PY_ENV_PREFIX
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

enable_ssh_pw_auth
set_pw

cd /tmp

mv /tmp/common.sh $WORK_DIR/settings/common.sh

curl https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/tmux.conf -o $WORK_DIR/settings/tmux.conf

install_essentials

install_clang
install_go
install_bazel
install_python_micromamba
install_zsh

clean_up

echo 'done!'
