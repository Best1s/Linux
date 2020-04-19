对 Pod 的健康检查可通过 LivenessProbe 和 ReadinessProbe,  kubelet 会通过这两类探针诊断容器的健康运行
- LivenessProbe：用于判断容器是否存活，如果 LivenessProbe 探测到容器不健康，则 kubelet 将其杀掉，并根据重启策略处理
- ReadinessProbe：用于判断服务是否可用 (Ready 状态),打到 Ready 状态的 Pod 才可以接受请求。 对于被 Service 管理的 Pod， Service 与 Pod Endpoint 的关系也基于 Pod 的 Ready。 如果运行过程中 Ready 变 False 则自动从 Service 的后端 Endpoint 隔离，后续恢复到 Ready 再加入 Endpoint 列表

LivenessProbe 和 ReadinessProbe 可通过以下三种方式实现。
- ExecAction: 容器内部执行一个命令，如果返回 0 容器健康
- tcpSocket：通过容器的 IP 和端口号检测，如果能建立 TCP 连接则容器健康
- httpGet：通过容器的 IP 和端口号几路径调用 httpGet ，如果状态码 大于等于 200 小于 400 则容器健康

```
apiVersion: v1
kind: Pod
matedata:
  name: pod-check
spec:
  containers:
    ...
    livenessProbe:     #对Pod内个容器健康检查的设置，当探测无响应几次后将自动重启该容器，检查方法有exec、httpGet和tcpSocket，对一个容器只需设置其中一种方法即可
      exec:      #对Pod容器内检查方式设置为exec方式
        command: [string]  #exec方式需要制定的命令或脚本
      httpGet:       #对Pod内个容器健康检查方法设置为HttpGet，需要制定Path、port
        path: string
        port: number
        host: string
        scheme: string
        HttpHeaders:
        - name: string
          value: string
      tcpSocket:     #对Pod内个容器健康检查方式设置为tcpSocket方式
        port: number
      initialDelaySeconds: int  #容器启动完成后首次探测的时间，单位为秒
      timeoutSeconds: int   #对容器健康检查探测等待响应的超时时间，单位秒，默认1秒
      periodSeconds: int   #对容器监控检查的定期探测时间设置，单位秒，默认10秒一次  超时会重启该容器
      successThreshold: int
      failureThreshold: int
    securityContext:
      privileged:false
    ...
```

对于每个探针，都需要设置 timeoutSeconds 和 periodSeconds


kubernetes 的 ReadinessProbe 机制可能无法满足某些复杂应用对容器内服务可用状态的判断，以 kubernetes 从1.11版本开始引入了 Pod Ready++ 特性对 Readiness 探测机制进行扩展，在 1.14 版本时达到GA稳定版本，称其为 Pod Readiness Gates。
通过 Pod Readiness Gates 机制，用户可以将自定义的 ReadinessProbe 探测方式设置在 Pod 上，辅助 kubernetes 设置 Pod 何时达到服务可用状态 Ready，自定义 ReadinessProbe，用户需要提供一个外部的控制器 Controller 来设置相应的 Condition 状态。Pod 的Readiness Gates 在 pod 定义中的 ReadinessGates 字段进行设置，如下示例设置了一个类型为www.example.com/feature-1的新Readiness Gates：
```
Kind: Pod
......
spec:
  readinessGates:
    - conditionType: "www.example.com/feature-1"
status:
  conditions:
    - type: Ready  # kubernetes系统内置的名为Ready的Condition
      status: "True"
      lastProbeTime: null
      lastTransitionTime: 2020-01-01T00:00:00Z
    - type: "www.example.com/feature-1"   # 用户定义的Condition
      status: "False"
      lastProbeTime: null
      lastTransitionTime: 2020-01-01T00:00:00Z
  containerStatuses:
    - containerID: docker://abcd...
      ready: true
......
```
新增的自定义 Conditio n的状态 status 将由用户自定义的外部控制器设置，默认值为 False，kubernetes 将在判断全部 readinessGates条件都为 True 时，才设置 pod 为服务可用状态（Ready或True）