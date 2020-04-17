内网环境中 Kubernetes 的各个组件与Master之间可以通过apiserver的非安全端口 http://apiserver:8080 进行访问，但如果apiserver需要对外提供服务更安全的做法是启用HTTPS安全机制。
API SERVER有三种认证方式：基本认证、CA认证、HTTP Base 或Token认证
这里进行CA签名双向数字证书安全设置
基于CA签名的双向数字赠书的生成过程如下：

（1）为kube-apiserver生成一个数字证书，并用CA证书进行签名。

（2）为kube-apiserver进程配置证书相关的启动参数，包括CA证书（用于验证客户端证书的签名真伪），自己的经过CA签名后的证书及私钥

（3）为每个访问Kubernetes API Server的客户端（如kube-controller-manager,kube-scheduler,kubelet,kube-proxy及调用API Server的客户端程序kubectl等）进程生成自己的数字证书，也都用CA证书进行签名，在相关程序的启动参数里增加CA证书，自己的证书等相关参数
####基于CA认证配置
**1) 设置kube-apiserver的CA证书相关的文件和启动参数**

使用OpenSSL工具在Master服务器上创建CA证书和私钥相关的文件
```
openssl genrsa  -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=yourcompany.com" -days 5000 -out ca.crt
openssl genrsa -out server.key 2048
```
**注意：生成ca.crt时，-subj参数中“/CN”的值通常为域名*
准备master_ssl.cnf文件，该文件用于x509 v3版本的证书，在该文件中主要需要配置Master 服务器的hostname(k8s-master),IP地址，以及Kubernetes Master Service的虚拟服务器名称（kubernetes.default等）和该虚拟服务的ClusterIP地址

master_ssl.cnf文件的示例如下：
```
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req  ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
DNS.5 = kubernetes
IP.1 = 虚拟服务的ClusterIP地址
IP.2 = k8s-masterIP地址
```
基于master_ssl.cnf创建server.csr和server.ert文件，在生成server.csr时，-subj参数中"/CN"指定的名字需为Master所在的主机名。
```
openssl req -new -key server.key -subj "/CN=Master所在的主机名" -config master_ssl.cnf -out server.csr
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 5000 -extensions v3_req -extfile master_ssl.cnf -out server.crt
```
全部执行完后会生成6个文件：ca.crt, ca,key, ca.srl, server.crt, server.csr,server.key.

将这些文件复制到一个目录中（例如：/var/lib/kubernetes/）,然后设置kube-apiserver的三个启动参数“--client-ca-file” "--tls-cert-file"和“--tls-private-key-file”,分别代表证书文件，服务端证书文件和服务端私钥文件:
```
--client_ca_file=/var/lib/kubernetes/ca.crt
--tls-private-key-file=/var/lib/kubernetes/server.key
--tls-cert-file=/var/lib/kubernetes/server.crt
同时，可以关掉非安全端口8080，设置安全端口为6443 （默认为6443）
--insecure-port=0
--secure-port=6443

文件内容类似如下
cat /etc/kubernetes/apiserver
KUBE_API_ARGS="--etcd-servers=http://127.0.0.1:2379 \
--insecure-bind-address=0.0.0.0 \
--insecure-port=0 \
--secure-port=443 \
--service-cluster-ip-range=169.169.0.0/16 \
--service-node-port-range=1-65535 \
--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota \
--logtostderr=false \
--client-ca-file=/var/lib/kubernetes/ca.crt \
--tls-private-key-file=/var/lib/kubernetes/server.key \
--tls-cert-file=/var/lib/kubernetes/server.crt \
--log-dir=/var/log/kubernetes --v=0"
```
最后重启kube-apiserver服务

**2) 设置kube-controller-manager的客户端证书密钥和启动参数**
```
openssl genrsa -out cs_client.key 2048
openssl req -new -key cs_client.key -subj "/CN=客户端名字" -out cs_client.csr
openssl x509 -req -in cs_client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out cs_client.crt -days 5000
```
其中，在生成cs_client.crt时，-CA 参数和-CAkey参数使用的是apiserver的ca.crt和ca.key文件将这些文件复制到一个目录中（/var/lib/kubernetes/）
接下来创建/etc/kubernetes/kubeconfig文件（kube-controller-manager与kube-scheduler公用），配置客户端证书等相关参数，如下
```
apiVersion: v1
kind: Config
users:
- name: controllermanager
  user:
    client-certificate: /var/lib/kubernetes/cs_client.crt
    client-key: /var/lib/kubernetes/cs_client.key
clusters:
- name: local
  cluster:
    certificate-authority: /var/lib/kubernetes/ca.crt
contexts:
- contest:
    cluster: local
    user: controllermanager
  name: my-context
current-contest: my-contest
```
然后设置kube-controller-manager服务的启动参数，注意，--master的地址为https安全地址，不适用非安全地址
```
--service-account-private-key-file=/var/lib/kubernetes/server.key
--root-ca-file=/var/lib/kubernetes/ca.crt

配置启动参数 类似结果如下：
cat /etc/kubernetes/controller-manager 
KUBE_CONTROLLER_MANAGER_ARGS="--kubeconfig=/etc/kubernetes/kubeconfig \
--service-account-private-key-file=/var/lib/kubernetes/server.key \
--root-ca-file=/var/lib/kubernetes/ca.crt \
--logtostderr=false \
--log-dir=/var/log/kubernetes --v=0"
```
重启kube-controller-manager 服务

