spec.ExternalTrafficPolicy: Local #能够保留来源IP，并可以保证公网、VPC内网访问（LoadBalancer）和主机端口访问（NodePort）模式下流量仅在本节点转发。Local转发使部分没有业务Pod存在的节点健康检查失败，可能存在流量不均衡的转发的风险。

spec.ExternalTrafficPolicy: Cluster #默认均衡转发到工作负载的所有Pod,日志内 IP 为pod IP
https://kubernetes.io/zh/docs/tutorials/services/source-ip/