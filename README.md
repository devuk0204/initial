# k8s_initial.sh comand option   
MASTER(optional) TRUE|FALSE  default: TRUE   
    - TRUE: Install docker-ce   
    - FALSE: Don't install docker-ce   

INIT(optional) TRUE|FALSE  default: TRUE   
    - TRUE : If the node is master node and init kubeadm automatically   
    - FALSE : If the node is master node and init kubeadm manually   

IF INIT == TRUE   
    MULTI(optional) TRUE|FALSE  default: FALSE   
        - TRUE: If you want to set up the multi-node cluster   
        - FALSE: If you want to setup the single-node cluster   
    CNI(optional) flannel|calico|cilium|weave  default:No CNI   
        - option: CNI you want to deploy   
        - flannel: Deploy flannel   
        - calico: Deploy calico   
        - cilium: Deploy Cilium   
        - weave: Deploy weave   


## custom alias list
..='cd ..'   
cl='clear'   
upgrade='sudo apt-get update && sudo apt-get uprade -y'   
k='kubectl'   
kp='kubectl get pod -n'   
kpa='kubectl get pod -A'   
kpo='kubectl get pod -A -o wide'   
wkp='watch -n 1 kubectl get pod -A'   
wkpo='watch -n 1 kubectl get pod -A -o wide'   
c='ctr'   
d='docker'   
i='istioctl'   


## k8s_initial.sh demo
git clone https://github.com/devuk0204/initial   
cd initial   
./k8s_initial.sh # MASTER, INIT == TRUE & MULTI == FALSE & CNI = no   
MASTER=FALSE ./k8s_initial.sh   
INIT=FALSE ./k8s_initial.sh    
INIT=TRUE MULTI=TRUE ./k8s_initial.sh
