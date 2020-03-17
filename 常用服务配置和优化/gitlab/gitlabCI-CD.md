GitLab-CI/CD就是一套配合GitLab使用的持续集成系统,GitLab8.0以后的版本是默认集成了GitLab-CI/CD并且默认启用的。
GitLab-Runner是配合GitLab-CI/CD进行使用的,在装有Runner的机器上用来执行软件集成脚本。
yum 安装
```
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | bash
yum install gitlab-runner
```
####注册Runner
进入gitlab设置页面找到Overview->Runners
装有Runner的机器上执行 gitlab-runner register
填入url  和 Token  其它选项看需求
```
[root@game-test ~]# gitlab-runner register 
Running in system-mode.                            
                                                   
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
https://xxx.com/
Please enter the gitlab-ci token for this runner:
7XKyskrxxxxzUZJdW
Please enter the gitlab-ci description for this runner:
[game-test]: citest   
Please enter the gitlab-ci tags for this runner (comma separated):

Whether to lock the Runner to current project [true/false]:
[true]: false
Registering runner... succeeded                     runner=7XKxxry
Please enter the executor: shell, docker+machine, parallels, docker-ssh, ssh, virtualbox, docker-ssh+machine, kubernetes, docker:
shell
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded! 

```
####执行
添加[.gitlab-ci.yml](https://github.com/Best1s/Linux/blob/master/%E5%B8%B8%E7%94%A8%E6%9C%8D%E5%8A%A1%E9%85%8D%E7%BD%AE%E5%92%8C%E4%BC%98%E5%8C%96/gitlab/gitlab-ci语法.md)到存储库的根目录

在对存储库进行任何推送时，GitLab都会查找该.gitlab-ci.yml文件，并根据该文件的内容在Runners上启动作业。
####验证文件
如果要验证.gitlab-ci.yml文件是否有效，在/ci/lint项目名称空间页面下方有一个Lint工具。


**更改runner运行用户*
通过指令ps aux|grep gitlab-runner可以看到：
```
/usr/bin/gitlab-runner run --working-directory /home/gitlab-runner --config /etc/gitlab-runner/config.toml --service gitlab-runner --syslog --user gitlab-runner
```
重新指定用户执行
```
gitlab-runner uninstall
gitlab-runner install --working-directory /home/gitlab-runner --user www
gitlab-runner restart
```
再次查看进程
```
/usr/bin/gitlab-runner run --working-directory /home/gitlab-runner --config /etc/gitlab-runner/config.toml --service gitlab-runner --syslog --user www
```