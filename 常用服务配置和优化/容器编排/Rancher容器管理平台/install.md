###单节点部署
	docker run -d --restart=unless-stopped -p 8080:8080 rancher/server
### 复杂物理环境，进行大规模生产时需要集群部署
Rancher服务端的集群部署模式，也是通过最前端的负载均衡器实现高可用，
在SLB上挂载多个Rancher服务端节点，同时数据持久化落到MYSQL上

	docker run -d --restart=unless-stopped -p 8080:8080 -p 9345:9345 rancher/server \
	--db-host myhost.example.com --db-port 3306 --db-user username --db-pass password --dbname cattle \
	--advertise-address <IP_of_hte_Node>

 	#<IP_of_hte_Node>唯一，该IP 为高可用集群设置中的IP，如果修改了-p 8080:8080并在host上
	 暴露了一个不一样的端口，则需要添加 --advertise-http-port<host_port> 参数	