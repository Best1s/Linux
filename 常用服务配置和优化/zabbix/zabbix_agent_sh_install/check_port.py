#!/usr/bin/env python
import os
import json
portlist = []
new_port_list = []
port_dict = {"data":None}
cmd = '''netstat -tnlp|egrep -i "$1"|awk {'print $4'}|'''
cmd += '''awk -F':' '{if ($NF~/^[0-9]*$/) print $NF}'|sort -n| uniq 2>/dev/null'''
auto_localport = os.popen(cmd).readlines()
for ports in auto_localport:
	new_port = ports.strip()
	portlist.append(new_port)
for port in portlist:
	pdict = {}
	pdict["{#TCP_PORT}"] = port
	new_port_list.append(pdict)
	port_dict["data"] = new_port_list
	jsonStr = json.dumps(port_dict,sort_keys=True,indent=4)
	#python3	
	#print(jsonStr)
	#python2
print jsonStr
