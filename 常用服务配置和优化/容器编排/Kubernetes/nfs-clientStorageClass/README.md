安装nfs
```
yum -y install nfs-utils 
```
挂载/etc/exports的设置
```
/xxx 172.16.x.x/16(rw,sync,no_root_squash)
exportfs -arv
```
安装 helm
https://github.com/helm/helm/releases
```
curl -O https://storage.googleapis.com/kubernetes-helm/helm-v2.10.0-linux-amd64.tar.gz
tar xzvf helm-v2.10.0-linux-amd64.tar.gz
sudo cp linux-amd64/helm /usr/local/bin/helm
helm init  #安装服务端
helm init --client-only #将 Helm 配置为 Client-only
```

helm 安装 nfs-client-provisioner
clone  https://github.com/helm/charts/tree/master/stable/nfs-client-provisioner
```
helm install --set nfs.server=x.x.x.x --set nfs.path=/exported/path stable/nfs-client-provisioner
```




ReadWriteOnce: 可读可写，只支持被单个Pod挂载。
ReadOnlyMany：可以以只读的方式被多个Pod挂载。
ReadWriteMany: 以读写模式被加载到多个节点上  
