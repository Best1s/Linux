1. 公共参数配置，可用于 kube-apiserver、kube-controller-manager、kube-scheduler、kubelet、kube-proxy。
![](1.png)
2. [kube-apiserver启动参数](https://kubernetes.io/zh/docs/reference/command-line-tools-reference/kube-apiserver/) 和 API Server 架构详细说明
- API层：主要有 REST 方式提供各种 API 接口，除了有 kubernetes 资源对象的 CRUD 和 Watch 还有健康检查，UI，日子，性能指标等 API
- 访问控制层：当客户端访问 API 接口时，访问层负责对用户身份鉴权，验明用户身份，权限等
- 注册表层：Kuberbetes 把所有资源对象都保存在注册表中，注册表中定义了 资源对象类型，如何创建资源对象，如何转换资源的不同版本及 资源编码和解码 JSON 或 ProtoBuf 存储
- etcd 数据库：用于持久化存储 Kubernetes 资源对象的 KV 数据库。通过 etcd 的 watch API 接口创新的设计了 List-Watch 高性能的资源对象实时同步机制，使 Kubernetes 可以管理超大规模的集群，及快速响应和快速处理集群中的各种事件。
- 
3. [kube-controller-manager 启动参数](https://kubernetes.io/zh/docs/reference/command-line-tools-reference/kube-controller-manager/)
![](11.jpg)
![](12.jpg)
![](13.jpg)
![](14.jpg)
![](15.jpg)

4. [kube-scheduler 启动参数](https://kubernetes.io/zh/docs/reference/command-line-tools-reference/kube-scheduler/)
![](16.jpg)
![](17.jpg)
5. [kubelet 启动参数](https://kubernetes.io/zh/docs/reference/command-line-tools-reference/kubelet/)
![](19.jpg)
![](20.jpg)
![](21.jpg)
![](22.jpg)
![](23.jpg)
![](24.jpg)
![](25.jpg)
![](26.jpg)
![](27.jpg)
6. [kube-proxy 启动参数](https://kubernetes.io/zh/docs/reference/command-line-tools-reference/kube-proxy/)
![](30.jpg)
![](31.jpg)
7. kubectl 子命令
![](28.jpg)
![](29.jpg)
