
Dockerfile是一个包含用于组合映像的命令的文本文档，通过读取Dockerfile中的指令自动生成映像。
Dockerfile的基本结构

```
#基础镜像信息
FROM <IMAGE>			#必须是已经存在的镜像，必须是第一条非注释语句
FROM <IMAGE>:<TAG>	
FROM <IMAGE>@<digest>

MAINTAINER <name>		#指定作者信息
MAINTAINER <xxxx>

#镜像操作指令
RUN <command>			#shell模式 (/bin/sh -c command执行)
	RUN yum install -y nginx
RUN ["executable", "param1", "param2"]	#exec模式下执行
	RUN ["/bin/bash","-c","echo hello"]
	RUN ["yum", "install", "-y", "nginx"]


CMD ["executable","param1","param2"]		#构建容器后调用，也就是在容器启动时才进行调用。会被run中cmd命令覆盖
    CMD ["/usr/bin/wc","--help"]
CMD ["param1","param2"] #作为ENTRYPOINT指令默认参数
CMD command param1 param2 (执行shell内部命令)
    CMD echo "This is a test." | wc 

	#CMD中只有一个指令。多个指令最后一个执行。

ENTRYPOINT ["executable", "param1", "param2"] (可执行文件, 优先) 不会被run中cmd命令覆盖 需要覆盖run命令加入 --entrypoint加指令
	ENTRYPOINT ["/usr/sbin/nginx", "-g","daemon off;"]

ENTRYPOINT command param1 param2 (shell内部命令,以shell -c形式执行)
　　　#ENTRYPOINT与CMD非常类似，不同的是通过docker run执行的命令不会覆盖ENTRYPOINT，而docker run命令中指定的任何参数，
	 #都会被当做参数再次传递给ENTRYPOINT。Dockerfile中只允许有一个ENTRYPOINT命令，
	 #多指定会覆盖前面的设置，只执行最后的ENTRYPOINT指令。


ADD #将本地文件添加到容器中，tar类型文件会自动解压(网络压缩资源不会被解压)，可以访问网络资源，类似wget
	ADD <src>... <dest>
	ADD ["<src>",... "<dest>"] #用于支持包含空格的路径

    ADD hom* /mydir/          # 添加所有以"hom"开头的文件
    ADD hom?.txt /mydir/      # ? 替代一个单字符,例如："home.txt"
    ADD test relativeDir/     # 添加 "test" 到 `WORKDIR`/relativeDir/
    ADD test /absoluteDir/    # 添加 "test" 到 /absoluteDir/

COPY	#功能类似ADD，但是不会自动解压文件，也不能访问网络资源,单纯复制文件推荐使用COPY
	COPY <src>... <dest>
	COPY["<src>",... "<dest>"] #用于支持包含空格的路径


VOLUME ["/path/to/dir"]	#用于指定持久化目录，数据卷容器
    VOLUME ["/data"]
    VOLUME ["/var/www", "/var/log/apache2", "/etc/apache2"]
	注：
	　　一个卷可以存在于一个或多个容器的指定目录，该目录可以绕过联合文件系统，并具有以下功能：
		1 数据卷可以一个或多个容器共同访问，数据卷是独立的
		2 容器并不一定要和其它容器共享卷
		3 修改数据卷会立即生效
		4 对卷的修改不会对镜像产生影响
		5 卷会一直存在，即使挂载数据卷的容器已经被删除,直到所有的挂载卷容器删除
		6 如果容器镜像的挂载点包含数据，这些数据会拷贝到新初始化的数据卷中。
		7 docker删除容器时不会删除其挂载的数据卷，不会存在垃圾收集机制。
		8 数据卷会在run时在容器创建目录

LABEL <key>=<value> <key>=<value> <key>=<value> ... #用于为镜像添加元数据
	注：
　　	使用LABEL指定元数据时，一条LABEL指定可以指定一或多条元数据，指定多条元数据时不同元数据之间通过空格分隔。
		推荐将所有的元数据通过一条LABEL指令指定，以免生成过多的中间镜像。

ENV <key> <value>  #<key>之后的内容均会被视为其<value>的组成部分，一次只能设置一个变量
    ENV <key>=<value> ...  #可以设置多个变量，每个变量为一个"<key>=<value>"的键值对，如果<key>中包含空格，
							可以使用\来进行转义，也可以通过""来进行标示；另外，反斜线也可以用于续行
    ENV DB_HOST 127.0.0.1
    ENV DB_PASSWORD 123456
    ENV DB_PORT 6379

EXPOSE <port> [<port>...]		#指定运行该容器使用的端口，可指定多个
    EXPOSE 80 443
    EXPOSE 8080
    EXPOSE 11211/tcp 11211/udp
	#指定应用程序的端口，但是并不会打开  run运行时需要映射


WORKDIR /path/to/workdir	#通常是绝对路径，设置为相对路径时会传递
    WORKDIR /a  (这时工作目录为/a
    WORKDIR b  #这时工作目录为/a/b
    WORKDIR c  #这时工作目录为/a/b/c
	注：
　　	通过WORKDIR设置工作目录后，Dockerfile中其后的命令RUN、CMD、ENTRYPOINT、ADD、COPY等命令
		都会在该目录下执行。在使用docker run运行容器时，可以通过-w参数覆盖构建时所设置的工作目录。

USER	#指定运行容器时的用户名或 UID，后续的 RUN 也会使用指定用户。默认root
　　USER user
　　USER user:group
　　USER uid
　　USER uid:gid
　　USER user:gid
　　USER uid:group
   注：
　　	使用USER指定用户后，Dockerfile中其后的命令RUN、CMD、ENTRYPOINT都将使用该用户。镜像构建完成后，
	    通过docker run运行容器时，可以通过-u参数来覆盖所指定的用户。

ARG <name>[=<default value>]	#用于指定传递给构建运行时的变量
    ARG build_user=www
	#ARG与ENV有些类似，它们都可以被后面的其它指令直接使用，但是它并不是环境变量，将来容器运行时是不会存在ARG变量的。

ONBUILD [INSTRUCTION]	#镜像触发器，当所构建的镜像被用做其它镜像的基础镜像，该镜像中的触发器将会被钥触发
　　ONBUILD ADD index.html /usr/shar/nginx/html
　　#当以该镜像构建时会拷贝 index.html 到镜像/usr/shar/nginx/html目录中
```

dockerfile 构建步骤中，可以使用中间层镜像排查错误
构建缓存 　　 
	- RUN指令创建的中间镜像会被缓存，并会在下次构建中使用。如果不想使用这些缓存镜像，
	- 可以在构建时指定--no-cache参数，如：docker build --no-cache
	- 还可以在 Dockerfile 文件中在不需要使用缓存的地方 加入 ENV REFRESH_DATE 2018-11-11
查看镜像构建过程
	- docker history [image]
	


FROM
MAINTAINER
RUN
LABEL
EXPOSE
ENV
ADD
COPY
ENTRYPOINT
CMD
SHELL
VOLUME
USER
WORKDIR
ONBUILD
STOPSIGNAL
HEALTHCHECK


构建优化：
1. 减少镜像的层数，尽量把一些功能上面统一的命令合到一起；
2. 注意清理镜像构建的中间产物；
3. 注意优化网络请求，镜像源
4. 尽量用构建缓存。
5. 多阶段进行镜像构建，将镜像制作的目的做一个明确。