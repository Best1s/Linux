#!/bin/bash
echo "根据访问IP统计UV"

echo `awk '{print $1}'  access.log|sort | uniq -c |wc -l`

echo `统计访问URL统计PV`

echo `awk '{print $7}' access.log|wc -l`

echo "查询访问最频繁的URL"

echo `awk '{print $7}' access.log|sort | uniq -c |sort -n -k 1 -r|more`

echo "查询访问最频繁的IP"

echo `awk '{print $1}' access.log|sort | uniq -c |sort -n -k 1 -r|more`

echo "根据时间段统计查看日志"

echo `cat  access_log| sed -n '/8\/Mar\/2017:21/,/10\/Mar\/2017:22/p'|more|wc -l`

echo "统计访问量前10的ip"

echo `awk '{a[$1]++}END{for (j in a) print a[j],j}' /var/log/nginx/access.log|sort -nr|head -10`


sed -n '/12\/Jul\/2019:08/,/12\/Jul\/2019:08:43/p' test.log |wc
1.根据访问IP统计UV
awk '{print $1}' access_iqueendress.com.log|sort | uniq -c |wc -l
awk '{print $1}' access_m.iqueendress.com.log|sort | uniq -c |wc -l
awk '{print $1}' access*.log|sort | uniq -c |wc -l

1.根据访问IP统计UV
awk '{print $1}' access.log|sort | uniq -c |wc -l

2.统计访问URL统计PV
awk '{print $7}' access.log|wc -l

3.查询访问最频繁的URL
awk '{print $7}' access.log|sort | uniq -c |sort -n -k 1 -r|more

4.查询访问最频繁的IP
awk '{print $1}' access.log|sort | uniq -c |sort -n -k 1 -r|more

5.根据时间段统计查看日志
cat access.log| sed -n '/14\/Mar\/2015:21/,/14\/Mar\/2015:22/p'|more


netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'

awk 高级应用
计算第一列值
awk '{if ($1 > xxx) print $1;else print "xxx"}' 
awk -F: 'BEGIN{i=0}{if($3<500){i++}}END{print i}' /etc/passwd

if 双分支语句
awk -F: 'BEGIN{i=0;j=0}{if($3<=500){i++}else{j++}}END{print i,j}' /etc/passwd
循环

awk 'i=1 {} BEGIN {while (i<3) {++i;print i}}' test.txt
awk 'BEGIN {do {++i;print i} while (i<3)}' test.txt 

awk 'BEGIN {for (i=1;i<3;i++) print i}' test.txt
awk 'BEGIN {for (i=3;i>1;i--) print i}' test.txt
* While 和 For 循环语句使用的 awk 均使用 BEGIN 模式，
BEGIN 和 END，BEGIN 被放置在没有读取任何数据之前，而 END 被放置在所有的数据读取完成以后执行
即在未读取文档内容前就会将 BEGIN 代码执行完毕，所以输入文档可以是任意文档。

体现如下：
BEGIN{}: 读入第一行文本之前执行的语句，一般用来初始化操作
{}: 逐行处理
END{}: 处理完最后以行文本后执行，一般用来处理输出结果

awk '{sum +=$1};END {print sum}‘






sort
参　　数：
  -b   忽略每行前面开始出的空格字符。
  -c   检查文件是否已经按照顺序排序。
  -d   排序时，处理英文字母、数字及空格字符外，忽略其他的字符。
  -f   排序时，将小写字母视为大写字母。
  -i   排序时，除了040至176之间的ASCII字符外，忽略其他的字符。
  -m   将几个排序好的文件进行合并。
  -M   将前面3个字母依照月份的缩写进行排序。
  -n   依照数值的大小排序。
  -o<输出文件>   将排序后的结果存入指定的文件。
  -r   以相反的顺序来排序。
  -t<分隔字符>   指定排序时所用的栏位分隔字符。
  -k  选择以哪个区间进行排序
  +<起始栏位>-<结束栏位>   以指定的栏位来排序，范围由起始栏位到结束栏位的前一栏位。
  --help   显示帮助。
  --version   显示版本信息

   