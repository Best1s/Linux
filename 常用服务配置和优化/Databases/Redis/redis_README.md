###Redis应用场景大概分为两种：
1. 应用程序直接访问 Redis 数据库
2. 应用程序直接访问 Redis，只有当 Redis 访问失败时才访问 MySQL

*实时性:实时浏览量计数*
适用场合：
1. 取最新 N  个数据的操作,超出集合部分从数据库获取
2. 排行榜应用，取 TOP N  操作
3. 需要精准设定过期时间的应用
4. 计数器应用
5. Uniq  操作，获取某段时间所有数据排重值
6. 实时系统，反垃圾系统
7. Pub/Sub  构建实时消息系统
8. 构建队列系统
9.  缓存

###Redis 常用类型：
1. string
string 是最简单的类型，一个 key 对应一个value
string 类型是二进制安全的。可以包含任何数据最大上限是 1G 字节
string 类型的定义:
```
struct sdshdr {
long len;		#len 是 buf 数组的长度。
long free;		#free 是数组中剩余可用字节数，
char buf[];		#buf 是个 char 数组用于存贮实际的字符串内容
};
```
操作
```
set		#设置一个键值对
setnx		#如果 key 已经存在，返回 0，nx 是 not exist 的意思。
setex		#设置 key 对应的值为 string 类型的 value，并指定此键值对应的有效期。
setrange	 #设置指定 key 的 value 值的子字符串。
mset		 #一次设置多个 key 的值，成功返回 ok 表示所有的值都设置了，失败返回 0 
msetnx	   #一次设置多个 key 的值，成功返回 ok 表示所有的值都设置了，失败返回 0 
get		  #获取 key 对应的 string 值,如果 key 不存在返回 nil。
getset	   #设置 key 的值，并返回 key 的旧值.
getrange	 #获取指定 key 的 value 值的子字符串。
mget		 #一次获取多个 key 的值，如果对应 key 不存在，则对应返回 nil。
incr		 #对 key 的值做加加操作,并返回新的值。注意 incr 一个不是 int 的 value 会返回错误，incr 一个不存在的 key，则设置 key 为 1
incrby	   #同 incr 类似，加指定值 ，key 不存在时候会设置 key，并认为原来的 value 是 0
decr		 #对 key 的值做的是减减操作，decr 一个不存在 key，则设置 key 为-1
decrby	   #同 decr，减指定值。
append	   #给指定 key 的字符串值追加 value,返回新字符串值的长度。
strlen		#取指定 key 的 value 值的长度。
```
1. Lists （列表）
list 是一个**链表结构**，主要功能是 push、pop、获取一个范围的所有值等等，操作中 key 理解为链表的名字。 list 类型其实就是一个每个子元素都是 string 类型的双向链表。链表的最大长度是(2的 32 次方)。
可以通过 push,pop 操作从链表的头部或者尾部添加删除元素。这使得 list既可以用**作栈**，也可以用作**队列**。
 list 的 pop 操作还有阻塞版本的，当我们[lr]pop 一个 list 对象时，如果 list 是空，或者不存在，会立即返回 nil。但是阻塞版本的 b[lr]pop 可以则可以阻塞，也可以加超时时间，超时后也会返回 nil。阻塞版本的 pop主要是为了避免轮询。
操作
```
lpush	#在 key 对应 list 的头部添加字符串元素
rpush	#在 key 对应 list 的尾部添加字符串元素
linsert	#在 key 对应 list 的特定位置之前或之后添加字符串元素
lset	#设置 list 中指定下标的元素值(下标从 0 开始)
lrem	#从 key 对应 list 中删除 count 个和 value 相同的元素。
ltrim	#保留指定 key 的值范围内的数据
lpop	#从 list 的头部删除元素，并返回删除元素
rpop	#从 list 的尾部删除元素，并返回删除元素
rpoplpush	#从第一个 list 的尾部移除元素并添加到第二个 list 的头部,最后返回被移除的元素值，
				#整个操作是原子的.如果第一个 list 是空或者不存在返回 nil
lindex	#返回名称为 key 的 list 中 index 位置的元素
llen	#返回 key 对应 list 的长度
```

