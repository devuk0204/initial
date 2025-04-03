echo "boan ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/boan

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

wget https://github.com/free5gc/gtp5g/archive/refs/tags/v0.8.10.tar.gz
tar xvfz v0.8.10.tar.gz
cd gtp5g-0.8.10/
sudo apt-get install gcc gcc-9 make -y

# compile gtp5g
sudo make
sudo make install
gcc -v
lsmod | grep gtp

wget https://dl.google.com/go/go1.21.8.linux-amd64.tar.gz
sudo tar -C /usr/local -zxvf go1.21.8.linux-amd64.tar.gz
mkdir -p ~/go/{bin,pkg,src}

echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' >> ~/.bashrc
echo 'export GO111MODULE=auto' >> ~/.bashrc
source ~/.bashrc

go version


sudo apt-get update

# add gpg key
sudo apt-get install -y curl ca-certificates gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# add docker repository
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# update the docker repo
sudo apt-get update

# install containerd
sudo apt-get install -y containerd.io

# set up the default config file
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml
sudo systemctl restart containerd

# add the key for Kubernetes repo
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# add sources.list.d
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# update repo
sudo apt-get update

# enable ipv4.ip_forward
sudo sysctl -w net.ipv4.ip_forward=1

# turn off swap filesystem
sudo swapoff -a

# install kubernetes
sudo apt-get install -y kubelet kubeadm kubectl

# exclude kubernetes packages from updates
sudo apt-mark hold kubelet kubeadm kubectl

# enable br_netfilter
sudo modprobe br_netfilter
sudo bash -c 'echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables'

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
