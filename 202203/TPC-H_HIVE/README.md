

# 软件说明

| 序号 | 软件名字 | 说明 | 最新版本下载地址 |
|:----:|:----:|:----:|:----:|
|  1 | TPC-H_Tools_v3.0.0 | tpch_tools是生成数据的工具,需要先运行该工具 |  https://www.tpc.org/tpc_documents_current_versions/current_specifications5.asp |
|  2 | TPC-H_on_Hive | 该工具已修改成包含hive的textfile/orc/parquet数据格式的工具，默认只支持textfile格式测试| https://issues.apache.org/jira/secure/attachment/12416615/TPC-H_on_Hive_2009-08-14.tar.gz |
|  3 | TPC-H-impala | imapa + kudu 案例参考 | https://github.com/kj-ki/tpc-h-impala |


# TPC-H_Tools_v3.0.0 使用

## 编译生成dbgen工具

```
-- 下载后进入后dbgen数据目录

$ cd TPC-H_Tools_v3.0.0/dbgen


-- 对文件进行修改,主要修改
-- CC      =gcc
-- DATABASE= HIVE
-- DATABASE= HIVE
-- WORKLOAD = TPCH


$ cp makefile.suite makefile
$ vim makefile

################
## CHANGE NAME OF ANSI COMPILER HERE
################
CC      =gcc
# Current values for DATABASE are: INFORMIX, DB2, TDAT (Teradata)
#                                  SQLSERVER, SYBASE, ORACLE, VECTORWISE
# Current values for MACHINE are:  ATT, DOS, HP, IBM, ICL, MVS,
#                                  SGI, SUN, U2200, VMS, LINUX, WIN32
# Current values for WORKLOAD are:  TPCH
DATABASE= HIVE
MACHINE = LINUX
WORKLOAD = TPCH
#
CFLAGS  = -g -DDBNAME=\"dss\" -D$(MACHINE) -D$(DATABASE) -D$(WORKLOAD) -DRNG_TEST -D_FILE_OFFSET_BITS=64
LDFLAGS = -O
# The OBJ,EXE and LIB macros will need to be changed for compilation under
#  Windows NT
OBJ     = .o
EXE     =
LIBS    = -lm


$ cp tpcd.h tpcd.h--back
$ vim   tpcd.h

-- 在文件中添加一下内容
#ifdef  HIVE
#define GEN_QUERY_PLAN  "explain;"
#define START_TRAN      "start transaction;\n"
#define END_TRAN        "commit;\n"
#define SET_OUTPUT      ""
#define SET_ROWCOUNT    "limit %d;\m"
#define SET_DBASE       "use %s;\n"
#endif


-- 进行编译生成dbgen文件，在编译时如果提示没有gcc则进行安装yum  install -y gcc
$ make


```

## 使用dbgen生成数据
```
-- 编译完之后会看到该目录下有一个dbgen文件，并查看使用帮助
./dbgen --help
./dbgen: invalid option -- '-'
ERROR: option '-' unknown.
TPC-H Population Generator (Version 3.0.0 build 0)
Copyright Transaction Processing Performance Council 1994 - 2010
USAGE:
dbgen [-{vf}][-T {pcsoPSOL}]
        [-s <scale>][-C <procs>][-S <step>]
dbgen [-v] [-O m] [-s <scale>] [-U <updates>]

Basic Options
===========================
-C <n> -- separate data set into <n> chunks (requires -S, default: 1)
-f     -- force. Overwrite existing files
-h     -- display this message
-q     -- enable QUIET mode
-s <n> -- set Scale Factor (SF) to  <n> (default: 1)
-S <n> -- build the <n>th step of the data/update set (used with -C or -U)
-U <n> -- generate <n> update sets
-v     -- enable VERBOSE mode

Advanced Options
===========================
-b <s> -- load distributions for <s> (default: dists.dss)
-d <n> -- split deletes between <n> files (requires -U)
-i <n> -- split inserts between <n> files (requires -U)
-T c   -- generate cutomers ONLY
-T l   -- generate nation/region ONLY
-T L   -- generate lineitem ONLY
-T n   -- generate nation ONLY
-T o   -- generate orders/lineitem ONLY
-T O   -- generate orders ONLY
-T p   -- generate parts/partsupp ONLY
-T P   -- generate parts ONLY
-T r   -- generate region ONLY
-T s   -- generate suppliers ONLY
-T S   -- generate partsupp ONLY

To generate the SF=1 (1GB), validation database population, use:
        dbgen -vf -s 1

To generate updates for a SF=1 (1GB), use:
        dbgen -v -U 1 -s 1





-- 1024 代表生成1024GB大小的数据，8个数据文件会在当前的目录下,在生成数据文件时注意当前磁盘的空间

$ ./dbgen -s 1024

-- 查看生成的数据文件,创建一个文件夹并把以下文件进行已到创建的文件夹下
$ du -sh *.tbl
24G        customer.tbl
777G        lineitem.tbl
4.0K        nation.tbl
173G        orders.tbl
118G        partsupp.tbl
24G        part.tbl
4.0K        region.tbl
1.4G        supplier.tbl

```


