#!/bin/bash

# 需要部署的模块
declare -A modules
modules=([xxxprovider]=18701 [xxxxconsumer]=18702 [xxxtask]=18703)
export repNum=1
expandvar='""'


branch=`echo ${GIT_BRANCH} |awk -F/ '{print $NF}'`
#分支环境变量
if [ $branch == "dev" ];then    
	export consul_ip="127.0.0.1"
    export consul_port="8500"
    export logPath="dev-log"
elif [ $branch == "test" ];then 
	export consul_ip="127.0.0.2"
    export consul_port="8500"
    export logPath="test-log"
else
	echo "\033[31m 没有${branch}分支部署环境 \033[0m"
	exit 1
fi

## -----------------------------------------------------------------------------------------------------------------------------------------
export active=$branch
templatesPath=$WORKSPACE/deploy-java-template.yaml
commit=${GIT_COMMIT:0:8}
export tag=$(date +%m%d-%H.%M.%m-$branch-$commit)
export nameSpace=java-$branch
export instance_id="\$instance_id"

> $WORKSPACE/buildModule.log
[ -d /tmp/build_log/$JOB_NAME ] || mkdir -p /tmp/build_log/$JOB_NAME
echo -e "$(date +"%Y-%m-%d %H:%M")\t${branch}:${commit} $comMsg" >> /tmp/build_log/$JOB_NAME/$JOB_NAME.log

jarPaths=($(ls */target/*.jar))
for module in ${!modules[*]}
do
	{
        if [[ "${jarPaths[@]}" =~ "$module" ]]; then
                for jar in ${jarPaths[*]}
                do
                     echo $jar | grep -v api | grep -q $module
                     if [ $? == 0 ];then
                        modulePath=$WORKSPACE/$(echo $jar | awk -F'/' '{print $1"/"$2}')
                        jarname=$(echo $jar | awk -F'/' '{print $NF}')
                        export port=${modules[$module]}
                        export appName=$JOB_NAME-$module
                        export hubAddress=127.0.0.1/java-$branch/$appName
                        cd $modulePath
                        cp $WORKSPACE/java-Dockerfile $modulePath/Dockerfile
                        echo -e "\033[32m--------------------begin build ${appName} images---------------------------------\033[0m"
                        echo "docker build --build-arg jarname=$jarname --build-arg expandvar=$expandvar -t $hubAddress:$tag ." | bash || echo "build ${appName} images faile!" >> $WORKSPACE/buildModule.log
                        echo "--------------------begin push ${appName} images!----------------------------------"
                        docker push $hubAddress:$tag  || echo "push ${appName} images faile!" >> $WORKSPACE/buildModule.log
                        echo -e "\033[32m--------------------begin deploy ${appName} on k8s!----------------------------------\033[0m"
                        #envsubst < $templatesPath > $modulePath/$appName$tag.yaml
                        envsubst < $templatesPath > /tmp/rollback/$appName$tag.yaml
                        echo -e "deploy k8s file is \033[33m /tmp/rollback/$appName$tag.yaml \033[0m "
                        kubectl apply -f /tmp/rollback/$appName$tag.yaml  && echo -e " \033[32m ${appName} deploy k8s SUCCESSFUL! \033[0m"
                        echo "$module" >> $WORKSPACE/buildModule.log
                     fi
                done
        fi
	} &
done
wait
echo -e "\033[32m --$branch consul_ip is: $consul_ip:$consul_port \033[0m"
echo -e " build module is \033[32m $(cat $WORKSPACE/buildModule.log) \033[0m"
grep -q "faile" $WORKSPACE/buildModule.log && cat $WORKSPACE/buildModule.log && exit 1 || echo 0
