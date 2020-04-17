下载需要k8s源码包
```
https://github.com/kubernetes/kubernetes/releases  #单击CHANGELOG下载二进制包，这里使用的是v1.16.8
解压将 kube-apiserver、kube-controller-manager、kube-scheduler文件复制到/usr/bin目录。 
```
Kubernetes 的主要服务程序 都可以通过二进制文件加启动参数完成运行。

将可执行文件复制到/usr/bin 然后在/usr/lib/system/system为服务创建system服务配置文件
###Master
Master上需要部署 etcd、kube-apiserver、kube-controller-manager、kube-scheduler 服务进程
**1.etcd服务**
用于共享配置和服务发现的分布式、一致性的KV存储系统，主要包括了增删改查、安全认证、集群、选举、事务、分布式锁、Watch机制等等
从Github(https://github.com/etcd-io/etcd/releases) 下载etcd二进制文件 这里使用的是二进制包V3.4.5，源码包需要go环境编译
将 etcd 和 etcdctl 二进制文件复制到 /usr/bin 目录
设置 systemd 服务配置文件/usr/lib/systemd/system/etcd.service
```
cat /usr/lib/systemd/system/etcd.service
[Unit]
Description=Etcd service
After=network.target

[Service]
Type=simple
WorkingDirectory=/var/lib/etcd/
EnvironmentFile=/etc/etcd/etcd.conf
ExecStart=/usr/bin/etcd
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2

[Install]
WantedBy=multi-user.target

mkdir /var/lib/etcd /etc/etcd
systemctl daemon-reload
systemctl enable etcd.service
systemctl start etcd
```
执行etcd cluster-health 验证etcd是否正确启动
```
etcdctl endpoint health
127.0.0.1:2379 is healthy: successfully committed proposal: took = 992.131µs
```
**2.kube-apiserver服务**
API SERVER是整个k8s集群的注册中心、交通枢纽、安全控制入口。
设置systemd服务配置文件 /usr/lib/systemd/system/kube-apiserver.service
```
cat /usr/lib/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API service
After=etcd.target
Wants=etcd.service

[Service]
EnvironmentFile=/etc/kubernetes/apiserver
ExecStart=/usr/bin/kube-apiserver $KUBE_API_ARGS
Restart=on-failure
LimiNOFILE=65536

[Install]
WantedBy=multi-user.target
```
配置文件/etc/kubernetes/apiserver 内容包括了kube-apiserver的全部启动参数，主要配置变量在KUBE_API_ARGS中指定
```
mkdir /var/log/kubernetes /etc/kubernetes/
vi /etc/kubernetes/apiserver 
KUBE_API_ARGS="--etcd-servers=http://127.0.0.1:2379 \
--insecure-bind-address=0.0.0.0 \
--insecure-port=8080 \
--service-cluster-ip-range=169.169.0.0/16 \
--service-node-port-range=1-65535 \
--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota \
--logtostderr=false \
--log-dir=/var/log/kubernetes --v=0"
```
**3.kube-controller-manager服务(依赖apiserver)**
Kube Controller Manager作为集群内部的管理控制中心,负责集群内的Node、Pod副本、服务端点（Endpoint）、命名空间（Namespace）、服务账号（ServiceAccount）、资源定额（ResourceQuota）的管理，当某个Node意外宕机时，Kube Controller Manager会及时发现并执行自动化修复流程，确保集群始终处于预期的工作状态。

设置systemd服务配置文件 /usr/lib/systemd/system/kube-controller-manager.service
```
vi /usr/lib/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
After=kube-apiserver.service
Wants=kube-apiserver.service

[Service]
EnvironmentFile=/etc/kubernetes/controller-manager
ExecStart=/usr/bin/kube-controller-manager $KUBE_CONTROLLER_MANAGER_ARGS
Restart=on-failure
LimiNOFILE=65536

[Install]
WantedBy=multi-user.target
```
配置文件/etc/kubernetes/controller-manager
```
vi /etc/kubernetes/controller-manager
KUBE_CONTROLLER_MANAGER_ARGS="--kubeconfig=/etc/kubernetes/kubeconfig \
--logtostderr=false \
--log-dir=/var/log/kubernetes --v=0"
```
与API server连接的相关配置 /etc/kubernetes/kubeconfig
```
vi /etc/kubernetes/kubeconfig
apiVersion: v1
kind: Config
users:
- name: client
  user:
clusters:
- name: default
  cluster:
    server: http://master的ip:8080
contexts:
- context:
    cluster: default
    user: client
  name: default
current-context: default
```
**4.kube-scheduler 服务(依赖apiserver) **
Kube Scheduler是负责调度Pod到具体的Node，它通过API Server提供的接口监听Pods，获取待调度pod，然后根据一系列的预选策略和优选策略给各个Node节点打分排序，然后将Pod调度到得分最高的Node节点上。
设置systemd服务配置文件 /usr/lib/systemd/system/kube-scheduler.service
```
vi /usr/lib/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
After=kube-apiserve.service
Wants=kube-apiserver.service

[Service]
EnvironmentFile=/etc/kubernetes/scheduler
ExecStart=/usr/bin/kube-scheduler $KUBE_SCHEDULER_ARGS
Restart=on-failure
LimiNOFILE=65536

[Install]
WantedBy=multi-user.target
```
配置文件 /usr/bin/kube-scheduler
```
vi /usr/bin/kube-scheduler
KUBE_SCHEDULER_ARGS="--kubeconfig=/etc/kubernetes/kubeconfig \
--logtostderr=false \
--log-dir=/var/log/kubernetes --v=0"
```
配置完成后启动服务 Master节点完成安装
```
systemctl daemon-reload
systemctl enable kube-apiserver
systemctl enable kube-controller-manager
systemctl enable kube-scheduler
systemctl start kube-apiserver
systemctl start kube-controller-manager
systemctl start kube-scheduler
```
###Node
Node上需要部署 docker、kubelet、kube-proxy 服务进程
**1.kubelet服务(依赖docker)**
k8s集群中，每个Node节点都会启动kubelet进程，用来处理Master节点下发到本节点的任务，管理Pod和pod中的容器。kubelet会在API Server上注册节点信息，定期向Master汇报节点资源使用情况，并通过cAdvisor监控容器和节点资源。 
设置服务配置文件/usr/lib/systemd/system/kubelet.service
```
mkdir /var/lib/kubelet
vi /usr/lib/systemd/system/kubelet.service
Unit]
Description=Kube Kubelet Server
After=docker.service
Requires=docker.service
 
[Service]
WorkingDirectory=/var/lib/kubelet
EnvironmentFile=/etc/kubernetes/kubelet
ExecStart=/usr/bin/kubelet $KUBELET_ARGS
Restart=on-failure
 
[Install]
WantedBy=multi-user.target

vi /etc/kubernetes/kubelet
KUBELET_ARGS="--kubeconfig=/etc/kubernetes/kubeconfig \
--hostname-override=node名称可设置为node的IP \
--logtostderr=false \
--log-dir=/var/log/kubernetes --v=0"
```
**2.kube-proxy**
kube-proxy是管理service的访问入口，包括集群内Pod到Service的访问和集群外访问service。
设置服务配置文件/usr/lib/systemd/system/kube-proxy.service
```
vi /usr/lib/systemd/system/kube-proxy.service
[Unit]
Description=Kube Kube-Proxy Server
After=network.target
Requires=network.target
 
[Service]
EnvironmentFile=/etc/kubernetes/proxy
ExecStart=/usr/bin/kube-proxy $KUBE_PROXY_ARGS
Restart=on-failure
LimitNOFILE=65536
 
[Install]
WantedBy=multi-user.target

vi /etc/kubernetes/proxy
KUBE_PROXY_ARGS="--kubeconfig=/etc/kubernetes/kubeconfig \
--logtostderr=false \
--log-dir=/var/log/kubernetes --v=0"
```

启动服务并加入开机启动

```
systemctl daemon-reload
systemctl enable kubelet.service
systemctl enable kube-proxy
systemctl start kubelet.service
systemctl start kube-proxy

查看注册的节点
kubectl get nodes
```


```
docker
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}

kubelet:
--cgroup-driver=systemd or --cgroup-driver=cgroupfs
```

未完成的配置
kubernetes集群的网络配置
Flanel、Werave、Calico、Open vSwitch 等跨主机的网络互通配置

内网中无法访问外网的 可以创建 私有的Docker Registry(docker hub)

kubelet配置
Kubernetes 中是以Pod而不是以Docker容器为管理单位，在Kubelet 创建Pod时，还要启动一个名为k8s.gcr.io/pause:x.x的镜像来实现Pod概念
node节点拉取镜像后 kubelet 服务启动加上 --pod-infra-container-image=xxx/pause:x.x 然后重启服务，这样每一个Pod启动的时候都会启动一个这样的容器,如果本地没有，kubelet会连接外网下载镜像