```
Affinity:  #(亲和性)
  nodeAffinity:
    requireDuringSchedulingIgnoredDuringExecution  #必须满足硬策略,运行后不满足也会运行
    requireDuringSchedulingRequiredDuringExecution #必须满足硬策略,运行后不满足重新调度
    preferredDuringSchedulingIgnoredDuringExecution #不满足忽略条件
    preferredDuringSchedulingRequiredDuringExecution #不满足忽略条件，满足后重新调度
```
nodeAffinity 主要解决POD要部署在哪些主机，以及POD不能部署在哪些主机上的问题，处理的是POD和主机之间的关系。

podAffinity 主要解决POD可以和哪些POD部署在同一个拓扑域中的问题（拓扑域用主机标签实现，可以是单个主机，也可以是多个主机组成的cluster、zone等。）

podAntiAffinity主要解决POD不能和哪些POD部署在同一个拓扑域中的问题。它们处理的是Kubernetes集群内部POD和POD之间的关系。
```
策略名称	匹配目标	支持的操作符	支持拓扑域	设计目标
nodeAffinity	主机标签	In，NotIn，Exists，DoesNotExist，Gt，Lt	不支持	决定Pod可以部署在哪些主机上
podAffinity	Pod标签	In，NotIn，Exists，DoesNotExist	支持	决定Pod可以和哪些Pod部署在同一拓扑域
PodAntiAffinity	Pod标签	In，NotIn，Exists，DoesNotExist	支持	决定Pod不可以和哪些Pod部署在同一拓扑域
```

case 
```
apiVersion: v1
kind: Pod
metadata:
    name: nodeaffinity-required 
spec:

   containers:
  -  name: myapp
      image: ikubernetes/myapp:v1
   affinity:
     nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          -  matchExpressions:
         #   -  {key: zone,operator: In,values: ["ssd","hard"]}    

              -  key: disktype
                 operator: In
                 values:
                 -  ssd

                 -  hard
```

1.Pod间的亲和性和反亲和性需要大量的处理，需要消耗大量计算资源，会增加调度时间,这会显着减慢大型集群中的调度。 我们不建议在大于几百个节点的群集中使用它们。

2.Pod反亲和性要求Node一致地标记,集群中的每个节点必须具有匹配topologyKey的标签,Pod反亲和性需要制定topologyKey如果某些或所有节点缺少指定的topologyKey标签，则可能导致意外行为。

3.在反亲和性中，空的selector表示不与任何pod亲和。

4.由于hard规则在预选阶段处理，所以如果只有一个node满足hard亲和性，但是这个node又不满足其他预选判断，比如资源不足，那么就无法调度。所以何时用hard，何时用soft需要根据业务考量。

5.如果所有node上都没有符合亲和性规则的target pod，那么pod调度可以忽略亲和性

6.如果labelSelector和topologyKey同级，还可以定义namespaces列表，表示匹配哪些namespace里面的pod，默认情况下，会匹配定义的pod所在的namespace，如果定义了这个字段，但是它的值为空，则匹配所有的namespaces。

7.所有关联requiredDuringSchedulingIgnoredDuringExecution的matchExpressions全都满足之后，系统才能将pod调度到某个node上。