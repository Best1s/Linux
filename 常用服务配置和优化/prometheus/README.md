prometheus 添加自定义 targets 

prometheus-prometheus.yaml

```yaml
  additionalScrapeConfigs:
    name: additional-scrape-configs
    key: prometheus-additional.yaml
```



prometheus-additional.yaml

```yaml
- job_name: mysqld_exporter
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  static_configs:
  - targets:
    - 10.102.211.59:9104
    labels:
      project: test
      server: xxxx
    - 10.109.132.27:9104
    labels:
      project: dev
      server: xxxx
    - 10.100.205.219:9104
    labels:
      project: dev
      server: xxxx
    - 10.102.192.81:9104
    labels:
      project: test
      server: xxxxx
```

执行

```shell
kubectl create secret generic additional-scrape-configs -n monitoring --from-file=prometheus-additional.yaml --dry-run=client -o yaml > additional-scrape-configs.yaml
kubectl apply -f additional-scrape-configs.yaml
```

