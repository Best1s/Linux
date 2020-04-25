https://edu.aliyun.com/lesson_1651_16894?spm=5176.10731542.0.0.12c320beB3sbVb#_16894
Kubernetes 是一个自动化的容器编排平台，它负责应用的部署、应用的弹性以及应用的管理，这些都是基于容器的。
Kubernetes 有如下几个核心功能：应用部署、访问、Scale Up/Down 以及滚动更新。
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


####核心概念
- Cluster 
Cluster 是计算、存储和网络资源的集合，Kubernetes 利用这些资源运行各种基于容器的应用。
- Master 
Master 是 Cluster 的大脑，它的主要职责是调度，即决定将应用放在哪里运行。Master 运行 Linux 操作系统，可以是物理机或者虚拟机。为了实现高可用，可以运行多个 Master。
- Node 
Node 的职责是运行容器应用。Node 由 Master 管理，Node 负责监控并汇报容器的状态，并根据 Master 的要求管理容器的生命周期。Node 运行在 Linux 操作系统，可以是物理机或者是虚拟机。
- Pod 
Pod 是 Kubernetes 的最小工作单元。每个 Pod 包含一个或多个容器。Pod 中的容器会作为一个整体被 Master 调度到一个 Node 上运行。
Kubernetes 引入 Pod 主要基于下面两个目的：
 - 可管理性。
有些容器天生就是需要紧密联系，一起工作。Pod 提供了比容器更高层次的抽象，将它们封装到一个部署单元中。Kubernetes 以 Pod 为最小单位进行调度、扩展、共享资源、管理生命周期。
 - 通信和资源共享。
Pod 中的所有容器使用同一个网络 namespace，即相同的 IP 地址和 Port 空间。它们可以直接用 localhost 通信。同样的，这些容器可以共享存储，当 Kubernetes 挂载 volume 到 Pod，本质上是将 volume 挂载到 Pod 中的每一个容器。
 - Pods 有两种使用方式：
 1、运行单一容器。
one-container-per-Pod 是 Kubernetes 最常见的模型，这种情况下，只是将单个容器简单封装成 Pod。即便是只有一个容器，Kubernetes 管理的也是 Pod 而不是直接管理容器。
 2 、运行多个容器。
但问题在于：哪些容器应该放到一个 Pod 中？ 这些容器联系必须 非常紧密，而且需要 直接共享资源。
- Controller 
Kubernetes 通常不会直接创建 Pod，而是通过 Controller 来管理 Pod 的。Controller 中定义了 Pod 的部署特性，比如有几个副本，在什么样的 Node 上运行等。为了满足不同的业务场景，Kubernetes 提供了多种 Controller，包括 Deployment、ReplicaSet、DaemonSet、StatefuleSet、Job 等
 - Deployment 是最常用的 Controller。Deployment 可以管理 Pod 的多个副本，并确保 Pod 按照期望的状态运行。
 - ReplicaSet 实现了 Pod 的多副本管理。使用 Deployment 时会自动创建 ReplicaSet，也就是说 Deployment 是通过 ReplicaSet 来管理 Pod 的多个副本，我们通常不需要直接使用 ReplicaSet。
 - DaemonSet 用于每个 Node 最多只运行一个 Pod 副本的场景。正如其名称所揭示的，DaemonSet 通常用于运行 daemon。
 - StatefuleSet 能够保证 Pod 的每个副本在整个生命周期中名称是不变的。而其他 Controller 不提供这个功能，当某个 Pod 发生故障需要删除并重新启动时，Pod 的名称会发生变化。同时 StatefuleSet 会保证副本按照固定的顺序启动、更新或者删除。
 - Job 用于运行结束就删除的应用。而其他 Controller 中的 Pod 通常是长期持续运行。
- Service 
Deployment 可以部署多个副本，每个 Pod 都有自己的 IP，外界通过Service访问这些副本。Kubernetes Service 定义了外界访问一组特定 Pod 的方式。Service 有自己的 IP 和端口，Service 为 Pod 提供了负载均衡。Kubernetes 运行容器（Pod）与访问容器（Pod）这两项任务分别由 Controller 和 Service 执行。
- Namespace
如果有多个用户或项目组使用同一个 Kubernetes Cluster，Namespace可以将他们创建的 Controller、Pod 等资源分开。Namespace 是将一个物理的 Cluster 逻辑上划分成多个虚拟 Cluster，每个 Cluster 就是一个 Namespace。不同 Namespace 里的资源是完全隔离的。

