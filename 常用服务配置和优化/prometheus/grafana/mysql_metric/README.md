mysql user 权限:

```mysql
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'192.168%' IDENTIFIED BY 'exporter123' WITH MAX_USER_CONNECTIONS 3;
flush privileges;
```

secret.yaml

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql
  namespace: exporter
type: Opaque
data:
  user: ZXhwb3J0ZXIK
  password: ZXhwb3J0ZXIxMjMK
```

mysql_export.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysqld-exporter100-svc
  namespace: exporter
spec:
  selector:
    app: mysqld-exporter100
  ports:
  - port: 9104
    targetPort: 9104
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysqld-exporter100
  annotations:
     kubernetes.io/change-cause: "init 192.168.0.100 mysqld_exporter"
  namespace: exporter
spec:
  minReadySeconds: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
  replicas: 1
  selector:
    matchLabels:
      app: mysqld-exporter100
  template:
    metadata:  
      labels:
        app: mysqld-exporter100
    spec:
      containers:
      - name: mysqld-exporter100
        image: 192.168.0.134/exporter/mysqld-exporter:latest
        ports:
        - containerPort: 9104
        env:
        - name: DATA_SOURCE_NAME
          value: "exporter:exporter123@(192.168.0.100:3306)/"
        - name: user
          valueFrom:
            secretKeyRef:
              name: mysql
              key: user
        - name: password
          valueFrom:
            secretKeyRef:
              name: mysql
              key: password
        - name: instance_id
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        livenessProbe:
          tcpSocket:
            port: 9104
          initialDelaySeconds: 5
          periodSeconds: 3
        readinessProbe:
          tcpSocket:
            port: 9104
          failureThreshold: 3
          initialDelaySeconds: 5
          periodSeconds: 5
          successThreshold: 1
          timeoutSeconds: 3
        resources:        
          requests:
            cpu: 20m
            memory: 50Mi
          limits:
            cpu: 100m
            memory: 100Mi
        volumeMounts:
        - name: secrets
          mountPath: "/home/.my.cnf"      
          readOnly: true
      restartPolicy: "Always"
      volumes:  
      - name: secrets    
        secret:      
          secretName: mysql
```

static-config.yaml

```yaml
- job_name: mysqld_exporter
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  static_configs:
  - targets: ['10.102.211.59:9104']
    labels:
      project: "test"
      server: "x.x.x.x"

```

