生产环境中的应用程序配置较为复杂，可能需要多个config文件、命令行参数和环境变量的组合。ConfigMap让我们能够从容器镜像中把配置的详细信息给解耦出来。通过ConfigMap我们能够把配置以key-value对的形式传递到container或者别的系统组件（比如Controller）里面。
ConfigMap的典型用法如下
- 生成为容器内的环境变量
- 设置容器的启动命令参数
- 以 Volume 的形式挂载为容器内部的文件或者目录

ConfigMap 以一个或多个 key：value 的形式保存在 Kubernetes 中，既可以用变量，也可以用于表示一个完整的配置文件。

#### 创建 ConfigMap 资源对象
1. 通过 YAML 配置文件方式创建
```
cat cm-appvars.yaml
```
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: cm-appvars
data:
  applogleve1: info
  appdatadir: /var/data
```
查看创建好的 ConfigMap
```
kubectl get configmap
kubectl describe configmap cm-appvars
kubectl get configmap cm-appvars -o yaml
```
2. 通过 kubectl 命令行方式创建
kubectl create configmap 使用参数 --from-file 或 --from-literal 指定内容，并且可以在一行中指定多个参数。
```
kubectl create configmap NAME --from-file=[key=]source
#
kubectl create configmap NAME --from-file=config-files-dir
#
kubectl create configmap NAME --from-literal=key1=value1 --from-literal=key2=value2
```

#### Pod 中使用 ConfigMap
1. 使用环境变量方式使用 ConfigMap
```
spec.containers.env.valueFrom.configMapKeyRef
```

2. 通过 volumeMount 使用 ConfigMap
```
spec.containers.volumes.configMap.items.key  path
```
如果在引用 ConfigMap 时不指定items，则使用 volumentMount 方式在容器内的目录下为每个 item 都生成一个以 key 命名的文件

使用 ConfigMap 的限制条件
- ConfigMap 必须在 Pod 之前创建
- ConfigMap 受 NameSpace 限制，只有相同的 NameSpace 才能引用
- ConfigMap 配额管理未实现
- kubelet 只支持可以被 API Server 管理的 Pod 使用，静态 Pod 无法使用
- 在 Pod 对 ConfigMap 进行挂载时，在容器内部只能挂载为目录。在挂载到容器内部后，在目录下将包含 ConfigMap 定义的每个 item,如果该目录有其他文件，则容器内该目录将被挂载的 ConfigMap 覆盖。**如果要保留原来的文件，可先挂载到其它目录，再通过  cp 或 link 应用到实际目录下。*