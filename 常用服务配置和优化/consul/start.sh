#!/bin/bash

main(){
    ip=$1
    if [ -z ${ip} ];then
        echo "$0 local_ip"
        exit -1
    fi

    chmod a+x consul
    mkdir -p data
    #nohup ./consul agent -server -bootstrap-expect=3 -data-dir=data -node=${ip} -bind=${ip} -client=0.0.0.0  -ui &>run.log &
    nohup ./consul agent -bind=${ip} -client=0.0.0.0 -server -join=x.x.x.x -join=x.x.x.x -ui -data-dir=./data  -node=${ip}  &>run.log &
    
    if [ $? -ne 0 ];then
        echo "start error, please check the run.log"
        exit -1
    fi
}

main $*
exit 0
