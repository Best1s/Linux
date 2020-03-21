####squid常用命令：
squid -k parse	验证其配置文件是否正确
squid -z 初始化cache目录
squid 启动
squid -k shutdown 停止
squid -k reconfigure 重新载入配置文件
squid -k rotate 轮循日志,squid会写大量的日志文件。周期性的滚动日志文件，阻止它们变得太大。

每天的早上4点滚动日志：
0 4 * * * /usr/local/squid/sbin/squid -k rotate

配置转发
echo 1 > /proc/sys/net/ipv4/ip_forward

配置文件：  /etc/squid/squid.conf  简单配置。

```
#
# Recommended minimum configuration:
#

# Example rule allowing access from your local networks.
# Adapt to list your (internal) IP networks from where browsing
# should be allowed
#ACL列表要写在前面
#定义acl(访问控制列表), 语法为:acl<acl> <acl名称> <acl类型> <配置的内容>
#acl类型
#1 src　　　　　    　	源地址
#2 dst　　　     　     目标地址
#3 port　　　   　     目标地址
#4 dstdomain　     　目标域
#5 time　　　        　访问时间
#6 maxconn　　    　	最大并发连接
#7 url_regex　       　目标URL地址  # 可以定义大的范围比如http://www.baidu.com
#8 urlpath_regex　　整个目标URL路径  # 可以定位到每个网站的具体目标的url，比如百度音乐的一首歌的url

acl localnet src 10.0.0.0/8		# RFC1918 possible internal network
acl localnet src 172.16.0.0/12	# RFC1918 possible internal network
acl localnet src 192.168.0.0/16	# RFC1918 possible internal network
acl localnet src fc00::/7       # RFC 4193 local private network range
acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines

acl SSL_ports port 443
acl Safe_ports port 80		# http
acl Safe_ports port 21		# ftp
acl Safe_ports port 443		# https
acl Safe_ports port 70		# gopher
acl Safe_ports port 210		# wais
acl Safe_ports port 1025-65535	# unregistered ports
acl Safe_ports port 280		# http-mgmt
acl Safe_ports port 488		# gss-http
acl Safe_ports port 591		# filemaker
acl Safe_ports port 777		# multiling http
acl CONNECT method CONNECT
acl Github dstdomain "/etc/squid/dmblock.list"

#
# Recommended minimum Access Permission configuration:
#
# Deny requests to certain unsafe ports

#定义好各种访问控制列表以后，需要使用httpd_access配置项来进行控制
#http_access  allow或deny  列表名……

http_access deny !Safe_ports

# Deny CONNECT to other than secure SSL ports
http_access deny CONNECT !SSL_ports

http_access allow Github

# Only allow cachemgr access from localhost
http_access allow localhost manager
http_access deny manager

# We strongly recommend the following be uncommented to protect innocent
# web applications running on the proxy server who think the only
# one who can access services on "localhost" is a local user
#http_access deny to_localhost

#
# INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
#

# Example rule allowing access from your local networks.
# Adapt localnet in the ACL section to list your (internal) IP networks
# from where browsing should be allowed
http_access allow localnet
http_access allow localhost

# And finally deny all other access to this proxy
http_access deny all

# Squid normally listens to port 3128
http_port 3128

# Uncomment and adjust the following to add a disk cache directory.
#cache_dir ufs /var/spool/squid 100 16 256

# Leave coredumps in the first cache dir
coredump_dir /var/spool/squid

#
# Add any of your own refresh_pattern entries above these.
#
refresh_pattern ^ftp:		1440	20%	10080
refresh_pattern ^gopher:	1440	0%	1440
refresh_pattern -i (/cgi-bin/|\?) 0	0%	0
refresh_pattern .		0	20%	4320

#高匿设置
request_header_access Via deny all
request_header_access X-Forwarded-For deny all

#用户认证需要添加
auth_param basic program /usr/lib/squid/ncsa_auth /etc/squid/passwd
auth_param basic children 5
auth_param basic credentialsttl 2 hours
auth_param basic realm Example.com's Squid proxy-caching
acl auth_user proxy_auth REQUIRED
http_access allow auth_user
#注释：
#第一行：选择的认证方式为basic，认证程序路径和密码文件路径。
#第二行：认证程序的进程数
#第三行：认证有效时间
#第四行：认证领域内容，上面定义的web浏览需要输入用户密码
#第五,六行：设置允许认证的用户访问
#生成密码文件 需要httpd-tools
#htpasswd -c /etc/squid/passwd auth_user 
```