OpenLDAP 手册http://www.openldap.org/doc/admin24/quickstart.html
OpenLDAP 安装http://www.openldap.org/doc/admin24/install.html
###必备软件
OpenLDAP依赖许多第三方包，根据需求安装。
1. 传输层安全
OpenLDAP客户端和服务器需要安装[OpenSSL](http://www.openssl.org/)，[GnuTLS]( http://www.gnu.org/software/gnutls/)或[MozNSS](http://developer.mozilla.org/en/NSS) TLS lib提供的传输层安全服务。除非OpenLDAP的configure检测到可用的TLS库，否则OpenLDAP软件将不完全符合LDAPv3 。

2. 简单身份验证和安全层
OpenLDAP客户端和服务器需要安装[Cyrus SASL](http://asg.web.cmu.edu/sasl/sasl-library.html) 库才能提供简单身份验证和安全层服务。除非OpenLDAP的configure检测到可用的Cyrus SASL安装，否则OpenLDAP软件将不完全符合LDAPv3。

3. Kerberos身份验证服务
OpenLDAP客户端和服务器支持Kerberos身份验证服务。OpenLDAP支持K​​erberos VGSS API SASL 身份验证机制称为GSSAPI机制。除了Cyrus SASL库，此功能还需要[Heimdal](http://www.pdc.kth.se/heimdal/)或[MIT Kerberos V](http://web.mit.edu/kerberos/www/)库。强烈建议使用强大的身份验证服务，例如Kerberos提供的服务。

4. 数据库软件
OpenLDAP的slapd的MDB主数据库后端使用LMDBOpenLDAP源附带的软件。无需下载任何其他软件即可获得MDB支持。操作系统可能在基本系统中或作为可选软件组件提供了受支持的Berkeley DB版本,如果没有，则必须自己获取并安装

5. 线程数
OpenLDAP支持POSIX pthreads，Mach CThreads和其它的线程。如果找不到合适的线程子系统，请查阅[OpenLDAP FAQ](http://www.openldap.org/faq/)的 Software | Installation | Platform Hints部分。

6. TCP包装器
如果预先安装，slapd支持TCP包装器（IP级别访问控制过滤器）。对于包含非公共信息的服务器，建议使用TCP包装程序或其他IP级别的访问过滤器（例如IP级别的防火墙提供的过滤器）。


[更多OpenLDAP依赖包信息](http://www.openldap.org/doc/admin24/appendix-recommended-versions.html)