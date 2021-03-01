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
加入 master 集群
```
kubeadm token create --print-join-command
```

service-cluster 地址范围配置
```
kube-apiserver 启动参数中加入 service-cluster-ip-range= x.x.x.x/x
```
（ p.s. kubectl -v=6 可以显示所有 API 细节指令）
etcd 小技巧：通过--etcd-servers-overrides可以将 Kubernetes Event 的资料写入作为切割，分不同机器处理，如下所示
--etcd-servers-overrides=/events#https://0.example.com:2381;https://1.example.com:2381;https://2.example.com:2381

kubectl 不用 yaml方式更新 pod
```
kubectl set image deployment  <deploymentName> <containerName>=<image>
eg:  kubectl set image deployment/hello-nginx hello-nginx=nginx:1.9.2
```
查看发布历史
```
kubectl rollout history deployment DeploymentName -n NameSpace
```
kubectl 回滚

```
kubectl  rollout undo deployment hello-nginx  # --to-revision=1  指定版本回退
```

