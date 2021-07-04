踩雷记录: 

环境 基于官方的 filebeat 6.8镜像

1、镜像时区设置

```
RUN rm -f /etc/localtime
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  #或者 ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo Asia/Shanghai > /etc/timezone
```

2、在`path/to/conf/module.d/`目录里所有的`.yml`开启`var.convert_timezone`[ELK开发日记(2) - 超坑爹的Filebeat 7.2.0时区漂移 (UTC+16) 解决方案 - SegmentFault 思否](https://segmentfault.com/a/1190000019911946)

3、如果以上还不行需要更改 filebeat setup 中的 syslog-pipeline

具体如下:

kibana -> Dev Tools 

```
GET _ingest/pipeline/  #获取 ES 数据预处理 找到自己需要模块的 pipeline

例如：
  "filebeat-6.8.10-system-syslog-pipeline" : {
    "description" : "Pipeline for parsing Syslog messages.",
    "processors" : [
      {
        "grok" : {
          "pattern_definitions" : {
            "GREEDYMULTILINE" : "(.|\n)*"
          },
          "ignore_missing" : true,
          "field" : "message",
          "patterns" : [
            """%{SYSLOGTIMESTAMP:system.syslog.timestamp} %{SYSLOGHOST:system.syslog.hostname} %{DATA:system.syslog.program}(?:\[%{POSINT:system.syslog.pid}\])?: %{GREEDYMULTILINE:system.syslog.message}""",
            "%{SYSLOGTIMESTAMP:system.syslog.timestamp} %{GREEDYMULTILINE:system.syslog.message}"
          ]
        }
      },
      {
        "remove" : {
          "field" : "message"
        }
      },
      {
        "date" : {
          "formats" : [
            "MMM  d HH:mm:ss",
            "MMM dd HH:mm:ss"
          ],
          "ignore_failure" : true,
          "field" : "date",
          "target_field" : "@timestamp"
        }
      }
    ],
    "on_failure" : [
      {
        "set" : {
          "field" : "error.message",
          "value" : "{{ _ingest.on_failure_message }}"
        }
      }
    ]
  }
```

把需要的 pipeline 内容提取出来执行

```
PUT _ingest/pipeline/filebeat-6.8.10-system-syslog-pipeline
{
    "description" : "Pipeline for parsing Syslog messages.",
    "processors" : [
      {
        "grok" : {
          "pattern_definitions" : {
            "GREEDYMULTILINE" : "(.|\n)*"
          },
          "ignore_missing" : true,
          "field" : "message",
          "patterns" : [
            """%{SYSLOGTIMESTAMP:system.syslog.timestamp} %{SYSLOGHOST:system.syslog.hostname} %{DATA:system.syslog.program}(?:\[%{POSINT:system.syslog.pid}\])?: %{GREEDYMULTILINE:system.syslog.message}""",
            "%{SYSLOGTIMESTAMP:system.syslog.timestamp} %{GREEDYMULTILINE:system.syslog.message}"
          ]
        }
      },
      {
        "remove" : {
          "field" : "message"
        }
      },
      {
        "date" : {
          "formats" : [
            "MMM  d HH:mm:ss",
            "MMM dd HH:mm:ss"
          ],
          "timezone" : "Asia/Shanghai",   #主要添加这段
          "ignore_failure" : true,
          "field" : "date",
          "target_field" : "@timestamp"
        }
      }
    ],
    "on_failure" : [
      {
        "set" : {
          "field" : "error.message",
          "value" : "{{ _ingest.on_failure_message }}"
        }
      }
    ]
  }
```



filebeat setup 自定义索引名

```
setup.module.overwrite: true
setup.template.overwrite: true
setup.configuration.overwrite: true
setup.template.pattern: "system-log*"
setup.dashboards.index: "system-log*"
```

