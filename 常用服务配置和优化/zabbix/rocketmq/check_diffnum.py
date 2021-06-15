#!/usr/bin/env python
import sys
import json
f = open("/tmp/rocketMQ.info",'r')
data = json.loads(f.readline())
print data[sys.argv[1]]
