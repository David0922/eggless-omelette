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
SETTINGS_DIR=$WORK_DIR/settings

export PATH=$PATH:$BIN

# -------------------------------------------------- #

reset_dir() {
  sudo rm -rf $WORK_DIR || true

  sudo mkdir $WORK_DIR
  sudo chown $USER $WORK_DIR

  sudo ln -s $WORK_DIR /$USER

  mkdir \
    $BIN \
    $SETTINGS_DIR \
    $WORK_DIR/downloads \
    $WORK_DIR/projects \
    $WORK_DIR/tmp
}

enable_ssh_pw_auth() {
  printf '%s\n' \
    'AllowTcpForwarding yes' \
    'GatewayPorts yes' \
    'PasswordAuthentication yes' \
    'PermitRootLogin yes' | sudo tee /etc/ssh/sshd_config.d/devbox.conf

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

install_julia() {
  JULIA_VER=1.6.7
  OS=linux
  JULIA_TAR=julia-$JULIA_VER-$OS-x86_64.tar.gz

  curl -fsSL -O https://julialang-s3.julialang.org/bin/linux/x64/1.6/$JULIA_TAR
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

install_pipx() {
  export PIPX_HOME=$BIN/pipx_home
  export PIPX_BIN_DIR=$BIN/pipx_bin

  export PATH=$PATH:$PIPX_BIN_DIR

  mkdir -p $PIPX_HOME $PIPX_BIN_DIR

  $INSTALL pipx
}

install_python_micromamba() {
  PY_VER=3.14
  PY_ENV_PREFIX=$BIN/py$PY_VER

  if [[ "$ARCH" == 'amd64' ]]; then
    MICROMAMBA_URL='https://micro.mamba.pm/api/micromamba/linux-64/latest'
  elif [[ "$ARCH" == 'arm64' ]]; then
    MICROMAMBA_URL='https://micro.mamba.pm/api/micromamba/linux-aarch64/latest'
  else
    echo "unsupported architecture: $ARCH"
    exit 1
  fi

  curl -Ls $MICROMAMBA_URL | tar -xvj bin/micromamba
  mv ./bin/micromamba $BIN/micromamba
  rm -rf ./bin

  export MAMBA_ROOT_PREFIX=$BIN/micromamba_root
  eval "$(micromamba shell hook --shell posix)"

  printf "channels:\n  - conda-forge\n" | tee $HOME/.condarc

  micromamba --yes create --prefix $PY_ENV_PREFIX \
    python=$PY_VER \
    diagrams \
    ipython \
    jupyter \
    matplotlib \
    numpy \
    pandas \
    pytest \
    PyYAML \
    requests \
    scikit-learn \
    scipy
    # grpcio \
    # grpcio-tools \
    # isort \
    # plotly \
    # pyspark \
    # yapf \

  # micromamba activate $PY_ENV_PREFIX
}

install_python_venv() {
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

  python$PY_VER -m venv $PY_ENV_PREFIX

  source $PY_ENV_PREFIX/bin/activate

  pip install \
    diagrams \
    ipython \
    jupyter \
    matplotlib \
    numpy \
    pandas \
    pytest \
    PyYAML \
    requests \
    scikit-learn \
    scipy
    # grpcio \
    # grpcio-tools \
    # isort \
    # plotly \
    # pyspark \
    # yapf \

  deactivate
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
    diagrams \
    ipython \
    jupyter \
    matplotlib \
    numpy \
    pandas \
    pytest \
    PyYAML \
    requests \
    scikit-learn \
    scipy
    # grpcio \
    # grpcio-tools \
    # isort \
    # plotly \
    # pyspark \
    # yapf \

  deactivate
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
  # requires ubuntu 26.04 lts
  $INSTALL starship

  $INSTALL zsh

  curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/.zshrc \
    -o $HOME/.zshrc

  curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/starship.toml \
    -o $SETTINGS_DIR/starship.toml

  install_zsh_plugin zsh-users zsh-autosuggestions

  sudo sed -i 's/auth\(.*\)pam_shells.so/auth sufficient pam_shells.so/' /etc/pam.d/chsh
  chsh -s $(which zsh)
}

clean_up() {
  $UPDATE
  $UPGRADE

  sudo apt-get clean -qq
  sudo apt-get autoremove -qq

  sudo rm -rf /var/lib/apt/lists/*
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

curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/tmux.conf \
  -o $SETTINGS_DIR/tmux.conf

install_essentials

install_clang
# install_clang_latest
# setup_ebpf_dev
# install_cmake
install_docker
install_git
install_go
# install_bazel # requires go
# install_julia
# install_microk8s
# install_mongodb
# install_nginx
install_nodejs
# install_postgresql
install_pipx
# install_python_micromamba
# install_python_venv
install_python_virtualenv
# install_gcloud # requires python
# install_rust
install_uv # requires pipx
install_conan # requires pipx
install_vcpkg
install_zsh

clean_up

echo 'done!'
echo 'manually configure: git rsa'

sudo reboot
