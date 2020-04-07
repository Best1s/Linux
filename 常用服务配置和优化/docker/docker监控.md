####Docker 自带的监控子命令ps，top, stats
```
docker container ps	#查看当前运行的容器。
docker container top [container]	#容器中运行了哪些进程,还可以跟上ps的参数显示特定的信息
docker container stats 显示每个容器各种资源的使用情况
```
docker 第三方监控。
- sysdig 是一个轻量级的系统监控工具，同时它还原生支持容器。sysdig 是将strace，tcpdump，htop， iftop，lsof ......工具的功能集成到一个工具中，并提供一个友好统一的操作界面。
安装和运行 sysdig
```
docker container run -it --rm --name=sysdig --privileged=true \
          --volume=/var/run/docker.sock:/host/var/run/docker.sock \
          --volume=/dev:/host/dev \
          --volume=/proc:/host/proc:ro \
          --volume=/boot:/host/boot:ro \
          --volume=/lib/modules:/host/lib/modules:ro \
          --volume=/usr:/host/usr:ro \
          sysdig/sysdig
启动后，通过 docker container exec -it sysdig bash 进入容器，执行 csysdig 命令，将以交互方式启动 sysdig。
sysdig 的特点如下：
 -监控信息全，包括 Linux 操作系统和容器。
 -界面交互性强。
```
- Weave Scope 的最大特点是会自动生成一张 Docker 容器地图，让我们能够直观地理解、监控和控制容器
```
执行如下脚本安装运行 Weave Scope。
curl -L git.io/scope -o /usr/local/bin/scope
chmod a+x /usr/local/bin/scope
scope launch
scope launch 将以容器方式启动 Weave Scope。
```
- [Prometheus](https://prometheus.io/docs/introduction/overview/)是一个开源的系统监控和警报工具包。
Prometheus的体系结构及其某些生态系统组件：
![Prometheus的体系结构](https://prometheus.io/assets/architecture.png)
概念：
	- Exporter一类数据采集组件的总称。它负责从目标处搜集数据，并将其转化为Prometheus支持的格式
	- node_exporter属于jobs/exporter部分称之为exporter导出器，是Prometheus主要的指标来源。
	- Prometheus Server是服务核心组件，采集到的监控数据均以metric（指标）形式保存在时序数据库中（TSDB）。
	- 配置方式包含多种，可以直接在写在yaml文件中，但如果配置较长也可以写入其他文件并启用文件发现(file_sd)功能让其自行侦听配置文件变化
	- Prometheus使用pull模型从节点暴露出来的端口拉取配置，这相比push方式更容易避免节点异常带来的干扰和繁琐的工作。
	- pushgateway类似于一个中转站，Prometheus的server端只会使用pull方式拉取数据，但是某些节点因为某些原因只能使用push方式推送数据，那么它就是用来接收push而来的数据并暴露给Prometheus的server拉取的中转站。
	- Prometheus支持告警系统，自带的alertmanager可以通过在配置文件中添加规则的方式，计算并发出警报。
	- Prometheus提供了PromQL语言进行查询，自带一个简易的UI界面，可以在界面上进行查询、绘图、查看配置、告警等等。不过通常使用Grafana等其他API客户端。
	
 运行流程：
prometheus根据配置定时去拉取各个节点的数据，默认使用的拉取方式是pull，也可以使用pushgateway提供的push方式获取各个监控节点的数据。将获取到的数据存入TSDB，一款时序型数据库。此时prometheus已经获取到了监控数据，可以使用内置的PromQL进行查询。它的报警功能使用Alertmanager提供，Alertmanager是prometheus的告警管理和发送报警的一个组件。prometheus原生的图标功能过于简单，可将prometheus数据接入grafana，由grafana进行统一管理。
快速部署：
  - 运行 node-exporter 用于采集服务器层面的运行指标，包括机器的loadavg、filesystem、meminfo等基础监控，类似于传统主机监控维度的zabbix-agent  
  ```
docker run -d -p 9100:9100 \
  -v "/proc:/host/proc" \
  -v "/sys:/host/sys" \
  -v "/:/rootfs" \
  --net=host \
  prom/node-exporter \
  --path.procfs /host/proc \
  --path.sysfs /host/sys \
  --collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"
```
 - 运行 cAdvisor(只支持容器启动)：cAdvisor可以对节点机器上的资源及容器进行实时监控和性能数据采集，包括CPU使用情况、内存使用情况、网络吞吐量及文件系统使用情况
 ```
docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  --net=host \
  google/cadvisor:latest
```
 - 运行 Prometheus Server
```
docker run -d -p 9090:9090 \
  -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml \
  --name prometheus \
  --net=host \
  prom/prometheus
```
 - 运行 Grafana
```
docker run -d -i -p 3000:3000 \
  -e "GF_SERVER_ROOT_URL=http://x.x.x.x"  \
  -e "GF_SECURITY_ADMIN_PASSWORD=secret"  \
  --net=host \
  grafana/grafana
打开浏览器输入配置的Grafana地址，配置 Data Source
```
更多监控 Docker 的 Dashboard[点击这里](https://grafana.com/grafana/dashboards?dataSource=prometheus&search=docker)
