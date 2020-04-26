1，	部署java环境。https://www.java.com/en/download/manual.jsp
	https://www.oracle.com/technetwork/java/javase/downloads/index.html
/etc/profile     或者使用的用户下的.bash_profile	
export JAVA_HOME=/usr/local/server/java/jdk1.8.0_221
export PATH=$PATH:$JAVA_HOME/bin 
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
	
2，	部署tomcat。https://tomcat.apache.org/download-80.cgi  或者 GlassFish
	

3，	下载Jenkins。https://jenkins.io/zh/doc/pipeline/tour/getting-started/	#download  Generic Java package(.war)

启动方式
1）把war包放入tomcat的webapps 目录 执行tomcat/bin/startup.sh  可以同时监控下logs/catalina.out

2）不用tomcat  直接启动  java -jar jenkins.war --httpPort=8080

#### docker启动
docker 中运行
```
docker run \
-u root \
-itd \
-p 80:8080 \
-p 50000:50000 \
-v /var/jenkins_home/:/var/jenkins_home \
-v /var/run/docker.sock:/var/run/docker.sock \
--name jenkins-master \
--restart=always \
jenkinsci/blueocean
```


https://jenkins.io/zh/doc/book/installing/



配置Jenkins。访问ip:80


jenkins yum 安装配置文件 /etc/sysconfig/jenkins



jenkins 语言控制插件 Locale plugin  Localization






