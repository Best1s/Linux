docker容器之间通信方式
* **bridge：**默认通讯方式，会创建docker0的虚拟网桥器之间的通信都是通过bridge网桥进行通信。然后网桥在与宿主机镜像进行ip转换，端口映射等通信
* **host：**如果容器指定网络模式为host，容器不会有自己的network namespace，而是和宿主机共用一个network网络及ip，容器不会有虚拟出自己的网卡、ip等 --net=host  --privileged=true 容器会被允许配置主机网络
* **none：**容器指定网络模式-net为none时，docker容器拥有自己的network namespace，但是网络配置都需要自行配置，如ip、网卡等  --net=none
* **Container：**将新建的容器放到一个已存在的网络栈中，新容器会和已存在的容器共享IP地址和端口等网络资源。 docker run --net=container:container_ID -d IMAGE_name

网桥管理工具brctl    #yum -y install bridge-utils
添加虚拟网桥  brctl addbr br0
ifconfig br0 x.x.x.x netmask x.x.x.x
更改docker守护进程启动配置文件：DOCKER_OPS值 -b=br0  #指定自定义网桥

--fixed-cidr   #限制IP地址分配范围

###容器互联（集群下网络结构）
* Bridge模式
1 允许所有容器互联
	```	
--icc=true #默认
	```

 2 拒绝容器间互联
 	```
docker启动配置文件中加入
DOCKER_OPS="--icc=false"
	```
3 允许特定容器间的连接
 ```
--icc=false --iptables=true
--link   #需要双向绑定
```
4 容器与外部网络连接 -- 依赖iptables
```
--ip-forward=true  #默认
filter表中包含的链
INPUT	
FORWARD	
OUTPUT
```
* 跨主机容器连接
 1.原理：通过设置网关与宿主机相同，配置简单，需要有网段控制权
![blockchain](http://www.binver.top/docker/docker_container_connect.pngdocker_container_connect.png "容器跨主机连接")

	2 Open vSwitch	
	原理利用 GRE VPN 协议进行数据帧或包重新封装，通过隧道发送，新的帧头提供路由信息
![blockchain](http://www.binver.top/docker/docker_OpenvSwitch.png "容器跨主机连接")
```
# 安装Open vSwitch 
下载openvswitch并安装
# 建立ovs网桥
ovs-vsctl add-br 虚拟网桥名
ovs-vsctl add-port 虚拟网桥名 接口名
ovs-vsctl set interface 接口名 type=gre options:remote_ip=远程docker主机ip
brctl addbr xxx
ipconfig xxx x.x.x.x netmask x.x.x.x
brctl addif xxx  ovs名
用新网桥代替docker0 重启docker服务
同样方式设置另一台。
ip route add 添加路由表信息
# 添加gre连接
# 配置docker 容器虚拟网桥
# 添加不同Docker容器网段路由
```
3 weave跨主机连接（https://www.weave.works）
![blockchain](http://www.binver.top/docker/docker-weave.png "容器跨主机连接weave")

 ```
#安装warve(https://github.com/weaveworks/weave)  只要weave就行 执行weave时会拉取weave镜像
weave lauch  #运行weave 会拉取镜像并运行
weave attach x.x.x.x/x containerID   #将ip绑定到网络，另一台host同样操作
```
4 Flannel模式
![blockchain](http://www.binver.top/docker/flannel%E6%A8%A1%E5%BC%8F.png "Flannel模式")
原理：通过分布式存储etcd在集群环境中维护一张全局路由表，每台宿主机都允许flanneld守护进程，负责和etcd交互，拿到路由表，监听宿主机上所有容器报文，执行类似交换机的路由转发操作。（SDN思想）
图中，Flannel会先安装一个flanneld虚拟网桥镜像/16网段的转发，由flanneld守护进程维护整个网络的路由表，把连个物理键的虚拟子网连接成一个更大的虚拟网络。各flaneld之间可以实现报文的二次封装和目标源更改，实现逻辑隧道。
yum install etcd flannel
配置 etcd.conf
 ```
#[Member]
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"	#数据存放位置
ETCD_LISTEN_PEER_URLS="http://localhost:2380"
ETCD_LISTEN_CLIENT_URLS="http://localhost:2379"	#监听客户端地址
ETCD_NAME="etc1"
ETCD_ADVERTISE_CLIENT_URLS="http://localhost:2379"	#通知客户端地址
ETCD_INITIAL_CLUSTER="default=http://localhost:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
```
 配置flannel.conf
```
FLANNEL_ETCD_ENDPOINTS="http://localhsst:2379"	#etcd地址
FLANNEL_ETCD_PREFIX="/atomic.io/network"
```

ipatbels 知识 https://www.cnblogs.com/kevingrace/p/6265113.html
[自己ipatbels](https://github.com/Best1s/Linux/tree/master/%E7%B3%BB%E7%BB%9F%E7%8E%AF%E5%A2%83%E9%85%8D%E7%BD%AE%E4%B8%8E%E5%AE%89%E5%85%A8/firewalld_iptables)
net.ipv4.conf.all.forwarding=1  #开启内核转发