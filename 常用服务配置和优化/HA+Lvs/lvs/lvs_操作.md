yum install -y ipvsadm
定义一个集群服务
```
ipvsadm -A|E -t|u|f service-address [-s scheduler]
-A        添加一个虚拟集群服务
-E        修改一个已存在的虚拟集群服务
-t		定义一个基于TCP协议的集群
-u		定义一个基于UDP协议的集群
-f		定义防火墙标记
service-addr: ip:port
-s		指定调度算法
ipvsadm -A -t x.x.x.x:80 -s rr
ipvsadm -A -t x.x.x.x:8080 -s rr
```
删除集群服务
```
ipvsadm  -D -t|u|f service-address
-D, --delete-service  （删除集群服务）
```
向集群服务添加real server
```
ipvsadm -a|e -t|u|f service-address -r server-address [-g|i|m] [-w weight]

-a, --add-server

Add a real server to a virtual service.(向集群添加一个RS地址)

-e, --edit-server

Edit a real server in a virtual service.（在集群中编辑一个RS）

-r, --real-server server-address（指定RS，host[:port]这样的格式）

选项：
	lvs类型： 
		-g:gateway,dr类型，默认
		-i:ipip,tun类型
		-m:masquerade,nat类型
	-w weight:权重 
```


删除集群服务中的real server
```
ipvsadm -d -t|u|f service-address -r server-address

-d, --delete-server

Remove a real server from a virtual service.（从虚拟服务中删除指定的real server）
```


清空所有的集群服务
```
ipvsadm -C

-C, --clear

Clear the virtual server table.（清空集群服务）
```


保存及重新加载规则
```
ipvsadm -S  > /path/to/some_rule_file (保存时用输出重定向把规则保存在一个文件中，默认保存在/etc/sysconfig/ipvsadm中)

-S, --save

Dump  the  Linux  Virtual  Server  rules  to  stdout  in  a  format  that  can  be read by

ipvsadm -R  < /path/from/some_rule_file (默认是从标准输入中读取规则，一般用输入重定向读取已保存了规则的文件)

-R, --restore
```


查看定义的集群服务及real server的信息
```

ipvsadm -L -n 

-c：查看各连接情况，可查看由哪个客户端访问了哪个虚拟服务，被director调度到了后端哪个real server的信息

--stats：显示统计数据，可查看客户端访问的次数，接收和发送的字节数

--rate：显示速率

--exact：显示精确值
```