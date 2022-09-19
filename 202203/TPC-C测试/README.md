# 软件下载



# TPC-C 是什么
TPC-C是由TPC(Transaction Processing Performance Council，事务处理性能委员会)提供的专门针对联机交易处理系统的规范，TPC-C模拟的是一个大型的商品批发销售公司交易负载。这个事务负载主要由9张表组成，主要涉及5类交易类型：新订单生成（New-Order）、订单支付（Payment）、发货（Delivery）、订单状态查询（Order-Status）、和库存状态查询（Stock-Level）。TPC-C测试使用吞吐量指标（Transaction per minute，简称tpmC)来衡量系统的性能，其中所统计的事务指的是新订单生成的事务，即以每分钟新订单生成的事务数来衡量系统的性能指标（在标准的TPC-C测试中，新订单的事务数量占总事务数的45%左右）。


# TPC-C参数设置
参数 | 参数值 | 说明 | 参数设置方式
-- | -- | -- | --
optimizer | off | 关闭针对AP场景的orca优化器，对TP性能更友好。 | gpconfig -c optimizer -v off
shared_buffers | 8GB | 将数据共享缓存调大。修改该参数需要重启实例。 | gpconfig -c shared_buffers -v 8GB
wal_buffers | 256MB | 将WAL日志缓存调大。修改该参数需要重启实例。 | gpconfig -c wal_buffers -v 256MB
log_statement | none | 将日志输出关闭。 | gpconfig -c log_statement -v none
random_page_cost | 10 | 将随机访问代价开销调小，有利于查询走索引。 | gpconfig -c random_page_cost -v 10
gp_resqueue_priority | off | 将resource queue关闭。需要重启实例 | gpconfig -c gp_resqueue_priority -v off
resource_scheduler | off | 将resource queue关闭。需要重启实例 | gpconfig -c resource_scheduler -v off
gp_enable_global_deadlock_detector | on | 控制是否开启全局死锁检测功能，打开它才可以支持并发更新/删除操作； | gpconfig -c gp_enable_global_deadlock_detector -v on
checkpoint_segments | 2 | 影响checkpoint主动刷盘的频率，针对OLTP大量更新类语句适当调小此设置会增加刷盘频率，平均性能会有较明显提升； | gpconfig -c checkpoint_segments -v 2 –skipvalidation


# 测试环境准备

## 使用已编辑好的benchmarksql工具



## 编译benchmarksql工具

### benchmarksql 工具介绍
工具 | 安装说明
-- | --
benchmarksql | 软件说明：https://github.com/dreamedcheng/benchmarksql-5.0?spm=a2c4e.10696291.0.0.605719a4TUrbqS&file=benchmarksql-5.0

### 在线编译benchmarksql
```
软件安装步骤：
 git clone https://github.com/dreamedcheng/benchmarksql-5.0.git
 yum install ant
 cd benchmarksql-5.0
 ant
```


# 创建gpadmin用户
```
CREATE USER gpadmin WITH ENCRYPTED PASSWORD 'gpadmin';
CREATE DATABASE gpadmin OWNER gpadmin;
```

# 生成的测试数据的总量
表名 | 数据量（行数）
-- | --
bmsql_warehouse | 1000
bmsql_district | 10000
bmsql_customer | 30000000
bmsql_history | 30000000
bmsql_new_order | 9000000
bmsql_oorder | 30000000
bmsql_order_line | 299976737
bmsql_item | 100000
bmsql_stock | 100000000


#  生成测试数据

## 修改配置文件
```
cd benchmarksql-5.0/run
vim gpdb.properties

-- 修改以下内容
db=postgres                                      // 使用默认的postgres
driver=org.postgresql.Driver                     // 使用默认的org.postgresql.Drive
conn=jdbc:postgresql://localhost:5432/tpcc    //实例连接地址
user=gpadmin                                // 连接实例的测试用户
password=gpadmin                           // 对应用户的密码

warehouses=1000                                  // 指定生成数据集warehouse的数量
loadWorkers=16                                   // 指定生成数据的线程数量，如果CPU core和内存够用可以调大，这样速度更快
fileLocation=/home/gpadmin/tpcc100                    // 指定生成数据的存储目录


```

## 生成测试数据
```
[gpadmin@sdw1 run]$ ./runLoader.sh gpdb.properties
Starting BenchmarkSQL LoadData

driver=org.postgresql.Driver
conn=jdbc:postgresql://localhost:5432/postgres
user=gpadmin
password=***********
warehouses=1000
loadWorkers=8
fileLocation=/home/mxadmin/tpcc100
csvNullValue (not defined - using default '')

Worker 000: Loading ITEM
Worker 001: Loading Warehouse      1

```

## 创建表结构
```

psql  -U gpadmin -d postgres -h localhost -p 5432 -f sql.common/tableCreates.sql

```


## 加载数据
```
time psql -h localhost -d tpcc -p 5432 -U gpadmin -c "copy bmsql_config from '$FILEPATH/config.csv' with delimiter ',' null '';"
time psql -h localhost -d tpcc -p 5432 -U gpadmin -c "copy bmsql_customer from '$FILEPATH/customer.csv' with delimiter ',' null '';"
time psql -h localhost -d tpcc -p 5432 -U gpadmin -c "copy bmsql_district from '$FILEPATH/district.csv' with delimiter ',' null '';"
time psql -h localhost -d tpcc -p 5432 -U gpadmin -c "copy bmsql_history from '$FILEPATH/cust-hist.csv' with delimiter ',' null '';"
time psql -h localhost -d tpcc -p 5432 -U gpadmin -c "copy bmsql_item from '$FILEPATH/item.csv' with delimiter ',' null '';"
time psql -h localhost -d tpcc -p 5432 -U gpadmin -c "copy bmsql_new_order from '$FILEPATH/new-order.csv' with delimiter ',' null '';"
time psql -h localhost -d tpcc -p 5432 -U gpadmin -c "copy bmsql_oorder from '$FILEPATH/order.csv' with delimiter ',' null '';"
time psql -h localhost -d tpcc -p 5432 -U gpadmin -c "copy bmsql_order_line from '$FILEPATH/order-line.csv' with delimiter ',' null '';"
time psql -h localhost -d tpcc -p 5432 -U gpadmin -c "copy bmsql_stock from '$FILEPATH/stock.csv' with delimiter ',' null '';"
time psql -h localhost -d tpcc -p 5432 -U gpadmin -c "copy bmsql_warehouse from '$FILEPATH/warehouse.csv' with delimiter ',' null '';"

```

##  创建索引
```

psql  -U mxadmin -d postgres -h localhost -p 5432 -f sql.common/indexCreates.sql

ALTER TABLE
ALTER TABLE
ALTER TABLE
CREATE INDEX
ALTER TABLE
CREATE INDEX
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE


```

## 执行vacuum和analyze
```
vacuum bmsql_warehouse;
vacuum bmsql_district;
vacuum bmsql_customer;
vacuum bmsql_history;
vacuum bmsql_new_order;
vacuum bmsql_oorder;
vacuum bmsql_order_line;
vacuum bmsql_item;
vacuum bmsql_stock;

analyze bmsql_warehouse;
analyze bmsql_district;
analyze bmsql_customer;
analyze bmsql_history;
analyze bmsql_new_order;
analyze bmsql_oorder;
analyze bmsql_order_line;
analyze bmsql_item;
analyze bmsql_stock;

```

##  进行测试
``` 
$ ./runBenchmark.sh gpdb.properties

```


