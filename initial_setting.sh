#initial_setting

#!/bin/bash

. /etc/os-release

if [ "$NAME" != "Ubuntu" ]; then
    echo "This script is for Ubuntu."
    exit
fi

cd ~

echo "###################################################
##############################################
alias setting
##############################################
##############################################"

echo "#custom alias
alias ..='cd ..'
alias k='kubectl'
alias kp='kubectl get pod -A'
alias wkp='watch -n 1 kubectl get pod -A'
alias cl='clear'
alias upgrade='~/tools/upgrade-ubuntu.sh'
alias c='ctr'
alias d='docker'
alias i='istioctl'" >> ~/.bashrc

cd ~

echo "####################################################
##########################################
cloning tools repo
##########################################
##########################################"
git clone https://github.com/boanlab/tools


echo "####################################################
##########################################
apt update & upgrade
##########################################
##########################################"
~/tools/upgrade-ubuntu.sh

echo "##########################################
##########################################
install net-tools & golang
##########################################
##########################################"

./tools/install-net-tools.sh

./tools/language/install-golang.sh

echo "##########################################
##########################################
install containerd
##########################################
##########################################"

./tools/containers/install-containerd.sh
sudo chmod 777 /run/containerd/containerd.sock


source ~/.bashrc



