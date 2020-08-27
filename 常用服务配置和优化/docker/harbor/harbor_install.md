安装 文档  https://goharbor.io/docs/2.0.0/install-config/download-installer/

compose 安装
软件需要  docker-ce, pip,  docker-compose

1：下载(https://github.com/goharbor/harbor/releases)
2：配置文件 harbor/make/harbor.yml  （一般修改hostname 关闭443 harb 登录密码 数据保存位置。）  
3：运行 ./prepare  脚本更新配置
4：运行安装脚本  ./install.sh
5：docker-compose up -d 后台启动 docker hub 应用,  同时可以运行update_compose.sh命令配置本地仓库
6 登录

最低配置要求
Resource	Minimum		Recommended
CPU			2 CPU		4 CPU
Mem			4 GB		8 GB
Disk		40 GB		160 GB


* docker hub  关闭ssl 需要在 /etc/docker/daemon.json 添加     ｛"insecure-registries": ["hubIP"]｝
eg:
```
{
  "selinux-enabled": false,
  "max-concurrent-downloads": 10,
  "live-restore": true,
  "ip-masq": false,
  "iptables": false,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-file": "10",
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "registry-mirrors":["http://hub-mirror.c.163.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "insecure-registries": ["x.x.x.x"]
}
```
