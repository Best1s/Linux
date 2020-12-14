jsonPath http://www.atoolbox.net/Tool.php?Id=792

```
Generic Webhook Trigger：
source_branch	$.object_attributes.source_branch
action	$.object_attributes.action
http_url	$.project.http_url
user_name	$.user_name
git_commit	$.checkout_sha
ref	$.ref
$username	$.user.username
eventType	$.event_name
comMsg	$.commits[0].message
object_kind	$.object_kind
project	$.project.name
Cause: $user_name  $eventType to $project $ref  comMsg : $comMsg
Expression:	^push_.*(?<!rc|gray|master)$
Text: $object_kind_$ref

```
Pipeline
```
pipeline {
    //agent { label 'master' }
    agent { label 'jenkins-slave_1' }
    stages {
        stage('git_check_out') {
            steps { 
                    echo "pull $ref"
                    sh "[ $ref ] || export ref=$source_branch"
                    echo "pull $ref"
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '$ref']],
                        doGenerateSubmoduleConfigurations: false,
                        userRemoteConfigs: [[credentialsId: 'xxxx', url: '$http_url']]])
                
            }
        }
        stage('deploy_provider-api') {
            steps {
                sh "git show $git_commit --stat | grep -q '^ provider-api' && cd $WORKSPACE/provider-api && mvn deploy  || echo 'no provider-api update.'"
            }
        }
        stage('deploy_mq') {
            steps {
                sh "git show $git_commit --stat | grep -q '^ mq' && cd $WORKSPACE/mq && mvn deploy || echo 'no mq update.'"
            }
        }
        stage('Clean Workspace') {
            steps {
                sh("ls -al ${env.WORKSPACE}")
					deleteDir()  // clean up current work directory
					sh("ls -al ${env.WORKSPACE}")
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
                currentBuild.description += "\n $user_name 构建失败！$ref  "
            }
    	}
    	cleanup {
    		echo "post condition executed: cleanup ... $user_name $ref"
    	}
    }
}

```

 ^(approved)_(gray|master)
 $action_$target_branch