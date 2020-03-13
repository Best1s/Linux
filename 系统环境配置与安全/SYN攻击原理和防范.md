####SYN攻击原理
- 服务器接收到连接请求（syn=j），将此信息加入未连接队列，并发送请求包给客户（syn=k,ack=j+1），此时进入SYN_RECV状态。当服务器未收到客户端的确认包时，重发请求包，一直到超时，才将此条目从未连接队列删除。
- SYN攻击属于DOS攻击的一种，它利用TCP协议缺陷，通过发送大量的半连接请求，耗费CPU和内存资源。
- SYN攻击除了能影响主机外，还可以危害路由器、防火墙等网络系统等

####检测SYN攻击
- 检测SYN攻击非常的方便，当你在服务器上看到大量的半连接状态时，特别是源IP地址是随机的，基本上可以断定这是一次SYN攻击。
- 使用netstat -n -p TCP 查看SYN_RECV状态

####SYN攻击防范技术
1.过滤网关防护
过滤网关主要指明防火墙，当然路由器也能成为过滤网关。过滤网关防护主要包括超时设置，SYN网关和SYN代理三种。

- 网关超时设置：防火墙设置SYN转发超时参数。当客户端发送完SYN包，服务端发送确认包后（SYN+ACK），防火墙如果在计数器到期时还未收到客户端的确认包（ACK），则往服务器发送RST包，以使服务器从队列中删去该半连接。

- SYN网关：SYN网关收到客户端的SYN包时，直接转发给服务器；SYN网关收到服务器的SYN/ACK包后，将该包转发给客户端，同时以客户端的名义给服务器发ACK确认包。此时服务器由半连接状态进入连接状态。当客户端确认包到达时，如果有数据则转发，否则丢弃。一般服务器所能承受的连接数量比半连接数量大得多。

- SYN代理：当客户端SYN包到达过滤网关时，SYN代理并不转发SYN包，而是以服务器的名义主动回复SYN/ACK包给客户，如果收到客户的ACK包，表明这是正常的访问，此时防火墙向服务器发送ACK包并完成三次握手。SYN代理事实上代替了服务器去处理SYN攻击。

2.加固tcp/ip协议栈

防范SYN攻击的另一项主要技术是调整tcp/ip协议栈，修改tcp协议实现。主要方法有SynAttackProtect保护机制、SYN cookies技术、增加最大半连接和缩短超时时间等。tcp/ip协议栈的调整可能会引起某些功能的受限，应该在进行充分了解和测试的前提下进行此项工作。

- SynAttackProtect机制：winserver上在注册表HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters位置增加SynAttackProtect键值(十六进制)
SynAttackProtect为0或不设置时，系统不受SynAttackProtect保护。
SynAttackProtect值为1时，系统通过减少重传次数和延迟未连接时路由缓冲项（route cache entry）防范SYN攻击。
SynAttackProtect值为2时（Microsoft推荐使用此值），系统不仅使用backlog队列，还使用附加的半连接指示，以此来处理更多的SYN连接，使用此键值时，tcp/ip的TCPInitialRTT、window size和可滑动窗囗将被禁止。

- SYN cookies技术
在SYN cookies中，服务器的初始序列号是通过对客户端IP地址、客户端端囗、服务器IP地址和服务器端囗以及其他一些安全数值等要素进行hash运算，加密得到的。当服务器遭受SYN攻击使得backlog队列满时，服务器并不拒绝新的SYN请求，而是回复cookie（回复包的SYN序列号）给客户端，如果收到客户端的ACK包，服务器将客户端的ACK序列号减去1得到cookie比较值，并将上述要素进行一次hash运算，看看是否等于此cookie。如果相等，直接完成三次握手(此时并不用查看此连接是否属于backlog队列）。
echo 1 > /proc/sys/net/ipv4/tcp_syncookies **启用SYN cookies 通常是开启的 *

- 增加最大半连接数
Linux用变量tcp_max_syn_backlog定义backlog队列容纳的最大半连接数。
我们可以通过以下命令修改此变量的值：sysctl -w net.ipv4.tcp_max_syn_backlog="2048"

- 缩短超时时间
减少超时时间也使系统能处理更多的SYN请求
LINUX：Redhat使用变量net.ipv4.tcp_synack_retries定义重传次数，其默认值是5次，总超时时间需要3分钟。可设置为2次