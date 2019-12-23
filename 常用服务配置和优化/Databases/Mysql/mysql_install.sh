#!/bin/bash
#依赖关系依次为common→libs→client→server https://blog.csdn.net/wudinaniya/article/details/81094578
##yum 安装https://dev.mysql.com/downloads/repo/yum/
#rpm 安装 依赖 libaio
rpm -qa|grep libaio-devel
if [ $? -eq 0 ];then
	rpm -ivh mysql-community-common-5.7.25-1.el7.x86_64.rpm
	rpm -ivh mysql-community-libs-5.7.25-1.el7.x86_64.rpm
	rpm -ivh mysql-community-server-5.7.25-1.el7.x86_64.rpm   
	rpm -ivh mysql-community-client-5.7.25-1.el7.x86_64.rpm
else
	exit 0
fi
mysqld --initialize --user=mysql
chown mysql:mysql -R /var/lib/mysql

