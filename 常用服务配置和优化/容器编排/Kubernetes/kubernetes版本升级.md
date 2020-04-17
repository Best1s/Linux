####kubernetes的版本升级
1. 二进制升级
kubernetes的版本升级需要考虑到当前集群中正在运行的容器不受影响。应对集群中的个Node逐个进行隔离，然后等待在其上运行的容器全部执行完成，再更新该Node上的kubelet和kube-proxy服务，将全部Node都更新完成后，最后更新Master服务。

 - 通过官网过去最新版本的二进制包kubernetes.tar.gz,解压缩后提取服务二进制文件
 
 - 逐个隔离Node,等待在其上运行的全部容器工作完成，更新kubelet和kube-proxy服务文件，然后重启这两个服务
 
 - 更新Master的kube-apiserver,kube-controller-manager,kube-scheduler服务文件并重启

2. 使用kubeadm进行集群升级，kubeadm 提供了upgrade命令用于对kubeadm安装的 kubernetes 集群进行升级。**注意*
 - kubeadm的升级不会触及工作负责，但还是要做好备份的准备
 - 升级过程可能会因为Pod的变化而造成容器重启

以CentOS 7环境为例，首先需要升级的是kubeadm：
查看kubeadm的版本：
```
ubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.1", GitCommit:"7879fc12a63337efff607952a323df90cdc7a335", GitTreeState:"clean", BuildDate:"2020-04-08T17:36:32Z", GoVersion:"go1.13.9", Compiler:"gc", Platform:"linux/amd64"}

```
接下来查看kubeadm的升级计划：
```
kubeadm upgrade plan
```
会出现预备升级的内容描述：
```
[upgrade/config] Making sure the configuration is correct:
[upgrade/config] Reading configuration from the cluster...
[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[preflight] Running pre-flight checks.
[upgrade] Running cluster health checks
[upgrade] Fetching available versions to upgrade to
[upgrade/versions] Cluster version: v1.18.1
[upgrade/versions] kubeadm version: v1.18.1
[upgrade/versions] Latest stable version: v1.18.2
[upgrade/versions] Latest stable version: v1.18.2
[upgrade/versions] Latest version in the v1.18 series: v1.18.2
[upgrade/versions] Latest version in the v1.18 series: v1.18.2

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT       AVAILABLE
Kubelet     3 x v1.18.1   v1.18.2

Upgrade to the latest version in the v1.18 series:

COMPONENT            CURRENT   AVAILABLE
API Server           v1.18.1   v1.18.2
Controller Manager   v1.18.1   v1.18.2
Scheduler            v1.18.1   v1.18.2
Kube Proxy           v1.18.1   v1.18.2
CoreDNS              1.6.7     1.6.7
Etcd                 3.4.3     3.4.3-0

You can now apply the upgrade by executing the following command:

	kubeadm upgrade apply v1.18.2

Note: Before you can perform this upgrade, you have to update kubeadm to v1.18.2.

```

按照任务指引进行升级：
```
kubeadm upgrade apply v1.18.2
```
由于我的版本过高 需要手动升级kubeadm版本为 v1.18.2 才能升级  下载安装包按照指示升级就行

Node版本升级
```
kubeadm upgrade node
```