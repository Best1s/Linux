
playbook由一个或多个'plays'组成 内容以'plays'元素的列表
play内容被称为tasks 即任务， 一个任务是对一个ansible模块的调用

playbooks使用yaml语法格式:
- 在单一的playbook文件中，可以连续三个连子号(---)区分多个play。还有选择性的连续三个点好(...)用来表示play的结尾，也可省略。
- 一个完整的代码块功能需要最少元素包括 name: task
- 缩进必须统一，不能空格和tab混用。

组成：
- Target section:     要执行Playbook主机名或组
- Variable section:	运行是的变量
- Task section:		远程主机上执行的任务列表
- section:	定义task执行完成后需要调用的任务

其对应目录层：
- hosts
- vars
- tasks
- handlers

playbooks核心元素为：
- Tasks:
- Variable:
- Templates；
- Handler:
- Roles:


Playboosk框架与格式
```
inventory/				##Server详细清单目录
	testenv				#具体清单与变量声明文件
roles/					#roles任务列表
	testbox/			#testbox详细任务
		tasks/			
			main.yml	#testbox主任务文件
deploy.yml				Playbook任务入口文件
```

###Playbook 运行方式
通过ansible-playbook命令运行
格式：ansible-playbook <filename.yml> ... [options]
```
[root@ansible PlayBook]# ansible-playbook -h
#ansible-playbook常用选项：
--check  or -C    #只检测可能会发生的改变，但不真正执行操作
--list-hosts      #列出运行任务的主机
--list-tags       #列出playbook文件中定义所有的tags
--list-tasks      #列出playbook文件中定义的所以任务集
--limit           #主机列表 只针对主机列表中的某个主机或者某个组执行
-f                #指定并发数，默认为5个
-t                #指定tags运行，运行某一个或者多个tags。（前提playbook中有定义tags）
-v                #显示过程  -vv  -vvv更详细
```

**[ansible文档](http://www.ansible.com.cn/docs/playbooks_intro.html#about-playbooks)*