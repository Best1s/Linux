需要： node节点安装 nfs-utils  nfs服务器。helm clinet-provisioner Chat文件

安装nfs
```
yum -y install nfs-utils rpcbind
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
会拉去国外镜像
helm init --client-only #将 Helm 配置为 Client-only
```

helm 安装 nfs-client-provisioner
clone  https://github.com/helm/charts/tree/master/stable/nfs-client-provisioner
```
helm install --name my-release --namespace xxxx --set storageClass.name=xxx-storage nfs.server=x.x.x.x --set nfs.path=/exported/path stable/nfs-client-provisioner
```


ReadWriteOnce(RWO): 可读可写，只支持被单个Pod挂载。
ReadOnlyMany(ROX)：可以以只读的方式被多个Pod挂载。
ReadWriteMany(RWX): 以读写模式被加载到多个节点上  
