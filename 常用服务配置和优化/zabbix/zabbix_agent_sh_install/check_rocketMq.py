#!/usr/bin/env python
import os
import json
name_dict = {"data":None}
new_name = []
new_list = []
jsonStr = ''
cmd = """
/usr/local/rocketmq-all-4.7.1-bin-release/bin/mqadmin consumerProgress -n 'x.x.x.x:9876' 2>/dev/null |awk '/CLUSTERING/{print $1 ":"$NF}'
"""
consumerProgress= os.popen(cmd).readlines()
for name in consumerProgress:
	new_name.append(name.strip().split(":"))
new_name = dict(new_name)
f = open("/tmp/rocketMQ.info",'w')
f.write(json.dumps(new_name))
for k,v in new_name.items():
	kdict = {}
        vdict = {}
	kdict["{#CONSUMER_GROUP_NAME}"] = k
	kdict["{#DIFF_NUM}"] = v
	new_list.append(dict(kdict,**vdict))
	name_dict["data"] = new_list
	jsonStr = json.dumps(name_dict,sort_keys=True,indent=4)
print jsonStr
