jenkins master主机模式，slave 为 pod  参考https://cloud.tencent.com/document/product/457/41394
1、plugins  Kubernetes
2、k8s 创建 ServiceAccount 
3、jenins -> Manage Nodes and Clouds -> configureClouds
configure
Kubernetes URL, key, namespace, Credentials, pod labels
4、pod Template configure
Name: jenkins-pod-agent
Labels: jenkins-pod-agent
Containers ->
name: jnlp
Docker image: jenkins/jnlp-slave
Working directory: /home/jenkins/agent
Volumes ->
Host Path: /usr/bin/docker
Mount path: /usr/bin/docker

Host Path: /var/run/docker.sock
Mount path: /var/run/docker.sock