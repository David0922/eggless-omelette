#!/bin/bash

# usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/David0922/eggless-omelette/main/provision/provision-prod-server.sh)"

set -e -x

export DEBIAN_FRONTEND=noninteractive

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
    $WORK_DIR/app \
    $WORK_DIR/downloads \
    $WORK_DIR/settings \
    $WORK_DIR/tmp
}

secure_ssh() {
  sudo sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
  sudo sed -i 's/^#\?UsePAM.*/UsePAM no/' /etc/ssh/sshd_config

  sudo systemctl reload sshd
}

set_timezone() {
  sudo timedatectl set-timezone UTC
  # sudo timedatectl set-timezone America/New_York
}

set_ufw_firewall() {
  sudo ufw --force enable

  sudo ufw allow http
  sudo ufw allow https
  sudo ufw allow ssh
}

install_essentials() {
  $INSTALL \
    autossh \
    busybox \
    colordiff \
    curl \
    htop \
    jq \
    net-tools \
    openssl \
    screenfetch \
    tmux \
    tree \
    unzip \
    vim \
    virtualenv \
    wget \
    zip
}

install_docker() {
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

  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

  sudo chmod +x /usr/local/bin/docker-compose

  sudo curl \
    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
    -o /etc/bash_completion.d/docker-compose
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

install_python() {
  $INSTALL python3-pip python3.9

  virtualenv -p $(which python3.9) $WORK_DIR/py3.9_env

  source $WORK_DIR/py3.9_env/bin/activate

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
install_nginx
install_python
install_zsh

clean_up

echo 'done!'
echo 'manually configure: git rsa'

sudo reboot
