https://edu.aliyun.com/lesson_1651_16894?spm=5176.10731542.0.0.12c320beB3sbVb#_16894
Kubernetes 是一个自动化的容器编排平台，它负责应用的部署、应用的弹性以及应用的管理，这些都是基于容器的。
Kubernetes 有如下几个核心的功能
- 服务的发现与负载的均衡； 

- 容器的自动装箱，我们也会把它叫做 scheduling，就是“调度”，把一个容器放到一个集群的某一个机器上，Kubernetes 会帮助我们去做存储的编排，让存储的声明周期与容器的生命周期能有一个连接； 

- Kubernetes 会帮助我们去做自动化的容器的恢复。在一个集群中，经常会出现宿主机的问题或者说是 OS 的问题，导致容器本身的不可用，Kubernetes 会自动地对这些不可用的容器进行恢复； 

- Kubernetes 会帮助我们去做应用的自动发布与应用的回滚，以及与应用相关的配置密文的管理； 

- 对于 job 类型任务，Kubernetes 可以去做批量的执行； 

- 为了让这个集群、这个应用更富有弹性，Kubernetes 也支持水平的伸缩。

```
#更新镜像
kubectl  set image

#快速回滚
kubectl rollout undo xxxx
#回滚到某一个版本,需要先查询版本列表
kubectl rollout history xxxx
kubectl rollout undo xxxx --to-version=x
```
kuberbetes中文文档 （http://docs.kubernetes.org.cn/）
使用Minikube部署Kubernetes集群 单机部署

首先下载kubectl
```
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.6.4/bin/linux/amd64/kubectl
chmod +x kubectl
```
安装minikube (https://kubernetes.io/docs/tasks/tools/install-minikube/#before-you-begin)
线上minikube (https://kubernetes.io/docs/tutorials/kubernetes-basics/create-cluster/cluster-interactive/)