#!/bin/bash
which docker-compose 1> /dev/null  || return 2
state=`docker-compose ps |grep cul-mysql |wc -l`
[ $state == 3 ] && echo cul-mysql is running && return 0
docker-compose up -d
