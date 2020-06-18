https://dev.mysql.com/doc/refman/5.7/en/	#mysql 5.7参考手册

mysqld  --initialize-insecure  #初始化msyql
###mysql用户操作
1. 创建用户       
```
#使用CREATE USER
CREATE USER user[IDENTIFIED BY [PASSWORD] 'password'],
[user[IDENTIFIED BY [PASSWORD] 'password']]...
#使用INSERT INTO
INSERT INTO mysql.user(Host,User,Password,ssl_cipher,x509_issuer,x509_subject) \
VALUES('%','newuser1',PASSWORD('123456'),'','','')
#赋予库权限
GRANT priv_type ON database.table TO user[IDENTIFIED BY [PASSWORD] 'password'] \
[,user [IDENTIFIED BY [PASSWORD] 'password']...]
#立即生效
FLUSH PRIVILEGES
set sql_mode =‘STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,\
NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION‘;
```
2. 删除用户
```
DROP USER user[,user]...
DROP USER 'newuser1'@'%
DELETE FROM mysql.user WHERE Host = '%' AND User = 'admin'
```
3. 修改密码
```
#使用mysqladmin
mysqladmin -u -username -p password "new_password"
#修改USER表
UPDATE user SET Password = PASSWORD('123') WHERE USER = 'myuser'  #5.7后没有password 字段
#SET语句修改
SET PASSWORD = PASSWORD("123");
#修改其他用户密码：
SET PASSWORD FOR 'myuser'@'%'=PASSWORD("123456")
GRANT SELECT ON *.* TO 'test3'@'%' IDENTIFIED BY '123'
#更新后执行，生效
FLUSH PRIVILEGES
```
4. 忘记密码的解决方案
```
mysqld --skip-grant-tables
mysqld-nt --skip-grant-tables
net start mysql --skip-grant-tables
```

###查询数据库大小
```
select TABLE_SCHEMA, concat(truncate(sum(data_length)/1024/1024,2),' MB') as data_size,
concat(truncate(sum(index_length)/1024/1024,2),'MB') as index_size
from information_schema.tables
group by TABLE_SCHEMA
order by data_length desc;
```
###主从配置
```
log_timestamps = SYSTEM
#创建个主从用户
grant replication slave on *.* to 'rep1'@'%' identified by 'mysql';

GRANT SElECT ON *.* TO 'username'@'%' IDENTIFIED BY "password";
#my.cnf配置中

binlog-ignore-db=xxxx  #忽略同步的库
binlog-do-db=xxx  #需要同同步的库不在内不同步
replicate-wild-do-table=db_name.%  #只复制到那个库的那个表
replicate-wild-ignore-table=mysql.% #忽略哪个库到那个表

#自增长字段，主主中需要配置，避免两台服务器同时做更新时自增长字段的值之间发生冲突。
auto_increment_offset = 1
auto_increment_increment = 2

#slave主从

CHANGE MASTER TO
MASTER_HOST='1.1.1.1',
MASTER_PORT=3306,
MASTER_USER='slave',
MASTER_PASSWORD='123456',
MASTER_LOG_FILE='mysql-bin.00001',
MASTER_LOG_POS=1111;



状态查看
show slave status;
show master status;
```
###数据备份
1. MySQL 导出数据 **SELECT ... INTO OUTFILE 语句**
```
LOAD DATA INFILE是SELECT ... INTO OUTFILE的逆操作，SELECT句法。为了将一个数据库的数据写入一个文件，使用SELECT ... INTO OUTFILE，为了将文件读回数据库，使用LOAD DATA INFILE。
SELECT...INTO OUTFILE 'file_name'形式的SELECT可以把被选择的行写入一个文件中。该文件被创建到服务器主机上，因此您必须拥有FILE权限，才能使用此语法。
输出不能是一个已存在的文件。防止文件数据被篡改。
你需要有一个登陆服务器的账号来检索文件。否则 SELECT ... INTO OUTFILE 不会起任何作用。
在UNIX中，该文件被创建后是可读的，权限由MySQL服务器所拥有。这意味着，虽然你就可以读取该文件，但可能无法将其删除。
```
2. **使用mysqldump**
```
mysqldump 导出数据需要使用 --tab 选项来指定导出文件指定的目录，该目标必须是可写的.
$ mysqldump -u root -p --no-create-info \
            --tab=/tmp x库名 x表名
password ******
or
$ mysqldump -u root -p x库名 x表名 > dump.sql
password ******
备份所有数据库：
$ mysqldump -u root -p --all-databases > database_dump.txt
password ******
```
xtrabackup  mysqldump  innobackupex  区别？
```
--single-transaction  #innodb可以不锁表  其他引擎不确定
```

