#需要安装npm 插件

#npm cache verify  #清除缓存
npm config set registry https://registry.npm.taobao.org 
npm get registry
npm install   
npm run build:test

# build images
commit=${GIT_COMMIT:0:8}
branch=${GIT_BRANCH:7}
tag=$branch-$commit

export tag=$(date +%m%d-%H.%M.%m-$tag)
export port=80
export repNum=1
export appName=front
templateName=front-template.yaml
export hubAddress=127.0.0.1/front/$appName
export nameSpace=fromt
templatesPath=/home/jenkins/$templateName


#realm name
export realmName="xxx.xxx.com"
export uri=\$uri

#envsubst < /home/jenkins/front-project-templates/nginx.conf > $WORKSPACE/nginx.conf
sed "s/\${realmName}/${realmName}/g"  /home/jenkins/front-project-templates/nginx.conf  > $WORKSPACE/nginx.conf
cp -f /home/jenkins/front-project-templates/Dockerfile $WORKSPACE

#buildImagePath=$WORKSPACE

#cd $buildImagePath
echo "--------------------begin build docker images!---------------------------------"
docker build -t $hubAddress:$tag -f $WORKSPACE/Dockerfile .
echo "--------------------begin push docker images!----------------------------------"
docker push $hubAddress:$tag

#
echo "--------------------begin deploy k8s!----------------------------------"

envsubst < $templatesPath > /tmp/rollback/$appName$tag.yaml
echo "deploy k8s file is $appName$tag.yaml"
kubectl apply -f /tmp/rollback/$appName$tag.yaml  && echo "deploy k8s SUCCESSFUL!"