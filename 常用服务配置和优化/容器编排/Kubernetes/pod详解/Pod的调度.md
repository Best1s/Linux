调度规则
- deployment全自动调度： 运行在哪个节点上完全由master的scheduler经过一系列的算法计算得出, 用户无法进行干预,用户只需在 Pod 定义中使用 nodeselector 、NodeAffinity、PodAffinity、Pod驱逐等就能完成 Pod 的精准调度。

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```
- nodeselector定向调度： 指定pod调度到一些node上, 通过设置node的标签和deployment的nodeSelctor属性相匹配多个node有相同标签, scheduler 会选择一个可用的node进行调度 nodeselector 定义的标签匹配不上任何node上的标签， 这个pod是无法调度
k8s给node预定义了一些标签， 通过kubectl describe node xxxx进行查看用户可以使用k8s给node预定义的标签，也可以用 kubectl label 命令给目标 Node 打上一些标签

```
kubectl label nodes <node-name> <label-key>=<label-value>
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
      nodeSelector:
        xxx: xxx
```

- NodeAffinity： node节点亲和性
硬限制 ： 必须满足指定的规则才可以调度pod到node上
软限制 ： 优先满足指定规则，调度器会尝试调度pod到node上， 但不强求

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 4
  template:
    metadata:
      labels:
        app: nginx
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution: #硬限制
              nodeSelectorTerms:
              - matchExpressions:
                - key: beta.kubernetes.io/arch
                  operator: In
                  values:
                  - amd64
          preferredDuringSchedulingIgnoredDuringExecution: #软限制
          - weight: 1
            preference:
              matchExpressions:
              - key: disk
                operator: In
                values:
                - ssd
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80 
```
- PodAffinity:  pod亲和与互斥调度， 根据在节点上正在运行的pod标签而不是节点的标签进行判断和调度
亲和： 匹配标签两个pod调度到同一个node上
互斥： 匹配标签两个pod不能运行在同一个node上

- Taints 和 Tolerations (污点和容忍)

- 独占节点

- Pod 驱逐

- Pod Prioriyt Preemption: Pod优先级调度 针对各种负载

- DaemonSet: 在每个 Node 上都调度一个 Pod

- Job 批处理调度   

- CronJob 定时任务

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: test
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: test
            image: docker.hobot.cc/library/centos:7.4
            args:
            - /bin/sh
            - -c
            - echo Hello World
          restartPolicy: OnFailure
```
- 自定义调度


容器初始化 
spec.initContainers: