生产环境中的应用程序配置较为复杂，可能需要多个config文件、命令行参数和环境变量的组合。ConfigMap让我们能够从容器镜像中把配置的详细信息给解耦出来。通过ConfigMap我们能够把配置以key-value对的形式传递到container或者别的系统组件（比如Controller）里面。
ConfigMap的典型用法如下
- 生成为容器内的环境变量
- 设置容器的启动命令参数
- 以 Volume 的形式挂载为容器内部的文件或者目录

ConfigMap 以一个或多个 key：value 的形式保存在 Kubernetes 中，既可以用变量，也可以用于表示一个完整的配置文件。

#### 创建 ConfigMap 资源对象
1. 通过 YAML 配置文件方式创建
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: cm-appvars
data:
  applogleve1: info
  appdatadir: /var/data
```
2. 