大并发情况下
iptables 关闭
内网服务器尽量不给外网地址，通过代理访问

iptables包含五个个表，常用三个：
1. FILTER：一般的过滤功能,真正负责防火墙功能的表。默认表
2. NAT：用于nat功能（端口映射，地址映射等）
3. MANGLE：用于对特定数据包的修改
4. RAW：有限级最高，设置raw时一般是为了不再让iptables做数据包的链接跟踪处理，提高性能
5. security：强制访问控制网络规则

表(Tables)中包含链:
1. INPUT：过滤进入主机的数据包
2. OUTPUT：:由本机产生，向外转发
3. FORWARD：转发数据包,目的地不为本机,net.ipv4.ip_forward=0
4. PREROUTING：数据包进入路由表之前
5. POSTROUTING：发送到网卡接口之前

链(Chains)中包含一条一条规则语句
规则(Policy) 一条条过滤语句。


![](http://cdn.binver.top/iptables.png "iptables")

iptables语法:
```
 iptables [-t 表名] 管理选项 [链名] [条件匹配] [-j 目标动作或跳转]
```
管理项
```
-A 追加一条规则（放到最后）
		iptables -t filter -A INPUT -j DROP  #拒绝所有人访问服务器,谨慎使用
		#在filter表的INPUT链中追加一条规则(作为最后一条规则),匹配所有访问本机IP数据包,匹配到的丢弃

-I 插入一条规则,默认是在开头,可以指定位置
		iptables -I INPUT -j DROP		#在filter表的INPUT中插入一条规则(插入成第一条)，执行后需要机房去接显示器了！
		iptables -I INPUT 4 -j DROP		#在filter表的iINPUT中插入一条规则(指定在第四条位置插入)

-R 替换或者修改规则
		iptables -t filter -R INPUT 4 .......    #修改filter表中INPUT链的第四条规则

-D 删除规则
		#按照号码匹配
		intables -L
		iptables -D INPUT 1
		#按照内容匹配
		iptables -D INPUT -s 192.168.0.1 -j DROP

-F 清空规则（清空之前一定要查看默认规则）
		iptables -F INPUT       #清空filter表INPUT链上的规则
		iptables -F             #清空filter表上的所有链规则
		iptables -t nat -f      #清空nat表上的所有规则链
		注意:-F仅仅是清空链中的规则,并不影响默认规则.如果之前设置的默认规则是DROP,然后清空规则,那么就无法连接
-P 设置默认规则
		iptables -P INPUT DROP       #设置默认规则为DROP
		iptables -P INPUT ACCEPT    #设置默认规则为ACCRPT
-Z 清空数据包
		iptables -nvL 查看数据包
		iptables -Z INPUT.
-L 列出规则
	v：显示详细信息,包括每条规则的匹配包数量和匹配字节数
	x：在v的基础上,禁止自动段位换算
	n：显示IP地址和端口号码,不显示域名和服务名称
	--line-numbers 显示序号
	iptables -nvL
	iptables -nvL --line-number
	比较安全的方法是,把需要放行的服务打开,然后在后面将DROP打开
```

二, 条件匹配 
1. 流入,流出接口(-i,-0)
```
-i 	#匹配数据进入的网络接口 此参数主要应用于nat表,例如目标地址装换
		-i eth0
		#匹配是否从网络接口eth进来
		-i ens33
		#匹配是否从网络接口ens33进来
-o 匹配数据流出的网络接口
		#例如
		-o eth0
		-o ens33
```
2. 来源,目的地址(-s,-d)
```
-s <匹配来源地址>
		#可以是IP,网段,域名,也可以空
		-s 192.168.0.1          #匹配来自192.168.0.1的数据包
		-s 192.168.1.0/24       #匹配来自192.168.1.0/24网络的数据包
		-s 192.168.0.0/16       #匹配来自192.168.0.0/16网络的数据包
-d <匹配目的地址>
		#可以是IP,网段,域名,也可以空
		-d 20.10.0.1 	#匹配去往20.10.0.1的数据包
		-d 20.10.0.0/16	#匹配去往20.10.0.0/16网络段的数据包
		-d www.abc.com 	#匹配去往域名www.abc.com的数据包
```
3. 协议类型 (-p)
```
-p <匹配协议类型>
		#可以是tcp,udp,icm
		-p tcp
		-p udp
		-icmp --icmp-type类型
```
4. 来源,目的端口(--sport,--dport)
```
#注意:--sport和--dport都必须配合-p参数使用
--sport #匹配源端口
		--sport 1000  	#匹配源端口是1000的数据包
		--sport 1000-3000 	#匹配源端口是1000-3000的数据包
		--sport :3000  	#匹配3000以下的数据包
		--sport 1000:  	#匹配源端口是1000以上的数据包
--dport #匹配目的端口
		--dport 80	#匹配目的端口是80的数据包
		--dport 22	#匹配目的端口是22的数据包
```


匹配应用举例
```
端口匹配
-p udp --dport 53
匹配网络中目的端口的是53的UDP协议数据包

地址匹配
-s 10.1.0.0/24 -d 172.17.0.0/16
匹配来自10.1.0.0/24去往172.17.0.0/16的所有数据包

端口和地址联合匹配
-s 192.168.0.1 -d www.abc.com -p tcp --dport 80
匹配来自192.168.0.1,去往www.abc.com的80端口的TCP协议数据包

*条件写的越多,匹配越精细,匹配范围越小
*如果用了NAT转发 需要开启FORWARD 80 端口
*iptables -I FORWARD -p tcp --dport 80 -j ACCEPT
```

三, 目标动作或跳转

1. ACCEPT 通过,允许数据包通过本链而不拦截它
```
-j ACCEPT	#通过,允许数据包通过本链而不拦截它
iptables -A INPUT -j ACCERT  #允许所有访问本机IP的数据包通过
```
3. REJECT 拒绝，有响应
2. DROP 丢弃,阻止数据包通过本链而丢弃它
```
-j DROP	#丢弃,阻止数据包通过本链而丢弃它
iptables -A FOREARD -s 192.168.80.39 -j DROP  #阻止来源地址为192.168.80.39的数据包通过本机
```
3. SNAT 原地址转换,SNAT支持单IP,也支持转换到IP地址池(一组连续的IP地址)
```
-j SNAT --to IP [-IP] [:端口-端口]	#nat表的POSTROUTING链,原地址转换,SNAT支持单IP更改,也支持转换到IP地址池.
		#例子
		#将内网192.168.0.0/24的原地址修改为1.1.1.1,用于NAT
		iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to 1.1.1.1
		#用于修改成一个地址池里的IP
		iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to 1.1.1.1-1.1.1.10
```
4. DNAT 目的地址装换,DNAT支持装换为单IP,也支持装换到IP地址池(一组连续的IP地址)
```
-j DNAT --to IP[-IP] [:端口-端口](nat表的PREROUTING链)	#目的地址更改,DNAT支持更改为单IP,也支持更改到IP地址池
		#把从eth0进来的要访问TCP/80的数据包目的地址改为192.168.0.1(端口映射,内网的服务可以映射出去)
			iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to 192.168.0.1
			iptables -t nat -A PREROUTING -i eth0 -p tco --dport 80 -j DNAT --to 192.168.0.1:81
		#把从eth0进来的要访问TCP/80的数据包目的地址改为192.168.0.1-192.169.1.10
			iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to 192.168.0.1-192.168.1.10
```
5. MASQUERADE 伪装
```
#动态原地址装换（动态IP的情况使用）
#将源地址是192.168.0.0、24的数据包进行地址伪装，装换成eth0的IP地址，eth0为路由器外网出口地址
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o eth0 -j MASQUERADE
```

四，附加模块

1. state 按照包状态匹配
```
#iptables有四种状态NEW，ESTABLISHED，RELATED，INVALID。这些状态可以一起使用，以便匹配数据包.
		#NEW状态：在使用UDP、TCP、ICMP等协议时，发出第一个包的状态就是"NEW".主机连接目标主机,第一个要连接的包.
		#ESTABLISHED状态：主机已与目标主机进行通信，判断标准只要目标主机回应了第一个包，就进入该状态。
		#RELATED状态：主机已与目标主机进行通信，目标主机发起新的链接方式，例如ftp21 20
		#INVALID状态：无效的封包，例如数据破损的封包状态
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j accept
```
2. mac 按照来源MAC匹配
```
#匹配某个mac地址
-m mac --mac-source MAC
#阻断来自该mac地址的数据包通过本机
iptables -A FORWARD -m mac --mac-source xx:xx:xx:xx:xx -j DROP
#报文经过路由后，数据包中的原有的mac信息会被替换，所以在路由后的iptables中使用mac模块是没有意义的
```
3. limit 按照包速率匹配
```
-m limit --limit 匹配速率 [--burst 缓冲数量]
限制机器对外发包速率
iptables -A FORWARD -d 192.168.0.1 -m limit --limit 50/s -j ACCRPT
```
4. multiport 多端口匹配 
```
-m multiport <--sports | --posts> 端口1，端口n
一次性匹配多个端口
例如
iptables -A INPUT -p tcp -m multiport --posts 21，22，25，80，110 -j AXXEPR
注意：必须和-p参数同时使用
```


配置防火墙后要保存
```
service iptables save
```
通过命令设置iptables会立即生效，还需要手动执行命令保存，会将设置的策略写入到主配置文件中 /etc/sysconfig/iptables