###数据恢复

1. 使用备份的sql文件，恢复到指定数据库
```
mysql -hhostname -uusername -ppassword databasename < backupfile.sql
or
gunzip < backupfile.sql.gz | mysql -uusername -ppassword databasename
```
2. **使用LOAD DATA**导入数据
```
mysql> LOAD DATA LOCAL INFILE 'dump.sql' INTO TABLE mytbl;
```
3. 直接将备份导入到新的数据库
```
mysqldump -uusername -ppassword databasename | mysql -host=192.168.1.101 -C databasename
```
4. 使用**source**导入sql文件
```
mysql > use cmdb
mysql > source /data/cmdb_backup.sql
```
5. 从二进制文件中恢复数据
```
1.事务位置恢复
mysql中用 show binlog events in ‘login.xxxx‘找到结束事务位置的pos位置使用mysqlbinlog恢复
mysqlbinlog /xxx/xxx/logbin.xxxxx --stop-pos=xxxxx |mysql -uroot -p
2. 通过时间恢复
通过mysqlbinlog来了查看日志文件，找到时间点
/usr/bin/mysqlbinlog --start-datetime="2019-07-27 20:57:55" --stop-datetime="2019-07-27 20:58:18" --database=xxx /var/lib/mysql/mysql-bin.000009 | /usr/bin/mysql -uroot -p -v xxx
```
7. 使用 mysqlimport 导入数据
```
$ mysqlimport -u root -p --local mytbl dump.sql
password *****
```

###数据修复
碰到 mysql Table 'xxxxx' is marked as crashed and should be repaired  问题时可尝试修复

1. mysqlcheck -r 数据库名 表名 -uroot -p
```
命令格式
Usage: mysqlcheck [OPTIONS] database [tables] 
OR mysqlcheck [OPTIONS] –databases DB1 [DB2 DB3…] 
OR mysqlcheck [OPTIONS] –all-databases
参数
A, –all-databases —选择所有的库 
-a, –analyze —分析表 
-B, –databases —选择多个库 
-c, –check —检查表 
-o, –optimize —-优化表 
-C, –check-only-changed —最后一次检查之后变动的表 
–auto-repair —-自动修复表 
-g, –check-upgrade —检查表是否有版本变更，可用 auto-repair修复 
-F, –fast —只检查没有正常关闭的表 
-f, –force —忽悠错误，强制执行 
-e, –extended —表的百分百完全检查，速度缓慢 
-m, –medium-check —近似完全检查，速度比 –extended稍快 
-q, –quick —最快的检查方式，在repair 时使用该选项，则只会修复 index tree 
-r, –repair —修复表 
-s, –silent —只打印错误信息 
-V, –version —显示版本
```

2. myisamchk
使用myisamchk必须暂时停止MySQL服务器。例如，我们要检修test数据库。执行以下操作：
```
# service mysqld stop ;
# myisamchk -r /var/lib/mysql/test/*MYI
# service mysqld start;
myisamchk会自动检查并修复数据表中的索引错误。
```

