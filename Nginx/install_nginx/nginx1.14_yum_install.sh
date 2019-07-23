#/bin/bash
#dep pcre-devel  zlib-devel
yum -y install yum-utils
cp ./nginx.repo /etc/yum.repos.d/
yum -config-manager --enable nginx-mainline
yum -y install nginx
#http://nginx.org/en/linux_packages.html#RHEL-CentOS
#http://nginx.org/en/linux_packages.html#RHEL-CentOS
