mysqldumpslow命令说明
```
Usage: mysqldumpslow [ OPTS... ] [ LOGS... ]

Parse and summarize the MySQL slow query log. Options are

  --verbose    verbose
  --debug      debug
  --help       write this text to standard output

  -v           verbose
  -d           debug
  -s ORDER     what to sort by (al, at, ar, c, l, r, t), 'at' is default
                al: average lock time
                ar: average rows sent
                at: average query time
                 c: count
                 l: lock time
                 r: rows sent
                 t: query time  
  -r           reverse the sort order (largest last instead of first)
  -t NUM       just show the top n queries
  -a           don't abstract all numbers to N and strings to 'S'
  -n NUM       abstract numbers with at least n digits within names
  -g PATTERN   grep: only consider stmts that include this string
  -h HOSTNAME  hostname of db server for *-slow.log filename (can be wildcard),
               default is '*', i.e. match all
  -i NAME      name of server instance (if using mysql.server startup script)
  -l           don't subtract lock time from total time
```

```
mysqldumpslow -s t -t 10 slow.log 	#按query time 排序 只要前10条记录

mysqldumpslow -s t -t 10 -g “left join” slow.log 	#按照query time 排序含有左连接的查询语句的前10条语句。

mysqldumpslow -a -s t -t 2 slow.log		#-a 参数，说明不合并类似的SQL语句，显示具体的SQL语句中的数字和字符串。
```
处理后的日志格式
```
Count: 4659  Time=68.20s (317744s)  Lock=0.00s (0s)  Rows=383.4 (1786466), root[root]@localhost
  select `video_id` from `fish_video_product_view_temporary` group by `video_id` having count(id)>= N and sum(is_share) < N order by sum(is_share) desc

出现次数(Count),
执行最长时间平均(Time),
累计总耗费时间(Time),
等待锁的时间(Lock),
发送给客户端的行总数(Rows),
扫描的行总数(Rows)

```
