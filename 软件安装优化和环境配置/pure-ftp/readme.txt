pure-ftpd

安装:

    yum install pure-ftpd

虚拟用户设置：

首先，可以在系统中添加相应的用户和组，如用户ftpuser 和组ftpgroup 。

    groupadd ftpgroup
    useradd ftpuser -g ftpgroup -d /home/ftp -s /sbin/nologin 

也可以是能登录系统的用户，但最好是不能登录系统的用户，安全。

然后利用pure-pw命令添加虚拟用户，如添加虚拟用户user1，并指定查看目录为/var/www/site1。

    pure-pw useradd user1 -u ftpuser -g ftpgroup -d /var/www/site1

另：一个系统用户可以绑定多个虚拟用户，然后控制所查看的目录。
如再添加虚拟用户user2，并指定查看目录为/var/www/site2

    pure-pw useradd user2 -u ftpuser -g ftpgroup -d /var/www/site2

pure-pw完之后会要求输入密码，也就是设置登录ftp用户的密码。

添加完之後，让 pure-ftpd 建立虚拟用户数据

    pure-pw mkdb

这样完了之后:

    /etc/init.d/pure-ftpd restart

是否可以登录？如果不可以，请查看 /etc/pure-ftpd/auth 下是否有 puredb ？  pure-pw mkdb
没有需要在/etc/pure-ftpd/auth下，创建一个软链接

    ln -s /etc/pure-ftpd/conf/PureDB 60puredb

至此，再次重启pure-ftpd。各个虚拟用户即可登录ftp查看各自的目录。
而且所有命令如果没有权限，记得加sudo。

其他：
1、删除一个用户的命令语法是：

    pure-pw userdel[-f] [-m]

这时，用户的信息会被从指定的 passwd 文件中删除，但是用户的 home 目录会被保留，需要手工删除。

2、改变用户口令

    pure-pw passwd[-f] [-m]

3、显示用户信息
/etc/pureftpd.passwd 文件中记录的信息不方便用户的阅读，因此 pure-ftpd 提供了显示用户信息的命令。其语法是：

    pure-pw show[-f]