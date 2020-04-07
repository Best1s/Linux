#!/bin/bash
#5601 - Kibana web 接口
#9200 - Elasticsearch JSON 接口
#5044 - Logstash 日志接收接口
docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk sebp/elk