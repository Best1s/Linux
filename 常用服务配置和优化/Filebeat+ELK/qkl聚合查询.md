统计某个字段的值出现的次数,返回20个bucket


```
GET filebeat-7.3.2/_search
{
  "query": {
      "bool": {
        "must": [
          {
            "match": {
              "log.file.path":"/var/log/nginx/xxx.com.log"
            }
          },
        {
          "range": {
            "@timestamp": {
              "gte": "2019-9-12T00:00:00",
              "lte": "2019-9-12T17:00:00"
            }
          }
        }
      ]
    }
  },
    "size": 0,
    "aggs":{
        "user_count":{
            "cardinality":{
                "field":"source.ip"
                          }
                      },
        "user_count":{
            "terms":{
                "field":"nginx.access.remote_ip_list",
                "size":20
            }
          }
    }
}
```

```
按x.keyword 分组 统计 id 并去重
GET index/_search
{
  "size": 0,
  "aggs": {
    "xxx_group": {
      "terms": {
        "field": "x.keyword"
      },
      "aggs": {
        "account_xxx": {
          "cardinality": {
            "field": "id"
          }
        }
      
      }
    }
  }
}
```

