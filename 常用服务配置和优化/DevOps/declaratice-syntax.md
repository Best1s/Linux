### 脚本式流水线
优点：
- 更少的代码段落和弱规范要求
- 更强大的程序代码能力
- 更像编写代码程序
- 传统的流水线即代码模型，用户熟悉并向后兼容
- 更灵活的自定义代码操作
- 能够构建更复杂的工作流和流水线

缺点：
- 普遍要求更高的编程水平
- 语法检查受限于 Groovy 语言及环境
- 和传统 Jenkins 模型有很大差异
- 与声明式流水线的实现相比，同一工作流会更复杂

```
//脚本式流水线  更像是一种脚本或者编程语言
node（'worker_node1'） {
	stage('Source') {
		git 'git@xxx:/xxxx/xxx.git'
	}
	stage('Compile') {
		sh "xxxx compile test"
	}
}
```

### 声明式流水线
优点：
- 更结构化，贴近传统的 Jenkins Web 表单形式
- 更强大的声明内容能力，高可读性
- 可以通过 Blue Ocean 图形化界面自动生成
- 段落可映射到常见的 Jenkins 概念
- 更友好的语法检查和错误识别
- 提升流水线间的一致性

缺点：
- 对迭代逻辑支持较弱
- 仍在开发完善中
- 更严格的结构
- 对于复杂的流水线和工作流难以胜任

```
//声明式语法 Jenkins的传统实现方式
pipeline {
	agent {label 'worker_node1'}
	stages {
		stage('Source') {
			steps {
				git 'git@xxx:/xxxx/xxx.git'
			}
		}
		stage('Compile') {
			steps {
				sh "xxxx compile test"
			}
		}
	}
}
```
### 语法选择


