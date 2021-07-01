#!/bin/bash

# usage: bash -c "$(curl -fsSL https://raw.github.com/david0922/hello-world/master/provision/provision-dev-server.sh)"

set -e -x

export DEBIAN_FRONTEND=noninteractive

INSTALL='sudo apt-get install -qq'
UPDATE='sudo apt-get update -qq'

WORK_DIR=/work-dir
BIN=$WORK_DIR/bin

sudo rm -rf $WORK_DIR $BIN $WORK_DIR/downloads $WORK_DIR/settings $WORK_DIR/tmp || true

sudo mkdir $WORK_DIR
sudo chown $USER $WORK_DIR

mkdir \
  $BIN \
  $WORK_DIR/downloads \
  $WORK_DIR/settings \
  $WORK_DIR/tmp

export PATH=$PATH:$BIN

cd $WORK_DIR/downloads

wget https://raw.github.com/david0922/hello-world/master/provision/common.sh -O $WORK_DIR/settings/common.sh

wget https://raw.github.com/david0922/hello-world/master/provision/tmux.conf -O $WORK_DIR/settings/tmux.conf

printf "\nsource $WORK_DIR/settings/common.sh\n" | tee -a $HOME/.bashrc

$UPDATE
sudo apt-get upgrade -qq

# enable ssh password authentication

sudo sed -i 's/.*AllowTcpForwarding.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config
sudo sed -i 's/.*GatewayPorts.*/GatewayPorts yes/' /etc/ssh/sshd_config
sudo sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

sudo systemctl reload sshd

# set root pw
printf "0000\n0000\n" | sudo passwd root

# ufw firewall

sudo ufw --force enable

sudo ufw allow http
sudo ufw allow https
sudo ufw allow ssh

# essentials

$INSTALL \
  build-essential \
  busybox \
  colordiff \
  curl \
  ethtool \
  git \
  hping3 \
  htop \
  iproute2 \
  iputils-ping \
  jq \
  libomp-dev \
  make \
  net-tools \
  openjdk-11-jdk \
  openssl \
  python3-pip \
  python3.8 \
  screenfetch \
  sipcalc \
  sshfs \
  tmux \
  tree \
  vim \
  virtualenv \
  wget \
  zsh

# clang & llvm

# https://apt.llvm.org/

$INSTALL gnupg lsb-release software-properties-common

$UPDATE

wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 12

$INSTALL clang-format-12

sudo mv /usr/bin/readelf /usr/bin/readelf_old || true

sudo rm -rf /usr/bin/clang /usr/bin/clang++ /usr/bin/llc /usr/bin/readelf /usr/bin/clang-format || true

sudo ln -s /usr/bin/clang-12 /usr/bin/clang
sudo ln -s /usr/bin/clang++-12 /usr/bin/clang++
sudo ln -s /usr/lib/llvm-12/bin/llc /usr/bin/llc
sudo ln -s /usr/lib/llvm-12/bin/llvm-readelf /usr/bin/readelf
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

# ebpf

if false; then
  $INSTALL \
    bpfcc-tools \
    build-essential \
    gcc-multilib \
    libelf-dev \
    linux-headers-$(uname -r) \
    strace

  git clone --depth 1 git://kernel.ubuntu.com/ubuntu/ubuntu-focal.git

  sudo mv ubuntu-focal /kernel-src

  cd /kernel-src/tools/lib/bpf
  make && make install prefix=/usr/local
fi

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

GO_VER=1.16.4
OS=linux
ARCH=amd64
GO_TAR=go$GO_VER.$OS-$ARCH.tar.gz

curl -O https://dl.google.com/go/$GO_TAR
tar --no-same-owner -xzf $GO_TAR -C $BIN

# microk8s

sudo snap install microk8s --classic

sudo usermod -aG microk8s $USER
sudo chown -f -R $USER ~/.kube || true

sudo microk8s stop

# nodejs

curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
$INSTALL nodejs

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
$UPDATE
$INSTALL yarn

# python

virtualenv -p $(which python3.8) $WORK_DIR/py3.8_env

source $WORK_DIR/py3.8_env/bin/activate

pip install \
  beautifulsoup4 \
  diagrams \
  flask \
  flask-cors \
  ipython \
  jupyter \
  matplotlib \
  numpy \
  pandas \
  requests \
  selenium \
  webdriver-manager \
  yapf

# ruby

RB_ENV=$BIN/rbenv

$INSTALL libssl-dev zlib1g-dev

git clone https://github.com/rbenv/rbenv.git $RB_ENV
git clone https://github.com/rbenv/ruby-build.git $RB_ENV/plugins/ruby-build

export PATH=$PATH:$RB_ENV/bin:$RB_ENV/plugins/ruby-build/bin

eval "$(rbenv init -)"

rbenv install 3.0.0
rbenv global 3.0.0

gem install rails

rbenv rehash

# MongoDB

$INSTALL gnupg

wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list

$UPDATE

$INSTALL mongodb-org

sudo systemctl start mongod

sudo sed -i 's/bindIp: "\(.*\)"/bindIp: "0.0.0.0"/' /etc/mongod.conf

sudo ufw allow 27017

# sudo systemctl enable mongod
# sudo systemctl restart mongod
sudo systemctl stop mongod
sudo systemctl disable mongod

# nginx

$INSTALL nginx

sudo systemctl stop nginx
sudo systemctl disable nginx

# PostgreSQL

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

$UPDATE

$INSTALL postgresql-13

printf "listen_addresses = '*'" | sudo tee -a /etc/postgresql/13/main/postgresql.conf

printf "ALTER USER postgres with encrypted password '0000';\n\\q" | sudo -u postgres psql

printf 'host all all 0.0.0.0/0 md5' | sudo tee -a /etc/postgresql/13/main/pg_hba.conf

sudo ufw allow 5432

# sudo systemctl enable postgresql.service
# sudo systemctl restart postgresql.service
sudo systemctl stop postgresql.service
sudo systemctl disable postgresql.service

# clean up

sudo ufw status

$UPDATE
sudo apt-get upgrade -qq

sudo apt-get clean -qq
sudo apt-get autoclean -qq
sudo apt-get autoremove -qq

echo 'done!'
echo 'manually configure: git rsa, zsh'
