####[Docker-Compose ](https://docs.docker.com/compose/)
是用来管理你的容器的，有点像一个容器的管家，有了Docker-Compose你只需要编写一个文件，在这个文件里面声明好要启动的容器，配置一些参数，执行一下这个文件，Docker就会按照你声明的配置去把所有的容器启动起来，但是Docker-Compose只能管理当前主机上的Docker，也就是说不能去启动其他主机上的Docker容器

install compose
需要依赖包 py-pip, python-dev, libffi-dev, openssl-dev, gcc, libc-dev, and make.
```
curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
Docker Compose 将所管理的容器分为三层，分别是工程（project）、服务（service）、容器（container）
Docker Compose 运行目录下的所有文件（docker-compose.yml）组成一个工程,一个工程包含多个服务，每个服务中定义了容器运行的镜像、参数、依赖，一个服务可包括多个容器实例

docker compose 常见命令
```

docker-compose ps	#列出所有运行容器

docker-compose logs	#查看服务日志输出

port：打印绑定的公共端口，下面命令可以输出 eureka 服务 8761 端口所绑定的公共端口
docker-compose port eureka 8761

docker-compose build	#构建或者重新构建服务

docker-compose start eureka	#启动指定服务已存在的容器

docker-compose stop eureka	#停止已运行的服务的容器

docker-compose rm eureka	#删除指定服务的容器

docker-compose up	#构建、启动容器

docker-compose kill eureka	#通过发送 SIGKILL 信号来停止指定服务的容器

pull：下载服务镜像
scale：设置指定服务容器的个数，以 service=num 形式指定
docker-compose scale user=3 movie=3

docker-compose run web bash	#在一个服务上执行一个命令

```

####docker-compose.yml 属性
- version：指定 docker-compose.yml 文件的写法格式
- services：多个容器集合
- build：配置构建时，Compose 会利用它自动构建镜像，该值可以是一个路径，也可以是一个对象，用于指定 Dockerfile 参数
```
build: ./dir
or
build:
    context: ./dir
    dockerfile: Dockerfile
    args:	#构建过程中指定环境变量，但是在构建成功后取消
        buildno: 1
```
- command：覆盖容器启动后默认执行的命令
```
command: bundle exec thin -p 3000
or
command: [bundle,exec,thin,-p,3000]
```
- dns：配置 dns 服务器，可以是一个值或列表
```
dns: 8.8.8.8
or
dns:
    - 8.8.8.8
    - 9.9.9.9
```
- dns_search：配置 DNS 搜索域，可以是一个值或列表
```
dns_search: example.com
or
dns_search:
    - dc1.example.com
    - dc2.example.com
```
- environment：环境变量配置，可以用数组或字典两种方式
```
environment:
    RACK_ENV: development
    SHOW: 'ture'
or
environment:
    - RACK_ENV=development
    - SHOW=ture
```

- env_file：从文件中获取环境变量，可以指定一个文件路径或路径列表，其优先级低于 environment 指定的环境变量
```
env_file: .env
or
env_file:
    - ./common.env
```
- expose：暴露端口，只将端口暴露给连接的服务，而不暴露给主机
```
expose:
    - "3000"
    - "8000"
```
- ports：对外暴露的端口定义，和 expose 对应
```
ports:   # 暴露端口信息  - "宿主机端口:容器暴露端口"
  - "8763:8763"
  - "8763:8763"
```
- image：指定服务所使用的镜像
```
image: java
```
- network_mode：设置网络模式
```
network_mode: "bridge"
network_mode: "host"
network_mode: "none"
network_mode: "service:[service name]"
network_mode: "container:[container name/id]"
```
- links：将指定容器连接到当前连接，可以设置别名，避免ip方式导致的容器重启动态改变的无法连接情况
```
links:    # 指定服务名称:别名 
    - docker-compose-eureka-server:compose-eureka
```
- volumes：卷挂载路径
```
volumes:
  - /lib:/lib	
  - /etc/example.cnf:/etc/xx.cnf
```
- tmpfs:挂载临时目录到容器内部，与 run 的参数一样效果
```
tmpfs: /run
or
tmpfs:
  - /run
  - /tmp
```
- logs：日志输出信息
```
--no-color          单色输出，不显示其他颜.
-f, --follow        跟踪日志输出，就是可以实时查看日志
-t, --timestamps    显示时间戳
--tail              从日志的结尾显示，--tail=200
```
- depends_on:解决了容器的依赖
```
version: '2'
services:
  web:
    build: .
    depends_on:
      - db
      - redis
  redis:
    image: redis
  db:
    image: postgres
```
- entrypoint ：类似Dockerfile 中 ENTRYPOINT指令，用于指定接入点
```
entrypoint: /code/entrypoint.sh
or
entrypoint:
    - php
    - -d
    - zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20100525/xdebug.so
    - -d
    - memory_limit=-1
    - vendor/bin/phpunit
```
Docker Compose 其它标签
- external_links: 能使容器连接到那些项目配置外部的容器
- extra_hosts:与Docker client的--add-host类似
- logging：标签用于配置日志服务
- cpu_shares, cpu_quota, cpuset, domainname, hostname, ipc, mac_address, mem_limit, memswap_limit, privileged, read_only, restart, shm_size, stdin_open, tty, user, working_dir  ...


更新容器
当服务的配置发生更改时，可使用 docker-compose up 命令更新配置
此时，Compose 会删除旧容器并创建新容器，新容器会以不同的 IP 地址加入网络，名称保持不变，任何指向旧容起的连接都会被关闭，重新找到新容器并连接上去

links
服务之间可以使用服务名称相互访问，links 允许定义一个别名，从而使用该别名访问其它服务
```
version: '2'
services:
    web:
        build: .
        links:
            - "db:database"
    db:
        image: postgres
```
