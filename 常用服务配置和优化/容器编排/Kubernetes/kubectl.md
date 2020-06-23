kubectl 安装 https://kubernetes.io/zh/docs/tasks/tools/install-kubectl/
启用 shell 自动补全功能
yum install bash-completion -y
行 source <(kubectl completion bash) 命令在您目前正在运行的 shell 中开启 kubectl 自动补全功能。
echo "source <(kubectl completion bash)" >> ~/.bashrc

kubectl命令行的语法如下：
```
kubectl [command] [TYPE] [NAME] [flags]

command: 子命令，用于操作 kubernetes 集群资源对象的命令，如 create、delete、describe、get、apply等
TYPE: 资源对象的类型，区分大小写
NAME: 资源对象的名称，区分大小写，如果不指定名称，系统将返回属于TYPE所有的对象列表，如 kubectl get pods
flags: kubectl 的可选参数 如 -s 指定 API Server的 URL 而不适用默认值 
```
####kubectl可操作的资源对象类型及其缩写

资源类型	| 缩写
----- | --------
clusters　|	 	 
componentstatuses	|	cs	 
configmaps			|	cm　	 
daemonsets	|ds	 
deployments|	deploy	 
endpoints	|ep	 
event	|ev	 
horizontalpodautoscalers|	hpa	 
ingresses	|ing	 
jobs	 |	 
limitranges|	limits	 
namespaces|	ns	 
networkpolicies	 	 |
nodes	|no	 
statefulsets	| 	 
persistentvolumeclaims	|pvc	 
persistentvolumes|	pv	 
pods |	po	 
podsecuritypolicies	| psp	 
podtemplates|	 	 
replicasets	|rs	 
replicationcontrollers	|rc	 
resourcequotas	|quota	 
cronjob	 	| 
secrets	 	| 
serviceaccount	|sa	 
services	|svc	 
storageclasses	| 	 
thirdpartyresources	 |
1. kubectl 子命令详解 见 [Kubernetes核心服务配置详解]()

####kubectl公共启动参数如下表

参数取值示例	| 说明
--- | ---	
–alsologtostderr=false	|设置为 true 表示将日志输出到文件的同时输出到 tderr
–as=”	|设置本次操作的用户名
–certificate-authority=”	|用于 CA 授权的 cert 文件路径
也－ chent-cert1 cate＝”	|用于 TLS 客户端证书文件路径
–chent-key=”	|TLS 客户端 key文件路径
–cluster="|	设置要 kubeconfig 中的 cluster名
–context=”	|设置要使用的 kubeconfig 中的 context名
–insecure-skip-tls-verify=false	|设置为true 表示 跳过TLS 安全验证模式，将使 得HTTPS 连接不安全
–kubec nfig= kubeconfig	|配置文件路径，在配置文件中包括 Master 地址信息及必要的认证信息
log back ace-at=	|记录日志每到“file：行号”时打印 stack trace
–log-dir=”	|日志文件路径
–log-flush-frequency=5s|	设置 flush 日志文件的时间间隔
–logtostderr=true	|设置为 true 表示 日志输出到 stderr ，不输出到日志文件
–match-server-version=false	|设置为true表示客户端版本号需要与服务端一致
–namespace=”	|设置本次操作所在的 namespace
–password=”	|设置api server 的basic authentication的密码
-s server=	|设置 apiserver URL 地址， 默认值localhost: 8080
–stdeπ reshold	|在该 threshold 级别之上的日志将输出到stderr
–token=”	|设置访问 apiserver 安全 token
–user="	|指定用户名
–username	|设置 api server的 basic authentication 的用户名
–v=O	|glog 日志级别
–vmodule=	|glog 基于模块的详细的日志级别

####命令输出格式

	kubectl [command] [type] [name] [flags] -o=<output_forment>

输出格式	| 说明
--- | ---
-o=custom-columns= |	根据自定义列名进行输出，以逗号分隔
-o=custom-columns-file ＝|	从文件中获取自定义列名进行输出
-o=json	|以json格式显示结果
-o=jsonpath＝＜template>	|输出 jsonpath 表达式定义的字段信息
-o=jsonpath-file=	|输出 jsonpath 表达式定义的字段信息，来源于文件
-o=name	|仅输出资源对象的名称
-o=wide	|输出额外信息。对于 Pod ，将输出 Pod 所在的 Node名称
-o=yaml	|以yaml格式显示结果


自定义插件，用户自定义插件需要命名可执行文件以 kubectl- 开头  通过 kubectl <plugin-name> 运行自定义插件

kubectl plugin list 显示系统中已安装的插件
插件开发示例， https://github.com/kubernetes/sample-cli-plugin