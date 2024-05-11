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
    $WORK_DIR/settings \
    $WORK_DIR/tmp

  printf "$USER\t$WORK_DIR\n" | sudo tee -a /etc/synthetic.conf
  printf "work-dir\t$WORK_DIR\n" | sudo tee -a /etc/synthetic.conf
}

install_essentials() {
  $INSTALL \
    clang-format \
    colordiff \
    htop \
    jq \
    protobuf \
    reattach-to-user-namespace \
    tmux \
    tree \
    wget
    # curl \
    # make \
    # unzip \
    # vim \
    # zip \
}

install_boost() {
  $INSTALL boost

  # BOOST_VER=1.82.0
  # BOOST_TAR=boost_1_82_0.tar.bz2

  # curl -O https://boostorg.jfrog.io/artifactory/main/release/$BOOST_VER/source/$BOOST_TAR
  # tar --bzip2 -xf $BOOST_TAR -C $BIN
}

install_go() {
  GO_VER=1.21.5
  OS=darwin
  ARCH=arm64
  GO_TAR=go$GO_VER.$OS-$ARCH.tar.gz

  curl -O https://dl.google.com/go/$GO_TAR
  tar -xzf $GO_TAR -C $BIN --no-same-owner

  export GOPATH=$WORK_DIR/projects/go
  export PATH=$PATH:$BIN/go/bin:$WORK_DIR/projects/go/bin

  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
}

install_bazel() {
  BAZEL_BIN=bazelisk-darwin-arm64

  wget https://github.com/bazelbuild/bazelisk/releases/download/v1.13.0/$BAZEL_BIN
  chmod +x ./$BAZEL_BIN
  mv ./$BAZEL_BIN $BIN
  sudo ln -s $BIN/$BAZEL_BIN $BIN/bazel
  bazel --version

  # requires go
  go install github.com/bazelbuild/buildtools/buildifier@latest
}

install_jdk() {
  # $INSTALL openjdk@17
  # $INSTALL --cask zulu
  $INSTALL --cask temurin
}

install_nodejs() {
  $INSTALL node yarn
}

install_python() {
  PY_VER=3.10

  $INSTALL python@$PY_VER virtualenv

  virtualenv -p $(which python$PY_VER) $WORK_DIR/py${PY_VER}_env

  source $WORK_DIR/py${PY_VER}_env/bin/activate

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
  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
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

# change screehshot location
defaults write com.apple.screencapture location $WORK_DIR/downloads

install_essentials

# install_rust
install_go
install_bazel
install_jdk
install_nodejs
install_python
install_gcloud # requires python
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
