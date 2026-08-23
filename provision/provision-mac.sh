#!/bin/bash

# usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/provision-mac.sh)"

set -e -x

INSTALL='brew install --quiet'
UPDATE='brew update --quiet'
UPGRADE='brew upgrade --quiet'

WORK_DIR=/Users/$USER/work-dir
BIN=$WORK_DIR/bin
SETTINGS_DIR=$WORK_DIR/settings

export PATH=$PATH:$BIN

# -------------------------------------------------- #

reset_dir() {
  sudo rm -rf $WORK_DIR || true

  sudo touch /etc/synthetic.conf
  sudo sed -i '' "/work-dir/d" /etc/synthetic.conf

  mkdir $WORK_DIR

  mkdir \
    $BIN \
    $SETTINGS_DIR \
    $WORK_DIR/downloads \
    $WORK_DIR/downloads/screenshots \
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
  GO_VER=1.26.7
  OS=darwin
  ARCH=arm64
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
  MICROMAMBA_URL=https://micro.mamba.pm/api/micromamba/osx-arm64/latest

  curl -Ls $MICROMAMBA_URL | tar -xvj bin/micromamba
  mv ./bin/micromamba $BIN/micromamba
  rm -rf ./bin

  export MAMBA_ROOT_PREFIX=$BIN/micromamba_root
  eval "$(micromamba shell hook --shell zsh)"

  printf "channels:\n  - conda-forge\n" | tee $HOME/.condarc

  micromamba --yes create --prefix $PY_ENV_PREFIX \
    python=$PY_VER \
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
    # diagrams \
    # grpcio \
    # grpcio-tools \
    # isort \
    # plotly \
    # pyspark \
    # yapf \

  # micromamba activate $PY_ENV_PREFIX
}

install_python_virtualenv() {
  PY_VER=3.14

  $INSTALL python@$PY_VER virtualenv

  virtualenv -p $(which python$PY_VER) $BIN/py${PY_VER}

  source $BIN/py${PY_VER}/bin/activate

  pip install \
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
    # diagrams \
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

install_conan() {
  # requires pipx
  pipx install conan
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

install_vlc() {
  $INSTALL --cask vlc
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
  # $INSTALL zsh

  curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/.zshrc \
    -o $HOME/.zshrc

  # $INSTALL starship
  # curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/starship.toml \
  #   -o $SETTINGS_DIR/starship.toml

  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $SETTINGS_DIR/powerlevel10k
  curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/.p10k.zsh \
    -o $SETTINGS_DIR/.p10k.zsh

  install_zsh_plugin zsh-users zsh-autosuggestions
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

curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/tmux.conf \
  -o $SETTINGS_DIR/tmux.conf

bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# change screenshots location
defaults write com.apple.screencapture location $WORK_DIR/downloads/screenshots

install_essentials

# install_boost
install_go
# install_bazel # requires go
# install_jdk
install_nodejs
install_pipx
# install_python_micromamba
install_python_virtualenv
# install_gcloud # requires python
# install_rust
install_uv # requires pipx
install_conan # requires pipx
install_vcpkg
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
