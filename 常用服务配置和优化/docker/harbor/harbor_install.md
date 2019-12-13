（https://github.com/goharbor/harbor/blob/master/docs/installation_guide.md）
软件需要  docker-ce, pip,  docker-compose

1：下载源码(https://github.com/goharbor/harbor)
2：配置文件 harbor/make/harbor.yml
3：运行 ./prepare  脚本更新配置
4：pip install docker-compose
5：docker-compose up -d 构建docker容器  同时可以运行update_compose.sh命令配置本地仓库
6 登录

最低配置要求
Resource	Minimum		Recommended
CPU			2 CPU		4 CPU
Mem			4 GB		8 GB
Disk		40 GB		160 GB