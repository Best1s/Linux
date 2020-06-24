document address:
https://cloud.tencent.com/developer/article/1167275
安装 tiller 服务端到 kubernetes 集群：
```
helm init
```

授权 tiller
```
kubectl create serviceaccount --namespace=kube-system tiller

kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

kubectl patch deploy --namespace=kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```