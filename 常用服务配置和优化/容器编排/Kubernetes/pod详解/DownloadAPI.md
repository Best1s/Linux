官方文档 https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/#the-downward-api
download api作用： 可以通过环境变量或 Volume 挂载将 pod 信息注入到容器内部
```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test
spec:
  containers:
  - name: test-container
    image: busybox
    command: ["/bin/sh","-c","env"]
    resources:
      requests:
        memory: "32Mi"
        cpu: "125m"
      limits:
        memory: 64Mi
        cpu: 250m       
    env:
    - name: MY_POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: MY_POD_NAMESPACE
      valueFrom:
        fieldRef:
          fieldPath: metadata.namespace
    - name: MY_POD_IP
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
    - name: MY_CPU-REQUEST
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
    - name: MY_CPU_REQUEST
      valueFrom:
        resourceFieldRef:
          containerName: test-container
          fieldPath: requests.cpu
    - name: MY_CPU_LIMIT
      valueFrom:
        resourceFieldRef:
          containerName: test-container
          fieldPath: limits.memory
    - name: MY_MEM_REQUEST
      valueFrom:
        resourceFieldRef:
          containerName: test-container
          fieldPath: requests.memory
    - name: MY_MEM_LIMIT
      valueFrom:
        resourceFieldRef:
          containerName: test-container
          fieldPath: limits.memory
  restartPolicy: Never
```
valueFrom 是 Download APId 的特殊语法，目前提供了以下变量
- metadata.name：  Pod 的名称
- status.podIP： Pod 的ip
- meteadata.namespace: Pod所在的 namespace
- metadata.labels - all of the pod’s labels, formatted as label-key="escaped-label-value" with one label per line
- metadata.annotations - all of the pod’s annotations, formatted as annotation-key="escaped-annotation-value" with one annotation per line
The following information is available through environment variables:

- status.podIP - the pod’s IP address
- spec.serviceAccountName - the pod’s service account name, available since v1.4.0-alpha.3
- spec.nodeName - the node’s name, available since v1.4.0-alpha.3
- status.hostIP - the node’s IP, available since v1.7.0-alpha.1



valueFrom  resourceFieldRef  downwardAPI