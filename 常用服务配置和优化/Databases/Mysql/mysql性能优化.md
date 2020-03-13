SHOW STATUS LIKE 'value';常用的性能参数:
- Connections，连接mysql服务器的次数。
- Uptime，mysql服务器的上线时间。
- Slow_queries,慢查询的次数。
- Com_select，查询操作的次数。
- Com_insert，插入操作的次数。
- Com_update，更新操作的次数。
- Com_delete，删除操作的次数。

SHOW STATUS LIKE 'Connections'; 查询mysql服务器的连接次数
SHOW STATUS LIKE 'Slow_queries'; 查询mysql服务器的慢查询次数


####1. 连接请求的变量
 
- **max_connections**
MySQL的最大连接数，如果服务器的并发连接请求量较大，建议调高此值，以增加并行连接数量，当然这建立在机器能支撑的情况下，因为如果连接数越多，MySQL回味每个连接提供连接缓冲区，就会开销越多的内存，所以要适当调整该值，不能盲目提高设值。
数值过小经常会出现ERROR 1040：Too mant connetcions错误，可以通过mysql>show status like 'connections'; 通配符来查看当前状态的连接数量（试图连接到MySQL（不管是否连接成功）的连接数），以定夺该值的大小。
show variables like 'max_connections'; 最大连接数
show variables like 'max_used_connection'; 相应连接数
max_used_connection/max_connections*100%（理想值约等于85%）
如果max_used_connections和max_connections相同，那么就是max_connections值设置过低或者超过服务器的负载上限了，低于10%则设置过大了。

- back_log
MySQL能够暂存的连接数量。当主要MySQL线程在一个很短时间内得到非常多的连接请求，他就会起作用。如果MySQL的连接数据达到max_connections时，新的请求将会被存在堆栈中，以等待某一连接释放资源，该堆栈数量即back_log，如果等待连接的数量超过back_log，将不被接受连接资源。

- wait_timeout和interative_timeout
wait_timeout：指的是MySQL再关闭一个非交互的连接之前所需要等待的秒数。
interative_timeout：指的是关闭一个交互的连接之前所需要等待的秒数。
如果设置太小，那么连接关闭的很快，从而使一些持久的连接不起作用
如果设置太大容易造成连接打开时间过长，在show processlist时，能够看到太多的sleep状态的连接，从而造成too many connections错误。
一般希望wait_timeuot尽可能的低。interative_timeout的设置将对你的web application没有多大的影响

####2. 缓冲区变量
全局缓冲

- key_buffer_size
key_buffer_size指定索引缓冲区的大小，它决定索引的处理速度，读的速度。通过检查状态值 key_read_requests和key_reads，可以知道key_buffer_size设置是否合理。比例key_reads/key_read_requests应该尽可能的低，至少是1：100，1：1000更好*（状态值可以使用show status like 'key_read%'获得）*
未命中缓存的概率：
key_cache_miss_rate = key_reads/key_read_requests*100%
key_buffer_size只对MAISAM表起作用。未实际验。
如何调整key_buffer_size的值

####3. query_cache_size（查询缓存简称QC)
使用查询缓存，MySQL将查询结果存放在缓冲区中，今后对同样的select语句（区分大小写），将直接从缓冲区中读取结果。
一个SQL查询如果以select开头，那么MySQL服务器将尝试对其使用查询缓存。**两个SQL语句，只要相差哪怕是一个字符（例如 大小写不一样：多一个空格等），那么两个SQL将使用不同的cache*

通过 show ststus like ‘Qcache%' 可以知道query_cache_size的设置是否合理

Qcache_free_blocks：缓存中相邻内存块的个数。如果该值显示过大，则说明Query Cache中的内存碎片较多了。
注：当一个表被更新后，和他相关的cache block将被free。但是这个block依然可能存在队列中，除非是在队列的尾部。可以用 flush query cache语句来清空free blocks。

Qcache_free_memory:Query Cache 中目前剩余的内存大小。通过这个参数我们可以较为准确的观察当前系统中的Query Cache内存大小是否足够，是需要增多还是过多了。

Qcache_hits：表示有多少次命中缓存。我们主要可以通过该值来验证我们的查询能缓存的效果。数字越大缓存效果越理想。

Qcache_inserts：表示多少次未命中而插入，意思是新来的SQL请求在缓存中未找到，不得不执行查询处理，执行查询处理后把结果insert带查询缓存中。这样的情况次数越多，表示查询缓存 应用到的比较少，效果也就不理想。

Qcache_lowmen_prunes：多少条Query因为内存不足而被清除出Query Cache，通过Qcache_lowmem_prunes和Qcache_free_memory 相互结合，能够更清楚的了解到我们系统中Query Cache的内存大小是否真的足够，是否非常频繁的出现因为内存不足而有Query被换出。这个数字最好是长时间来看，如果这个数字在不断增长，就表示可能碎片化非常严重，或者内存很少。

