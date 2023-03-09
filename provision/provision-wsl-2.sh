#!/bin/bash

# usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/provision-wsl-2.sh)"

set -e -x

export DEBIAN_FRONTEND=noninteractive

PW=0000

INSTALL='sudo apt-get install -qq'
UPDATE='sudo apt-get update -qq'

WORK_DIR=/work-dir
BIN=$WORK_DIR/bin

sudo rm -rf $WORK_DIR $BIN $WORK_DIR/downloads $WORK_DIR/settings $WORK_DIR/tmp $HOME/.oh-my-zsh || true

sudo mkdir $WORK_DIR
sudo chown $USER $WORK_DIR

mkdir \
  $BIN \
  $WORK_DIR/downloads \
  $WORK_DIR/settings \
  $WORK_DIR/tmp

export PATH=$PATH:$BIN

cd $WORK_DIR/downloads

curl https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/common.sh -o $WORK_DIR/settings/common.sh

curl https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/tmux.conf -o $WORK_DIR/settings/tmux.conf

$UPDATE
sudo apt-get upgrade -qq

# enable ssh password authentication & port 2222

sudo sed -i 's/.*AllowTcpForwarding.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config
sudo sed -i 's/.*GatewayPorts.*/GatewayPorts yes/' /etc/ssh/sshd_config
sudo sed -i 's/.*ListenAddress.*/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config
sudo sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/.*Port.*/Port 2222/' /etc/ssh/sshd_config

sudo service ssh --full-restart

# set root pw
printf "$PW\n$PW\n" | sudo passwd root

# essentials

$INSTALL \
  build-essential \
  busybox \
  clang-12 \
  clang-format-12 \
  colordiff \
  curl \
  git \
  htop \
  jq \
  make \
  openjdk-11-jdk \
  python3-pip \
  python3.8 \
  screenfetch \
  tmux \
  tree \
  vim \
  virtualenv \
  wget \
  zsh

# clang

sudo rm -rf /usr/bin/clang /usr/bin/clang++ /usr/bin/clang-format || true

sudo ln -s /usr/bin/clang-12 /usr/bin/clang
sudo ln -s /usr/bin/clang++-12 /usr/bin/clang++
sudo ln -s /usr/bin/clang-format-12 /usr/bin/clang-format

# docker

$INSTALL \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

$UPDATE

$INSTALL docker-ce docker-ce-cli containerd.io

sudo groupadd docker || true
sudo usermod -aG docker $USER

sudo service docker --full-restart

# gcloud

# https://cloud.google.com/sdk/docs/downloads-interactive
# requires python

curl https://sdk.cloud.google.com > install.sh
bash install.sh --disable-prompts --install-dir=$BIN

ln -s $BIN/google-cloud-sdk/bin/gcloud $BIN/gcloud

# gcloud -q components install kubectl
# ln -s $BIN/google-cloud-sdk/bin/kubectl $BIN/kubectl

# git

git config --global color.ui true

# go

GO_VER=1.19.5
OS=linux
ARCH=amd64
GO_TAR=go$GO_VER.$OS-$ARCH.tar.gz

curl -O https://dl.google.com/go/$GO_TAR
tar --no-same-owner -xzf $GO_TAR -C $BIN

# nginx

$INSTALL nginx

sudo service nginx stop

# nodejs

curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
$INSTALL nodejs

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
$UPDATE
$INSTALL yarn

# python

virtualenv -p $(which python3.8) $WORK_DIR/py3.8_env

source $WORK_DIR/py3.8_env/bin/activate

pip install \
  diagrams \
  flask \
  flask-cors \
  ipython \
  jupyter \
  matplotlib \
  numpy \
  pandas \
  pytest \
  PyYAML \
  requests \
  yapf

# zsh

sudo sed -i 's/auth\(.*\)pam_shells.so/auth sufficient pam_shells.so/' /etc/pam.d/chsh

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sed -i 's/ZSH_THEME="\(.*\)"/ZSH_THEME="candy"/' $HOME/.zshrc

chsh -s $(which zsh)

printf "\nsource $WORK_DIR/settings/common.sh\n" | tee -a $HOME/.zshrc

# clean up

$UPDATE
sudo apt-get upgrade -qq

sudo apt-get clean -qq
sudo apt-get autoclean -qq
sudo apt-get autoremove -qq

echo 'done!'
echo 'manually configure: git rsa'