####Kubernetes 架构
Kubernetes Cluster 由 Master 和 Node 组成，节点上运行着若干 Kubernetes 服务。
- Master 节点
Master 是 Kubernetes Cluster 的大脑，运行着如下 Daemon 服务：kube-apiserver、kube-scheduler、kube-controller-manager、etcd 和 Pod 网络（例如 flannel）。

 - API Server（kube-apiserver）
API Server 提供 HTTP/HTTPS RESTful API，即 Kubernetes API。API Server 是 Kubernetes Cluster 的前端接口，各种客户端工具（CLI 或 UI）以及 Kubernetes 其他组件可以通过它管理 Cluster 的各种资源。

 - Scheduler（kube-scheduler）
Scheduler 负责决定将 Pod 放在哪个 Node 上运行。Scheduler 在调度时会充分考虑 Cluster 的拓扑结构，当前各个节点的负载，以及应用对高可用、性能、数据亲和性的需求。

 - Controller Manager（kube-controller-manager）
Controller Manager 负责管理 Cluster 各种资源，保证资源处于预期的状态。Controller Manager 由多种 controller 组成，包括 replication controller、endpoints controller、namespace controller、serviceaccounts controller 等。
不同的 controller 管理不同的资源。例如 replication controller 管理 Deployment、StatefulSet、DaemonSet 的生命周期，namespace controller 管理 Namespace 资源。

 - etcd
etcd 负责保存 Kubernetes Cluster 的配置信息和各种资源的状态信息。当数据发生变化时，etcd 会快速地通知 Kubernetes 相关组件。

 - Pod 网络
Pod 要能够相互通信，Kubernetes Cluster 必须部署 Pod 网络，flannel 是其中一个可选方案。

- Node 节点
Node 是 Pod 运行的地方，Kubernetes 支持 Docker、rkt 等容器 Runtime。 Node上运行的 Kubernetes 组件有 kubelet、kube-proxy 和 Pod 网络（例如 flannel）
 - kubelet
kubelet 是 Node 的 agent，当 Scheduler 确定在某个 Node 上运行 Pod 后，会将 Pod 的具体配置信息（image、volume 等）发送给该节点的 kubelet，kubelet 根据这些信息创建和运行容器，并向 Master 报告运行状态。

 - kube-proxy
service 在逻辑上代表了后端的多个 Pod，外界通过 service 访问 Pod。service 接收到的请求是如何转发到 Pod 的呢？这就是 kube-proxy 要完成的工作。
每个 Node 都会运行 kube-proxy 服务，它负责将访问 service 的 TCP/UPD 数据流转发到后端的容器。如果有多个副本，kube-proxy 会实现负载均衡。

 - Pod 网络
Pod 要能够相互通信，Kubernetes Cluster 必须部署 Pod 网络，flannel 是其中一个可选方案。

####Kubernetes 创建资源的两种方式
1. 用 kubectl 命令直接创建，简单直观快捷，上手快。适合临时测试或实验。比如：
kubectl run nginx-deployment --image=nginx:1.7.9 --replicas=2

2. 通过配置文件和 kubectl apply 创建可执行命令：kubectl apply -f xxx.yml
配置文件提供了创建资源的模板，能够重复部署。
可以像管理代码一样管理部署。
适合正式的、跨环境的、规模化部署。

Kubernets 还提供了几个类似的命令，例如 kubectl create、kubectl replace、kubectl edit 和 kubectl patch。
通常kubectl apply 命令已经能够应对超过 90% 的场景

Swarm 向 Kubernetes 迁移  Kompose工具  Swarm 转换成 kubernetes yaml文件

Derrick 容器迁移工具，代码探测， 5中语言(PHP,GO,JAVA,NODE,PYTHON) 30款框架 Dockerfile/Docker Compose/k8s resource yaml/CI/CD pipeline as code config