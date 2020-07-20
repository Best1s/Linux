kubectl重启某个pod或者强制停掉

由于项目起了多个节点，其中一个挂掉了，想要不用yaml 只重启挂掉的这个，可用命令：
```
kubectl get pods PODNAME -n NAMESPACE -o yaml | kubectl replace --force -f -
```
同样的一个pod需要停掉执行命令
```
kubectl get deployment -n NAMESPACE
kubectl delete deployment DEPLOYNAME -n NAMESPACE
```
