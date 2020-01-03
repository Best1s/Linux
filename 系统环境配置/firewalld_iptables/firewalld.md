Centos7以上的发行版自带了firewalld防火墙的。
### iptables与firewalld
* iptables的防火墙策略是交由内核层面的netfilter网络过滤器来处理，
* firewalld则是交由内核层面的nftables包过滤框架来处理。 
* firewalld支持动态更新技术并加入了区域（zone）的概念。
* firewalld预先准备了几套防火墙策略集合（策略模板），用户可以根据生产场景的不同而选择合适的策略集合，从而实现防火墙策略之间的快速切换。

firewalld 配置文件目录，/usr/lib/firewalld 和 /etc/firewalld

server 文件夹存储服务数据，就是一组定义好的规则。

zones 存储区域规则

firewalld.conf 默认配置文件，可以设置默认使用的区域，默认区域为 public，对应 zones目录下的 public.xml

Firewalld区域
```
区域								描述
drop（丢失）	任何接收的网络数据包都被丢弃，没有任何回复。仅能有发送出去的网络练连接

block（限制）	任何接收的网络连接都被IPv4的icmp-host-prohibited信息和icmp6-adm-prohibited信息所拒绝

public (公共)	在公共区域内使用，不能相信网络内的其他计算机不会对您的计算机造成危害，只能接收经过选取的连接

external (外部)	特别是为路由器启用了伪装功能的外部网。不能信任来自网络的其他计算，不能相信它们不会对您的计算机造成危害，只能接收经过选择的连接

dmz (非军事区)	用于您的非军事区内的电脑，此区域内可公开访问，可以有限地进入您的内部网络，仅仅接收经过选择的连接

work (工作)	用于工作区。您可以基本相信网络内的其他电脑不会危害您的电脑。仅仅接收经过选择的连接用于家庭网络。

home (家庭)	您可以基本信任网络内的其他计算机不会危害您的计算机。仅仅接收经过选择的连接

internal (内部)	用于内部网络。您可以基本上信任网络内的其他计算机不会威胁您的计算机。仅仅接受经过选择的连接

trusted (信任)	可接受所有的网络连接

```
### firewall-cmd用法


1. 重载防火墙配置
```
firewall-cmd --reload
```

2. 查看防火墙运行状态
```
firewall-cmd --state
```
3. 区域设置
```
firewall-cmd --list-all	#查看默认区域设置
firewall-cmd --get-default-zone 	#查看默认区域
firewall-cmd --get-active-zone	#查看当前活跃的区域
firewall-cmd --set-default-zone=<区域名>	#修改默认区域
firewall-cmd --permanent  --change-interface=eth0 --zone=drop	#将网络接口关联至drop区
firewall-cmd --permanent --add-source=192.168.12.0/24 --zone=trusted	#将192.168.12.0/24网段加入trusted白名单
firewall-cmd --zone=public --query-service=ssh	#查询public区域是否允许请求SSH协议的流量，对应服务对应状态
恢复默认规则操作
firewall-cmd --set-default-zone=public
firewall-cmd --remove-source=192.168.12.0/24 --zone=trusted --permanent
```
4. 应急命令
```
firewall-cmd --panic-on  # 拒绝所有流量，远程连接会立即断开，只有本地能登陆
firewall-cmd --panic-off  # 取消应急模式，但需要重启firewalld后才可以远程ssh
firewall-cmd --query-panic  # 查看是否为应急模式
```
5. 服务管理的命令
```
firewall-cmd --get-services  #显示预先定义的服务
firewall-cmd --list-services #查看添加的服务
firewall-cmd --add-service=<service name> #添加服务,设置默认区域允许该服务的流量
firewall-cmd --remove-service=<service name> #移除服务,设置默认区域不再允许该服务的流量
		firewall-cmd --permanent --remove-service=https 	#请求https协议的流量设置为永久拒绝
```
6. 指定端口
```
firewall-cmd --add-port=<port>/<protocol> #添加端口/协议（TCP/UDP）
firewall-cmd --remove-port=<port>/<protocol> #移除端口/协议（TCP/UDP）
firewall-cmd --list-ports #查看开放的端口
				加上--permanent 查看永久生效的配置参数、资源、端口以及服务等信息
端口转发策略,需要用到forward-port
		#转发本机80/tcp端口的流量至127.0.0.1:8080/tcp端口上
		firewall-cmd --permanent --zone=public --add-forward-port=port=80:proto=tcp:toport=8080:toaddr=127.0.0.1
		firewall-cmd --remove-forward-port=port=80:proto=tcp:toport=8080:toaddr=127.0.0.1	#移除转发
		firewall-cmd --add-masquerade --permanent #IP地址转换,开启后才能转发端口
```
7. 协议
```
firewall-cmd --add-protocol=<protocol> # 允许协议 (例：icmp，即允许ping)
firewall-cmd --remove-protocol=<protocol> # 取消协议
firewall-cmd --list-protocols # 查看允许的协议
```
8. 网卡
``` 
firewall-cmd --add-interface=<网卡名称>  #将源自该网卡的所有流量都导向某个指定区域
firewall-cmd --change-interface=<网卡名称>   #将某个网卡与区域进行关联
```

