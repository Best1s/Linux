sysctl指令可在内核运行时动态地修改内核的运行参数
1. 常见用法
- 列出所有的变量并查看
```
sysctl -a
```

- 修改某变量的值
sysctl -w 变量名=变量值
```
sysctl -w vm.max_map_count=262144
```

- 读一个指定的变量，例如 kernel.msgmnb：
```
sysctl kernel.msgmnb 
kern.maxproc: 65536
```

- 要设置一个指定的变量，直接用 variable=value 这样的语法：
```
sysctl kernel.msgmnb=1024
kernel.msgmnb: 1024
```
- 可以使用sysctl修改系统变量，也可以通过编辑sysctl.conf文件来修改系统变量
sysctl 变量的设置通常是字符串、数字或者布尔型。 (布尔型用 1 来表示'yes'，用 0 来表示'no')。
```
#配置文件位置
/run/sysctl.d/*.conf
/etc/sysctl.d/*.conf
/usr/local/lib/sysctl.d/*.conf
/usr/lib/sysctl.d/*.conf
/lib/sysctl.d/*.conf
/etc/sysctl.conf
```
linux内核参数注释
https://www.cnblogs.com/bodhitree/p/5756719.html