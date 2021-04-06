#!/bin/bash

# usage: sh -c "$(curl -fsSL https://raw.github.com/david0922/hello-world/master/provision/provision-dev-server.sh)"

set -e -x

export DEBIAN_FRONTEND=noninteractive

INSTALL='sudo apt-get install -qq'
UPDATE='sudo apt-get update -qq'

DAVID=/david
BIN=$DAVID/bin

mkdir -p $DAVID
sudo chown $USER $DAVID

mkdir -p \
  $BIN \
  $DAVID/downloads \
  $DAVID/settings \
  $DAVID/tmp

cd $DAVID/downloads

wget https://raw.github.com/david0922/hello-world/master/provision/common.sh $DAVID/settings

$UPDATE
sudo apt-get upgrade -y

$INSTALL

# essentials

$INSTALL \
  build-essential \
  busybox \
  colordiff \
  curl \
  git \
  htop \
  make \
  net-tools \
  python3-pip \
  python3.8 \
  screenfetch \
  tmux \
  tree \
  vim \
  virtualenv \
  wget \
  zsh

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

# git

git config --global color.ui true

# go

GO_VER=1.16.2
OS=linux
ARCH=amd64
GO_TAR=go$GO_VER.$OS-$ARCH.tar.gz

curl -O https://dl.google.com/go/$GO_TAR
tar --no-same-owner -xzf $GO_TAR -C $BIN

# nodejs

curl -fsSL https://deb.nodesource.com/setup_15.x | sudo -E bash -

$INSTALL nodejs

# python

virtualenv -p $(which python3.8) $DAVID/py3.8_env

source $DAVID/py3.8_env/bin/activate

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

sudo systemctl enable mongod
sudo systemctl restart mongod

# PostgreSQL

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

$UPDATE

$INSTALL postgresql-13

printf "listen_addresses = '*'" | sudo tee -a /etc/postgresql/13/main/postgresql.conf

printf "ALTER USER postgres with encrypted password '0000';\n\\q" | sudo -u postgres psql

printf 'host all all 0.0.0.0/0 md5' | sudo tee -a /etc/postgresql/13/main/pg_hba.conf

sudo ufw allow 5432

sudo systemctl enable postgresql.service
sudo systemctl restart postgresql.service

# zsh

sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sed -i 's/ZSH_THEME="\(.*\)"/ZSH_THEME="eastwood"/' ~/.zshrc
printf 'source /david/settings/common.sh' >> ~/.zshrc

# clean up

$UPDATE
sudo apt-get -y upgrade

sudo apt-get -y clean
sudo apt-get -y autoclean
sudo apt-get -y autoremove

echo 'done!'
