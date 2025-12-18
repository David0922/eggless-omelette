#!/bin/bash

# usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/provision-mac.sh)"

set -e -x

INSTALL='brew install --quiet'
UPDATE='brew update --quiet'
UPGRADE='brew upgrade --quiet'

WORK_DIR=/Users/$USER/work-dir
BIN=$WORK_DIR/bin

export PATH=$PATH:$BIN

# -------------------------------------------------- #

reset_dir() {
  sudo rm -rf $WORK_DIR $HOME/.oh-my-zsh || true

  sudo touch /etc/synthetic.conf
  sudo sed -i '' "/work-dir/d" /etc/synthetic.conf

  mkdir $WORK_DIR

  mkdir \
    $BIN \
    $WORK_DIR/downloads \
    $WORK_DIR/downloads/screenshots \
    $WORK_DIR/settings \
    $WORK_DIR/tmp

  printf "$USER\t$WORK_DIR\n" | sudo tee -a /etc/synthetic.conf
  printf "work-dir\t$WORK_DIR\n" | sudo tee -a /etc/synthetic.conf
}

install_essentials() {
  $INSTALL \
    clang-format \
    cmake \
    colordiff \
    jq \
    ninja \
    reattach-to-user-namespace \
    tmux \
    tree \
    wget
    # curl \
    # htop \
    # make \
    # protobuf \
    # unzip \
    # vim \
    # zip \

  $INSTALL --cask rectangle
}

install_boost() {
  $INSTALL boost

  # BOOST_VER=1.82.0
  # BOOST_TAR=boost_1_82_0.tar.bz2

  # curl -O https://boostorg.jfrog.io/artifactory/main/release/$BOOST_VER/source/$BOOST_TAR
  # tar --bzip2 -xf $BOOST_TAR -C $BIN
}

install_go() {
  GO_VER=1.24.2
  OS=darwin
  ARCH=arm64
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

install_jdk() {
  # $INSTALL openjdk@17
  # $INSTALL --cask zulu
  $INSTALL --cask temurin
}

install_nodejs() {
  export NPM_CONFIG_PREFIX=$BIN/npm-global
  export PATH=$PATH:$NPM_CONFIG_PREFIX/bin

  $INSTALL node

  npm install --global pnpm@latest-10 yarn
}

install_python() {
  PY_VER=3.12

  $INSTALL python@$PY_VER virtualenv

  virtualenv -p $(which python$PY_VER) $BIN/py${PY_VER}_env

  source $BIN/py${PY_VER}_env/bin/activate

  pip install \
    conan \
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

  # gcloud -q components install kubectl
  # ln -s $BIN/google-cloud-sdk/bin/kubectl $BIN/kubectl
}

install_rust() {
  mkdir -p $BIN/rust

  export RUSTUP_HOME=$BIN/rust/.rustup
  export CARGO_HOME=$BIN/rust/.cargo

  export PATH=$PATH:$BIN/rust/.cargo/bin

  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
}

install_vcpkg() {
  cd $BIN
  $INSTALL pkg-config
  git clone --branch 2025.12.12 --depth 1 https://github.com/microsoft/vcpkg.git
  cd vcpkg
  ./bootstrap-vcpkg.sh -disableMetrics
  cd $WORK_DIR/downloads
}

install_vlc() {
  $INSTALL --cask vlc
}

install_zsh() {
  # $INSTALL zsh
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  sed -i '' 's/ZSH_THEME="\(.*\)"/ZSH_THEME="candy"/' $HOME/.zshrc
  printf "\nsource $WORK_DIR/settings/common.sh\n" | tee -a $HOME/.zshrc
}

clean_up() {
  $UPDATE
  $UPGRADE

  brew cleanup --prune=all
  brew autoremove
}

# -------------------------------------------------- #

reset_dir

cd $WORK_DIR/downloads

softwareupdate --agree-to-license --install-rosetta
arch -x86_64 echo 'testing rosetta 2'

curl https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/common-mac.sh -o $WORK_DIR/settings/common.sh

curl https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/tmux.conf -o $WORK_DIR/settings/tmux.conf

bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# change screenshots location
defaults write com.apple.screencapture location $WORK_DIR/downloads/screenshots

install_essentials

# install_boost
install_go
install_bazel # requires go
# install_jdk
install_nodejs
install_python
# install_gcloud # requires python
# install_rust
# install_vcpkg
install_vlc
install_zsh

clean_up

echo 'done!'
echo 'manually configure:
  android studio
  brave
  chrome
  firefox
  git config --global color.ui true
  git config --global core.ignorecase false
  git config --global user.email EMAIL
  git config --global user.name NAME
  git rsa
  google drive
  macOS settings
  sublime
  vscode
  xcode'

sudo reboot
