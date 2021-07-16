需要 kubectl  webhook

go_template 内容

```go
{{printf "%s\t%s\t%s" .metadata.annotations.dingding .metadata.namespace .metadata.name }} {{range.status.containerStatuses}}{{printf "RESTART: %d" .restartCount}}{{end}} {{printf "[点击查看日志](https://x.x.x.x:6443/api/v1/namespaces/%s/pods/%s/log?tailLines=200)" .metadata.namespace .metadata.name}}
```



dingding 通知

```bash
#!/bin/bash
log="/tmp/sedMsg.log"
echo $(date) >> $log	#log
dingding_url="https://oapi.dingtalk.com/robot/send?access_token=xxxx" #告警组
dingding="/tmp/dingding.txt"

get_msg(){
pods="$1"
namespace="$2"
if [ "$pods" ];then
	echo $pods
        for pod in $pods
                do
                        tMsg=$(kubectl get pods $pod -n $namespace -o go-template-file --template=./go_template)
			echo $tMsg
			restartCount="$(echo $tMsg|awk '{print $5}')"
			at=$(echo $tMsg|awk '{print $1}')
			case $restartCount in
			     "5")
			dingdingAT "$namespace $pod 已经重启$restartCount次，有空请处理。" "$at" 
			;;
			     "20")
			dingdingAT "$namespace $pod 已经重启$restartCount次，请及时处理。" "$at" 
			;;
			     "50")
			dingdingAT "$namespace $pod 已经重启$restartCount次，请及时处理。" "$at" 
			;;
			esac
			
			grep -q $at $dingding || echo $at, >> $dingding
			Msg="$(echo $tMsg|awk '{$1="";print $0}')\n\n$Msg"
                done
fi
}

send_markdown_msg(){
  curl -s "$dingding_url"\
     -H 'Content-Type: application/json' \
     -d "
    {\"msgtype\": \"markdown\", 
      \"markdown\": {
          \"title\": \"pod无法启动\",
          \"text\": \"$Msg\"
       },
    }"
}

dingdingAT(){
remind_msg="$1"
at="$2"
curl -s "$dingding_url"\
   -H 'Content-Type: application/json' \
   -d "
  {\"msgtype\": \"text\", 
    \"text\": {
        \"content\": \"$remind_msg\"
     },
    \"at\": {
        \"atMobiles\": [
            \"$at\",
            ],
	},
  }"
}
pods="$(kubectl get  pods -n java |grep -v STATUS|grep -v Creating |grep -v Ter |grep -v "1/1"|awk '{if ($4>3){print $1 }}')"


get_msg "$pods"  "java"

send_markdown_msg >> $log
```

