### docker基本组成
Docker client
Docker daemon
Docker image
Docker container
Docker registry
原则上一个镜像一个服务
### 安装 Docker Engine-Community
官方文档：https://docs.docker.com/install/linux/docker-ce/centos/
安装所需的软件包。
```
yum install -y yum-utils device-mapper-persistent-data  lvm2
```
添加docker源官方
```
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```
阿里云
```
yum-config-manager \
	--add-repo \
	http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```
安装dcoker-ce,并启动
```
yum install docker-ce
systemctl start docker-ce
```

### docker 镜像源加速 /etc/docker/daemon.json文件添加
```
{
    "registry-mirrors" : [
    "https://registry.docker-cn.com",
    "https://docker.mirrors.ustc.edu.cn",
    "http://hub-mirror.c.163.com",
    "https://cr.console.aliyun.com/"
  ]
}
```
### Docker 官方中国区
```
https://registry.docker-cn.com
#网易
http://hub-mirror.c.163.com
#ustc
https://docker.mirrors.ustc.edu.cn
#aliyun

```


方法一
在拉取镜像时候指定镜像源地址
```
docker pull registry.docker-cn.com/myname/myrepo:mytag
例如:
docker pull registry.docker-cn.com/library/ubuntu:16.04
```
方法二 
使用 –registry-mirror 配置 Docker 守护进程

```
docker --registry-mirror=https://registry.docker-cn.com daemon
```
方法三
修改 /etc/docker/daemon.json 文件并添加上 registry-mirrors 键值
```
{
  "registry-mirrors": ["http://hub-mirror.c.163.com"]
}
systemctl restart docker
```

docker免费在线工具  https://labs.play-with-docker.com/
docker 教程https://training.play-with-docker.com/
