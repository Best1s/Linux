#!/usr/bin/env bash
# Need centos 7.0+
yum install -y yum-utils device-mapper-persistent-data  lvm2  # install docker dependents
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo || \
yum-config-manager \
	--add-repo \
	http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo   # install docker-ce.repo
[ -f /etc/yum.repos.d/docker-ce.repo ] && yum install -y docker-ce 

systemctl start docker
echo -e '{\n  "registry-mirrors":["http://hub-mirror.c.163.com"],\n  "exec-opts": ["native.cgroupdriver=systemd"]\n}' > /etc/docker/daemon.json
systemctl restart docker


