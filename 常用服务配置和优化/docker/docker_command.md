##docker常用命令
官方文档https://docs.docker.com/engine/reference/run/

**Docker环境信息 — docker [info|version]**
```
* docker info
* docker version
```

**容器生命周期管理 —  docker [create|run|exec|start|stop|restart|kill|rm|pause|unpause]**
```
* docker create [OPTIONS] IMAGE [COMMAND] [ARG...]
* docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
	--name=xxx	#自定义容器名字
	--restart=always #docker服务重启时，容器会自动启动
		# --restart no – 容器退出时不要自动重启。这个是默认值
		# always – 不管退出状态码是什么始终重启容器。
		#unless-stopped – 不管退出状态码是什么始终重启容器，不过当daemon启动时，如果容器之前已经为停止状态，不要尝试启动它。
		#1已经启动的容器  docker container update --restart=always 容器名字
		#2修改配置文件，要先停止容器，配置文件路径为：/var/lib/docker/containers/容器ID
		#在该目录下找到一个文件 hostconfig.json ，找到该文件中关键字 RestartPolicy
		#修改前配置："RestartPolicy":{"Name":"no","MaximumRetryCount":0}
		#修改后配置："RestartPolicy":{"Name":"always","MaximumRetryCount":0}
	-i  --interactive=ture|fasle  #默认false 交互式启动容器
	-t  --tty=true|false 默认false
	-d  #后台启动
	-P	--publish-all=ture 	#大写P 为容器暴露的所有端口进行映射
	-p  #指定容器映射端口 4中方式
		#containerPort
		#hostPort:containerPort
		#ip::containerPort
		#ip:hostPort:containerPort
	-e #环境变量
	--volumes-from [container] #挂载容器数据卷，数据卷压缩还原
	-v #挂载卷，如果目录不存在会创建，数据卷可加访问权限默认rw  ro只读
	--link <name or id>:alias	#链接2个容器使之间可以互相通信
								 #name和id是源容器的name和id，alias是源容器在link下的别名
	--rm #删除容器时删除与该容器关联的匿名卷
	Ctrl+P Ctrl+Q  将交互式容器转到后台  docker attach containername重新进入

* docker exec [OPTIONS] CONTAINER COMMAND [ARG...]	#在运行容器中启动新进程

* docker rm [OPTIONS] CONTAINER [CONTAINER...]		#删除停止的容器


* docker start [OPTIONS] CONTAINER [CONTAINER...] 	#重新启动容器
 
* docker stop [OPTIONS] CONTAINER [CONTAINER...]	  #发送信号等待停止容器

* docker restart [OPTIONS] CONTAINER [CONTAINER...]	#重启容器
 
* docker kill CONTAINER ID|NAMES						#直接停止容器

* docker pause CONTAINER [CONTAINER...]				#暂停一个或多个容器中的所有进程
 
* docker unpause CONTAINER [CONTAINER...] #取消暂停一个或多个容器中的所有进程
```

**容器操作运维 — docker [ps|container|inspect|top|attach|wait|export|port|rename]**
```
* docker ps [OPTIONS]				#正在运行的容器	
	-a	所有的容器
	-l	最新创建的一个容器
	...
* docker container COMMAND 		#容器管理命令

* docker inspect [OPTIONS] NAME|ID [NAME|ID...]	#返回Docker对象的信息

* docker top CONTAINER [ps OPTIONS] 	#查看容器内进程

* docker attach [OPTIONS] CONTAINER		#

* docker wait CONTAINER [CONTAINER...]	#阻止直到一个或多个容器停止，然后打印它们的退出代码

* docker export [OPTIONS] CONTAINER		#将容器的文件系统导出为tar存档

* docker port CONTAINER [PRIVATE_PORT[/PROTO]]	#列出端口映射或容器的特定映射

* docker rename CONTAINER NEW_NAME				#重命名容器
```
**容器rootfs命令 — docker [commit|cp|diff]**
```
* docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]	#根据容器的更改创建新镜像

* docker cp [OPTIONS] CONTAINER:SRC_PATH DEST_PATH|-
	docker cp [OPTIONS] SRC_PATH|- CONTAINER:DEST_PATH	#在容器和本地文件系统之间复制文件/文件夹

* docker diff CONTAINER		#检查对容器文件系统上的文件或目录的更改

```
**镜像仓库 — docker [login|pull|push|search]**
```
* docker login [OPTIONS] [SERVER]			 #登录Docker注册表。如果未指定服务器，则默认值由守护进程定义。

* docker pull [OPTIONS] NAME[:TAG|@DIGEST]	#拉取镜像

* docker push [OPTIONS] NAME[:TAG]			#推送镜像

* docker search [OPTIONS] TERM				#在Docker Hub中搜索镜像
	 --automated=false	#只显示自动化构建镜像
	 --no-trunc=false	#截断方式显示输出
	 -s,--stars=0		#限制显示的星级
	 -f, --filter filter   Filter output based on conditions provided
		  --fileter=stars=100
	      --format string   Pretty-print search using a Go template
	      --limit int       Max number of search results (default 25)
	      --no-trunc        Don't truncate output

```
**本地镜像管理 — docker [build|images|rmi|tag|save|import|load]**
```
* docker build [OPTIONS] PATH | URL | -	#从Dockerfile生成镜像
	-t	#给镜像打名字和标签
	-f	#指定Dockerfile 默认是PATH/Dockerfile

* docker images [OPTIONS] [REPOSITORY[:TAG]]		  #列出镜像
	-a	--all=false		#显示所有镜像，中间层镜像
	-f	--filter=[]		#过滤条件
	--no-trunc=false  	 #默认false
	-q	--quiet=false	#默认false	#只显示IMAGE ID


* docker rmi [OPTIONS] IMAGE [IMAGE...]		 	  #删除的镜像
	-f --force=false	#强制删除镜像
	--no-prune=false	#保留被打标签的父镜像
* docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]	#标记目标镜像

* docker save [OPTIONS] IMAGE [IMAGE...]			  #将一个或多个图像保存到tar存档（默认情况下流式传输到STDOUT）

* docker import [OPTIONS] file|URL|- [REPOSITORY[:TAG]]	#从tarball导入内容以创建文件系统映像

* docker load [OPTIONS]		#从tar存档或STDIN加载镜像

```
**容器资源管理 — docker [volume|network]**
```
* docker network COMMAND	#创建创建卷

* docker network COMMAND	#管理网络
```
**系统日志信息 — docker [events|history|logs]**
```
* docker events [OPTIONS]	#从服务器获取实时事件

* docker history [OPTIONS] IMAGE		 #显示图像的镜像

* docker logs [OPTIONS] CONTAINER		#显示提供给日志的额外详细信息

-f --follows=true|false 默认为false   #直跟踪日志的变化和结果
-t --timestamps=true|false 默认false	 #返回的结果是加上时间戳
--tail=xx 0最新		#返回结尾处多少数量的日志，不指定会返回所有
```


docker api
/var/run/docker.sock      get /info http/1.1    #通过api获取信息

docker 启动配置文件
-H  tcp://host:port
	unix:///path/to/socker
	fd://*or fd://socktfd
默认客户端配置
-H unix://var/run/docker.sock
docker -H "tcp://x.x.x.x" 远程链接
利用docker环境变量  DOCKER_HOST="tcp://" 可不用输入地址


docker live-restore  解除容器对 docker daemon的依赖
live-restore 添加到 /etc/docker/daemon.json
KillMode=process  添加到 /usr/lib/systemd/system/docker.service

