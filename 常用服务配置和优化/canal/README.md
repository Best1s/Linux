容器集群安装 HA canal

依赖: 需要提前部署  zookeeper，可使用 helm 安装 （需要准备 Storageclass）

zookeeper: [charts/bitnami/zookeeper at master · bitnami/charts (github.com)](https://github.com/bitnami/charts/tree/master/bitnami/zookeeper)

```
helm install -n canal zookeeper/Chart.yml
```

部署 canal-admin  canal-deploy  [alibaba/canal: 阿里巴巴 MySQL binlog 增量订阅&消费组件 (github.com)](https://github.com/alibaba/canal)

```shell
kubectl apply -f canal_install
```

登录  canal-admin  添加集群，添加主配置文件即可。