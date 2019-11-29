docker容器之间通信的三种方式
* **bridge：**默认通讯方式，会创建docker0的虚拟网桥器之间的通信都是通过bridge网桥进行通信。然后网桥在与宿主机镜像进行ip转换，端口映射等通信
* **host：**如果容器指定网络模式为host，容器不会有自己的network namespace，而是和宿主机共用一个network网络及ip，容器不会有虚拟出自己的网卡、ip等
* **none：**容器指定网络模式-net为none时，docker容器拥有自己的network namespace，但是网络配置都需要自行配置，如ip、网卡等

网桥管理工具brctl    #yum -y install bridge-utils
添加虚拟网桥  brctl addbr br0
ifconfig br0 x.x.x.x netmask x.x.x.x
更改docker守护进程启动配置文件：DOCKER_OPS值 -b=br0  #指定自定义网桥

--fixed-cidr   #限制IP地址分配范围

###容器互联
* 允许所有容器互联
	```	
--icc=true #默认
	```

* 拒绝容器间互联
 	```
docker启动配置文件中加入
DOCKER_OPS="--icc=false"
	```
* 允许特定容器间的连接
 ```
--icc=false --iptables=true
--link   #需要双向绑定
```
* 容器与外部网络连接 -- 依赖iptables
```
--ip-forward=true  #默认
filter表中包含的链
INPUT	
FORWARD	
OUTPUT
```
* 跨主机容器连接
 1.原理：通过设置网关与宿主机相同，配置简单，需要有网段控制权
![blockchain](http://cdn.binver.top/docker/docker_container_connect.pngdocker_container_connect.png "容器跨主机连接")

	2 Open vSwitch	
	原理利用 GRE VPN 协议进行数据帧或包重新封装，通过隧道发送，新的帧头提供路由信息
![blockchain](http://cdn.binver.top/docker/docker_OpenvSwitch.png "容器跨主机连接")
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
![blockchain](http://cdn.binver.top/docker/docker-weave.png "容器跨主机连接weave")

```
#安装warve(https://github.com/weaveworks/weave)  只要weave就行 执行weave时会拉取weave镜像
weave lauch  #运行weave 会拉取镜像并运行
weave attach x.x.x.x/x containerID   #将ip绑定到网络，另一台host同样操作


```
ipatbels 知识 https://www.cnblogs.com/kevingrace/p/6265113.html
net.ipv4.conf.all.forwarding=1