###Gitlab主要构成
- nginx
- Gitlab-workhorse轻量级的反向代理服务器
- Gitlab-shell 用于处理Git命令和修改authorized keys列表
- Logrotate
- Postgresql 数据库
- redis

###Gitlab的工作流程
- 创建并克隆项目
- 创建项目某Feature分支
- 编写代码并提交到改分支
- 推送该项目分支到远程Gitlab服务器
- 进行代码检查并提交Master主分支合并申请
- 审查代码并确定合并申请

###Gitlab安装和配置 
** 以下仅供参考需要有基础
*
官方文档：https://about.gitlab.com/install/
安装依赖，Postfix(邮件)，添加GitLab软件包存储库，安装GitLab包
```
yum install -y curl policycoreutils-python openssh-server
yum install postfix #用第三方可以不安装亲测
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh |  bash
systemctl start postfix 
EXTERNAL_URL="https://gitlab.example.com" #也可以后面修改文件
yum install -y gitlab-ce


```
*如果出现postfix报错[ fatal: parameter inet_interfaces: no local interface found for ::1 ]
```
vi /etc/postfix/main.cf
inet_interfaces = localhost 修改成
inet_interfaces = all
```
*gitlab-ee:Enterprise Edition 

*gitlab-ce : Community Edition  社区版

gitlab配置文件 /etc/gitlab/gitlab.rb
###gitlab邮箱配置 我这里使用的是 smtp.163.com
官方文档 https://docs.gitlab.com/omnibus/settings/smtp.html#example-configurations
```
###! Docs: https://docs.gitlab.com/omnibus/settings/smtp.html
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.163.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "xxxuser@163.com"
gitlab_rails['smtp_password'] = "password"
gitlab_rails['smtp_domain'] = "163.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = true
gitlab_rails['gitlab_email_from'] = 'xxxuser@163.com'
gitlab_rails['smtp_openssl_verify_mode'] = 'none'
```
配置好文件后 gitlab-ctl reconfigure 打开域名配置gitlab

gitlab-rails console 进入控制台测试邮件
```
Notify.test_email("xxxuser@163.com","subject","This is a test mail").deliver_now
```
###gitlab 常用命令

```

gitlab-ctl start 		   		#启动全部服务
gitlab-ctl restart 		 		#重启全部服务
gitlab-ctl stop 					#停止全部服务
gitlab-ctl restart nginx 		   #重启单个服务
gitlab-ctl status 				  #查看全部组件的状态
gitlab-ctl show-config 			 #验证配置文件
gitlab-ctl uninstall 			   #删除gitlab(保留数据）
gitlab-ctl cleanse 				 #删除所有数据，重新开始
gitlab-ctl tail <svc_name>  	    #查看服务的日志
gitlab-rails console production 	#进入控制台,可以修改root 的密码
```
