Linux系统默认安装logrotate工具，它默认的配置文件在：
/etc/logrotate.conf
/etc/logrotate.d/

logroate的状态文件
/var/lib/logrotate/lograotate.status

logrotate命令格式：
```
logrotate [OPTION...] <configfile>
-d, --debug ：debug模式，测试配置文件是否有错误。
-f, --force ：强制转储文件。
-m, --mail=command ：压缩日志后，发送日志到指定邮箱。
-s, --state=statefile ：使用指定的状态文件。
-v, --verbose ：显示转储过程。
```
Logrotate是基于cron来运行的，其脚本是/etc/cron.daily/logrotate
**如果想指定时间分割日志，可以把logrotate脚本单独配置个时间，或者修改 /etc/anacron文件中的START_HOURS_RANGE=3-22*

cat /etc/cron.daily/logrotate
``` 
#!/bin/sh

/usr/sbin/logrotate -s /var/lib/logrotate/logrotate.status /etc/logrotate.conf
EXITVALUE=$?
if [ $EXITVALUE != 0 ]; then
    /usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"
fi
exit 0
```
如果等不及cron自动执行日志轮转，想手动强制切割日志，需要加-f参数；执行前最好通过Debug选项来验证一下（-d参数）
```
# /usr/sbin/logrotate -d -f /etc/logrotate.d/nginx
```

###logrotate.conf主要配置参数
```

主要配置参数							说明

monthly			日志文件将按月轮循。其它可用值为'daily'，'weekly'或者'yearly'。

rotate 5		一次将存储5个归档日志。对于第六个归档，时间最久的归档将被删除。只保存5个。

compress		在轮循任务完成后，已轮循的归档将使用gzip进行压缩。

delaycompress	总是与compress选项一起用，delaycompress选项指示logrotate不要将最近的归档压缩，压缩将在下一次轮循周期进行。这在你或任何软件仍然需要读取最新归档时很有用。

missingok		在日志轮循期间，任何错误将被忽略，例如“文件无法找到”之类的错误。

notifempty		如果日志文件为空，轮循不会进行。

dateext			切割后的日志文件以当前日期为格式结尾，不加会按-1，-2结尾

create 644 root root	以指定的权限创建全新的日志文件，同时logrotate也会重命名原始日志文件。可以不指定create后的值，则创建新的日志文件和原来文件有相同的权限；

postrotate/endscript	在所有其它指令完成后，postrotate和endscript里面指定的命令将被执行。在这种情况下，rsyslogd 进程将立即再次读取其配置并继续运行。

minsize 1M              文件大小超过 1M 后才会切割
						
```						
###logrotate.conf 
**如果 /etc/logrotate.d/ 里面的文件中没有设定一些细节，则会以/etc/logrotate.conf这个文件的设定来作为默认值。*
```
------------------------------------------------------------------
# see "man logrotate" for details
# rotate log files weekly
weekly

# keep 4 weeks worth of backlogs
rotate 4

# create new (empty) log files after rotating old ones
create

# use date as a suffix of the rotated file
dateext

# uncomment this if you want your log files compressed
#compress

# RPM packages drop log rotation information into this directory
include /etc/logrotate.d

# no packages own wtmp and btmp -- we'll rotate them here
/var/log/wtmp {
    monthly
    create 0664 root utmp
	minsize 1M
    rotate 1
}

/var/log/btmp {
    missingok
    monthly
    create 0600 root utmp
    rotate 1
}
```


logrotate 常见配置参数小结

```
配置参数								说明

compress       			通过gzip压缩转储以后的日志

nocompress              不压缩

copytruncate          	用于还在打开中的日志文件，把当前日志备份并截断；是先拷贝再清空的方式，拷贝和清空之间有一个时间差

nocopytruncate          备份日志文件但是不截断

create mode owner group 转储文件，使用指定的文件模式创建新的日志文件

nocreate                不建立新的日志文件

delaycompress           和 compress 一起使用时，转储的日志文件到下一次转储时才压缩

nodelaycompress         覆盖 delaycompress 选项，转储同时压缩。

errors address          专储时的错误信息发送到指定的Email 地址

ifempty                 即使是空文件也转储，这个是 logrotate 的缺省选项。

notifempty              如果是空文件的话，不转储

mail address            把转储的日志文件发送到指定的E-mail 地址

nomail                  转储时不发送日志文件

olddir directory        转储后的日志文件放入指定的目录，必须和当前日志文件在同一个文件系统

noolddir                转储后的日志文件和当前日志文件放在同一个目录下

sharedscripts           运行postrotate脚本，作用是在所有日志都轮转后统一执行一次脚本。如果没有配置这个，那么每个日志轮转后都会执行一次脚本

postrotate              在logrotate转储之后需要执行的指令，例如重新启动 (kill -HUP) 某个服务！必须独立成行

prerotate/endscript     在转储以前需要执行的命令可以放入这个对，这两个关键字必须单独成行

daily                   指定转储周期为每天

weekly                  指定转储周期为每周

monthly                 指定转储周期为每月

rotate count            指定日志文件删除之前转储的次数，0 指没有备份，5 指保留5 个备份

dateext          	   使用当期日期作为命名格式

dateformat .%s   		配合dateext使用，紧跟在下一行出现，定义文件切割后的文件名，必须配合dateext使用，只支持 %Y %m %d %s 这四个参数

tabooext [+] list		让logrotate不转储指定扩展名的文件，缺省的扩展名是：.rpm-orig, .rpmsave, v, 和 ~

size size               当日志文件到达指定的大小时才转储，bytes(缺省)及KB(sizek)或MB(sizem)

missingok				在日志轮循期间，任何错误将被忽略，例如“文件无法找到”之类的错误。

```
