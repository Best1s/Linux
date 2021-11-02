mysqldump  --skip-lock-tables  不锁表备份数据。

mysql  查看当前用户权限  SHOW GRANTS;

mysql 只读 set` `global read_only=1;  写 set` `global read_only=0

锁表 flush tables with read lock;  解除 unlock tables;

show global variables like '%read%';

mysql 初始化

```
./mysqld --initialize --user=mysql
 /usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf --user=mysql

alter user user() identified by "XXXXXX";

CHANGE  MASTER  TO
MASTER_HOST='192.168.1.19',
MASTER_USER='root',
MASTER_PORT=3306,
MASTER_LOG_FILE='mysql-bin.000173',
MASTER_LOG_POS=814410864,
MASTER_CONNECT_RETRY=10;

清理bin log 日志 PURGE MASTER LOGS TO 'mysql-bin.000025';
set global expire_logs_days=1;
show variables like '%logs_days%';
flush logs;


强制恢复 http://dev.mysql.com/doc/refman/5.6/en/forcing-innodb-recovery.html
innodb_force_recovery = 1
1(SRV_FORCE_IGNORE_CORRUPT):忽略检查到的corrupt页。
2(SRV_FORCE_NO_BACKGROUND):阻止主线程的运行，如主线程需要执行full purge操作，会导致crash。
3(SRV_FORCE_NO_TRX_UNDO):不执行事务回滚操作。
4(SRV_FORCE_NO_IBUF_MERGE):不执行插入缓冲的合并操作。
5(SRV_FORCE_NO_UNDO_LOG_SCAN):不查看重做日志，InnoDB存储引擎会将未提交的事务视为已提交。
6(SRV_FORCE_NO_LOG_REDO):不执行前滚的操作。
```

