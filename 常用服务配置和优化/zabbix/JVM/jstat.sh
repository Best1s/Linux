#!/bin/bash
# S0：年轻代中第一个survivor（幸存区）已使用的占当前容量百分比
# S1：年轻代中第二个survivor（幸存区）已使用的占当前容量百分比
# E：年轻代中Eden（伊甸园）已使用的占当前容量百分比
# O：old代已使用的占当前容量百分比
# M：元数据区已使用的占当前容量百分比
# CCS：压缩类空间已使用的占当前容量百分比
# YGC ：从应用程序启动到采样时年轻代中gc次数
# YGCT ：从应用程序启动到采样时年轻代中gc所用时间(s)
# FGC ：从应用程序启动到采样时old代(全gc)gc次数
# FGCT ：从应用程序启动到采样时old代(全gc)gc所用时间(s)
# GCT：从应用程序启动到采样时gc用的总时间(s)

function Survivor0 { 
jstat -gcutil $pid | awk 'NR==2 {print $1}'
} 
function Survivor1 { 
jstat -gcutil $pid | awk 'NR==2 {print $2}'
} 
function Eden { 
jstat -gcutil $pid | awk 'NR==2 {print $3}'
} 
function Old { 
jstat -gcutil $pid | awk 'NR==2 {print $4}'
} 
function Metaspace { 
jstat -gcutil $pid | awk 'NR==2 {print $5}'
} 
function YGC { 
jstat -gcutil $pid | awk 'NR==2 {print $7}'
} 
function FGC { 
jstat -gcutil $pid | awk 'NR==2 {print $9}'
} 

process=$(ps -ef | grep jvm | grep -v 'jstat' | grep -v 'grep' | grep "$2")

if [ -n "$process" ];then
	pid=$(echo $process | awk '{print $2}')
else
	echo "not found process!"
	exit 1
fi
$1 "$2"
