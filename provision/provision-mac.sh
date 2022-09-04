#!/bin/bash

# usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/David0922/hello-world/main/provision/provision-mac.sh)"

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

  sudo touch /etc/sysctl.conf
  sudo sed -i '' "/work-dir/d" /etc/sysctl.conf

  mkdir $WORK_DIR

  mkdir \
    $BIN \
    $WORK_DIR/downloads \
    $WORK_DIR/settings \
    $WORK_DIR/tmp

  printf "$USER\t$WORK_DIR\n" | sudo tee -a /etc/sysctl.conf
  printf "work-dir\t$WORK_DIR\n" | sudo tee -a /etc/sysctl.conf
}

install_essentials() {
  $INSTALL \
    boost \
    colordiff \
    htop \
    jq \
    openjdk@17 \
    tmux \
    tree \
    wget
    # curl \
    # make \
    # unzip \
    # vim \
    # zip \
}

install_go() {
  GO_VER=1.19
  OS=darwin
  ARCH=arm64
  GO_TAR=go$GO_VER.$OS-$ARCH.tar.gz

  curl -O https://dl.google.com/go/$GO_TAR
  tar --no-same-owner -xzf $GO_TAR -C $BIN

  export GOPATH=$WORK_DIR/projects/go
  export PATH=$PATH:$BIN/go/bin:$WORK_DIR/projects/go/bin
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

install_nodejs() {
  $INSTALL node yarn
}

install_python() {
  $INSTALL python@3.10 virtualenv

  virtualenv -p $(which python3.10) $WORK_DIR/py3.10_env

  source $WORK_DIR/py3.10_env/bin/activate

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

curl https://raw.github.com/david0922/hello-world/master/provision/common-mac.sh -o $WORK_DIR/settings/common.sh

curl https://raw.github.com/david0922/hello-world/master/provision/tmux.conf -o $WORK_DIR/settings/tmux.conf

bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

install_essentials

install_go
install_bazel
install_nodejs
install_python
install_gcloud # requires python
install_zsh

clean_up

echo 'done!'
echo 'manually configure:
  android studio
  brave
  chrome
  firefox
  git config --global color.ui true
  git config --global user.email EMAIL
  git config --global user.name NAME
  git rsa
  google drive
  macOS settings
  sublime
  vscode
  xcode'

sudo reboot