 文档： [容器服务 Pod 一直处于 Terminating 状态 - 故障处理 - 文档中心 ](https://cloud.tencent.com/document/product/457/43238)



FailedSync 状态处理 ： 

1、docker升级为 19版本  



2、临时手动删除 kubectl delete pods --force --grace-period=0   bug：[【Pod Terminating原因追踪系列之二】exec连接未关闭导致的事件阻塞 -(tencent.com)](https://cloud.tencent.com/developer/article/1680613)



3、关闭 PodDisruptionBudget  该 Kind 对 tsf平台 pod 应用无效， 当 pod 为 Terminating 时，应用会被注册中心屏蔽，添加 PodDisruptionBudget Kind 后，当 pod 被驱逐时候虽然 Pod 没有立即结束，但是会被标记成 Terminating 