Qcache_queries_in_cache：当前Query Cache 中cache的Query数量
Qcache_total_blocks：当前Query Cache中block的数量

查询服务器关于query_cache的配置
各字段的解释：
query_cache_limit：超出此大小的查询将不被缓存
query_cache_min_res_unit：缓存块的最小大小，query_cache_min_res_unit的配置是一柄双刃剑，默认是 4KB ，设置值大对大数据查询有好处，但是如果你查询的都是小数据查询，就容易造成内存碎片和浪费。
query_cache_size：查询缓存大小（注：QC存储的单位最小是1024byte，所以如果你设定的一个不是1024的倍数的值。这个值会被四舍五入到最接近当前值的等于1024的倍数的值。）
query_cache_type：缓存类型，决定缓存什么样子的查询，注意这个值不能随便设置必须设置为数字，可选值以及说明如下：
    0：OFF 相当于禁用了
    1：ON 将缓存所有结果，除非你的select语句使用了SQL_NO_CACHE禁用了查询缓存
    2：DENAND  则只缓存select语句中通过SQL_CACHE指定需要缓存的查询。
query_cache_wlock_invalidate：当有其他客户端正在对MyISAM表进行写操作时，如果查询在query cache中，是否返回cache结果还是等写操作完成在读表获取结果。

查询缓存碎片率：Qcache_free_block/Qcache_total_block*100%
如果查询缓存碎片率超过20%，可以用flush query cache整理缓存碎片，或者试试减小query_cache_min_res_unit，如果你的查询都是小数据量的话。

查询缓存利用率：（query_cache_size-Qcache_free_memory)/query_cache_size*100%
查询缓存利用率在25%以下的话说明query_cache_size设置过大，可以适当减小：查询缓存利用率在80%以上而且Qcache_lowmem_prunes>50
的话说明query_cache_size可能有点小，要不就是碎片太多

查询缓存命中率：Qcache_hits/(Qcache_hits+Qcache_inserts)*100%

Query Cache的限制
a）所有子查询中的外部查询SQL 不能被Cache：
b）在p'rocedure，function以及trigger中的Query不能被Cache
c）包含其他很多每次执行可能得到不一样的结果的函数的Query不能被Cache

- max_connect_errors：
是一个MySQL中与安全有关的计数器值，他负责阻止过多尝试失败的客户端以防止暴力破解密码的情况，当超过指定次数，MySQL服务器将禁止host的连接请求，直到mysql服务器重启或通过flush hotos命令清空此host的相关信息。（与性能并无太大的关系）


- sort_buffer_size：
每个需要排序的线程分配该大小的一个缓冲区。增加这值加速ORDER BY 或 GROUP BY操作
sort_buffer_size是一个connection级的参数，在每个connection（session）第一次需要使用这个buffer的时候，一次性分配设置的内存。
sort_buffer_size：并不是越大越好，由于是connection级的参数，过大的设置+高并发可能会耗尽系统的内存资源。例如：500个连接将会消耗500*sort_buffer_size(2M)=1G


- max_allowed_packet=32M
根据配置文件限制server接受的数据包大小。

- join_buffer_size=2M
用于表示关联缓存的大小，和sort_buffer_size一样，该参数对应的分配内存也是每个连接独享。


- thread_cache_size=300
服务器线程缓存，这个值表示可以重新利用保存在缓存中的线程数量，当断开连接时，那么客户端的线程将被放到缓存中以响应下一个客户而不是销毁（前提时缓存数未达上限），如果线程重新被请求，那么请求将从缓存中读取，如果缓存中是空的或者是新的请求，这个线程将被重新请求，那么这个线程将被重新创建，如果有很多新的线程，增加这个值可以改善系统性能，通过比较Connections和Threads_created状态的变量，可以看到这个变量的作用。
设置规则如下：1G内存配置为8，2G内存为16.服务器处理此客户的线程将会缓存起来以响应下一个客户而不是被销毁（前提是缓存数未到达上限）
Threads_cached：代表当前此时此刻线程缓存中有多少空闲线程。
Threads_connected：代表当前已建立连接的数量，因为一个连接就需要一个线程，所以也可以看成当前被使用的线程数。
Threads_created：代表最近一次服务启动，已创建线程的数量，如果发现Threads_created值过大的话，说明MySQL服务器一直在创建线程，这也比较消耗资源，可以适当增加配置文件中thread_cache_size值
Threads_running：代表当前激活的（非睡眠状态）线程数。并不是代表正在使用的线程数，有时候连接已建立，但是连接处于sleep状态。


