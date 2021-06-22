##  一、rdbtools工具介绍

源码地址:https://github.com/sripathikrishnan/redis-rdb-tools/

redis-rdb-tools 是一个 python 的解析 rdb 文件的工具，

- 生成内存快照
- 转储成 json 格式
- 使用标准的 diff 工具比较两个 dump 文件

##  二、redis-rdb-tools 安装

redis-rdb-tools 有两种安装方式。

1、使用 pip 安装

```
pip install rdbtools python-lzf
```

 

2、从源码安装

```
# git clone https://github.com/sripathikrishnan/redis-rdb-tools.git
# cd redis-rdb-tools/
# python setup.py install
```

 



 使用语法：

> ```shell
> Usage: rdb [options] dump.rdb
> Example : rdb –command json -k “user.*” /var/redis/6379/dump.rdb
> Options:
> -h, –help #显示此帮助消息并退出;
> -c FILE, –command=FILE #指定rdb文件;
> -f FILE, –file=FILE #指定导出文件;
> -n DBS, –db=DBS #解析指定数据库,如果不指定默认包含所有;
> -k KEYS, –key=KEYS #指定需要导出的KEY,可以使用正则表达式;
> -o NOT_KEYS, –not-key=NOT_KEYS #指定不需要导出的KEY,可以使用正则表达式;
> -t TYPES, –type=TYPES #指定解析的数据类型,可能的值有:string,hash,set,sortedset,list;可以提供多个类型,如果没有指定,所有数据类型都返回;
> -b BYTES, –bytes=BYTES #限制输出KEY大大小;
> -l LARGEST, –largest=LARGEST #根据大小限制的top key;
> -e ESCAPE, –escape=ESCAPE #指定输出编码,默认RAW;
> ```

转换rdb文件成json格式

```
# rdb --command json dump.rdb > dump.json
```



##  三、生成内存报告

生成CSV格式的内存报告。包含的列有：数据库ID，数据类型，key，内存使用量(byte)，编码。内存使用量包含key、value和其他值。
注意：内存使用量是近似的。在一般情况下，略低于实际值。可以根据key或数据库ID或数据类型对报告的内容进行过滤。
内存报告有助于检测是否是应用程序逻辑导致的内存泄露，也有助于优化reids内存使用情况。

```
# rdb -c memory dump.rdb --bytes 128 -f dump_memory.csv
```

输出字段说明：

```
database ：key在redis的db
type ：key类型
key ：key值
size_in_bytes ：key的内存大小(byte)
encoding ：value的存储编码形式
num_elements ：key中的value的个数
len_largest_element ：key中的value的长度
expiry ：key过期时间
```

按键值大小排序

```
# awk -F',' '{print $4,$2,$3,$1}' dump_memory.csv | sort  > dump_memory_csv.sort
```

 

##  四、单个key所使用的内存量

查询某个key所使用的内存。可以使用redis-memory-for-key命令。
redis-memory-for-key 需要依赖redis-py包。

```
# redis-memory-for-key -s x.x.x.x -p 6379 -a xxxx:XXXXX name
```

 

##  五、比较RDB文件

使用 –command diff 选项，并通过管道来进行排序。

```
# rdb --command diff dump1.rdb | sort > dump1.txt
# rdb --command diff dump2.rdb | sort > dump2.txt
```

 

使用kdiff3工具来进行比较，kdiff3是图形化的工具，比较直观。kdiff3工具比较两个或三个输入文件或目录。
安装kdiff3（需要epel源）

```
# yum install kdiff3
# kdiff3 dump1.txt dump2.txt
```

