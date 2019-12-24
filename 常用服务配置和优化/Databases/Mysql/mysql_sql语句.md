###mysql数据库基本操作
1. 创建数据库
1) 使用 **create** 命令创建数据库.
```
CREATE DATABASE 数据库名;
```
2) 使用 mysqladmin 创建数据库.
```
mysqladmin -u root -p create RUNOOB
Enter password:******
```
2. 删除数据库
 1) 使用**drop** 命令
```
drop database <数据库名>;
```
2) 使用 **mysqladmin** 删除数据库
```
[root@host]# mysqladmin -u root -p drop RUNOOB
Enter password:******
```
3. MySQL 选择数据库
```
use 数据库名
```

###**MySQL 数据类型**
1. 数据类型
![](http://cdn.binver.top/mysql/mysql_number_type.png '数据类型')

2. **字符串类型**
![](http://cdn.binver.top/mysql/mysql_string_type.png '字符串类型')

3. **日期类型**
![](http://cdn.binver.top/mysql/mysql_date_type.png '日期类型')

###mysql数据表基本操作
1. 创建数据表的SQL通用语法：
```
CREATE TABLE table_name (column_name column_type);
```
2. ALTER命令,修改数据表名或者修改数据表字段
```
# ALTER 命令及 DROP 子句来删除以上创建表的 i 字段：
mysql> ALTER TABLE testalter_tbl  DROP i;
#使用 ADD 子句来向数据表中添加列
mysql> ALTER TABLE testalter_tbl ADD i INT;
#指定新增字段的位置，使用MySQL提供的关键字 FIRST (设定位第一列)， AFTER 字段名（设定位于某个字段之后）。
ALTER TABLE testalter_tbl DROP i;
ALTER TABLE testalter_tbl ADD i INT FIRST;
ALTER TABLE testalter_tbl DROP i;
ALTER TABLE testalter_tbl ADD i INT AFTER c;
#修改字段类型及名称，修改字段类型及名称, 在ALTER命令中使用 MODIFY 或 CHANGE 子句 
mysql> ALTER TABLE testalter_tbl MODIFY c CHAR(10);
#使用 CHANGE 子句, 语法有很大的不同。 在 CHANGE 关键字之后，紧跟着的是你要修改的字段名，然后指定新字段名及类型。
mysql> ALTER TABLE testalter_tbl CHANGE i j BIGINT;
mysql> ALTER TABLE testalter_tbl CHANGE j j INT;
#当修改字段时，可以指定是否包含值或者是否设置默认值。
mysql> ALTER TABLE testalter_tbl 
    -> MODIFY j BIGINT NOT NULL DEFAULT 100;
#使用 ALTER 来修改字段的默认值
mysql> ALTER TABLE testalter_tbl ALTER i SET DEFAULT 1000;
#使用 ALTER 命令及 DROP子句来删除字段的默认值
mysql> ALTER TABLE testalter_tbl ALTER i DROP DEFAULT;
#修改数据表存储引擎，可以使用 ALTER 命令来完成。
mysql> ALTER TABLE testalter_tbl ENGINE = MYISAM;
#修改表名
mysql> ALTER TABLE testalter_tbl RENAME TO alter_tbl;
```
2. 删除数据表
```
DROP TABLE table_name ;
```
3. 插入数据
```
INSERT INTO table_name ( field1, field2,...fieldN )
                       VALUES
                       ( value1, value2,...valueN );
```
4. 查询数据
```
SELECT column_name,column_name
FROM table_name
[WHERE Clause]
[LIMIT N][ OFFSET M]
```
**WHERE** 子句
```
SELECT field1, field2,...fieldN FROM table_name1, table_name2...
[WHERE condition1 [AND [OR]] condition2.....
```
LIKE 子句,SQL LIKE 子句中使用百分号 %字符来表示任意字符
```
SELECT field1, field2,...fieldN 
FROM table_name
WHERE field1 LIKE condition1 [AND [OR]] filed2 = 'somevalue'
```
**ORDER BY** 子句 排序
```
SELECT field1, field2,...fieldN FROM table_name1, table_name2...
ORDER BY field1 [ASC [DESC][默认 ASC]], [field2...] [ASC [DESC][默认 ASC]]
```
**GROUP BY** 分组
```
SELECT column_name, function(column_name)
FROM table_name
WHERE column_name operator value
GROUP BY column_name;
#WITH ROLLUP 可以实现在分组统计数据基础上再进行相同的统计（SUM,AVG,COUNT…）。
```
**UNION** 操作符，UNION 操作符用于连接两个以上的 SELECT 语句的结果组合到一个结果集合中。多个 SELECT 语句会删除重复的数据。
```
SELECT expression1, expression2, ... expression_n
FROM tables
[WHERE conditions]
UNION [ALL | DISTINCT]
SELECT expression1, expression2, ... expression_n
FROM tables
[WHERE conditions];
```
MySQL 连接的使用
```
INNER JOIN（内连接,或等值连接）：获取两个表中字段匹配关系的记录。
LEFT JOIN（左连接）：获取左表所有记录，即使右表没有对应匹配的记录。
RIGHT JOIN（右连接）： 与 LEFT JOIN 相反，用于获取右表所有记录，即使左表没有对应匹配的记录。
```
![](http://cdn.binver.top/mysql/mysql_JOIN.png)
**NULL** 值处理
当提供的查询条件字段为 NULL 时，SELECT 命令及 WHERE 子句可能就无法正常工作。
```
IS NULL: 当列的值是 NULL,此运算符返回 true。
IS NOT NULL: 当列的值不为 NULL, 运算符返回 true。
<=>: 比较操作符（不同于 = 运算符），当比较的的两个值相等或者都为 NULL 时返回 true。
```
MySQL **正则表达式**
```
#MySQL中使用 REGEXP 操作符来进行正则表达式匹配。
查找name字段中以'st'为开头的所有数据：
mysql> SELECT name FROM person_tbl WHERE name REGEXP '^st';
查找name字段中以'ok'为结尾的所有数据：
mysql> SELECT name FROM person_tbl WHERE name REGEXP 'ok$';
查找name字段中包含'mar'字符串的所有数据：
mysql> SELECT name FROM person_tbl WHERE name REGEXP 'mar';
查找name字段中以元音字符开头或以'ok'字符串结尾的所有数据：
mysql> SELECT name FROM person_tbl WHERE name REGEXP '^[aeiou]|ok$';
```
5. UPDATE 更新
```
UPDATE table_name SET field1=new-value1, field2=new-value2
[WHERE Clause]
```
6. DELETE 语句
```
DELETE FROM table_name [WHERE Clause]
```
UNION ALL 实例会显示全部值
9. MySQL 事务
**事务是必须满足4个条件（ACID）**
```
事务控制语句：
BEGIN 或 START TRANSACTION 显式地开启一个事务；
COMMIT 	也可以使用 COMMIT WORK，不过二者是等价的。COMMIT 会提交事务，并使已对数据库进行的所有修改成为永久性的；
ROLLBACK   也可以使用 ROLLBACK WORK，不过二者是等价的。回滚会结束用户的事务，并撤销正在进行的所有未提交的修改；
SAVEPOINT identifier，SAVEPOINT 	允许在事务中创建一个保存点，一个事务中可以有多个 SAVEPOINT；
RELEASE SAVEPOINT identifier 	删除一个事务的保存点，当没有指定的保存点时，执行该语句会抛出一个异常；
ROLLBACK TO identifier 把事务回滚到标记点；
SET TRANSACTION 	用来设置事务的隔离级别。InnoDB 存储引擎提供事务的隔离级别有READ UNCOMMITTED、READ COMMITTED、REPEATABLE READ 和 SERIALIZABLE。
```
MYSQL 事务处理主要有两种方法：
1、用 BEGIN, ROLLBACK, COMMIT来实现
```
BEGIN 开始一个事务
ROLLBACK 事务回滚
COMMIT 事务确认
```
2、直接用 SET 来改变 MySQL 的自动提交模式:
```
SET AUTOCOMMIT=0 禁止自动提交
SET AUTOCOMMIT=1 开启自动提交
```
9. mysql 索引
索引分单列索引和组合索引。
单列索引，即一个索引只包含单个列，一个表可以有多个单列索引，但这不是组合索引。组合索引，即一个索引包含多个列。
创建索引时，你需要确保该索引是应用在 SQL 查询语句的条件(一般作为 WHERE 子句的条件)。
1） 普通索引
这是最基本的索引，它没有任何限制。它有以下几种创建方式：
```
CREATE INDEX indexName ON mytable(username(length)); 
```
创建表的时候直接指定
```
CREATE TABLE mytable(   
ID INT NOT NULL,    
username VARCHAR(16) NOT NULL, 
INDEX [indexName] (username(length))  
);  
```
删除索引的语法
```
DROP INDEX [indexName] ON mytable; 
```
2） 唯一索引
它与前面的普通索引类似，不同的就是：索引列的值必须唯一，但允许有空值。如果是组合索引，则列值的组合必须唯一。
创建索引
```
CREATE UNIQUE INDEX indexName ON mytable(username(length)) 
```
修改表结构
```
ALTER table mytable ADD UNIQUE [indexName] (username(length))
```
创建表的时候直接指定
```
CREATE TABLE mytable( 
ID INT NOT NULL,
username VARCHAR(16) NOT NULL, 
UNIQUE [indexName] (username(length)) 
);
```
3） 使用ALTER 命令添加和删除索引
有四种方式来添加数据表的索引：
```
ALTER TABLE tbl_name ADD PRIMARY KEY (column_list);		#该语句添加一个主键，这意味着索引值必须是唯一的，且不能为NULL。
ALTER TABLE tbl_name ADD UNIQUE index_name (column_list);	#这条语句创建索引的值必须是唯一的（除了NULL外，NULL可能会出现多次）。
ALTER TABLE tbl_name ADD INDEX index_name (column_list);	 #添加普通索引，索引值可出现多次。
ALTER TABLE tbl_name ADD FULLTEXT index_name (column_list);		#该语句指定了索引为 FULLTEXT ，用于全文索引。
```
删除索引。
```
ALTER TABLE tbl_name DROP INDEX (column_list);
```
使用 ALTER 命令添加和删除主键
主键只能作用于一个列上，添加主键索引时，你需要确保该主键默认不为空（NOT NULL）。
```
mysql> ALTER TABLE testalter_tbl MODIFY i INT NOT NULL;
mysql> ALTER TABLE testalter_tbl ADD PRIMARY KEY (i);
```
使用 ALTER 命令删除主键：
```
mysql> ALTER TABLE testalter_tbl DROP PRIMARY KEY;
```
4） 显示索引信息
```
mysql> SHOW INDEX FROM table_name \G
```

10. **Mysql 临时表**
临时表只在当前连接可见，当关闭连接时，Mysql会自动删除表并释放所有空间。
```
CREATE TEMPORARY TABLE 临时表名 (column_name column_type);
```
用查询直接创建临时表的方式：
```
CREATE TEMPORARY TABLE 临时表名 AS
(
    SELECT *  FROM 旧的表名
    LIMIT 0,10000
);
``` 
11. **MySQL 复制表**
完整的复制MySQL数据表
```
使用 SHOW CREATE TABLE 命令获取创建数据表(CREATE TABLE) 语句，该语句包含了原数据表的结构，索引等。
mysql> SHOW CREATE TABLE 表名 \G
复制上面命令显示的SQL语句，修改数据表名，并执行SQL语句，通过以上命令 将完全的复制数据表结构。
如果想复制表的内容，你就可以使用 INSERT INTO ... SELECT 语句来实现。
mysql> INSERT INTO 新表 (x1,x2,x3,x4) VALUES  (SELECT x1,x2,x3,x4 FROM 表名);
```
另一种完整复制表的方法:
```
CREATE TABLE targetTable LIKE sourceTable;
INSERT INTO targetTable SELECT * FROM sourceTable;
or
create table 新表 like 旧表
or
create table新表 select * from 旧表 
```
其他:
可以拷贝一个表中其中的一些字段:
```
CREATE TABLE newadmin AS
(
    SELECT username, password FROM admin
)
```
可以将新建的表的字段改名:
```
CREATE TABLE newadmin AS
(  
    SELECT id, username AS uname, password AS pass FROM admin
)
```
可以拷贝一部分数据:
```
CREATE TABLE newadmin AS
(
    SELECT * FROM admin WHERE LEFT(username,1) = 's'
)
```
可以在创建表的同时定义表中的字段信息:
```
CREATE TABLE newadmin
(
    id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY
)
AS
(
    SELECT * FROM admin
)
```

12. 获取服务器元数据
以下命令语句可以在 MySQL 的命令提示符使用，也可以在脚本中 使用，如PHP脚本。
```
命令								描述
SELECT VERSION( )			服务器版本信息
SELECT DATABASE( )			当前数据库名 (或者返回空)
SELECT USER( )				当前用户名
SHOW STATUS					服务器状态
SHOW VARIABLES				服务器配置变量
```

13. MySQL 序列使用
一张数据表只能有一个字段自增主键， 如果想其他字段也实现自动增加，需要使用MySQL序列 AUTO_INCREMENT

14. MySQL 处理重复数据
设置指定的字段为 PRIMARY KEY（主键） 或者 UNIQUE（唯一） 索引来保证数据的唯一性。
统计重复数据
统计表中 first_name 和 last_name的重复记录数：
```
mysql> SELECT COUNT(*) as repetitions, last_name, first_name
    -> FROM person_tbl
    -> GROUP BY last_name, first_name
    -> HAVING repetitions > 1;
以上查询语句将返回 person_tbl 表中重复的记录数。 一般情况下，查询重复的值，请执行以下操作：
确定哪一列包含的值可能会重复。
在列选择列表使用COUNT(*)列出的那些列。
在GROUP BY子句中列出的列。
HAVING子句设置重复数大于1
```
过滤重复数据
如果你需要读取不重复的数据可以在 SELECT 语句中使用 DISTINCT 关键字来过滤重复数据。
```
mysql> SELECT DISTINCT last_name, first_name
    -> FROM person_tbl;
你也可以使用 GROUP BY 来读取数据表中不重复的数据：
mysql> SELECT last_name, first_name
    -> FROM person_tbl
    -> GROUP BY (last_name, first_name);
```
删除重复数据
删除数据表中的重复数据，可以使用以下的SQL语句：
```
mysql> CREATE TABLE tmp SELECT last_name, first_name, sex FROM person_tbl  GROUP BY (last_name, first_name, sex);
mysql> DROP TABLE person_tbl;
mysql> ALTER TABLE tmp RENAME TO person_tbl;
也可以在数据表中添加 INDEX（索引） 和 PRIMAY KEY（主键）这种简单的方法来删除表中的重复记录。方法如下：
mysql> ALTER IGNORE TABLE person_tbl
    -> ADD PRIMARY KEY (last_name, first_name);
```