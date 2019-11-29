###NFS服务简介
NFS就是Network File System的缩写，它最大的功能就是可以通过网络，让不同的机器、不同的操作系统可以共享彼此的文件。

###RPC与NFS通讯原理：
​ NFS支持的功能相当多，不同的功能都会使用不同的程序来启动，每启动一个功能就会启用一些端口来传输数据，因此NFS的功能对应的端口并不固定，客户端要知道NFS服务器端的相关端口才能建立连接进行数据传输，而RPC就是用来统一管理NFS端口的服务，并且统一对外的端口是111，RPC会记录NFS端口的信息，如此我们就能够通过RPC实现服务端和客户端沟通端口信息。PRC最主要的功能就是指定每个NFS功能所对应的port number,并且通知客户端，记客户端可以连接到正常端口上去。

那么RPC又是如何知道每个NFS功能的端口呢？

首先当NFS启动后，就会随机的使用一些端口，然后NFS就会向RPC去注册这些端口，RPC就会记录下这些端口，并且RPC会开启111端口，等待客户端RPC的请求，如果客户端有请求，那么服务器端的RPC就会将之前记录的NFS端口信息告知客户端。如此客户端就会获取NFS服务器端的端口信息，就会以实际端口进行数据的传输了。

*注意：在启动NFS SERVER之前，首先要启动RPC服务（即portmap服务，下同）否则NFS SERVER就无法向RPC服务区注册，另外，如果RPC服务重新启动，原来已经注册好的NFS端口数据就会全部丢失。因此此时RPC服务管理的NFS程序也要重新启动以重新向RPC注册。特别注意：一般修改NFS配置文档后，是不需要重启NFS的，直接在命令执行systemctl reload nfs或exportfs –rv即可使修改的/etc/exports生效


NFS的相关文件：

主要配置文件：
```
/etc/exports #这是 NFS 的主要配置文件了。
/usr/sbin/exportfs	#NFS 文件系统维护指令,这个是维护 NFS 分享资源的指令，可以利用这个
					#指令重新分享 /etc/exports 变更的目录资源、将 NFS Server 分享的目录卸除或重新分享。
/var/lib/nfs/*tab	#分享资源的登录档在 NFS 服务器的登录文件都放置到 /var/lib/nfs/ 目录里面，
					 #在该目录下有两个比较重要的登录档， 一个是 etab ，主要记录了 NFS 所分享出来的目录的完整权限设定值；
					 #另一个 xtab 则记录曾经链接到此 NFS 服务器的相关客户端数据。
/usr/sbin/showmount #客户端查询服务器分享资源的指令这是另一个重要的 NFS 指令。
					#exportfs 是用在 NFS Server 端，而 showmount 则主要用在 Client 端。
					#showmount 可以用来察看 NFS 分享出来的目录资源。
```
###服务端安装NFS服务步骤：
第一步：安装NFS和rpc。
```
[root@localhost ~]# yum install -y  nfs-utils   
#安装nfs服务
[root@localhost ~]# yum install -y rpcbind
```
###安装rpc服务
```

[root@localhost ~]# systemctl start rpcbind    #先启动rpc服务
[root@localhost ~]# systemctl enable rpcbind   #设置开机启动
[root@localhost ~]# systemctl start nfs-server nfs-secure-server      
#启动nfs服务和nfs安全传输服务
[root@localhost ~]# systemctl enable nfs-server nfs-secure-server
[root@localhost /]# firewall-cmd --permanent --add-service=nfs
```

```
配置文件说明：

格式： 共享目录的路径 允许访问的NFS客户端（共享权限参数）

如上，共享目录为/public , 允许访问的客户端为192.168.245.0/24网络用户，权限为只读。

请注意，NFS客户端地址与权限之间没有空格。

NFS输出保护需要用到kerberos加密（none，sys，krb5，krb5i，krb5p），格式sec=XXX

none：#以匿名身份访问，如果要允许写操作，要映射到nfsnobody用户，同时布尔值开关要打开，setsebool nfsd_anon_write 1

sys：#文件的访问是基于标准的文件访问，如果没有指定，默认就是sys， 信任任何发送过来用户名

krb5：#客户端必须提供标识，客户端的表示也必须是krb5，基于域环境的认证

krb5i：#在krb5的基础上做了加密的操作，对用户的密码做了加密，但是传输的数据没有加密

krb5p：#所有的数据都加密
```

用于配置NFS服务程序配置exportfs文件的参数：
```
参数	作用
ro	#只读
rw	#读写
root_squash		#当NFS客户端以root管理员访问时，映射为NFS服务器的匿名用户
no_root_squash	 #当NFS客户端以root管理员访问时，映射为NFS服务器的root管理员
all_squash		 #无论NFS客户端使用什么账户访问，均映射为NFS服务器的匿名用户
sync		   #同时将数据写入到内存与硬盘中，保证不丢失数据
async		  #异步优先将数据保存到内存，然后再写入硬盘；这样效率更高，但可能会丢失数据
anonuid		#指定匿名用户uid
anongid		#指定匿名用户gid

*客户端于参数之间没有空格
```

showmount命令的用法；
```
参数	作用
-e	显示NFS服务器的共享列表
-a	显示本机挂载的文件资源的情况NFS资源的情况
-v	显示版本号
```
###在该文件中挂载，使系统每次启动时都能自动挂载
```
 vim /etc/fstab 

	192.168.245.128:/public  /mnt/public       nfs    defaults 0 0
	192.168.245.128:/protected /mnt/data     nfs    defaults  0 1

```
autofs  自动挂载  
主要两个文件 
auto.master #定义本地挂载点
auto.misc #配置文件设置需要挂载的文件系统类型，和选项