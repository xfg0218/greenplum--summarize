# 软件说明

| 序号 | 软件名字 | 说明 | 最新版本下载地址 |
|:----:|:----:|:----:|:----:|
|  1 | TPC-H-impala | imapa + kudu 案例参考 | https://github.com/kj-ki/tpc-h-impala |

# 使用Impala + kudu 做查询

```
-- 使用Impala + kudu 做查询思路如下
(1) 先使用impala-shell创建8张外部表和8张kudu表
(2) 并使用insert into tablename select * from XXXX 转化成kudu表中数据
(3) 然后再使用impala-shell做查询

-- 修改文件textfile_to_impala.hive下的文件

1、把tpch_impala下的textfile_to_impala.hive修改一下内容，修改成kudu的master的信息，如果有多个master建议都填上
kudu.master_addresses' = 'sdw18:7051,sdw19:7051'

2、对impala+kudu做查询测试
$ nohup ./tpch_benchmark_impala.sh >> tpch_benchmark_impala.log &

```








