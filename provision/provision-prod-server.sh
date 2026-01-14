#!/bin/bash

# usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/provision-prod-server.sh)"

set -e -x

export DEBIAN_FRONTEND=noninteractive

export ARCH=$(dpkg --print-architecture)

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
    $WORK_DIR/app \
    $WORK_DIR/downloads \
    $WORK_DIR/settings \
    $WORK_DIR/tmp
}

secure_ssh() {
  # todo: set configs in /etc/ssh/sshd_config.d/*.conf instead of modifying /etc/ssh/sshd_config

  $INSTALL fail2ban
  sudo systemctl enable fail2ban

  sudo sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?GatewayPorts.*/GatewayPorts clientspecified/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?UsePAM.*/UsePAM no/' /etc/ssh/sshd_config

  # sudo systemctl reload ssh.service
}

set_timezone() {
  sudo timedatectl set-timezone UTC
  # sudo timedatectl set-timezone America/New_York
}

set_ufw_firewall() {
  $UPDATE
  $INSTALL ufw

  sudo ufw --force enable

  sudo ufw allow http
  sudo ufw allow https
  sudo ufw allow ssh
}

install_essentials() {
  $INSTALL \
    autossh \
    colordiff \
    curl \
    htop \
    jq \
    tmux \
    tree \
    vim \
    wget
    # busybox \
    # iproute2 \
    # openssl \
    # screenfetch \
    # unzip \
    # virtualenv \
    # zip \
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

install_git() {
  $INSTALL git
  git config --global color.ui true
}

install_microk8s() {
  sudo snap install microk8s --classic

  sudo usermod -aG microk8s $USER
  sudo chown -f -R $USER ~/.kube || true

  sudo microk8s stop
}

install_python_micromamba() {
  PY_VER=3.11
  PY_ENV_PREFIX=$BIN/py$PY_VER

  curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
  mv ./bin/micromamba $BIN/micromamba
  rm -rf ./bin

  export MAMBA_ROOT_PREFIX=$BIN/micromamba_root
  eval "$(micromamba shell hook -s posix)"

  micromamba --yes create --prefix $PY_ENV_PREFIX \
    python=$PY_VER \
    ipython \
    jupyter \
    -c conda-forge

  micromamba activate $PY_ENV_PREFIX
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

  pip install ipython jupyter
}

install_nginx() {
  $INSTALL nginx

  sudo systemctl stop nginx
  sudo systemctl disable nginx
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
secure_ssh
set_timezone
set_ufw_firewall

cd $WORK_DIR/downloads

curl https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/common.sh -o $WORK_DIR/settings/common.sh

curl https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/tmux.conf -o $WORK_DIR/settings/tmux.conf

install_essentials

install_docker
install_git
# install_microk8s
# install_nginx
# install_python_micromamba
install_python_virtualenv
install_zsh

clean_up

echo 'done!'
echo 'manually configure: git rsa'

sudo reboot
