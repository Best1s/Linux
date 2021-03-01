```
service     nohup ./consul agent -bind=${ip} -client=0.0.0.0 -server -join=x.x.x.x -ui -data-dir=./data  -node=${ip}  &>run.log &
client	nohup ./consul agent -bind=${ip} -client=0.0.0.0  -join=x.x.x.x -ui -data-dir=./data  -node=${ip}  &>run.log &
```
