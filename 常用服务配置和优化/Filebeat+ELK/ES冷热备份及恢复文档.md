Elasticsearch要解决的是海量数据的存储和检索问题，海量的数据就意味需要大量的存储空间，如果都使用SSD固态硬盘成本将成为一个很大的问题，这也是制约许多企业和个人使用Elasticsearch的因素之一。为了解决这个问题，Elasticsearch冷热分离架构应运而生。

冷热分离 腾讯云的 Elasticsearch文档（https://cloud.tencent.com/document/product/845/41176）
存储配置，资源，分片等评估。 (https://cloud.tencent.com/document/product/845/19551)


原理：elasticsearch 节点配置 node.attr.temperature 标签，指定节点区分热冷，即用户如何对冷热数据进行标识，并将冷数据移动到冷节点，热数据移动到热节点。
```
eg:
node.attr.temperature: cold
or
node.attr.temperature: hot
```
指定数据的冷热属性，来设置和调整数据分布.冷热分离方案中数据冷热分布的基本单位是索引，即指定某个索引为热索引，另一个索引为冷索引。
通过索引的分布来实现控制数据分布的目的。
```
用户可以在创建索引，或后续的任意时刻设置这些配置来控制索引在不同标签节点上的分配动作。

index.routing.allocation.include.{attribute} 表示索引可以分配在包含多个值中其中一个的节点上。
index.routing.allocation.require.{attribute} 表示索引要分配在包含索引指定值的节点上（通常一般设置一个值）。
index.routing.allocation.exclude.{attribute} 表示索引只能分配在不包含所有指定值的节点上。
```



配置 logstash 模版
```
  "routing": {
    "allocation": {
      "require": {
        "temperature": "hot"
      }
    }
  },
```
配置索引声明周期并关联 logstash