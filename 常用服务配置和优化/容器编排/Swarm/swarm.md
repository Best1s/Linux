从docker v1.12 开始Docker Swarm 的功能已经完全与 Docker Engine 集成，要管理集群，只需要启动 Swarm Mode。安装好 Docker，Swarm 就已经在那里了，服务发现也在那里了（不需要安装 Consul 等外部数据库）。
用 Docker Swarm 创建集群非常简单，不需要额外安装任何软件，也不需要做任何额外的配置。
重要概念
- swarm
swarm 运行 Docker Engine 的多个主机组成的集群。
- node
swarm 中的每个 Docker Engine 都是一个 node，有两种类型的 node：manager 和 worker。
manager node：会将部署任务拆解并分配给一个或多个 worker node 完成部署。负责执行编排和集群管理工作，保持并维护 swarm 处于期望的状态。如果有多个 manager node，它们会自动协商并选举出一个 leader 执行编排任务。woker node 接受并执行由 manager node 派发的任务。默认配置下 manager node 同时也是一个 worker node，不过可以将其配置成 manager-only node，让其专职负责编排和集群管理工作。
work node： 会定期向 manager node 报告自己的状态和它正在执行的任务的状态，这样 manager 就可以维护整个集群的状态。
- service
service 定义了 worker node 上要执行的任务。swarm 的主要编排任务就是保证 service 处于期望的状态下。
举一个 service 的例子：在 swarm 中启动一个 http 服务，使用的镜像是 httpd:latest，副本数为 3。manager node 负责创建这个 service，经过分析知道需要启动 3 个 httpd 容器，根据当前各 worker node 的状态将运行容器的任务分配下去，比如 worker1 上运行两个容器，worker2 上运行一个容器。运行了一段时间，worker2 突然宕机了，manager 监控到这个故障，于是立即在 worker3 上启动了一个新的 httpd 容器。这样就保证了 service 处于期望的三个副本状态。