防火墙富规则策略,上面的条目富规则都可实现具体配置案例查询firewalld.richlanguage
```
富规则语法:
rule [family="ipv4|ipv6"|"be"]
	[source] address="address[/mask]" [invert="True"]
	[destination] address="address[/mask]" invert="True"
	service name="service name" |
	port="port value" protocol="tcp or udp" |
	protocol value="<protocol>" |
	icmp-block |
	masquerade |
	forward-port port="port value"  to-port="port value" protocol="tcp|udp" to-addr="address"
	[log] [prefix="prefix text"] [level="log level"] [limit value="rate/duration"]
	[audit]
	[accept|reject|drop]

#区里的富规则按先后顺序匹配，按先匹配到的规则生效。
firewall-cmd --add-rich-rule='<RULE>'    //在指定的区添加一条富规则
firewall-cmd --remove-rich-rule='<RULE>' //在指定的区删除一条富规则
firewall-cmd --query-rich-rule='<RULE>'  //找到规则返回0 ，找不到返回1
firewall-cmd --list-rich-rules       //列出指定区里的所有富规则
firewall-cmd --list-all 和 --list-all-zones 也能列出存在的富规则
```
1. 允许指定ip的所有流量
```
firewall-cmd --add-rich-rule="rule family="ipv4" source address="<ip>" accept"
例：
firewall-cmd --add-rich-rule="rule family="ipv4" source address="192.168.2.1" accept" # 表示允许来自192.168.2.1的所有流量
```
2. 允许指定ip的指定协议
```
firewall-cmd --add-rich-rule="rule family="ipv4" source address="<ip>" protocol value="<protocol>" accept"
例：
firewall-cmd --add-rich-rule="rule family="ipv4" source address="192.168.2.208" protocol value="icmp" accept" # 允许192.168.2.208主机的icmp协议，即允许192.168.2.208主机ping
```
3. 允许指定ip访问指定服务
```
firewall-cmd --add-rich-rule="rule family="ipv4" source address="<ip>" service name="<service name>" accept"
例：
firewall-cmd --add-rich-rule="rule family="ipv4" source address="192.168.2.208" service name="ssh" accept" # 允许192.168.2.208主机访问ssh服务
firewall-cmd --add-rich-rule="rule family="ipv4" source address="192.168.0.0/24" service name="tftp" log prefix="tftp" accept"	#在192.168.0.0/24这个段里可以访问tftp服务,开启log
```
4. 允许指定ip访问指定端口
```
firewall-cmd --add-rich-rule="rule family="ipv4" source address="<ip>" port protocol="<port protocol>" port="<port>" accept"
例：
firewall-cmd --add-rich-rule="rule family="ipv4" source address="192.168.2.1" port protocol="tcp" port="22" accept" # 允许192.168.2.1主机访问22端口
```
5. 将指定ip改为网段
```
8-11 的各个命令都支持 source address 设置为网段，即这个网段的ip都是适配这个规则：
例如：
firewall-cmd --zone=drop --add-rich-rule="rule family="ipv4" source address="192.168.2.0/24" port protocol="tcp" port="22" accept"
表示允许192.168.2.0/24网段的主机访问22端口 。
```
6. 禁止指定ip/网段
```
8-12 各个命令中，将 accept 设置为 reject表示拒绝，设置为 drop表示直接丢弃（会返回timeout连接超时）
例如：
firewall-cmd --zone=drop --add-rich-rule="rule family="ipv4" source address="192.168.2.0/24" port protocol="tcp" port="22" reject"
表示禁止192.168.2.0/24网段的主机访问22端口 。
```
7. 指定网段转发 
```
firewall-cmd --add-masquerade
firewall-cmd --zone=public --permanent --add-rich-rule="rule family="ipv4" source address="192.168.0.0/24" forward-port port="80" to-port="8080" protocol="tcp" to-addr="local"   #来自192.168.0.0/24这个段的80端口数据转发到本地的8080端口
```


防火墙开启内部上网
1、网卡默认是在public的zones内，也是默认zones。永久添加源地址转换功能
```
firewall-cmd --add-masquerade --permanent
firewall-cmd --reload
```
2、共享上网
开启的ip转发后，相当了一台本地的nat服务器。
将client的网关指向你配置的ip转发服务器的IP。
只要你的ip转发服务器可以正常解析公网IP(dns可解析公网地址)。
Clent服务器就可以借助IP转发服务器实现上网（前提是中间路由可达）。
