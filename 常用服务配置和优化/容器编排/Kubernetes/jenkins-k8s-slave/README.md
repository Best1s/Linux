Jenkins时间和centos时间相差八小时解决方法
系统设置 -> 脚本命令行 -> 点击执行一下命令
System.setProperty('org.apache.commons.jelly.tags.fmt.timeZone', 'Asia/Shanghai')