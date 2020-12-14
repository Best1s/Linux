jenkins 需要安装的插件 DingTalk, Managed file, Assign Roles, git parameter, build description, Generic Webhook,Color ANSI Console Output

```
Git Parameter:
NAME: BRANCH
Parameter Type: Branch

Extended Choice Parameter: 
NAME: build_module
Basic Parameter Types: Check Boxes
Delimiter: 
Value: -pl xxx,-pl xxxx,-am
Default Value: -am

Provide Configuration files:
deploy-java-template.yaml
java-Dockerfile

Generic Webhook Trigger:
BRANCH	$.ref
user_name	$.user_name
comMsg	$.commits[0].message
webhook Cause: $user_name committed to $BRANCH  comMsg: $comMsg

Build: clean $build_module package  -DskipTests

Build description: $user_name committed to $BRANCH  comMsg: $comMsg
```