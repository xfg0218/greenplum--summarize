# 软件下载

https://github.com/xfg0218/greenplum--summarize/blob/master/document/file/TPCB.tar.gz


# TPC-B 是什么

TPC-B是由TPC(Transaction Processing Performance Council，事务处理性能委员会)提供的benchmark，主要用于衡量一个系统每秒能够处理的并发事务数。TPC-B不像TPC-C那样模拟了现实生活中一个具体的交易场景，其中的事务都是由简单SQL构成的没有语义的事务（事务中混杂了大表与小表的插入、更新与查询操作），而且每个client的请求间也不会像TPC-C那样会有一个human think time的间隔时间，而是一旦前一个事务执行完成，立马会有下一个事务请求发出。因此，TPC-B经常用于对数据库系统的事务性能压测。TPC-B性能的衡量指标是每秒处理的事务数量，即TPS（Transactions per Second）。


# TPC-B参数设置

参数设置参考官网介绍
https://gp-docs-cn.github.io/docs/ref_guide/config_params/guc-list.html

```
-- 进程可以使用的内存量,根据实际情况修改
gpconfig -c gp_vmem_protect_limit -v 300 -m 160

-- 最大的连接数
gpconfig -c max_connections -v 500 -m 110

-- 根据实际情况修改
gpconfig -c shared_buffers -v 2GB

-- 内存相关
gpconfig -c work_mem -v 2048MB     
gpconfig -c statement_mem -v 32MB  

-- WAL的大小
gpconfig -c max_wal_size -v 32GB

-- 是否开启并行
gpconfig -c enable_parallel_mode -v off

-- 关闭optimizer优化器
gpconfig -c optimizer -v off

-- 控制是否开启全局死锁检测功能，打开它才可以支持并发更新/删除操作；           
gpconfig -c gp_enable_global_deadlock_detector -v on

-- 关闭日志，减少IO
gpconfig -c log_statement -v none

--   关闭自动收集统计信息 
gpconfig -c gp_autostats_mode -v none

-- 指定全局死锁检测器后台工作进程的执行间隔（秒）
gpconfig -c gp_global_deadlock_detector_period -v 5

-- 不记录任何的事务  
gpconfig -c log_transaction_sample_rate -v 0  

-- 索引成本估计的参数
gpconfig -c effective_cache_size -v 24GB

-- 数据库的维护操作
gpconfig -c maintenance_work_mem -v 2GB

--  checkpoint的间隔
gpconfig -c checkpoint_completion_target -v 0.9

-- 将随机访问代价开销调小，有利于查询走索引。
gpconfig -c random_page_cost -v 1.1

-- 设置较高的值，降低CPU的开销
gpconfig -c effective_io_concurrency -v 200

--  将resource queue关闭，需要重启实例
gpconfig -c gp_resqueue_priority -v off

-- 影响checkpoint主动刷盘的频率，针对OLTP大量更新类语句适当调小此设置会增加刷盘频率，平均性能会有较明显提升；
gpconfig -c checkpoint_segments -v 2 –skipvalidation

--  将resource queue关闭。需要重启实例 
gpconfig -c resource_scheduler -v off


gpconfig -c synchronous_commit -v off 


-- 修改表的填充比例因子
alter table pgbench_accounts set (fillfactor=70);
alter table pgbench_branches set (fillfactor=70);
alter table pgbench_history set (fillfactor=70);
alter table pgbench_tellers set (fillfactor=70);

-- unlogged table不记录wal日志，IO开销小，写入速度快，备库无数据，只有结构，批量计算的中间结果，频繁变更的会话数据，当数据库crash后，
-- 数据库重启时自动清空unlogged table的数据。其中写性能unlogged table > 普通表(异步事务) > 普通表(同步事务)
alter table pgbench_accounts set unlogged;
alter table pgbench_branches set unlogged;
alter table pgbench_history set unlogged;
alter table pgbench_tellers set unlogged;

```

# TPC-B安装


## 解压软件
```
$ tar -zxvf TPCB.tar.gz

```

## 查看使用介绍
```
cat  run_tpcb.sh

## 设置生成数据量的大小,单位是10万,2000是2亿条
SCALE_FACTOR=2000

## 测试的数据库名字
DB_NAME=tpcb

## 这个值和cpu个数相关,一般设置为和CPU个数相同即可.
JOB=96

## 测试时长,单位秒
RUN_TIME=120

## 日志输出频率为多少秒打印一次
PRINT_FREQUENCY=20

## 测试并发量
conn_arr=( 100 200 )

# 执行TPCB后台运行测试
nohup ./run_tpcb.sh >nohup.out 2>&1 &

# 查看测试结果
cat ./log/crud_res.log
cat ./log/select_res.log
cat ./log/insert_res.log
cat ./log/update_res.log

```

## 查看测试结果
```
以下结果在虚拟机中的结果。

$ cat crud_res.log

scale: 20 ,client: 10, tps: 1682.086858
scale: 20 ,client: 20, tps: 1902.737941

$ cat select_res.log

scale: 20 ,client: 10, tps: 25114.119212
scale: 20 ,client: 20, tps: 30032.283585

$ cat update_res.log

scale: 20 ,client: 10, tps: 6816.132827
scale: 20 ,client: 20, tps: 8509.653922

$ cat insert_res.log

scale: 20 ,client: 10, tps: 8418.500023
scale: 20 ,client: 20, tps: 10190.844608
```



