Ingress 用于将不同的 URL 的访问请求转发到后端不同的 Service，以实现 HTTP 层的业务路由机制。Kubernetes 使用了一个 Ingress 策略定义和一个具体的 Ingress Controller 结合。

使用 Ingress 进行负载分发时， Ingress Controller 基于 Ingress 规则将客户端请求直接转发到 Service 对应后端的 Endpoint 上,这样会跳过 kube-proxy 的转发功能。  如果 Ingress Controller 提供的是对外服务，则实际上的是边缘路由器的功能。

一个最小的 Ingress 资源示例：

```
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: simple-fanout-example
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - path: /foo
        backend:
          serviceName: service1       #对目标地址 http://foo.bar.com//foo 转发到 service1	
          servicePort: 4200
      - path: /bar
        backend:
          serviceName: service2
          servicePort: 8080
```
文档 https://kubernetes.io/zh/docs/concepts/services-networking/ingress/

ingress策略配置技巧 
1. 转发到单个服务后端上，无需定义任何 rule

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
spec:
  backend:
    serviceName: myweb
    servicePort: 8080
```

2. 同一域名下，不同 URL 路径被转发到不同的服务上。定义 rules规则

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
spec:
  rules:
  - host: mywebsite.com
    http:
      paths:
      - path: /web
        backend:
          serviceName: myweb
          servicePort: 8080
      - path: /api
        backend:
          serviceName: api-service
          servicePort: 8081
```
3. 不同的域名 （虚拟主机名）被转发到不同的服务上。

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - backend:
          serviceName: service1
          servicePort: 8080
  - host: foo.bar2.com
    http:
      paths:
      - backend:
          serviceName: service2
          servicePort: 8080
```
4. 不使用域名的转发规则。用于一个网站不适用域名，直接提供服务的场景，此时通过任意台运行 ingress-controller 的 Node 都能访问到后端服务器。

```
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: simple-fanout-example
spec:
  rules:
    http:
      paths:
      - path: /foo
        backend:
          serviceName: service1
          servicePort: 4200
```
**使用无域名的 Ingress 转发时， 默认将禁用非安全的 HTTP，强制使用HTTPS 还需要配置 TLS 或者通过 metadata.annotations.ingress.kubernetes.io/ssl-redirect:"false"强制关闭*