官方安装文档（https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/）

Minikube部署Kubernetes集群 单机部署
首先下载kubectl
```
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.6.4/bin/linux/amd64/kubectl
chmod +x kubectl
```
安装minikube (https://kubernetes.io/docs/tasks/tools/install-minikube/#before-you-begin)
线上minikube (https://kubernetes.io/docs/tutorials/kubernetes-basics/create-cluster/cluster-interactive/)

这里使用使用kubeadm工具快速安装
环境准备
```
2核CPU 4G内存
CentOS7.7 关闭firewalld, selinux, swap,安装docker 19.03.8
```
配置yum源(国内http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/)
(国外https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64)
```
yum-config-manager \
    --add-repo \
    http://www.binver.top/kubernetes.repo
```
安装kubeadm和相关工具并启动
```
yum install -y kubelet kubeadm  --disableexcludes=kubernetes
systemctl enable kubelet && systemctl start kubelet
* 指定版本安装   kubelet-x.xx.x
```
配置docker国内镜像源,配置docker Cgroup
```
echo -e '{\n  "registry-mirrors":["http://hub-mirror.c.163.com"],\n  "exec-opts": ["native.cgroupdriver=systemd"]\n}' > /etc/docker/daemon.json
```
运行kubeadm init 安装master
```
或者 提前下载好 kubeadm config images list 中的镜像

echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
 
kubeadm init --pod-network-cidr 10.244.0.0/16  --service-cidr 10.233.0.0/16 --image-repository registry.cn-hangzhou.aliyuncs.com/google_containers 
#指定安装源 指定 pod service 网络段 pod段用于flannel 网络设置   单master 节点  多master 添加 --control-plane-endpoint  参数 指定 vip:port
```
kubeadm init --config=kubeadm-config.yaml  --upload-certs   # 多master 节点
```
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: "192.168.0.138:16443"
networking:
  podSubnet: "10.200.0.0/16"
  serviceSubnet: 10.50.0.0/12
```
 添加 kubectl 访问配置文件
```

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubeadm token create --ttl 0 #创建token,无时间限制
kubeadm token list	#显示token 
```
安装node节点
```
yum install -y kubelet  kubectl kubeadm --disableexcludes=kubernetes
systemctl enable kubelet && systemctl start kubelet
```
加入集群
```
kubeadm join 192.168.59.128:6443 --token 711sqt.aqea0scx6zz2oipg \
    --discovery-token-ca-cert-hash sha256:cb6f67a9f019cb2aa0d6c32dedbc832ca9c486b0485250765d0bcb4cfa3b7a99
```
也可以生成配置配置文件
```
cat join-config.yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: JoinConfiguration
discovery:
  bootstrapToken:
    apiServerEndpoint: master的ip和端口
    token: master提供的token
    unsafeSkipCAVerification: true
  tlsBootstrapToken: master提供的token

kubeadm join --config=join-config.yaml
```
**默认情况下Master不参与工作负载 执行以下命令可以让Master成为一个Node*
```
kubectl taint nodes --all node-role.kubernetes.io/master-
```
[安装网络插件](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network)
```
#Flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml
#weave
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```
验证 Kubernetes 集群是否安装完成
```
kubectl get pods --all-namespaces
```
**如果安装失败可执行kubeadm reset 再重新执行kubeadm init*



对比
```
# join master node
kubeadm join 192.168.x.xxx:16443 --token 19cfj3.18zez8y28w1alezz \
    --discovery-token-ca-cert-hash sha256:bf2b19a56369f021546a747865a1e510a721518c817afc91d3abe84c5cbd114d \
    --control-plane --certificate-key 62da85e24cbabe2fd1a8ce38a4912d02a8924821545c83b0f35387dd0503cbeb
# join worker node
kubeadm join 192.168.0.138:16443 --token 19cfj3.18zez8y28w1alezz \
    --discovery-token-ca-cert-hash sha256:bf2b19a56369f021546a747865a1e510a721518c817afc91d3abe84c5cbd114d 

# 显示 control-plane key  
kubeadm init phase upload-certs --upload-certs
# 加入node 
kubeadm token create --print-join-command
```