# TPC-H_on_Hive 上传数据文件到HDFS上和测试hive的TPCH


## 设置Hadoop和Hive的环境变量
```

-- 设置的该用户的权限必须有hdfs的创建目录和查询的权限，例如以下是以hive用户创建

$ su - hive
$ vim /home/hive/.bash_profile

export HADOOP_HOME=/usr/hdp/current/hadoop-client
export  HIVE_HOME=/usr/hdp/current/hive-client

PATH=$PATH:$HOME/.local/bin:$HOME/bin:$HADOOP_HOME/bin:$HIVE_HOME/bin
export PATH


# source /home/hive/.bash_profile


```

## 修改文件把生成的数据文件上传到HDFS上
```

$ cd TPC-H_on_Hive/data
$ vim tpch_prepare_data.sh



-- 修改成使用dbgen生成的8个*.tbl文件的路径，例如export FILE_PATH=/TPC-H_Tools_v3.0.0/dbgen

export FILE_PATH=/TPC-H_Tools_v3.0.0/dbgen

************


-- 把8个*.tbl文件上传到HDFS上
$ nohup ./tpch_prepare_data.sh >> tpch_prepare_data.log &




-- 上传之后的文件的大小，1.1T是源文件的大小,3.3T 是hadoop的3副本大小
$ hadoop fs -du -s -h /tpch
1.1 T  3.3 T  /tpch


$ hadoop fs -ls /tpch
Found 8 items
drwxr-xr-x   - hive hive          0 2022-05-08 18:18 /tpch/customer
drwxr-xr-x   - hive hive          0 2022-05-08 18:51 /tpch/lineitem
drwxr-xr-x   - hive hive          0 2022-05-08 18:51 /tpch/nation
drwxr-xr-x   - hive hive          0 2022-05-08 18:59 /tpch/orders
drwxr-xr-x   - hive hive          0 2022-05-08 19:00 /tpch/part
drwxr-xr-x   - hive hive          0 2022-05-08 19:05 /tpch/partsupp
drwxr-xr-x   - hive hive          0 2022-05-08 19:05 /tpch/region
drwxr-xr-x   - hive hive          0 2022-05-08 19:05 /tpch/supplier


```


## 对Hive进行textfile数据格式的测试
```
-- 修改benchmark.conf 文件,把NUM_OF_TRIALS=6 修改成NUM_OF_TRIALS=1,该参数是循环点的次数
$ vim  benchmark.conf 
NUM_OF_TRIALS=1



-- 修改 tpch_benchmark.sh 文件中的source benchmark.conf; 修改成source ./benchmark.conf;即可

$ vim  tpch_benchmark.sh
# TEXTFILE FRAMART
source ./benchmark.conf;

*******


-- 对Hive进行textfile数据格式的测试
$ nohup ./tpch_benchmark.sh >> tpch_benchmark.log &


-- 当前正在运行的日志在benchmark.log,运行完在logs下会有一个benchmark.log.2022-05-07-08:30的日志,
-- 过滤该文件中的Time:关键字查看执行时间，一行数据代表一个Query的耗时

$ cat benchmark.log.2022-05-07-08:30|grep "Time:"
Time:828.75
Time:132.43
Time:1920.8
Time:2544.56
Time:1972.58
Time:515.38
Time:5053.183
Time:2016.2
Time:3047.84
Time:1679.5
Time:226.12
Time:1749.04
Time:852.39
Time:573.96
Time:1047.79
Time:592.49
Time:6994.56
Time:4195.88
Time:500.28
Time:2733.27
Time:19046.48
Time:1375.2


```


## 对Hive进行orc数据格式的测试
```
-- hive对orc的测试思路如下
（1）先创建8个外部表，例如part_textfile，再创建8张内部表，例如part，再把外部表的数据inset into 到内部表
（2）详细步骤可参考，tpch_orc/textfile_to_orc.hive 文件
（3）如果想测试单个query的耗时，确保当前query的内部表存在即可


-- 对Hive进行orc数据格式的测试
$ nohup ./tpch_benchmark_orc.sh >> tpch_benchmark_orc.log &


```



## 对Hive进行parquet数据格式的测试
```

-- hive对orc的测试思路如下
（1）先创建8个外部表，例如part_textfile，再创建8张内部表，例如part，再把外部表的数据inset into 到内部表
（2）详细步骤可参考，tpch_parquet/textfile_to_parquet.hive 文件
（3）如果想测试单个query的耗时，确保当前query的内部表存在即可


-- 对Hive进行orc数据格式的测试
$ nohup ./tpch_benchmark_parquet.sh >> tpch_benchmark_parquet.log &


```


## 使用Impala + kudu 做查询
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








