静态 pod 是由 kubelet 进行管理，近存在特定的Nodes上的pod.他们不能通过 ApiServer 进行管理，无法与 RelicaController、Deployment 或者 DaemonSet 进行关联，并且 kubelet 无法对它们进行安全健康检查。静态 pod 总是由 kubelet 创建，并总在 kubelet 所在的 Node 上运行。
创建静态 pod 有两种方式：配置文件方式和 HTTP 方式
- 配置文件方式
设置 kubelet 的启动参数 "--pod-manifest-path" (或者在配置文件中设置 staticPodPath:xxdir)指定配置文件的所在目录，kubelet 会定期扫描该目录，并根据目录下的 .yaml 或 .json 文件进行创建操作。
如果用kubeadm部署的集群，在 /etc/kubernetes/manifest/ 目录下，可以看到 kube-apiserver.yaml 、kube-controller-manager.yaml 、kube-scheduler.yaml三个静态Pod yaml文件
模板

```
apiVersion: v1
kind: Pod
metadata:
  name: static-web
  labels:
    name: static-web
spec:
  containers:
    - name: static-web
      image: nginx
      ports:
        - name: web
          containerPort: 80
```
- HTTP 方式
设置 kubelet 启动参数 "–manifest-url=" kubelet 会周期地从指定参数的地址下载 POD 定义的文件并创建，实现方式与配置文件方式一致。