jenkins pipeline *需要依赖 python  jq mvn java  Generic Webhook Trigger  jenkins  library dingding@ https://github.com/Best1s/jenkinsLibrary
Generic Webhook Trigger
```
source_branch  $.object_attributes.source_branch
action $.object_attributes.action
http_url $.project.http_url
user_name $.user_name
git_commit  $.checkout_sha
ref  $.ref
target_branch $.object_attributes.target_branch
comMsg $.object_attributes.title
project $.project.name
```

pipeline
```
@Library('jenkinsLibrary') _     
def tool = new org.devops.tools()
pipeline {
    agent any    
    stages {
        stage('Clean Workspace') {
            steps {
					deleteDir()  // clean up current work directory
			}
        }
        stage('git_check_out') {
            steps { 
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '$ref']],
                        doGenerateSubmoduleConfigurations: false,
                        userRemoteConfigs: [[credentialsId: 'xxx', url: '$http_url']]])                
            }
        }
        stage('sonaqube_scan') {
            steps {
                sh "export"
                sh "echo 'start scan--' "
                //sh "mvn clean package -DskipTests sonar:sonar -Dsonar.projectName=${project} -Dsonar.projectKey=${project} -Dsonar.branch.name=${ref} -Dsonar.host.url=http://x.x.x.x:9000 -Dsonar.login=xxx"
                sh "mvn clean package -DskipTests sonar:sonar -Dsonar.projectKey=${project} -Dsonar.branch.name=${ref} -Dsonar.login=xxx"
            }
        }
        stage('get_sonaqube_scan_status') {
            steps {
                script { // ceTaskId  dashboardUrl  ceTaskUrl
                    sh label: '', script: '''export header='Authorization: Basic YWRtaW46YWRtaW4xMjM='
                    export analysis_url='http://x.x.x.x:9000/api/qualitygates/project_status?analysisId='
                    export `grep x.x.x.x target/sonar/report-task.txt`  
                    echo "$dashboardUrl" > dashboardUrl
                    sleep 15
                    for i in `seq 8`
                    do
                        sleep 5
                        date
                        curl -s  --header "${header}" "${ceTaskUrl}" |python -m json.tool > sonar_task.log
                        grep -q analysisId sonar_task.log && break || continue
                    done
                    export analysisId=`cat sonar_task.log | jq '.task.analysisId'|tr -d '"' `
                    cat sonar_task.log
                    echo -n $analysisId > analysisId
                    curl -s  --header "${header}" "$analysis_url${analysisId}" |jq '.projectStatus.status'|grep OK &&  echo -n 0 > project_status ||  echo -n 1 > project_status
                    '''
                    dashboard_url = readFile 'dashboardUrl'
                    project_status = readFile 'project_status'
                    analysisId = readFile 'analysisId'
                    echo "project_status is $project_status"
                    if ( project_status == "1" && analysisId != "null" ){
                        echo "扫描不通过. dingidng send $dashboard_url"
                        dingtalk (
                            robot: 'x.x.x.x',
                            type: "MARKDOWN",
                            title: "",
                            text: [
                                project + " 项目代码扫描不通过 -分支：" + ref ,
                                "- [点击查看扫描结果](" + dashboard_url + ")"
    
                            ],
                            at: [
                                tool.get_user(user_name)
                                //tool.get_user("1")
                            ]
                        )
                    } else {
                        echo " 不发送dingding  $dashboard_url $project_status"
                    }
                }
            }
        }
    }
    post{
        success {
               
            script{
                currentBuild.description += "\n $user_name 构建成功 $ref"
            }
        }
        unstable {
    		echo "post condition executed: unstable ... $user_name $ref"
    	}
    	unsuccessful {
    	    
            script{
                currentBuild.description += "\n $user_name 构建失败！$ref"
            }
    	}
    	cleanup {
    		echo "post condition executed: cleanup ... $user_name $ref "
    	}
    }
}

```