**3）设置kube-scheduler启动参数**
kube-scheduler复用kube-controller-manager创建的客户端证书，配置启动参数
重启kube-scheduler服务

**4）设置每台Node上kubelet的客户端证书，私钥和启动参数**
首先复制kube-apiserver的ca.crt和ca.key文件到Node上，在生成kubelet_client.crt时-CA参数和-CAkey参数使用的是apiserver的ca.crt和ca.key文件。生成kubelet_client.csr时-subj 参数中的 "/CN" 设置为本Node的IP地址
```
openssl genrsa -out kubelet_client.key 2048
openssl req -new -key kubelet_client.key -subj "/CN=本Node的IP地址" -out kubelet_client.csr
openssl x509 -req -in kubelet_client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kubelet_client.crt -days 5000
```
将这些文件复制到（/var/run/kubernetes/）
接下来创建/etc/kubelet/kubeconfig文件（kubelet和kube-proxy进程共用），配置客户端证书等相关参数，内容如下：
```
apiVersion: v1
kind: Config
users:
- name: kubelet
  user:
    client-certificate: /var/lib/kubernetes/cs_client.crt
    client-key: /var/lib/kubernetes/cs_client.key
clusters:
- name: local
  cluster:
    certificate-authority: /var/lib/kubernetes/ca.crt
    server: https://192.168.59.136:6443
contexts:
- context:
    cluster: local
    user: kubelet
  name: my-context
current-context: my-context
```
设置kubelet服务启动参数
```
--kubeconfig=/etc/kubelet/kubeconfig
```
重启kubelet

**5) 设置kube-proxy的启动参数**

kube-procy 复用上一步kubelet创建的客户端证书，配置启动参数
```
--kubeconfig=/etc/kubelet/kubeconfig
```
重启kube-proxy服务
至此，一个基于CA的双向数字证书认证的Kubernetes集群环境搭建完成了

6）设置kubect客户端使用安全方式访问apiserver
使用kubectl对Kubernetes集群进行操作时，默认使用非安全端口8080对apiserver进行访问，也可以设置为安全访问apiserver的模式，需要设置3个证书相关参数 “--certificate-authority” "--client-certificate"和 “--client-key”,分别表示用于CA授权的证书，客户端证书和客户端密钥
```
--certificate-authority:  #使用kube-apiserver生成ca.crt文件
--client-certificate:     #使用kube-controller-manager生成cs_client.crt文件。
--client-key:             #使用为kube-controller-manager生成cs_client.key文件
```
同时，指定apiserver的URL的地址为HTTPS安全地址（如 https://kubernetes-master:6443) 最后输入需要执行的子命令，即可对apiserver进行安全访问：
```
kubectl --server=https://master-ip:6443 --certificate-authority=/xxxx/ca.crt --client-certificate=/xxxx/cs_client.crt --client-key=/xxxx/cs_client.key get node
NAME           STATUS    AGE
192.168.59.136   Ready     3m
```
####基于HTTP BASE或TOKEN的简单认证方式

除了基于CA的双向数字证书认证方式，Kubernetes也提供了基于HTTP BASE或TOKEN的简单认证方式，各组件与apiserver之间的通信方式仍采用HTTPS，但不使用CA数字证书

采用基于HTTP BASE或TOKEN的简单认证方式时，API Server 对外暴露HTTPS端口，客户端提供用户名，密码或Toker来完成认证过程。
**kubectl 命令行工具比较特殊，它同时支持CA双向认证与简单认证两种模式与apiserver通信，其他客户端组件只能配置为双向安全认证或非安全模式与apiserver通信。*

####基于HTTP BASE 认证的配置过程如下。
1）创建包括用户名，密码和UID的文件basic_auth_file,放置在合适的目录中。**需要注意的是这是一个纯文本文件，用户名，密码都是明文。*
```
vi /etc/kubernetes/basic_auth_file

admin,admin,1
system,system,2
```
2)设置kube-apiserver 的启动参数 “--basic_auth_file”,使用上述文件提供安全认证：
```
--secure-port=443
--basic_auth_file=/etc/kubernetes/basic_auth_file
```
然后重启API Server服务

3)使用kubectl通过指定的用户名和密码来访问API Server:
```
kubectl --server=https://MASTER的IP:6443 --username=admin --password=admin --insecure-skip-tls-verify=true get nodes
```

####基于TOKEN认证的配置过程如下

1）创建包括用户名，密码和UID的文件token_autha-file,放置在合适的目录中。**注意这是一个纯文本文件，用户名，密码都是明文。*
```
cat /etc/kubernetes/tocken_auth_file
admin,admin,1
system,system,2
```
2)设置kube-apiserver的启动参数"--token_auth_file",使用上述文件提供安全认证：
```
--secure-port=443
 
--token_auth_file=/etc/kubernetes/token_auth_file
```
然后，重启API Server服务。

3）用curl验证和访问API Server
```
[root@kubernetes ~]# curl -k --header "Authorization:Bearer admin" https://master的IP:6443/version
{
  "major": "1",
  "minor": "3",
  "gitVersion": "v1.3.0",
  "gitCommit": "283137936a498aed572ee22af6774b6fb6e9fd94",
  "gitTreeState": "clean",
  "buildDate": "2016-07-01T19:19:19Z",
  "goVersion": "go1.6.2",
  "compiler": "gc",
  "platform": "linux/amd64"
```