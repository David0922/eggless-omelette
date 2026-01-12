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

  sudo ln -s $WORK_DIR /$USER

  mkdir \
    $BIN \
    $WORK_DIR/downloads \
    $WORK_DIR/projects \
    $WORK_DIR/settings \
    $WORK_DIR/tmp
}

enable_ssh_pw_auth() {
  sudo sed -i 's/^#\?AllowTcpForwarding.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?GatewayPorts.*/GatewayPorts yes/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

  # sudo systemctl reload ssh.service
}

set_timezone() {
  sudo timedatectl set-timezone UTC
  # sudo timedatectl set-timezone America/New_York
}

set_pw() {
  printf "$PW\n$PW\n" | sudo passwd root
  printf "$PW\n$PW\n" | sudo passwd $USER || true
}

set_ufw_firewall() {
  $UPDATE
  $INSTALL ufw

  sudo ufw --force enable

  sudo ufw allow http
  sudo ufw allow https
  sudo ufw allow ssh

  sudo ufw allow 2222
  sudo ufw allow 3000
  sudo ufw allow 3001
  sudo ufw allow 8080
  sudo ufw allow 8081
}

install_essentials() {
  $INSTALL \
    autossh \
    build-essential \
    colordiff \
    curl \
    htop \
    jq \
    sshfs \
    tmux \
    tree \
    vim \
    wget
    # busybox \
    # cmake \
    # ethtool \
    # hping3 \
    # iproute2 \
    # iputils-ping \
    # libboost-all-dev \
    # libomp-dev \
    # make \
    # openjdk-21-jdk \
    # openssl \
    # protobuf-compiler \
    # screenfetch \
    # sipcalc \
    # unzip \
    # zip \
}

install_clang_latest() {
  # https://apt.llvm.org/

  CLANG_VER=20

  $INSTALL gnupg lsb-release software-properties-common

  $UPDATE

  wget https://apt.llvm.org/llvm.sh
  chmod +x llvm.sh
  sudo ./llvm.sh $CLANG_VER

  $INSTALL clang-format-$CLANG_VER

  sudo mv /usr/bin/readelf /usr/bin/readelf_old || true

  sudo rm -rf \
    /usr/bin/clang \
    /usr/bin/clang-format \
    /usr/bin/clang++ \
    /usr/bin/ld.lld \
    /usr/bin/llc \
    /usr/bin/readelf \
    /usr/bin/lld \
  || true

  sudo ln -s /usr/bin/clang-$CLANG_VER /usr/bin/clang
  sudo ln -s /usr/bin/clang-format-$CLANG_VER /usr/bin/clang-format
  sudo ln -s /usr/bin/clang++-$CLANG_VER /usr/bin/clang++
  sudo ln -s /usr/bin/ld.lld-$CLANG_VER /usr/bin/ld.lld
  sudo ln -s /usr/bin/lld-$CLANG_VER /usr/bin/lld
  sudo ln -s /usr/lib/llvm-$CLANG_VER/bin/llc /usr/bin/llc
  sudo ln -s /usr/lib/llvm-$CLANG_VER/bin/llvm-readelf /usr/bin/readelf
}

install_clang() {
  CLANG_VER=19

  $INSTALL clang-$CLANG_VER clang-format-$CLANG_VER

  sudo ln -s $(realpath /usr/bin/clang-$CLANG_VER) /usr/bin/clang
  sudo ln -s $(realpath /usr/bin/clang++-$CLANG_VER) /usr/bin/clang++

  sudo ln -s $(realpath /usr/bin/clang-format-$CLANG_VER) /usr/bin/clang-format
}

install_cmake() {
  CMAKE_VER=v4.2.1

  $INSTALL libssl-dev openssl

  git clone --branch $CMAKE_VER --depth 1 https://github.com/Kitware/CMake.git
  cd CMake
  ./bootstrap && make && sudo make install

  cd ..
}

install_docker() {
  $INSTALL \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    uidmap

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  $UPDATE

  $INSTALL docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  sudo groupadd docker || true
  sudo usermod -aG docker $USER

  # sudo systemctl disable --now docker.service docker.socket
  # sudo rm -rf /var/run/docker.sock
  # dockerd-rootless-setuptool.sh install
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

  cd $WORK_DIR/downloads
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

install_julia() {
  JULIA_VER=1.6.7
  OS=linux
  JULIA_TAR=julia-$JULIA_VER-$OS-x86_64.tar.gz

  curl -O https://julialang-s3.julialang.org/bin/linux/x64/1.6/$JULIA_TAR
  tar -xzf $JULIA_TAR -C $BIN --no-same-owner

  export PATH=$PATH:$BIN/julia-$JULIA_VER/bin
}

install_microk8s() {
  sudo snap install microk8s --classic

  sudo usermod -aG microk8s $USER
  sudo chown -f -R $USER ~/.kube || true

  sudo microk8s stop
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

  printf "fs.inotify.max_user_watches = 1048576\n" | sudo tee -a /etc/sysctl.conf
  sudo sysctl -p
}

install_python_micromamba() {
  PY_VER=3.11  # grpcio-tools hasn't supported python 3.12
  PY_ENV_PREFIX=$BIN/py$PY_VER

  curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
  mv ./bin/micromamba $BIN/micromamba
  rm -rf ./bin

  export MAMBA_ROOT_PREFIX=$BIN/micromamba_root
  eval "$(micromamba shell hook -s posix)"

  printf "channels:\n  - conda-forge\n" | tee $HOME/.condarc

  micromamba --yes create --prefix $PY_ENV_PREFIX \
    python=$PY_VER \
    diagrams \
    ipython \
    isort \
    jupyter \
    matplotlib \
    numpy \
    pandas \
    plotly \
    pytest \
    PyYAML \
    requests \
    yapf
    # grpcio \
    # grpcio-tools \
    # pyspark \

  micromamba activate $PY_ENV_PREFIX
}

install_python_venv() {
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

  python$PY_VER -m venv $PY_ENV_PREFIX

  source $PY_ENV_PREFIX/bin/activate

  pip install \
    diagrams \
    ipython \
    isort \
    jupyter \
    matplotlib \
    numpy \
    pandas \
    plotly \
    pytest \
    PyYAML \
    requests \
    yapf
    # grpcio \
    # grpcio-tools \
    # pyspark \
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
    diagrams \
    ipython \
    isort \
    jupyter \
    matplotlib \
    numpy \
    pandas \
    plotly \
    pytest \
    PyYAML \
    requests \
    yapf
    # grpcio \
    # grpcio-tools \
    # pyspark \
}

install_gcloud() {
  # https://cloud.google.com/sdk/docs/downloads-interactive
  # requires python

  curl https://sdk.cloud.google.com > install.sh
  bash install.sh --disable-prompts --install-dir=$BIN

  ln -s $BIN/google-cloud-sdk/bin/gcloud $BIN/gcloud

  gcloud config set disable_usage_reporting false

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

install_conan() {
  # requires uv
  uv tool install conan
}

install_vcpkg() {
  cd $BIN
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

install_clang
# install_clang_latest
# setup_ebpf_dev
# install_cmake
install_docker
install_git
install_go
install_bazel # requires go
# install_julia
# install_microk8s
# install_mongodb
# install_nginx
install_nodejs
# install_postgresql
# install_python_micromamba
# install_python_venv
install_python_virtualenv
# install_gcloud # requires python
# install_ruby
install_rust
install_uv # requires rust
install_conan # requires uv
install_vcpkg
install_zsh

clean_up

echo 'done!'
echo 'manually configure: git rsa'

sudo reboot