####docker swarm 常用命令
```
# 管理配置文件
docker config
    - docker config ls    # 查看已创建配置文件
    - docker config create docker 配置文件名 本地配置文件    # 将已有配置文件添加到docker配置文件中

# 管理swarm节点
docker node
    - docker node ls    # 查看集群中的节点    
    - docker node demote 主机名    # 将manager角色降级为worker     
    - docker node promote 主机名    # 将worker角色升级为manager     
    - docker node inspect 主机名    # 查看节点的详细信息，默认json格式     
    - docker node inspect --pretty 主机名          # 查看节点信息平铺格式     
    - docker node ps    # 查看运行的一个或多个及节点任务数，默认当前节点
    - docker node rm 主机名    # 从swarm中删除一个节点
    - docker node update    # 更新一个节点
    - docker node update --availability          # 对节点设置状态（“active”正常|“pause”暂停|“drain”排除自身work任务）
	- docker node update --label-add env=xxx 主机名		#为其添加 label
# 管理敏感数据存储
docker secret create
#use secret
docker create service --secret secret_var 服务名

# 服务栈，栈的形式，一般作为编排使用，格式与docker compose相同。
docker stack
    - docker stack deploy -c 文件名.yml 编排服务名    # 通过.yml文件指令部署
    - docker stack ls    # 查看编排服务
    - docker stack rm    
docker stack deploy 不支持的标签
build
cgroup_parent
container_name
devices
dns
dns_search
tmpfs
external_links
links
network_mode
security_opt
stop_signal
sysctls
userns_mode

# 作为集群的管理
docker swarm

    - docker swarm init    # 初始化一个swarm

    - docker swarm init --advertise-addr 管理端IP地址          # 指定初始化ip地址节点

	- docker swarm init --force-new-cluster	  # 去除本地之外的所有管理器身份

    - docker swarm join    # 将节点加入swarm集群，两种加入模式manager与worker
          - docker swarm join-token          # 工作节点加入管理节点需要通过join-token认证
          - docker swarm join-token worker   # 重新获取docker获取初始化命令

    - docker swarm leave    # 离开swarm
    - docker swarm update    # 对swarm集群更新配置
    - 
# 服务管理
docker service
    - docker service create    # 创建一个服务
          # 创建的副本数
          - docker service create --replicas 副本数
          # 每个节点都必须创建一个
          - docker service create --mode global xx
          # 指定容器名称
          - docker service create --name 名字
          # 每次容器与容器之间的更新时间间隔。
          - docker service create --update-delay s秒
          # 更新时同时并行更新数量，默认1
          - docker service create --update-parallelism 个数
          # 任务容器更新失败时的模式，（“pause”停止|”continue“继续），默认pause。
          - docker service create --update-failure-action 类型
          # 每次容器与容器之间的回滚时间间隔。
          - docker service create --rollback-monitor 20s
          # 回滚故障率如果小于百分比允许运行
          - docker service create --rollback-max-failure-ratio .数值（列“.2”为%20）
          # 添加网络
          - docker service create --network 网络名
          # 创建volume类型数据卷
          - docker service create --mount type=volume,src=volume名称,dst=容器目录
          # 创建bind读写目录挂载
          - docker service create --mount type=bind,src=宿主目录,dst=容器目录
          # 创建bind只读目录挂载
          - docker service create --mount type=bind,src=宿主目录,dst=容器目录,readonly
          # 创建dnsrr负载均衡模式
          - docker service create --endpoint-mode dnsrr 服务名
          # 创建docker配置文件到容器本地目录
          - docker service create --config source=docker配置文件,target=配置文件路径
          # 创建添加端口
          - docker service create --publish 暴露端口:容器端口 服务名
          # 指定test标签主机运行
          - docker service create --constraint node.labels.env==test 服务名
          # 健康检查
          - docker service create --health-cmd "xxxxxx" 服务名
          
    # 查看服务详细信息，默认json格式
    - docker service inspect          
          - docker service inspect --pretty 服务名	# 查看服务信息平铺形式

    - docker service logs    # 查看服务内输出

    - docker service ls    # 列出服务

    - docker service ps　　 # 列出服务任务信息
          - docker service ps 服务名          # 查看服务启动信息
          - docker service ps -f "desired-state=running" 服务名          # 过滤只运行的任务信息

    - docker service rm    # 删除服务

    - docker service scale    # 缩容扩容服务
          - docker service scale 服务名=副本数          # 扩展服务容器副本数量

    - docker service update    # 更新服务相关配置
          # 容器加入指令
          - docker service update --args “指令” 服务名
          # 更新服务容器版本
          - docker service update --image 更新版本 服务名         
         # 回滚服务容器版本
         - docker service update --rollback 回滚服务名
          # 添加容器网络
          - docker service update --network-add 网络名 服务名
          # 删除容器网络
          - docker service update --network-rm 网络名 服务名
          # 服务添加暴露端口
          - docker service update --publish-add 暴露端口:容器端口 服务名
          # 移除暴露端口
          - docker service update --publish-rm 暴露端口:容器端口 服务名
          # 修改负载均衡模式为dnsrr
          - docker service update --endpoint-mode dnsrr 服务名
          # 添加新的配置文件到容器内
          - docker service update --config-add 配置文件名称，target=/../容器内配置文件名 服务名
---eg:----
# 1创建配置文件
docker config create nginx2_config nginx2.conf 
# 2删除旧配置文件
docker service update --config-rm ce_nginx_config 服务名
# 3添加新配置文件到服务
ocker service update --config-add src=nginx2_config,target=/etc/nginx/nginx.conf ce_nginx

# 删除配置文件
- docker service update --config-rm 配置文件名称 服务名
# 强制重启服务
- docker service update --force 服务名
```
swarm内置failover策略可以实现故障转移
overlay 网络的服务发现
Swarm 管理数据，利用 Docker 的 volume driver。由外部 storage provider 管理和提供 volume（[Rex-Ray](https://rexray.readthedocs.io/en/stable/)）**[docker支持的volume](https://docs.docker.com/engine/extend/legacy_plugins/#volume-plugins)*