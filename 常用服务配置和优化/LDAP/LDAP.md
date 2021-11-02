OpenLDAP 手册http://www.openldap.org/doc/admin24/quickstart.html
OpenLDAP 安装http://www.openldap.org/doc/admin24/install.html

部署：

```bash
docker run --detach  --name openldap \
   --network ldap-network  \
   --env LDAP_ADMIN_USERNAME=admin \
   --env LDAP_ADMIN_PASSWORD=admin \
   --env LDAP_CONFIG_ADMIN_PASSWORD=admin \
   --env LDAP_CONFIG_ADMIN_PASSWORD=admin \
   --env LDAP_USERS=test \
   --env LDAP_PASSWORDS=test \
   --env LDAP_GROUP=test \
   --env LDAP_ROOT='dc=xxxx,dc=com' \
   -v /data/openldap:/bitnami/openldap \
   -p 1389:1389 \
   -p 1636:1636 \
   bitnami/openldap:latest
```



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

ldap

```
DN: distinguished name
    DC (Domain Component)
    CN (Common Name)
    OU (Organizational Unit)
    O (Organization Name) (可选项)
String X.500 AttributeType

CN      commonName
L       localityName
ST      stateOrProvinceName
O       organizationName
OU      organizationalUnitName
C       countryName
STREET  streetAddress
DC      domainComponent
UID     userid

DC 是最高的  DC 下一级就会有一个 OU，OU 可以理解为一个组织单元, OU 下面是 CN ，可以理解是 CN 就是一个具体的实例
要定位一个实例，那么路径就是 CN - OU - DC
可能会有多个 OU，多个 DC，但是最后都会定位到最高一级的 DC 这长串字符串放到一起，就是 DN
```

objectClass  : LDAP对象类，是LDAP内置的数据模型。每种objectClass有自己的数据结构
可分为以下3类：

- 结构型（Structural）：如person和organizationUnit；
- 辅助型（Auxiliary）：如extensibeObject；
- 抽象型（Abstract）：如top，抽象型的objectClass不能直接使用。

常用的objectClass的名称。

```
account
alias
dcobject
domain
ipHost
organization
organizationalRole
organizationalUnit
person
organizationalPerson
inetOrgPerson
residentialPerson
posixAccount
posixGroup
```

Entry  (LDAP中的entry只有DN是由LDAP Server来保证唯一的)

- entry可以被称为条目，一个entry就是一条记录，是LDAP中一个基本的存储单元；也可以被看作是一个DN和一组属性的集合。注意，一条entry可以包含多个objectClass，例如zhang3可以存在于“电话薄”中，也可以同时存在于“同学录”中。

LDAP Search filter

- 使用filter对LDAP进行搜索。 Filter一般由 (attribute=value) 这样的单元组成，比如：(&(uid=ZHANGSAN)(objectclass=person)) 表示搜索用户中，uid为ZHANGSAN的LDAP Entry．

Base DN

- 一条Base DN可以是“dc=163,dc=com”，也可以是“dc=People,dc=163,dc=com”。执行LDAP Search时一般要指定basedn，由于LDAP是树状数据结构，指定basedn后，搜索将从BaseDN开始，我们可以指定Search Scope为：只搜索basedn（base），basedn直接下级（one level），和basedn全部下级（sub tree level）。

```
migrationtools工具  /usr/share/migrationtools/

ldapsearch -x -H ldap://x.x.x.x:1389 -b dc=xxxx,dc=com -D 'cn=admin,dc=xxxx,dc=com' -W
ldapadd -x -H ldap://x.x.x.x:1389 -f rootDNchange.ldif  -D 'cn=admin,dc=xxxx,dc=com' -W

容器内 /opt/bitnami/openldap/etc/schema 
for i in $(ls *.ldif);do   ldapadd -Y EXTERNAL -H ldapi:/// -f $i;done


```

ldap管理工具 ldapAdmin


