#!/bin/bash

# usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/provision-dev-server.sh)"

set -e -x

export DEBIAN_FRONTEND=noninteractive

export ARCH=$(dpkg --print-architecture)

PW=0000

INSTALL='sudo apt-get install -qq'
UPDATE='sudo apt-get update -qq'
UPGRADE='sudo apt-get upgrade -qq'

WORK_DIR=/work-dir
BIN=$WORK_DIR/bin

export PATH=$PATH:$BIN

# -------------------------------------------------- #

reset_dir() {
  sudo rm -rf $WORK_DIR $HOME/.oh-my-zsh || true

  sudo mkdir $WORK_DIR
  sudo chown $USER $WORK_DIR

  mkdir \
    $BIN \
    $WORK_DIR/downloads \
    $WORK_DIR/settings \
    $WORK_DIR/tmp
}

enable_ssh_pw_auth() {
  sudo sed -i 's/^#\?AllowTcpForwarding.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?GatewayPorts.*/GatewayPorts yes/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

  sudo systemctl reload sshd
}

set_timezone() {
  sudo timedatectl set-timezone America/New_York
}

set_pw() {
  printf "$PW\n$PW\n" | sudo passwd root
  printf "$PW\n$PW\n" | sudo passwd $USER || true
}

set_ufw_firewall() {
  sudo ufw --force enable

  sudo ufw allow http
  sudo ufw allow https
  sudo ufw allow ssh

  sudo ufw allow 3000
  sudo ufw allow 3001
  sudo ufw allow 8080
  sudo ufw allow 8081
}

install_essentials() {
  $INSTALL \
    autossh \
    build-essential \
    busybox \
    colordiff \
    curl \
    ethtool \
    hping3 \
    htop \
    iproute2 \
    iputils-ping \
    jq \
    libboost-all-dev \
    libomp-dev \
    make \
    net-tools \
    openjdk-11-jdk \
    openssl \
    protobuf-compiler \
    screenfetch \
    sipcalc \
    sshfs \
    tmux \
    tree \
    unzip \
    vim \
    wget \
    zip
}

install_clang_latest() {
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
}

install_clang() {
  $INSTALL clang-12 clang-format-12

  sudo ln -s /usr/bin/clang-12 /usr/bin/clang
  sudo ln -s /usr/bin/clang++-12 /usr/bin/clang++

  sudo ln -s /usr/bin/clang-format-12 /usr/bin/clang-format
}

install_docker() {
  $INSTALL \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  $UPDATE

  $INSTALL docker-ce docker-ce-cli containerd.io

  sudo groupadd docker || true
  sudo usermod -aG docker $USER

  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

  sudo chmod +x /usr/local/bin/docker-compose

  sudo curl \
    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
    -o /etc/bash_completion.d/docker-compose
}

setup_ebpf_dev() {
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
}

install_git() {
  $INSTALL git
  git config --global color.ui true
}

install_go() {
  GO_VER=1.20.2
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
  sudo ln -s $BIN/$BAZELISK $BIN/bazel
  bazel --version

  # requires go
  go install github.com/bazelbuild/buildtools/buildifier@latest
}

install_julia() {
  JULIA_VER=1.6.7
  OS=linux
  JULIA_TAR=julia-$JULIA_VER-$OS-x86_64.tar.gz

  curl -O https://julialang-s3.julialang.org/bin/linux/x64/1.6/$JULIA_TAR
  tar --no-same-owner -xzf $JULIA_TAR -C $BIN

  export PATH=$PATH:$BIN/julia-$JULIA_VER/bin
}

install_microk8s() {
  sudo snap install microk8s --classic

  sudo usermod -aG microk8s $USER
  sudo chown -f -R $USER ~/.kube || true

  sudo microk8s stop
}

install_nodejs() {
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  $INSTALL nodejs

  sudo npm install --global yarn

  printf "fs.inotify.max_user_watches = 1048576\n" | sudo tee -a /etc/sysctl.conf
  sudo sysctl -p

  $UPDATE
  $INSTALL yarn
}