2. Sets （集合）
set 是集合对集合的操作有添加删除元素，有对多个集合求交并差等操作，操作中 key 理解为集合的名字。
Redis 的 set 是 string 类型的无序集合。set 元素最大可以包含(2 的 32 次方)个元素。
set 的是通过 hash table 实现的，hash table 会随着添加或者删除自动的调整大小。需要注意的是调整 hash table 大小时候需要同步（获取写锁）会阻塞其他读写操作，可能不久后就会改用跳表（skip list）来实现，跳表已经在 sortedset 中使用了。set 集合还包含集合的取并集(union)，交集(intersection)，差集(difference)
操作
```
sadd	#向名称为 key 的 set 中添加元素
srem	#删除名称为 key 的 set 中的元素 member
spop	#随机返回并删除名称为 key 的 set 中一个元素
sdiff	#返回所有给定 key 与第一个 key 的差集
sdiffstore	#返回所有给定 key 与第一个 key 的差集，并将结果存为另一个 key
sinter	#返回所有给定 key 的交集
sinterstore	#返回所有给定 key 的交集，并将结果存为另一个 key
sunion	#返回所有给定 key 的并集
sunionstore	#返回所有给定 key 的并集，并将结果存为另一个 key
smove	#从第一个 key 对应的 set 中移除 member 并添加到第二个对应 set 中
scard	#返回名称为 key 的 set 的元素个数
sismember	#测试 member 是否是名称为 key 的 set 的元素
srandmember	#随机返回名称为 key 的 set 的一个元素，但是不删除元素
```
3. Sorted sets （有序集合）
sorted set 是 set 的一个升级版本，它在 set 的基础上增加了一个顺序属性，这一属性在添加修改元素的时候可以指定，每次指定后，zset 会自动重新按新的值调整顺序。可以理解为有两列的 mysql 表，一列存 value，一列存顺序。操作中 key 理解为 zset 的名字。
和 set 一样 sorted set 也是 string 类型元素的集合，不同的是每个元素都会关联一个 double类型的 score。sorted set 的实现是 skip list 和 hash table 的混合体。
操作
```
zadd	#向名称为 key 的 zset 中添加元素 member，score 用于排序。如果该元素已经存在，则根据score 更新该元素的顺序
zrem	#删除名称为 key 的 zset 中的元素 member
zincrby	#如果在名称为 key 的 zset 中已经存在元素 member，则该元素的 score 增加 increment；
		#否则向集合中添加该元素，其 score 的值为 increment
zrank	#返回名称为 key 的 zset 中 member 元素的排名(按 score 从小到大排序)即下标
zrevrank	#返回名称为 key 的 zset 中 member 元素的排名(按 score 从大到小排序)即下标
zrevrange	#返回名称为 key 的 zset（按 score 从大到小排序）中的 index 从 start 到 end 的所有元素
zrangebyscore	#返回集合中 score 在给定区间的元素
zcount	#返回集合中 score 在给定区间的数量
zcard	#返回集合中元素个数
zscore	#返回给定元素对应的 score
zremrangebyrank	#删除集合中排名在给定区间的元素
zremrangebyscore	#删除集合中 score 在给定区间的元素
```
4. Hashes （哈希表）
Redis hash 是一个 string 类型的 field 和 value 的映射表.它的添加、删除操作都是 O(1) （平均）。
新建一个hash 对象时是用 zipmap（又称为 small hash）来存储的，会占用更少的内存,zipmap由于一般对象的 field 数量都不太多。如果 field 或者 value的大小超出一定限制后，Redis 会在内部自动将 zipmap 替换成正常的 hash 实现. 这个限制可以在配置文件中指定
```
hash-max-zipmap-entries 64 #配置字段最多 64 个
hash-max-zipmap-value 512 #配置 value 最大为 512 字节
```
操作
```
hset	  #设置 hash field 为指定值，如果 key 不存在，则先创建
hsetnx	#设置 hash field 为指定值，如果 key 不存在，则先创建。如果 field 已经存在，返回 0，nx 是not exist 的意思。
hmset	 #同时设置 hash 的多个 field。
hget	  #获取指定的 hash field。
hmget	 #获取全部指定的 hash filed。
hincrby	#指定的 hash filed 加上给定值。
hexists	#测试指定 field 是否存在。
hlen	  #返回指定 hash 的 field 数量
hdel	  #返回指定 hash 的 field 数量。
hkeys	 #返回 hash 的所有 field。
hvals	 #返回 hash 的所有 value。
hincrby	#指定的 hash filed 加上给定值。
hexists	#测试指定 field 是否存在
hlen	#返回指定 hash 的 field 数量
hdel	#返回指定 hash 的 field 数量。
hkeys	#返回 hash 的所有 field。
hvals	#返回 hash 的所有 value。
hgetall	#获取某个 hash 中全部的 filed 及 value。
```

###Redis 常用命令
1. 键值相关命令
```
keys	#返回满足给定 pattern 的所有 key
exists	 #确认一个 key 是否存在
del		#删除一个 key
expire	 #设置一个 key 的过期时间(单位:秒)
move	   #将当前数据库中的 key 转移到其它数据库中
persist	#移除给定 key 的过期时间
randomkey	#随机返回 key 空间的一个 key
rename	 #重命名 key
type	   #返回值的类型
```
2. 服务器相关命令
```
ping	#测试连接是否存活
echo	#在命令行打印一些内容
select	#选择数据库。Redis 数据库编号从 0~15，我们可以选择任意一个数据库来进行数据的存取
quit	#退出连接。
dbsize	 #返回当前数据库中 key 的数目。
info	   #获取服务器的信息和统计。
monitor	#实时转储收到的请求。实时转储收到的请求。
config get	#获取服务器配置信息。
flushdb	 #删除当前选择数据库中的所有 key。
flushall	#删除所有数据库中的所有 key。
```

