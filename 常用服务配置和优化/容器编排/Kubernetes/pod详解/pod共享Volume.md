同一个 Pod 中的多个容器能共享 Pod 级别的存储卷 Volume。Volume 可以被定义为各种类型，多个容器各自进行挂载操作。

例：pod中包含tomcat和busybox两个容器，tomcat写日志， busybox读日志
创建pod-volume-applogs.yaml

```
apiVersion: v1
kind: Pod
metadata:
  name: volume-pod
spec:
  containers:
    - name: tomcat
      image: tomcat
      ports:
      - containerPort: 8080
      # tomcat挂载目录
      volumeMounts:
      - name: app-logs
        mountPath: /usr/local/tomcat/logs
    - name: busybox
      image: busybox
      command: ["sh", "-c", "tail -f /logs/catalina*.log"]
      volumeMounts:
      # busybox挂载目录
      - name: app-logs
        mountPath: /logs
    volumes:
    # emptyDir的意思是： 内容为空，无须指定宿主机对应的目录文件，pod从node中移除时也会被永久删除，一般用于临时空间、临时目录
    - name: app-logs
      emptyDir: {}
```

#### 查看busybox的日志
kubectl logs volume-pod -c busybox
#### 查看tomcat的日志
kubectl exec -it volume-pod -c tomcat -- ls -l /usr/local/tomcat/logs
kubectl exec -it volume-pod -c tomcat -- tail -200f /usr/local/tomcat/logs/catalina.2020-04-17.log