# 软件下载

https://github.com/xfg0218/greenplum--summarize/blob/master/document/file/TPC-H.tar.gz


# TPCH 是什么

TPC-H（商业智能计算测试） 是美国交易处理效能委员会(TPC,Transaction Processing Performance Council) 组织制定的用来模拟决策支持类应用的一个测试集.目前,在学术界和工业界普遍采用它来评价决策支持技术方面应用的性能. 这种商业测试可以全方位评测系统的整体商业计算综合能力，对厂商的要求更高，同时也具有普遍的商业实用意义，

TPC-H查询包含8张数据表、22条复杂的SQL查询，大多数查询包含若干表Join、子查询和Group-by聚合等。

# TPCH 8张表的含义
| 序号 | 表名 | 表名含义 |
|:----:|:----:|:----:|
| 1 | part | 零部件信息 |
| 2 | supplier | 供货商信息 |
| 3 | partsupp | 供货商零件的信息 |
| 4 | customer | 消费者的信息 |
| 5 | orders | 订单信息 |
| 6 | lineitem | 在线商品信息 |
| 7 | nation | 国家信息 |
| 8 | region | 地区信息 |


# TPCH表关系图
![images](https://github.com/xfg0218/greenplum--summarize/blob/master/images/matrixdb-images/tpch.png)


# TPCH 的22条SQL解释

| 序号 | query | query定义 | query含义 | query特点 |
|:----:|:----:|:----:|:----:|:----:|
| 1 | Q1  | 价格统计报告查询 |  Q1语句是查询lineItems的一个定价总结报告。在单个表lineitem上查询某个时间段内，对已经付款的、已经运送的等各类商品进行统计，包括业务量的计费、发货、折扣、税、平均价格等信息。 | 带有分组、排序、聚集操作并存的单表查询操作。这个查询会导致表上的数据有95%到97%行被读取到。 | 
| 2 | Q2 | 最小代价供货商查询 | Q2语句查询获得最小代价的供货商。得到给定的区域内，对于指定的零件（某一类型和大小的零件），哪个供应者能以最低的价格供应它，就可以选择哪个供应者来订货。 | Q2语句的特点是：带有排序、聚集操作、子查询并存的多表查询操作。查询语句没有从语法上限制返回多少条元组，但是TPC-H标准规定，查询结果只返回前100行|
| 3 | Q3 | 运送优先级查询 | Q3语句查询得到收入在前10位的尚未运送的订单。在指定的日期之前还没有运送的订单中具有最大收入的订单的运送优先级和潜在的收入 | Q3语句的特点是：带有分组、排序、聚集操作并存的三表查询操作。查询语句没有从语法上限制返回多少条元组，但是TPC-H标准规定，查询结果只返回前10行 | 
| 4 | Q4 | 订单优先级查询 | Q4语句查询得到订单优先级统计值。计算给定的某三个月的订单的数量，在每个订单中至少有一行由顾客在它的提交日期之后收到。 | Q4语句的特点是：带有分组、排序、聚集操作、子查询并存的单表查询操作。子查询是相关子查询。 | 
| 5 | Q5 | 某地区供货商为公司带来的收入查询 | Q5语句查询得到通过某个地区零件供货商而获得的收入统计信息。可用于决定在给定的区域是否需要建立一个当地分配中心。 | Q5语句的特点是：带有分组、排序、聚集操作、子查询并存的多表连接查询操作。 | 
| 6 | Q6 | 预测收入变化查询 | Q6语句查询得到某一年中通过变换折扣带来的增量收入。 | Q6语句的特点是：带有聚集操作的单表查询操作。查询语句使用了BETWEEN-AND操作符，有的数据库可以对BETWEEN-AND进行优化。 | 
| 7 | Q7 | 货运盈利情况查询 | Q7语句是查询从供货商国家与销售商品的国家之间通过销售获利情况的查询。此查询确定在两国之间货运商品的量用以帮助重新谈判货运合同。 | Q7语句的特点是：带有分组、排序、聚集、子查询操作并存的多表查询操作。子查询的父层查询不存在其他查询对象，是格式相对简单的子查询。 | 
| 8 | Q8 | 国家市场份额查询 | Q8语句是查询在过去的两年中一个给定零件类型在某国某地区市场份额的变化情况。 |  Q8语句的特点是：带有分组、排序、聚集、子查询操作并存的查询操作。子查询的父层查询不存在其他查询对象，是格式相对简单的子查询，但子查询自身是多表连接的查询。 | 
| 9 | Q9 | 产品类型利润估量查询 | Q9语句是查询每个国家每一年所有被定购的零件在一年中的总利润。 | Q9语句的特点是：带有分组、排序、聚集、子查询操作并存的查询操作。子查询的父层查询不存在其他查询对象，是格式相对简单的子查询，但子查询自身是多表连接的查询。子查询中使用了LIKE操作符，有的查询优化器不支持对LIKE操作符进行优化。 | 
| 10 | Q10| 货运存在问题的查询 | Q10语句是查询每个国家在某时刻起的三个月内货运存在问题的客户和造成的损失。 | Q10语句的特点是：带有分组、排序、聚集操作并存的多表连接查询操作。查询语句没有从语法上限制返回多少条元组，但是TPC-H标准规定，查询结果只返回前10行 | 
| 11 | Q11 | 库存价值查询 | Q11语句是查询库存中某个国家供应的零件的价值。 | Q11语句的特点是：带有分组、排序、聚集、子查询操作并存的多表连接查询操作。子查询位于分组操作的HAVING条件中。 | 
| 12 | Q12 | 货运模式和订单优先级查询 | Q12语句查询获得货运模式和订单优先级。 | Q12语句的特点是：带有分组、排序、聚集操作并存的两表连接查询操作 | 
| 13 | Q13 | 消费者订单数量查询 | Q13语句查询获得消费者的订单数量，包括过去和现在都没有订单记录的消费者。 |  Q13语句的特点是：带有分组、排序、聚集、子查询、左外连接操作并存的查询操作。| 
| 14 | Q14 | 促销效果查询 |  Q14语句查询获得某一个月的收入中有多大的百分比是来自促销零件。 | Q14语句的特点是：带有分组、排序、聚集、子查询、左外连接操作并存的查询操作。 | 
| 15 | Q15 | 头等供货商查询 | Q15语句查询获得某段时间内为总收入贡献最多的供货商（排名第一）的信息。可用以决定对哪些头等供货商给予奖励、给予更多订单、给予特别认证、给予鼓舞等激励。 | Q15语句的特点是：带有分排序、聚集、聚集子查询操作并存的普通表与视图的连接操作。| 
| 16 | Q16| 零件/供货商关系查询 | Q16语句查询获得能够以指定的贡献条件供应零件的供货商数量。可用于决定在订单量大，任务紧急时，是否有充足的供货商 | Q16语句的特点是：带有分组、排序、聚集、去重、NOT IN子查询操作并存的两表连接操作。 | 
| 17 | Q17 | 小订单收入查询 | Q17语句查询获得比平均供货量的百分之二十还低的小批量订单。 |  Q17语句的特点是：带有聚集、聚集子查询操作并存的两表连接操作。| 
| 18 | Q18| 大订单顾客查询 | Q18语句查询获得比指定供货量大的供货商信息。 | Q18语句的特点是：带有分组、排序、聚集、IN子查询操作并存的三表连接操作。 | 
| 19 | Q19 | 折扣收入查询 | Q19语句查询得到对一些空运或人工运输零件三个不同种类的所有订单的总折扣收入。零件的选择考虑特定品牌、包装和尺寸范围。 | Q19语句的特点是：带有分组、排序、聚集、IN子查询操作并存的三表连接操作。 | 
| 20 | Q20| 供货商竞争力查询 | Q20语句查询确定在某一年内，找出指定国家的能对某一零件商品提供更有竞争力价格的供货货。 | Q20语句的特点是：带有排序、聚集、IN子查询、普通子查询操作并存的两表连接操作。 | 
| 21 | Q21 | 不能按时交货供货商查询 | Q21语句查询获得不能及时交货的供货商。 | Q21语句的特点是：带有分组、排序、聚集、EXISTS子查询、NOT EXISTS子查询操作并存的四表连接操作。 | 
| 22 | Q22 | 全球销售机会查询 | Q22语句查询获得消费者可能购买的地理分布。 | Q22语句的特点是：带有分组、排序、聚集、EXISTS子查询、NOT EXISTS子查询操作并存的四表连接操作。 | 


# TPCH安装


## 解压软件
```
$ tar -zxvf TPC-H.tar.gz

```

## 配置TPCH软件

### 配置环境变量
```

-- 编辑配置文件
$ vi tpch_variables.sh 

REPO_URL="https://github.com/ymatrix-data/TPC-H"
# 执行的用户
ADMIN_USER="mxadmin"
# 配置TPCH的路径
INSTALL_DIR="/home/mxadmin/TPC-H-master"
EXPLAIN_ANALYZE="false"
RANDOM_DISTRIBUTION="false"
MULTI_USER_COUNT="1"

#生成数据量的大小，1代表生成1GB的数据量
GEN_DATA_SCALE="1024"   

#单用户模式下，运行SQL迭代次数   
SINGLE_USER_ITERATIONS="1"

#编译gen,保持true即可，这一步骤会生成segment_hosts.txt文件，否则报错找不到这个文件 
RUN_COMPILE_TPCH="true"    

#是否生成数据，true 生成，false 不生成
RUN_GEN_DATA="true"      

#是否执行初始化，再次运行的时候，不需要重新初始化，就置为false  
RUN_INIT="true"

#是否加载ddl            
RUN_DDL="true" 

#是否加载数据            
RUN_LOAD="true"   

#是否执行SQL         
RUN_SQL="false"     

#是否生成报告       
RUN_SINGLE_USER_REPORT="false"  

#是否运行多用户
RUN_MULTI_USER="false"     
RUN_MULTI_USER_REPORT="false"
GREENPLUM_PATH="/usr/local/matrixdb/greenplum_path.sh"
SMALL_STORAGE="" # For region/nation, empty means heap
MEDIUM_STORAGE="with(appendonly=true, orientation=column)" # For customer/part/partsupp/supplier, eg: with(appendonly=true, orientation=column), empty means heap
LARGE_STORAGE="with(appendonly=true, orientation=column,  compresstype=zstd, COMPRESSLEVEL=1)" # For lineitem, eg: with(appendonly=true, orientation=column, compresstype=1z4), empty means heap
OPTIMIZER="off"
GEN_DATA_DIR="/home/mxadmin/TPC-H-master/generated"
EXT_HOST_DATA_DIR="~"



-- 增加执行权限
$ chmod +x tpch_variables.sh

-- 创建数据库
$ createdb mxadmin;


#运行,第一次运行使用root会安装一些需要的软件
$ nohup ./tpch.sh > tpch.log 2>&1 &

```


### 添加主外键约束
```
添加主外键约束

psql -f 04_load/foreignkeys/059.gpdb.foreignkeys.sql 

```

### 对表执行vacuum和analyze

```
vacuum part;
vacuum supplier;
vacuum partsupp;
vacuum customer;
vacuum orders;
vacuum lineitem;
vacuum nation;
vacuum region;

analyze part;
analyze supplier;
analyze partsupp;
analyze customer;
analyze orders;
analyze lineitem;
analyze nation;
analyze region;
```


### 运行查看

```

-- 手工执行一下统计信息收集
psql -d mxadmin -c "vacuum analyse;"

-- 再次修改配置参数，使SQL运行查询并生成查询报告
vi tpch_variables.sh

RUN_COMPILE_TPCH="false"   #编译gen
RUN_GEN_DATA="false"       #运行生成数据
RUN_INIT="false"           #执行初始化，再次运行的时候，不需要重新初始化，就置为false
RUN_DDL="false"            #加载ddl
RUN_LOAD="false"           #加载数据
RUN_SQL="true"             #执行SQL
RUN_SINGLE_USER_REPORT="true"  #是否生成报告
RUN_MULTI_USER="false"     #是否运行多用户
RUN_MULTI_USER_REPORT="false"

-- 再次运行，运行完之后即可查询报告
nohup ./tpch.sh > tpch.log 2>&1 &


```

### 查看运行的结果报告

```
mxadmin=# \dn
    List of schemas
     Name     |  Owner  
--------------+---------
 ext_tpch     | mxadmin
 gp_toolkit   | mxadmin
 public       | mxadmin
 tpch         | mxadmin
 tpch_reports | mxadmin
 tpch_testing | mxadmin
(6 rows)

mxadmin=# set seqrch_path to tpch_reports;

mxadmin=# \dt
                    List of relations
    Schema    |     Name     | Type  |  Owner  | Storage
--------------+--------------+-------+---------+---------
 tpch_reports | compile_tpch | table | mxadmin | heap
 tpch_reports | ddl          | table | mxadmin | heap
 tpch_reports | gen_data     | table | mxadmin | heap
 tpch_reports | init         | table | mxadmin | heap
 tpch_reports | load         | table | mxadmin | heap
 tpch_reports | sql          | table | mxadmin | heap
(6 rows)


-- 查看每个SQL运行的耗时报告
mxadmin=# select * from sql order by id ;
 id  | description | tuples |    duration
-----+-------------+--------+-----------------
 101 | tpch.01     |      4 | 00:02:00.120332
 102 | tpch.02     |    100 | 00:00:57.57254
 103 | tpch.03     |     10 | 00:02:26.146764
 104 | tpch.04     |      5 | 00:01:06.66708
 105 | tpch.05     |      5 | 00:04:24.264684
 106 | tpch.06     |      1 | 00:00:04.4965
 107 | tpch.07     |      4 | 00:01:38.98724
 108 | tpch.08     |      2 | 00:00:58.58781
 109 | tpch.09     |    175 | 00:04:55.295413
 110 | tpch.10     |     20 | 00:01:57.117659
 111 | tpch.11     |      0 | 00:00:17.17446
 112 | tpch.12     |      2 | 00:00:49.49295
 113 | tpch.13     |     29 | 00:00:57.57334
 114 | tpch.14     |      1 | 00:00:07.7818
 115 | tpch.15     |      1 | 00:00:29.29081
 116 | tpch.16     |  27840 | 00:00:25.25266
 117 | tpch.17     |      1 | 00:01:56.116548
 118 | tpch.18     |    100 | 00:08:11.491717
 119 | tpch.19     |      1 | 00:00:28.28176
 120 | tpch.20     | 113661 | 00:00:45.45653
 121 | tpch.21     |    100 | 00:03:57.237783
 122 | tpch.22     |      7 | 00:00:19.19021
(22 rows)


