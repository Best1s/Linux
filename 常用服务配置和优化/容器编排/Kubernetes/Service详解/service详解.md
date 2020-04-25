service 官方文档 https://kubernetes.io/zh/docs/concepts/services-networking/service/

Service 定义了这样一种抽象：逻辑上的一组 Pod，一种可以访问它们的策略 —— 通常称为微服务。

服务发现
如果想要在应用程序中使用 Kubernetes 接口进行服务发现，则可以查询 API server 的 endpoint 资源，只要服务中的Pod集合发生更改，端点就会更新。


没有 selector 的 Service
服务最常见的是抽象化对 Kubernetes Pod 的访问，但是它们也可以抽象化其他种类的后端。

- 希望在生产环境中使用外部的数据库集群，但测试环境使用自己的数据库。
- 希望服务指向另一个 命名空间 中或其它集群中的服务。
- 正在将工作负载迁移到 Kubernetes。 

在任何这些场景中，都能够定义没有 selector 的 Service。 实例:
```
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```
由于此服务没有选择器，因此不会自动创建相应的 Endpoint 对象。可以通过手动添加 Endpoint 对象，将服务手动映射到运行该服务的网络地址和端口：
```
apiVersion: v1
kind: Endpoints
metadata:
  name: my-service
subsets:
  - addresses:
      - ip: 192.0.2.42
    ports:
      - port: 9376
```
访问没有 selector 的 Service，与有 selector 的 Service 的原理相同。 请求将被路由到用户定义的 Endpoint， YAML中为: 192.0.2.42:9376 (TCP)

VIP 和 Service 代理

多端口 Service
Kubernetes允许在Service对象上配置多个端口定义。 为服务使用多个端口时，必须提供所有端口名称
```
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 9376
    - name: https
      protocol: TCP
      port: 443
      targetPort: 9377
```

Headless Service
自己控制负载均策略， “去中心化”（类似于Cassandra） 自定义SeedProvider 通过 Headless Service 自动查找后端 Pod； 自动添加新节点。


### 服务发现
Kubernetes 支持2种基本的服务发现模式 —— 环境变量和 DNS。
环境变量：当创建一个Pod的时候，kubelet会在该Pod中注入集群内所有Service的相关环境变量。**注意的是，要想一个Pod中注入某个Service的环境变量，则必须Service要先比该Pod创建。*

DNS：可以通过cluster add-on的方式轻松的创建KubeDNS来对集群内的Service进行服务发现。

集群外访问 Pod 或 Service 
1. 设置容器级别的 hostPort，
2. 设置 Pod 级别的 hostNetwork=true ,该 Pod 所有容器的端口号直接映射到物理机。
3. 设置 nodePort 同时设置 Service 的类型为 NodePort。 
4. 云 同过 LoadBalancer 映射到服务商提供的 LoadBalancer.