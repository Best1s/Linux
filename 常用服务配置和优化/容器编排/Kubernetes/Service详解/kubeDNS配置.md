官方文档 https://kubernetes.io/zh/docs/tasks/administer-cluster/dns-custom-nameservers/

Kube-dns 可选的 DNS 服务器。 正在运行的DNS Pod包含3个容器：
- “kubedns“：监测 Kubernetes 主节点的服务和 Endpoints 的更改，并维护内存中的查找结构以服务DNS 请求。
- “dnsmasq“：添加 DNS 缓存以提高性能。
- “sidecar“：提供单个运行状况检查端点，对 dnsmasq 和 Kubedns 进行健康检查。

1.11版本开始 CoreDNS 是通用的权威DNS服务器，可以用作集群DNS，符合dns 规范。(kubeadm 默认安装)

安装：需要提前修改每个 kubectl 上的启动参数
```
--cluster-nds=x.x.x.x DNS 服务的 ClusterIP 地址
--cluster-domain=cluster.local   为在DNS服务中设置的域名。
```

部署 CoreDNS 需创建一个 ConfigMap （主配置文件），一个 Deployment （容器应用）和一个 Service （DNS 服务）。

Corefile 配置包括以下 CoreDNS 的 插件：

- errors：错误信息进行日志记录。

- health：对 Endpoint 进行健康检查

- kubernetes：CoreDNS 将基于 Kubernetes 的服务和 Pod 的 IP 答复 DNS 查询。 

- prometheus：CoreDNS的度量标准以Prometheus格式在 http://localhost:9153/metrics 上提供。

- proxy: 转发特定的域名到其它多个DNS 服务器，同时提供多个 DNS 服务器的负债均衡功能。

- cache：这将启用前端缓存。

- loop：检测到简单的转发循环，如果发现死循环，则中止 CoreDNS 进程。

- reload：允许自动重新加载已更改的 Corefile。 编辑 ConfigMap 配置后，请等待两分钟，以使更改生效。

- loadbalance：这是一个轮询 DNS 负载均衡器，它在应答中随机分配 A，AAAA 和 MX 记录的顺序。

- etcd: 从 etcd 读取 zone 数据

- host: 使用 /etc/hosts 文件或 其他文件读取 zone 数据，可用于自定义域名记录。
 
- auto: 从磁盘中自动加载区域文件。

- forward: 转发域名查询到上游DNS服务器。

- pprof: 在 URL 路径 /debug/pprof 下提供运行时的性能数据。

- log: 对 DNS 查询进行日志查询

#### Pod 级别的 DNS 配置
除了使用集群范围的 DNS 服务， Pod 级别也能设置相关 DNS 的相关策略和配置。
文档 https://kubernetes.io/zh/docs/concepts/services-networking/dns-pod-service/