###Redis高级特性
1. 安全性
设置客户端连接后进行任何其他指定前需要使用的密码。一个外部的用户可以在一秒钟进行 150K 次的密码尝试
2. 主从复制
3. 事务控制
redis 只能保证一个 client 发起的事务中的命令可以连续的执行，而中间不会插入其他 client 的命令。
一般情况下 redis 在接受到一个 client 发来的命令后会立即处理并 返回处理结果，但是当一个 client 在一个连接中发出 multi 命令有，这个连接会进入一个事务上下文，该连接后续的命令并不是立即执行，而是先放到一个队列中。当从此连接受到 exec 命令后，redis 会顺序的执行队列中的所有命令。并将所有命令的运行结果打包到一起返回给 client.然后此连接就 结束事务上下文。
4. 取消一个事务
调用 discard 命令来取消一个事务，让事务回滚。
redis只能保证事务的每个命令连续执行，如果事务中的一个命令失败了，并不回滚其他命令
5. [乐观锁](https://baike.baidu.com/item/%E4%B9%90%E8%A7%82%E9%94%81/7146502?fr=aladdin '')复杂事务控制
简单来说就是操作数据后比对版本值
使用watch监视给定key， exec 时候如果监视的 key 从调用 watch 后发生过变化，则整个事务会失败。 watch 的 key 是对整个连接有效的，事务也一样。如果连接断开，监视和事务都会被自动清除。
5. 持久化机制
6. 发布及订阅消息
发布订阅(pub/sub)消息通信模式
redis 将消息类型称为通道(channel)。当发布者通过publish 命令向 redis server 发送特定类型的消息时。订阅该消息类型的全部 client 都会收到此消息。一个client可以订阅多个channel,也可以向多个channel发送消息
```
subscribe 或者 psubscribe 订阅通道
 unsubscribe 或者 punsubscribe 命令退出订阅模式
psubscribe 命令订阅多个通配符通道
```
6. Pipeline  批量发送请求
redis 是一个 cs 模式的 tcp server，使用和 http 类似的请求响应协议。一个 client 可以通过一个 socket 连接发起多个请求命令。每个请求命令发出后 client 通常会阻塞并等待 redis 服务处理，redis 处理完后请求命令后会将结果通过响应报文返回给 client。
redis可以利用 pipeline 的方式从 client 打包多条命令一起发出，不需要等待单条命令的响应返回，而 redis 服务端会处理完多条命令后会将多条命令的处理结果打包到一起返回给客户端。减少发送的TCP报文
7. 虚拟内存的使用
8. redis 没有使用操作系统提供的虚拟内存机制而是自己在实现了自己的虚拟内存机制，主要的理由有两点:
1、操作系统的虚拟内存是已 4k 页面为最小单位进行交换的。而 redis 的大多数对象都远小于 4k，所以一个操作系统页面上可能有多个 redis 对象。另外 redis 的集合对象类型如 list,set可能存在与多个操作系统页面上。最终可能造成只有 10%key 被经常访问，但是所有操作系统页面都会被操作系统认为是活跃的，这样只有内存真正耗尽时操作系统才会交换页面。
2、相比于操作系统的交换方式，redis 可以将被交换到磁盘的对象进行压缩,保存到磁盘的对象可以去除指针和对象元数据信息，一般压缩后的对象会比内存中的对象小10倍，这样redis的虚拟内存会比操作系统虚拟内存能少做很多 io 操作。
下面是 vm 相关配置
```
vm-enabled yes 	#开启 vm 功能
vm-swap-file /tmp/redis.swap 	#交换出来的 value 保存的文件路径
vm-max-memory 1000000 		   #redis 使用的最大内存上限
vm-page-size 32 		#每个页面的大小 32 个字节
vm-pages 134217728 	 #最多使用多少页面
vm-max-threads 4 	   #用于执行 value 对象换入换出的工作线程数量
```
redis 的虚拟内存在设计上**为了保证 key 的查找速度，只会将 value 交换到 swap 文件中**。所以如果是内存问题是由于太多 value 很小的 key 造成的，那么虚拟内存并不能解决，和操作系统一样 redis 也是按页面来交换对象的。redis 规定**同一个页面只能保存一个对象**。但是**一个对象可以保存在多个页面中**。在 **redis 使用的内存没超过 vm-max-memory 之前是不会交换任何 value 的**。当超过最大内存限制后，redis 会选择较过期的对象。如果两个对象一样过期会优先交换比较大的对象，精确的公式 swappability = age*log(size_in_memory)。
对于vm-page-size 的设置应该根据自己的应用将页面的大小设置为可以容纳大多数对象的大小，太大了会浪费磁盘空间，太小了会造成交换文件出现碎片。对于交换文件中的每个页面，redis会在内存中对应一个 1bit 值来记录页面的空闲状态。所以像上面配置中页面数量(vm-pages
134217728 )会占用 16M 内存用来记录页面空闲状态。vm-max-threads 表示用做交换任务的线程数量。如果大于 0 推荐设为服务器的 cpu 内核的数量，如果是 0 则交换过程在主线程进