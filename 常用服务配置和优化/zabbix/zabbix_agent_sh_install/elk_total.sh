#!/bin/bash
#eg：./elk_total.sh index* "NOT 404 AND NOT 301""
#set -x
sTimeStamp=`date -d "\`date \"+%Y-%m-%d %H:%M:%S\"\`" +%s` >/dev/null 2>&1
fTimeStamp=$((sTimeStamp-60))

index=$1
filte="$2"
es_url="http://x.x.x.x:9200"

resu3=`curl -s -XGET "$es_url/$index/_search" -H 'Content-Type: application/json' -d"{\"aggs\":{},\"size\":0,\"_source\":{\"excludes\":[]},\"stored_fields\":[\"*\"],\"script_fields\":{},\"docvalue_fields\":[{\"field\":\"@timestamp\",\"format\":\"date_time\"}],\"query\":{\"bool\":{\"must\":[{\"query_string\":{\"query\":\"$filte\",\"analyze_wildcard\":true,\"default_field\":\"*\"}},{\"range\":{\"@timestamp\":{\"gte\":$fTimeStamp,\"lte\":$sTimeStamp,\"format\":\"epoch_second\"}}}],\"filter\":[],\"should\":[],\"must_not\":[]}}}"` >/dev/null 2>&1
echo $resu3|awk -F \: '{print $(NF-2)}'|awk -F\, '{print $1}'
