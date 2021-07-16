需要 [Parameterized Trigger plugin](https://plugins.jenkins.io/parameterized-trigger)

GitLab webhook 触发需要添加

```bash
> dingding_env
[ "${gitlabUserName}" ] && echo user="${gitlabUserName}" >> dingding_env || echo user="$(git --no-pager show -s --format='%an')" >> dingding_env
[ "$comMsg" ] && echo comMsg="$comMsg" >> dingding_env || echo comMsg="$(git --no-pager show -s --format='%s')" >> dingding_env
echo BRANCH="${gitlabBranch}" >> dingding_env
echo job="${JOB_NAME}" >> dingding_env
echo commitid="${gitlabMergeRequestLastCommit}" >> dingding_env
echo url="${JOB_URL}" >> dingding_env
echo num="${BUILD_NUMBER}" >> dingding_env
##DEF VAR##
```

Generic Webhook Trigger 触发需要添加

```bash
> dingding_env
[ "$user_name" ] && echo user="$user_name" >> dingding_env || echo user="$(git --no-pager show -s --format='%an')" >> dingding_env
[ "$comMsg" ] && echo comMsg="$comMsg" >> dingding_env || echo comMsg="$(git --no-pager show -s --format='%s')" >> dingding_env
echo BRANCH="${BRANCH}" >> dingding_env
echo job="${JOB_NAME}" >> dingding_env
echo commitid="${GIT_COMMIT}" >> dingding_env
echo url="${JOB_URL}" >> dingding_env
echo num="${BUILD_NUMBER}" >> dingding_env
##DEF VAR##
```

构建后操作添加 Trigger parameterized build on other projects  触发 failBuildDingDingAt

Add Paramethes 添加  Parameters from properties file        dingding_env

failBuildDingDingAt  项目 

This project is parameterized 添加

```
user 1
job 
BRANCH
commitid 1
url JOB_URL
num BUILD_NUMBER
comMsg
```



pipeline

```groovy
#!groovy
@Library('jenkinsLibrary') _     
def tool = new org.devops.tools()

pipeline {
    agent { node {  label "master" }}
    stages {
        stage('text'){
            steps {
                echo job + " 构建失败" + " - " + BRANCH + " - " + commitid + " - user:" + user
                }
            post {
                success {
                    dingtalk (
                        robot: 'cda6b232-c92b-435b-8c71-6bf2ec165596',
                        type: "MARKDOWN",
                        title: "",
                        text: [
                             job + " 项目构建失败 - ",
                            "分支：" + BRANCH,
                            "- CommitID: " + commitid ,
                            "# 更新摘要： ",
                            comMsg,
                            "- [构建日志传送门](" + url + "/" + num + "/console)"

                        ],
                        at: [
                            tool.get_user(user)
                        ]
                    )
                }
            }
        }
    }
}
```

