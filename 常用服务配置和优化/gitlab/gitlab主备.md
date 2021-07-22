原理：

```
postgresql 进行主从同步数据。

lsyncd 通过内核 inotify 触发机制，然后通过rsync去差异同步数据 。

缺点：没有双向同步，备用机器升为maste 时候， 原 master 数据需要重新同步
```



主，备机安装  gitlab， 主还需要安装 lsyncd [syncd: Lsyncd ](https://github.com/axkibe/lsyncd)

gitlab install  [Download and install GitLab | GitLab](https://about.gitlab.com/install/)

lsyncd  ``` yum -y install lsyncd```

#### 主节点操作(已经安装gitlab)。

配置免密登录

```bash
ssh-kengen #敲回车
ssh-copy-id root@x.x.x.x #备机 IP 地址
scp -r /etc/gitlab/ root@x.x.x.x:/etc/gitlab/
```

修改 /var/opt/gitlab/postgresql/data/postgresql.conf 参数说明 [复制 (postgres.cn)](http://www.postgres.cn/docs/9.4/runtime-config-replication.html)

```
listen_addresses = '*'
wal_level = hot_standby
max_wal_senders = 2
hot_standby = on
```

创建 postgresql 主从帐号

```
gitlab-psql
gitlabhq_production=# create role "account" login replication encrypted password 'password'
```

修改 /var/opt/gitlab/postgresql/data/pg_hba.conf  添加登录权限 [pg_hba.conf文件 (postgres.cn)](http://postgres.cn/docs/9.4/auth-pg-hba-conf.html)

```
host   replication         account       x.x.x.x/32    md5
```

lsync.conf 配置 [lsyncd 参考](https://linux.cn/article-5849-1.html)

```
settings {
    logfile ="/var/log/lsyncd/lsyncd.log",
    statusFile ="/var/log/lsyncd/lsyncd.status",
    inotifyMode = "CloseWrite or Modify",
    maxProcesses = 20,
    }

sync {
    default.rsync,
    source = "/var/opt/gitlab/",
    target = "root@x.x.x.x:/var/opt/gitlab/",
    exclude = {"postgresql","alertmanager", "backups", "gitlab-ci", "sockets", "gitlab.yml", "redis", "prometheus", "postmaster.pid","node-exporter","postgres-exporter" },
    -- maxDelays = 100,
    delay = 30,
    -- init = false,
    rsync = {
        binary = "/usr/bin/rsync",
        archive = true,
        compress = true,
	verbose = true,
        owner = true,   
        group = true,   
        perms = true,   
        -- bwlimit   = 2000
        -- rsh = "/usr/bin/ssh -p 22 -o StrictHostKeyChecking=no"
        }
  }
```

```
systemctl start lsyncd
tail -f /var/log/lsyncd/lsyncd.log  #等待数据传送完成
```

#### 备节点操作(已安装gitlab) ：

```
gitlab-ctl reconfigure
gitlab-ctl stop
```

复制 master postgresql 数据

```bash
/opt/gitlab/embedded/bin/pg_basebackup -h x.x.x.x -p65245 -U slave_role -D /var/opt/gitlab/postgresql/data/ -Fp -Xs -R -P  #等待数据完成同步 如果/var/opt/gitlab/postgresql/data/ 有数据需要删除或者移动到其它地方。
#同步完成后 修改 /var/opt/gitlab/postgresql/data/recovery.conf 追加
recovery_target_timeline = 'latest'
trigger_file = '/var/opt/gitlab/postgresql/.trigger'
#启动 gitlab
gitlab-ctl restart   #此时 gitlab 只读只做备用(数据库是从，只读模式，touch /var/opt/gitlab/postgresql/.trigger 触发切换为主)
```



#### 其它

postgresql 备份

```
/opt/gitlab/embedded/bin/pg_basebackup  -Ft -R -Pv -Xf -z -D /tmp/postgresql_bakcup -Z5 -U local_slave  -h x.x.x.x -p5432 -W
```

gitlab 备份 & 恢复

```
#backup
gitlab-rake gitlab:backup:create
#restore backup file
gitlab-rake gitlab:backup:restore BACKUP=xxxx
```

