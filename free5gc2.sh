sudo sysctl -w net.ipv4.ip_forward=1
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo modprobe br_netfilter
if [ $(cat /proc/sys/net/bridge/bridge-nf-call-iptables) == 0 ]; then
    sudo bash -c "echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables"
    sudo bash -c "echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf"
fi

sudo apt-get -qq -y install docker-ce
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock
