一、安装方式我们选用的是docker安装的方式。

1、安装sonarqube
```

docker run -d --name sonarqube   \
-p 9000:9000 \
--link sonarqube_postgres  \
-e "SONARQUBE_JDBC_USERNAME=sonar" \
-e "SONARQUBE_JDBC_PASSWORD=sonar" \
-e "SONARQUBE_JDBC_URL=jdbc:postgresql://sonarqube_postgres:5432/sonar"  \
-v /home/sonarqube/conf:/opt/sonarqube/conf  \
-v /home/sonarqube/data:/opt/sonarqube/data  \
-v /home/sonarqube/logs:/opt/sonarqube/logs  \
-v /home/sonarqube/extensions:/opt/sonarqube/extensions sonarqube
```
2、因为安装sonarqube的版本是最新版的，所以不支持mysql，只能安装postgresql数据库。
```
docker run --name sonarqube_postgres \
-e POSTGRES_USER=sonar \
-e POSTGRES_PASSWORD=sonar \
-v /home/postgresql/data:/var/lib/postgresql/data  \
-d postgres
```
安装完成后一般会有报ES的错误，需要调整VMA(虚拟内存区域)的数量。

sysctl -w vm.max_map_count=262144


3、配置 gitlab和sonarqube的集成交互，添加 gitlab 地址, Applivation ID, Secret

4、jenkins和sonarqube的集成交互。安装插件sonarqube scanner 。 添加 sonarqube的token 凭证,全局中设置 sonarqube servers地址。

5、jenkins 项目中添加
```
sonar.projectKey=$JOB_NAME
sonar.projectName=$JOB_NAME
sonar.projectVersion=1.0

sonar.language=xxxx
sonar.sourceEncoding=UTF-8

sonar.sources=$WORKSPACE
sonar.java.binaries=$WORKSPACE

```