install_python() {
  PY_VER=3.9

  $INSTALL python3-pip python$PY_VER virtualenv

  virtualenv -p $(which python$PY_VER) $WORK_DIR/py${PY_VER}_env

  source $WORK_DIR/py${PY_VER}_env/bin/activate

  pip install \
    diagrams \
    grpcio \
    grpcio-tools \
    ipython \
    jupyter \
    matplotlib \
    numpy \
    pandas \
    pytest \
    PyYAML \
    requests \
    yapf
}

install_gcloud() {
  # https://cloud.google.com/sdk/docs/downloads-interactive
  # requires python

  curl https://sdk.cloud.google.com > install.sh
  bash install.sh --disable-prompts --install-dir=$BIN

  ln -s $BIN/google-cloud-sdk/bin/gcloud $BIN/gcloud

  # gcloud -q components install kubectl
  # ln -s $BIN/google-cloud-sdk/bin/kubectl $BIN/kubectl
}

install_ruby() {
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
}

install_rust() {
  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
}

install_mongodb() {
  MONGO_VER=6.0

  $INSTALL gnupg

  wget -qO - https://www.mongodb.org/static/pgp/server-$MONGO_VER.asc | sudo apt-key add -

  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/$MONGO_VER multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-$MONGO_VER.list

  $UPDATE

  $INSTALL mongodb-org

  sudo systemctl start mongod

  sudo sed -i 's/bindIp: \(.*\)/bindIp: 0.0.0.0/' /etc/mongod.conf

  sudo ufw allow 27017

  # sudo systemctl enable mongod
  # sudo systemctl restart mongod
  sudo systemctl stop mongod
  sudo systemctl disable mongod
}

install_nginx() {
  $INSTALL nginx

  sudo systemctl stop nginx
  sudo systemctl disable nginx
}

install_postgresql() {
  sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

  $UPDATE

  $INSTALL postgresql-13

  printf "listen_addresses = '*'\n" | sudo tee -a /etc/postgresql/13/main/postgresql.conf

  printf "ALTER USER postgres with encrypted password '$PW';\n\\q" | sudo -u postgres psql

  printf 'host all all 0.0.0.0/0 md5\n' | sudo tee -a /etc/postgresql/13/main/pg_hba.conf

  sudo ufw allow 5432

  # sudo systemctl enable postgresql.service
  # sudo systemctl restart postgresql.service
  sudo systemctl stop postgresql.service
  sudo systemctl disable postgresql.service
}

install_zsh() {
  $INSTALL zsh

  sudo sed -i 's/auth\(.*\)pam_shells.so/auth sufficient pam_shells.so/' /etc/pam.d/chsh

  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  sed -i 's/ZSH_THEME="\(.*\)"/ZSH_THEME="candy"/' $HOME/.zshrc

  chsh -s $(which zsh)

  printf "\nsource $WORK_DIR/settings/common.sh\n" | tee -a $HOME/.zshrc
}

clean_up() {
  sudo ufw status

  $UPDATE
  $UPGRADE

  sudo apt-get clean -qq
  sudo apt-get autoclean -qq
  sudo apt-get autoremove -qq
}

# -------------------------------------------------- #

$UPDATE
$UPGRADE

reset_dir
enable_ssh_pw_auth
set_timezone
set_pw
set_ufw_firewall

cd $WORK_DIR/downloads

curl https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/common.sh -o $WORK_DIR/settings/common.sh

curl https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/tmux.conf -o $WORK_DIR/settings/tmux.conf

install_essentials

# install_clang_latest
# install_mongodb
# install_postgresql
# install_ruby
# install_rust
# setup_ebpf_dev
install_clang
install_docker
install_git
install_go
install_bazel
install_microk8s
install_nginx
install_nodejs
install_python
install_gcloud # requires python
install_zsh

clean_up

echo 'done!'
echo 'manually configure: git rsa'

sudo reboot
