#initial_setting

#!/bin/bash

. /etc/os-release

if [ "$NAME" != "Ubuntu" ]; then
    echo "This script is for Ubuntu."
    exit
fi

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

cd ~

echo "##########################################
##########################################
This script automatically sets up the Kubernetes cluster node.
##############################################
##############################################"


echo "##########################################
##########################################
               alias setting
##############################################
##############################################"

echo "#custom alias
alias ..='cd ..'
alias k='kubectl'
alias kp='kubectl get pod -n'
alias kpa='kubectl get pod -A'
alias kpo='kubectl get pod -A -o wide'
alias wkp='watch -n 1 kubectl get pod -A'
alias wkpo='watch -n 1 kubectl get pod -A -o wide'
alias cl='clear'
alias upgrade='sudo apt-get update && sudo apt-get upgrade -y'
alias c='ctr'
alias d='docker'
alias i='istioctl'" >> ~/.bashrc

cd ~


echo "##########################################
##########################################
           apt update & upgrade
##########################################
##########################################"
sudo apt-get update 
sudo apt-get -y upgrade 
sudo apt-get -y autoremove 
sudo apt-get autoclean


echo "##########################################
##########################################
            install net-tools
##########################################
##########################################"
sudo apt-get -qq -y install net-tools iproute2 iputils-ping


echo "##########################################
##########################################
        install wget & curl & make
##########################################
##########################################"
sudo apt-get -qq -y install wget curl make


echo "##########################################
##########################################
             install golang
##########################################
##########################################"
goBinary=$(curl -s https://go.dev/dl/ | grep linux | head -n 1 | cut -d'"' -f4 | cut -d"/" -f3)
wget https://dl.google.com/go/$goBinary -O /tmp/$goBinary
sudo tar -C /usr/local -xvzf /tmp/$goBinary
rm /tmp/$goBinary

echo >> /home/$USER/.bashrc
echo "export GOPATH=\$HOME/go" >> /home/$USER/.bashrc
echo "export GOROOT=/usr/local/go" >> /home/$USER/.bashrc
echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> /home/$USER/.bashrc
echo >> /home/$USER/.bashrc
mkdir -p /home/$USER/go
chown -R $USER:$USER /home/$USER/go


echo "##########################################
##########################################
           install containerd
##########################################
##########################################"
sudo apt-get -qq -y install ca-certificates gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get -qq update

sudo apt-get -qq -y install containerd.io

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml
sudo systemctl restart containerd


echo "##########################################
##########################################
          install kubernetes
##########################################
##########################################"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get -qq update

sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo sysctl -w net.ipv4.ip_forward=1
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo modprobe br_netfilter
if [ $(cat /proc/sys/net/bridge/bridge-nf-call-iptables) == 0 ]; then
    sudo bash -c "echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables"
    sudo bash -c "echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf"
fi



if [ -z "$MASTER" ]; then
    echo "##########################################
    ##########################################
                install docker
    ##########################################
    ##########################################"
    sudo apt-get -qq -y install docker-ce
    sudo usermod -aG docker $USER
    sudo chmod 666 /var/run/docker.sock
elif [ "$MASTER" == "TRUE" ]; then
    echo "##########################################
    ##########################################
                install docker
    ##########################################
    ##########################################"
    sudo apt-get -qq -y install docker-ce
    sudo usermod -aG docker $USER
    sudo chmod 666 /var/run/docker.sock
else
    exit
fi

if [ -z "$INIT" ] || [ "$INIT" == "TRUE" ]; then
echo "##########################################
##########################################
              init kubeadm
##########################################
##########################################"
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16 | tee -a ~/k8s_init.log

    if [ -z "$MULTI" ] || [ "$MULTI" == "FALSE" ]; then
        kubectl taint nodes --all node-role.kubernetes.io/control-plane-
    fi

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $USER:$USER $HOME/.kube/config
    export KUBECONFIG=$HOME/.kube/config
    echo "export KUBECONFIG=$HOME/.kube/config" | tee -a ~/.bashrc

    if [ -z "$CNI" ]; then
        echo "Deploy CNI manually"
        exit
    elif [ "$CNI" == "flannel" ]; then
        kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
    elif [ "$CNI" == "calico" ]; then
        kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/calico.yaml
    elif [ "$CNI" == "cilium" ]; then
        curl -LO https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz
        sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
        rm cilium-linux-amd64.tar.gz
        cilium install
    elif [ "$CNI" == "weave" ]; then
        kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
    fi

    cat ~/.kube/config
fi

cat ~/k8s_init.log
echo "Use the kubeadm join in worker node to add node to the cluster"
echo "You must execute source ~/.bashrc"
