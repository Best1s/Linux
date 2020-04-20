#### Deployment
1. Deployment 的升级 可以用 kubectl rollout status 命令查看升级状态
 - kubectl set image deployment/xxxx xxx=xxxx
 - 直接修改配置文件 。
 
2. Deployment 的回滚
```
kubectl rollout history deployment xxx #查看版本  加 --revision=<N> 查看详细信息
kubectl rollout undo deployment xxx   #回滚上一个版本   --to-revision=<N> 回滚指定版本
```
3. 暂停和恢复 Deployment 的部署
```
kubectl rollout pause history deployment xxxx
kubectl rollout resume history deployment xxxx
```

#### RC
```
kubectl rolling-update #使用配置文件
```
**注意 RC 的名字不能与旧 RC 相同，selector 中至少有一个 Label 与旧 RC 的 Lable 不同，直接使用命令不用* 
#### DaemonSet
DaemonSet 的升级策略有两种: OnDelete 和 RollingUpdate
DaemonSet: 创建新的配置，手动删除旧版本 Pod，触发创建
RollingUpdate：自动杀掉旧 Pod，创建新的 Pod
#### StatefulSet
向 Deployment 和 DaemonSet 更新策略看齐， 也将实现  OnDelete 、Paritioned 和 RollingUpdate 几种策略。

#### Pod 扩容
**手动扩容**
手动执行 kubectl scale 命令， 或通过 RESTful API 对一个 Deployment/RC 进行 Pod 副本数量的设置。
 
**自动扩缩容机制**
- Pod级别的自动缩放：包括Horizontal Pod Autoscaler（HPA）和Vertical Pod Autoscaler（VPA）; 两者都可以扩展容器的可用资源。
- 集群级别的自动缩放：集群自动调节器（CA）通过在必要时向上或向下扩展集群内的节点数来管理这种可扩展性平面。

这里讲主要讲 HPA 官方文档地址：(https://kubernetes.io/zh/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)
基于 CPU 使用率进行自动 Pod 扩缩容功能 HPA, HPA 控制器基于 Master 的 kube-controller-manager 服务启动参数 --horizontal-pod-autoscaler-sync-period 定义的探测周期 (默认 15s), 周期性的监测 Pod 的资源指标。

HPA会在集群中缩放Pod副本的数量。该操作由CPU或内存触发，以根据需要向上或向下扩展。但是，也可以根据各种外部的和自定义指标（metrics.k8s.io，external.metrics.k8s.io和custom.metrics.k8s.io）来配置HPA以扩展Pod。

**扩容算法：**
Autoscler 控制器从聚合 API 获取到 Pod 性能指标数据之后，基于下面的算法计算出目标 Pod 副本数量，与当前运行的 Pod 副本数量做比较，决定是否进行扩缩容操作：
```
desiredReplicas = ceil[currentReplicas * (currentMetricValue / desiredMetricValue)
```
即当前副本数 x (当前指标值/期望的指标值)，将结果向上取整。

Horizontal Pod Autoscaler 资源对象处于 Kubernetes 的 API 组 "autoscaling"中，主要有 V1 和 V2 两个版本。 其中 autoscaling/v1 仅支持基于 CPU 使用率的自动扩缩容，**需要预安装 Heapster 组件或 Metrics Server**。 autoscaling/v2 则用于支持任意指标配置扩缩容。
基于 autoscaling/v1 的 HorizontalPodAutoscaler 配置
命令行方式
```
kubectl create deployment php-apache --image=k8s.gcr.io/hpa-example 
kubectl set resource deployment php-apache--requests=cpu=200m
kubect expose deployment php-apache --port=80
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10 

可通过 kubectl get hpa 查看 autoscaler 的状态
```
文件方式
```
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
  namespace: default
spec:
  scaleTargetRef:	#目标作用对象，可以是 Deployment、Replication、ReplicaSet.
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1	#系统在 minReplicas 和 maxReplicas 值之内进行自动扩容操作，并维持每个 Pod 的 CPU 使用率为 50%
  maxReplicas: 10
targetCPUUtilizationPercentage: 50	#期望每个 Pod 的 CPU 使用率都为 50%，该使用率基于 Pod 设置 CPU Request 值进行计算。

```
基于 autoscaling/v2beta2 的 HorizontalPodAutoscaler [配置](https://kubernetes.io/zh/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#%e5%9f%ba%e4%ba%8e%e5%a4%9a%e9%a1%b9%e5%ba%a6%e9%87%8f%e6%8c%87%e6%a0%87%e5%92%8c%e8%87%aa%e5%ae%9a%e4%b9%89%e5%ba%a6%e9%87%8f%e6%8c%87%e6%a0%87%e8%87%aa%e5%8a%a8%e4%bc%b8%e7%bc%a9)
```
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource		#基于资源的指标 需要启动 Metrics Server
    resource:
      name: cpu
      target:
        type: AverageUtilization
        averageUtilization: 50
  - type: Pods		#基于Pod的指标，系统将对全部 Pod 副本的指标值进行平均值计算 
    pods:
      metric:
        name: packets-per-second
      targetAverageValue: 1k
  - type: Object		#基于某种资源对象的指标或应用系统的任意自定义指标。
    object:
      metric:
        name: requests-per-second
      describedObject:
        apiVersion: networking.k8s.io/v1beta1
        kind: Ingress
        name: main-route
      target:
        kind: Value
        value: 10k
  - type: External		#基于Kubernetes以外的度量指标伸缩
    external:
      metric:
        name: queue_messages_ready
        selector: "queue=worker_tasks"
      target:
        type: AverageValue
        averageValue: 30
```

基于自定义指标的 HPA （基于 Prometheus 的 HPA）
