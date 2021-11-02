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

etcd 小技巧：通过--etcd-servers-overrides可以将 Kubernetes Event 的资料写入作为切割，分不同机器处理:

 ```--etcd-servers-overrides=/events#https://0.example.com:2381;https://1.example.com:2381;https://2.example.com:2381```

kubectl 不用 yaml方式更新 pod
```
kubectl set image deployment  <deploymentName> <containerName>=<image>
eg:  kubectl set image deployment/hello-nginx hello-nginx=nginx:1.9.2
```
查看发布历史

 ```kubectl rollout history deployment DeploymentName -n NameSpace```

kubectl 回滚 

```
kubectl  rollout undo deployment hello-nginx  # --to-revision=1  指定版本回退
```

强制删除 pods 

  ```
kubectl delete pod [pod name] --force --grace-period=0 -n [namespace]
  ```

k8s强制删除pv  

```
kubectl patch pv pv-name -p '{"metadata":{"finalizers":null}}'
```



k8s command & args

```
command、args两项实现覆盖Dockerfile中ENTRYPOINT的功能，具体的command命令代替ENTRYPOINT的命令行，args代表集体的参数。
 
如果command和args均没有写，那么用Dockerfile的配置。
如果command写了，但args没有写，那么Dockerfile默认的配置会被忽略，执行输入的command（不带任何参数，当然command中可自带参数）。
如果command没写，但args写了，那么Dockerfile中配置的ENTRYPOINT的命令行会被执行，并且将args中填写的参数追加到ENTRYPOINT中。
如果command和args都写了，那么Dockerfile的配置被忽略，执行command并追加上args参数。比如：
command：/test.sh,p1,p2
args: p3,p4
 
另：多命令执行使用sh,-c,[command;command,...]的形式，单条命令的参数填写在具体的command里面，例如：
command：sh,-c,echo '123';/test.sh,p1,p2,p3,p4
args: 不填
```





pod 安全策略
```yaml
spec:
  securityContext:
    runAsUser: 5000
    runAsGroup: 5000
  containers:
    securityContext:
      allowPrivilegeEscalation: false

#or
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



docker image 设置时区。这对于日志、调用链等功能能否在 TSF 控制台被检索到非常重要。

```
RUN rm -f /etc/localtime
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  # ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo Asia/Shanghai > /etc/timezone
```

``` shell
perf record -F 99 -p 873 -g -- sleep 30

ansible all -m authorized_key -a "user=root state=present key=\"{{ lookup('file', '/root/.ssh/id_rsa.pub') }} \"" -k 

alias curl='curl -w "\ntime_namelookup: "%{time_namelookup}"\ntime_connect: "%{time_connect}"\ntime_appconnect: "%{time_appconnect}"\ntime_pretransfer: "%{time_pretransfer}"\ntime_starttransfer: "%{time_starttransfer}"\ntime_redirect: "%{time_redirect}"\ntime_total: "%{time_total}"\n" '
```

PodDisruptionBudget 3个字段 #https://kubernetes.io/zh/docs/tasks/run-application/configure-pdb/#%E6%8C%87%E5%AE%9A-poddisruptionbudget
.spec.selector
.spec.minAvailable       #驱逐后仍须保证可用的 Pod 数量 可以是绝对值，也可以是百分比
.spec.maxUnavailable	#驱逐后允许不可用的 Pod 的最大数量。其值可以是绝对值或是百分比。



优化 k8s nginx

```yaml
lifecycle:
  preStop:
    exec:
      command: [
        # Gracefully shutdown nginx
        "sleep 5 &&  /usr/sbin/nginx", "-s", "quit"
      ]
```



组件  DynamicScheduler  DeScheduler  OOMGuard NodeProblemDetectorPlus P2P NginxIngress

 