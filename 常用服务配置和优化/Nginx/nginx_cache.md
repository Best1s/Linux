nginx 实现动态/静态文件缓存

nginx 缓存指令

proxy_cache_path
```
作用：设置缓存数据的相关信息

Syntax:     proxy_cache_path path [levels=levels] [use_temp_path=on|off] keys_zone=name:size [inactive=time] [max_size=size] [manager_files=number] [manager_sleep=time] [manager_threshold=time] [loader_files=number] [loader_sleep=time] [loader_threshold=time] [purger=on|off] [purger_files=number] [purger_sleep=time] [purger_threshold=time];
Default:     —
Context:     http

值：
    path：缓存目录的位置
    levels：指定使用几级缓存目录
    keys_zone：指定缓存区域的名称和缓存空间的大小

例子：
    proxy_cache_path /data/nginx/cache levels=1:4 keys_zone=mycache:10m;
说明
    1：表示一级目录可以由1个字符来构成
    4：表示二级目录可以由4个字符来构成
    mycache：是这个缓存区域的名称
    10m：可以缓存10M大小的数据

缓存结果
    /data/nginx/cache/c/29ad/b7f54b2df7773722d382f4809d65029c

说明
    /data/nginx/cache/：这里是缓存目录
    c：因为一级目录可以由1个字符构成，所有这里随机出现一个c
    29ad：二级目录由4个随机字符构成
    b7f54b2df7773722d382f4809d65029c：缓存的数据
```

proxy_cache
```
作用：调用缓存

    Syntax:     proxy_cache zone | off;
    Default:     proxy_cache off;
    Context:     http, server, location
    注意：      该指令写在不同的位置，缓存数据对象也不同
```

proxy_cache_min_uses
```
作用：指定一个文件至少需要被用户访问多少次以后，才会被缓存，默认1

    Syntax:     proxy_cache_min_uses number;
    Default:     proxy_cache_min_uses 1;
    Context:     http, server, location
```
proxy_cache_purge
```
Syntax:     proxy_cache_purge string ...;
    Default:     —
    Context:     http, server, location

    使用场景：上游服务器中的资源发生了更改，但是缓存中的数据尚未过去，这个时候就需要手动执行purge让缓存中的数据过去
    使用举例：
        http {
            proxy_cache_path /data/nginx/cache levels=1:4 keys_zone=mycache:10m;
            server {
                listen 10.220.5.196:80;
                location / {
                    proxy_pass http://10.220.5.180:80:
                    proxy_cache mycache;
                    ....
                    ....
                }

                location = /cleanCache {
                    allow=
                    deny=
                    proxy_cache_purge mycache;  #这里需要指定上面定义的缓存名称
                    ...
                    ...
                    ...
                }
            }
        }
```
proxy_cache_valid
```
作用：定义缓存数据的有效期

    Syntax:     proxy_cache_valid [code ...] time;
    Default:     —
    Context:     http, server, location

    例子：
        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 301      1h;
        proxy_cache_valid any      1m;
```
proxy_cache_key
```
作用：指定缓存的key的名称

    Syntax:     proxy_cache_key string;
    Default:     proxy_cache_key $scheme$proxy_host$request_uri;
    Context:     http, server, location

    例子：
        proxy_cache_key "$host$request_uri $cookie_user";
        proxy_cache_key "$uri"
```
expires
```
添加    Cache-Control、Expires头

Syntax:    expires [modified]  time；

           expires epoch|max|off；

Default:   expires off；                 # 静态缓存

Context:   http，server，location，if in location
```


静态缓存配置
```
location ~ .*\.(gif|jpg|png|htm|html|css|js|flv|ico|swf)$ {
		expires 30m;
       }
```
效果
```
Cache-Control: max-age=1800
Content-Encoding: gzip
Content-Type: application/javascript
Date: Wed, 21 Oct 2019 09:23:16 GMT
ETag: W/"5f8ec162-69cb"
Expires: Wed, 21 Oct 2019 09:53:16 GMT
Last-Modified: Tue, 20 Oct 2019 10:52:18 GMT
Server: nginx
Vary: Accept-Encoding
X-Frame-Options: SAMEORIGIN
```
动态缓存配置
	
```
#http 中添加
proxy_cache_path  /tmp/cache levels=1:2   keys_zone=cache_one:200m inactive=1d max_size=5g;
add_header cachestatus $upstream_cache_status;   #添加本条可以在浏览器中看到是否命中缓存

       location / {
            proxy_pass http://xxxx:80;
            proxy_cache cache_one;
            proxy_cache_valid  200 15s;
    }
```











