apt-get update -y
hostnamectl set-hostname master
# configure the hosts file
echo "slaveIP slave" >> /etc/hosts
echo "masterIP master" >> /etc/hosts
# disable swap memory
swapoff -a
# Docker installation
wget -qO- https://get.docker.com/ | sh
#Kubernetes installation
modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
sleep 30
cp /home/ubuntu/10-kubeadm.conf /etc/systemd/system/kubelet.service.d/ 
sleep 30
systemctl daemon-reload
sleep 30
# master node config
rm /etc/containerd/config.toml
systemctl restart containerd
sleep 30
kubeadm init --pod-network-cidr=10.244.0.0/16
kubeadm token create --print-join-command > /home/ubuntu/join.sh
# to start to use clus
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml