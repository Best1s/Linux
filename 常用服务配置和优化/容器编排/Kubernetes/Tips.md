kubectl重启某个pod或者强制停掉

由于项目起了多个节点，其中一个挂掉了，想要不用yaml 只重启挂掉的这个，可用命令：
```
kubectl get pods PODNAME -n NAMESPACE -o yaml | kubectl replace --force -f -
```
滚动更新重启,通过添加一个环境变量。
```
kubectl patch deployment <deployment-name> \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"<container-name>","env":[{"name":"RESTART_","value":"'$(date +%s)'"}]}]}}}}'
```
同样的一个pod需要停掉执行命令
```
kubectl get deployment -n NAMESPACE
kubectl delete deployment DEPLOYNAME -n NAMESPACE
```
加入 master 集群 ```kubeadm token create --print-join-command```

service-cluster 地址范围配置 ```kube-apiserver 启动参数中加入 service-cluster-ip-range= x.x.x.x/x```

（ p.s. kubectl -v=6 可以显示所有 API 细节指令）
etcd 小技巧：通过--etcd-servers-overrides可以将 Kubernetes Event 的资料写入作为切割，分不同机器处理，如下所示 ```--etcd-servers-overrides=/events#https://0.example.com:2381;https://1.example.com:2381;https://2.example.com:2381```

kubectl 不用 yaml方式更新 pod
```
kubectl set image deployment  <deploymentName> <containerName>=<image>
eg:  kubectl set image deployment/hello-nginx hello-nginx=nginx:1.9.2
```
查看发布历史 ```kubectl rollout history deployment DeploymentName -n NameSpace```

kubectl 回滚 ``` kubectl  rollout undo deployment hello-nginx  # --to-revision=1  指定版本回退```

强制删除 ```pods   kubectl delete pod [pod name] --force --grace-period=0 -n [namespace]```

k8s强制删除pv ```kubectl patch pv pv-name -p '{"metadata":{"finalizers":null}}'```

mysqldump  --skip-lock-tables  不锁表备份数据。

pod 安全策略
```
spec:
  securityContext:
    runAsUser: 5000
    runAsGroup: 5000
  containers:
    securityContext:
      allowPrivilegeEscalation: false

or
spec:
  privileged: false
  #Required to prevent escalations to root.
  allowPrivilegeEscalation: false
  allowedCapabilities:
  - '*'
  volumes:
  - 'nfs'
  hostNetwork: true
  hostPorts:
  - min: 8000
    max: 8000
  hostIPC: true
  hostPID: true
  runAsUser:
    #Require the container to run without root.
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
```
service
space.ExternalTrafficPolicy: Cluster | Local
能够保留来源IP，并可以保证公网、VPC内网访问（LoadBalancer）和主机端口访问（NodePort）模式下流量仅在本节点转发。Local转发使部分没有业务Pod存在的节点健康检查失败，可能存在流量不均衡的转发的风险。

docker  USER redis  #使用redis 用户运行 redis 用户必须存在容器



查看证书有效期 ```kubeadm alpha certs check-expiration```

证书```kubeadm alpha certs renew all```

通过crontab定时更新证书 ```0 0 15 10 * kubeadm alpha certs renew all```

证书过期kubectl命令无法使用

更新客户端配置：```/usr/bin/cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config```