####4. Innodb的几个变量
**innodb_buffer_pool_size** 对Innodb表来说非常重要。是整个MySQL服务器最重要的变量。
MySQL InnoDB buffer pool 包含一下几点：
- 数据缓存，InnoDB数据页面
- 索引缓存，索引数据
- 缓冲数据，脏页（在内存中修改尚未刷新(写入)到磁盘的数据）
- 内部结构，如自适应哈希索引，行锁等。

innodb_buffer_pool_size默认大小为128M。当缓冲池大小大于1G时，将innodb_buffer_pool_instances设置大于1的值可以提高服务器的可扩展性。
调优参考计算方法：
```
val = Innodb_buffer_pool_pages_data / Innodb_buffer_pool_pages_total * 100%
val > 95% 则考虑增大 innodb_buffer_pool_size， 建议使用物理内存的75%
val < 95% 则考虑减小 innodb_buffer_pool_size， 建议设置为：Innodb_buffer_pool_pages_data * Innodb_page_size * 1.05 / (1024*1024*1024)
```
在线调整InnoDB缓冲池大小

	mysql> SET GLOBAL innodb_buffer_pool_size = 2147483648;
配置的innodb_buffer_pool_size是否合适？
可以通过分析InnoDB缓冲池的性能来验证,使用以下公式计算InnoDB缓冲池性能：

Performance = innodb_buffer_pool_reads / innodb_buffer_pool_read_requests * 100

innodb_buffer_pool_reads：表示InnoDB缓冲池无法满足的请求数。需要从磁盘中读取。

innodb_buffer_pool_read_requests：表示从内存中读取逻辑的请求数。
```
mysql> show status like 'innodb_buffer_pool_read%';
+---------------------------------------+-----------+
| Variable_name                         | Value     |
+---------------------------------------+-----------+
| Innodb_buffer_pool_read_ahead_rnd     | 0         |
| Innodb_buffer_pool_read_ahead         | 0         |
| Innodb_buffer_pool_read_ahead_evicted | 0         |
| Innodb_buffer_pool_read_requests      | 416127875 |
| Innodb_buffer_pool_reads              | 58828     |
+---------------------------------------+-----------+
5 rows in set (0.01 sec)
Performance = 58828 / 416127875 * 100 = 0.014137000555
从磁盘完成读取的百分比非常小。因此无需增加innodb_buffer_pool_size值。

```
其它Innodb的几个变量
- innodb_flush_log_at_trx_commit
主要控制了innodb将log buffer中的数据写入日志文件并flush磁盘的时间点，取值分别为0，1，2.
该值对插入数据的速度影响非常大，设置为2时插入10000条记录只需要两秒，设置为0时只需要一秒，设置为1时，则需要229秒。因此，MySQL手册也建议尽量将插入操作合并成一个事务，这样可以大幅度提高速度。

- innodb_thread_concurrency=0
此参数用来设置innodb线程的并发数，默认值为0表示不被限制，若要设置则与服务器的CPU核心数相同或是CPU的核心数的2倍。


- innodb_log_buffer_size
此参数确定日志文件所用的内存大小，以M为单位。缓冲区更大能提高性能，对于较大的事务，可以增大缓存大小。


- innodb_log_file_size=50M
此参数确定数据日志文件的大小，以M为单位，更大的设置可以提高性能。


- innodb_log_files_in_group=3
为提高性能，MySQL可以以循环方式将日志文件写到多个文件。推荐设置为3


- read_buffer_size=1M
MySQL 读入缓冲区大小。对表进行顺序扫描的请求将分配到一个读入缓冲区MySQL会为他分配一段内存缓冲区


- read_rnd_buffer_size=16M
MySQL 的随机读（查询操作）缓冲区大小。当按任意顺序读取行时（例如，按照排序顺序），将分配到一个随机都缓冲区。进行排序查询时，MySQL会首先扫描一遍该缓冲区，以避免磁盘搜索，提高查询速度，如果需要排序大量数据，可适当调高该值。但是MySQL会为每个客户连接发放该缓冲空间，所以应尽量适当设置该值，以避免内存消耗过大。
注：顺序读是根据索引的叶节点数据就能顺序的读取所需要的行数据。随机读是指一般需要根据辅助索引叶节点中的主键寻找侍其巷进行数据，而辅助索引和主键所在的数据端不同，因此访问方式是随机的。


- bulk_insert_buffer_size=64M
批量插入数据缓存大小，可以有效的提高插入效率，默认为8M


- binary log
binlog_cache_size=2M   //为每个session分配的内存，在事务过程中用来存储二进制日志的缓存，提高记录bin-log的效率。
max_binlog_cache_size=8M //表示的是binlog能够使用的最大cache内存大小
max_binlog_size=512M  //指定binlog日志文件的大小。不能将变量设置为大于1G或小于4096字节。默认值为1G.在导入大容量的sql文件时，建议关闭，sql_log_bin，否则硬盘扛不住，而且建议定期做删除。
expire_logs_days=7  //定义了mysql清除过期日志的时间