3 表
表损坏的原因分析
以下原因是导致mysql 表毁坏的常见原因：
1、 服务器突然断电导致数据文件损坏。
2、 强制关机，没有先关闭mysql 服务。
3、 mysqld 进程在写表时被杀掉。
4、 使用myisamchk 的同时，mysqld 也在操作表。
5、 磁盘故障。
6、 服务器死机。
7、 mysql 本身的bug 。


用 check  table table_name;     检查表 不用重启

修复表
1、 使用 repair table table_name； 或myisamchk 来修复。
2、 如果上面的方法修复无效，采用备份恢复表。


###mysql-bin文件清除

```
#确认文件没用，mysql中执行
reset master;
or
reset slave;
#bin文件会从零开始
```

###其他操作
从二进制文件查询 事件语句
```
mysqlbinlog --base64-output=decode-rows -vv bin_file|grep -A 20 'pos_num'
```
定位效率低的查询：
```
show processlist\G  或 show full processlist; 
```
对于查询时间长、运行状态（State 列）是“Sending data”、“Copying to tmp table”、
```
“Copying to tmp table on disk”、“Sorting result”、“Using filesort”等都可能是有性能问题的查询（SQL）
```

事务处理  将步骤打包成一件事情来做， 失败一步 数据将回滚之前状态

MySQL防误删插件Recycle_bin

```
只读，在配置文件/etc/my.cnf中的mysqld中配置
read_only=1  		#0关闭只读，1开启  super可写
super_read_only=1	#全账号只读，mysql的root用户都不能写入
binlog_format = MIXED                  #binlog日志格式，mysql默认采用statement，建议使用mixed

#MIXED说明
对于执行的SQL语句中包含now()这样的时间函数，会在日志中产生对应的unix_timestamp()*1000的时间字符串，slave在完成同步时，
取用的是sqlEvent发生的时间来保证数据的准确性。另外对于一些功能性函数slave能完成相应的数据同步，而对于上面指定的一些类似于UDF函数，
导致Slave无法知晓的情况，则会采用ROW格式存储这些Binlog，以保证产生的Binlog可以供Slave完成数据同步。
```
###log 根据需要开启
常见的MySQL数据库日志有：错误日志（log_error）、慢查询日志（slow_query_log）、二进制日志（bin_log）、通用查询日志（general_log）
```
#bin-log
log-bin = /data/mysql/mysql-bin.log    #binlog日志文件
expire_logs_days = 7                   #binlog过期清理时间
max_binlog_size = 100m                 #binlog每个日志文件大小
binlog_cache_size = 4m                 #binlog缓存大小
max_binlog_cache_size = 512m           #最大binlog缓存大小

#slow-log
slow_query_log = 1
slow_query_log_file = /xxx/xxx.log 	
long_query_time = 1 
log_queries_not_using_indexes = 1 #记录所有没有利用索引来进行查询的语句

#错误日志
log_error = /var/log/mysql/error.log

#通用查询日志
general_log = 1	#mysql中的所有操作将会记录下来
general_log_file = /var/log/mysql/mysql.log
log_output='FILE’ #表示将日志存入文件,默认值是FILE


```

Mysql 设置隔离级别，以及事物隔离有几种级别。
1）read uncommitted : 读取尚未提交的数据 ：就是脏读
2）read committed：读取已经提交的数据 ：可以解决脏读
3）repeatable read：重读读取：可以解决脏读 和 不可重复读 ---mysql默认的
4）serializable：串行化：可以解决 脏读 不可重复读 和 虚读---相当于锁表
查看设置：SELECT @@tx_isolation;
修改事务权限的语句是：set [ global | session ] transaction isolation level Read uncommitted | Read committed | Repeatable | Serializable;

如果选择global，意思是此语句将应用于之后的所有session，而当前已经存在的session不受影响。
如果选择session，意思是此语句将应用于当前session内之后的所有事务。
如果什么都不写，意思是此语句将应用于当前session内的下一个还未开始的事务。

