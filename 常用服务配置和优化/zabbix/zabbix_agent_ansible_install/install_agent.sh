#!/bin/bash
#Need change Server ip
zabbix_agent_dir=/usr/local/zabbix
groupadd zabbix 2>> ~/install.log
useradd zabbix -g zabbix -s /sbin/nologin 2>> ~/install.log
cd /usr/local/src/
rpm -qa |grep perc-devel
if [ $? -ne 0 ]
	then rpm -ih pcre-devel-8.32-17.el7.x86_64.rpm 
fi
tar -zxf zabbix-4.0.5.tar.gz
cd /usr/local/src/zabbix-4.0.5
./configure --prefix=$zabbix_agent_dir --enable-agent
if [ ! $? ];then echo -e "\033[31m make fail,please checking ./configure \033[0m" 
        else
        make install
fi
#--configure_file zabbix_agentd.conf
client_hostname=`hostname`
Server=192.168.1.99
cp /usr/local/zabbix/sbin/zabbix_agentd /etc/init.d/
cat > /usr/local/zabbix/etc/zabbix_agentd.conf << EOF
LogFile=/tmp/zabbix_agentd.log
Server=$Server
Hostname=$client_hostname
HostMetadataItem=system.uname
LogFileSize=1024
PidFile=/tmp/zabbix_agentd.pid
Include=/usr/local/zabbix/etc/zabbix_agentd.conf.d/*.conf
EOF
#start zabbix_agentd
/usr/local/zabbix/sbin/zabbix_agentd

#add auto start
grep -q '/usr/local/zabbix/sbin/zabbix_agentd' /etc/rc.d/rc.local || \
echo '/usr/local/zabbix/sbin/zabbix_agentd' >> /etc/rc.d/rc.local
if [ ! -x '/etc/rc.d/rc.local' ];then chmod 744 /etc/rc.d/rc.local ;fi

