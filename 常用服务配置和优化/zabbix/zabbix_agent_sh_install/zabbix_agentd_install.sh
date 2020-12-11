#!/bin/bash
#不需要端口检查请注释 check_port.py
 
url="http://x.x.x.x"
zabbix_serverip="x.x.x.x"
ss -tln |grep -q 10050 && echo "zabbix_agentd is Running" >> /tmp/install_zabbix_agent.log && exit 1
 
cd /tmp
curl -L -O -s $url/check_port.py
curl -L -O -s $url/tcp.sh
curl -L -O -s $url/zabbix-4.0.5.tar.gz
tar -zxf zabbix-4.0.5.tar.gz
cd zabbix-4.0.0
rpm -qa |grep -q pcre-devel || yum -y install pcre-devel
./configure --prefix=/usr/local/zabbix/ --enable-agent >> /tmp/install_zabbix_agent.log
make && make install
cat << EOF > /usr/local/zabbix/etc/zabbix_agentd.conf
LogFile=/tmp/zabbix_agent.log
Server=$zabbix_serverip
ServerActive=$zabbix_serverip
Hostname=HOSTNAME
HostMetadata=xxxx aaa
EnableRemoteCommands=1
AllowRoot=1
UnsafeUserParameters=1
Timeout=10
UserParameter=tcp_status[*],/bin/bash /usr/local/zabbix/scripts/tcp.sh \$1 \$2 \$3
UserParameter=tcpportlisten,/usr/local/zabbix/scripts/check_port.py
EOF
hname=`cat /etc/hostname`
ip=$(ip a|awk '/global eth0/{print $2}'|awk -F/ '{print $1}')
sed -i "s/Hostname=HOSTNAME/Hostname=$hname$ip/" /usr/local/zabbix/etc/zabbix_agentd.conf
mkdir /usr/local/zabbix/scripts/
mv /tmp/check_port.py  /tmp/tcp.sh /usr/local/zabbix/scripts/
#chown -R zabbix.zabbix /usr/local/zabbix/scripts
#chmod  777 /usr/local/zabbix/scripts/*
grep -q zabbix_agentd /etc/rc.local || echo "/usr/local/zabbix/sbin/zabbix_agentd" >> /etc/rc.local
/usr/local/zabbix/sbin/zabbix_agentd
rm -rf /tmp/zabbix-4.0.0 /tmp/zabbix-4.0.5.tar.gz
echo "zabbix_agentd install Successful !!" >> /tmp/install_zabbix_agent.log