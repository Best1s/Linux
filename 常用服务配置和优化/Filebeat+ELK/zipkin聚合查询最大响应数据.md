kql api
```
{
  "size": 0,
  "query": {
    "bool": {
      "must": [
        {
          "regexp": {
            "name": "xxx"
          }
        },
        {
          "range": {
            "timestamp": {
              "gte": "1605024000000000",
              "lte": "1605110399000000"
            }
          }
        },
        {
          "range": {
            "duration": {
              "gte": 500000
            }
          }
        }
      ]
    }
  },
  "sort": [
    {
      "duration": {
        "order": "desc"
      }
    }
  ],
  "aggregations": {
    "data": {
      "terms": {
        "field": "name",
        "size": 300
      },
      "aggs": {
        "dumax": {
          "top_hits": {
            "sort": [
              {
                "duration": {
                  "order": "desc"
                }
              }
            ],
            "size": 1
          }
        }
      }
    }
  }
}
```
curl -s -XGET "http://xxxxx:9200/zipkin*/_search?pretty" -H 'Content-Type: application/json' -d @get_data.json > date.log
python 处理 输出自己想要的值
```
import json
import time
file="date.log"
f_obj=open(file)
data=json.load(f_obj,encoding='utf-8')
num=0
for i in data["aggregations"]["data"]["buckets"]:
   num += 1
   source=i['dumax']['hits']['hits'][0]['_source']
   date=time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(source["timestamp_millis"]/1000))
   print(num," cmd:",i["key"],"count:",i["doc_count"],"date:",date,"traceID:",source['traceId'],"time:",source["duration"])
```




