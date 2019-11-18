# gptransfer命令同步数据(统计群与异集群)
	主要介绍作者使用gptransfer的总结，个人感觉比较66666，分享给大家

# gptransfer目录
	1.gptransfer命令使用
	1.1 gptransfer 介绍
	1.2 gptransfer 命令参数介绍
	1.3 同集群之间同步数据
	1.4 验证数据的准确性
	1.5 使用gptransfer总结
	1.6 不同集群之间同步数据

# 1.1 gptransfer 介绍
	详细请查看官网介绍:
	https://gpdb.docs.pivotal.io/510/utility_guide/admin_utilities/gptransfer.html
	或查看中文文档:
	https://gp-docs-cn.github.io/docs/admin_guide/managing/gptransfer.html
	
# 1.2 gptransfer 命令参数介绍

	gptransfer参数详细介绍请查看:
	https://blog.csdn.net/xfg0218/article/details/90233815
	 
	$ gptransfer --help
	gptransfer
	   { --full |
	   { [-d <database1> [ -d <database2> ... ]] |
	   [-t <db.schema.table> [ -t <db1.schema1.table1> ... ]] |
	   [-f <table-file> [--partition-transfer | --partition-transfer-non-partition-target]]
	   [-T <db.schema.table> [ -T <db1.schema1.table1> ... ]]
	   [-F <table-file> ] } }
	   [--skip-existing | --truncate | --drop]
	   [--analyze] [--validate=<type> ] [-x] [--dry-run]
	   [--schema-only ]
	   [--no-final-count]
	
	   [--source-host=<source_host> [--source-port=<source_port>]
	   [--source-user=<source_user>] ]
	   [--base-port=<base_gpfdist_port>]
	   [--dest-host=<dest_host> --source-map-file=<host_map_file>
	   [--dest-port=<dest_port>] [--dest-user=<dest_user>] ]
	   [--dest-database=<dest_database_name>]
	 
	   [--batch-size=<batch_size>] [--sub-batch-size=<sub_batch_size>]
	   [--timeout <seconds>]
	   [--max-line-length=<length>]
	   [--work-base-dir=<work_dir>] [-l <log_dir>]
	   [--delimiter=<delim> ]
	   [--format=[CSV|TEXT] ]
	   [--quote=<character> ]
	 
	   [-v | --verbose]
	   [-q | --quiet]
	   [--gpfdist-verbose]
	   [--gpfdist-very-verbose]
	   [-a]

# 1.3 同集群之间同步数据
## 1.3.1 查看表的详细信息

	查看表的大小
	select pg_size_pretty(pg_relation_size('dim.xiaoxu_test1'));
	-- 27 GB
	
	查看表的行数
	select count(*) from dim.xiaoxu_test1;
	-- 182683056

## 1.3.2 进行表数据同步
	查看source_host_map_file文件的配置
	$ cat source_host_map_file
	
	gpdev152,192.168.***.**
	gpdev153,192.168.***.**
	gpdev154,192.168.***.**
	gpdev155,192.168.***.**
	 
	查看source_tb_list 文件的配置,如果是多个表请一行一行的追加
	$ cat source_tb_list
	test.dim.test1
	test : 数据库的名字
	dim:schema的名字
	test1:表的名字
	 
	$ gptransfer --source-host=192.168.***.** --source-port=5432 --source-user=gpadmin -f source_tb_list  --source-map-file=source_host_map_file -a --dest-host=192.168.***.** --dest-port=5432 --dest-database=stagging --drop
	 
	 
	20190515:15:21:04:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Starting gptransfer with args: --source-host=192.168.***.** --source-port=5432 --source-user=gpadmin -t test.dim.test1 --source-map-file=source_host_map_file -a --dest-host=192.168.***.** --dest-port=5432 --dest-database=stagging --drop
	20190515:15:21:04:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Validating options...
	20190515:15:21:04:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Retrieving configuration of source Greenplum Database...
	20190515:15:21:05:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Retrieving configuration of destination Greenplum Database...
	20190515:15:21:06:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Retrieving source tables...
	20190515:15:21:06:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Checking for gptransfer schemas...
	20190515:15:21:07:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Retrieving list of destination tables...
	20190515:15:21:07:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Reading source host map file...
	20190515:15:21:07:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Building list of source tables to transfer...
	20190515:15:21:07:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Number of tables to transfer: 1
	20190515:15:21:07:143245 gptransfer:gpdev152:gpadmin-[INFO]:-gptransfer will use "fast" mode for transfer.
	20190515:15:21:07:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Validating source host map...
	20190515:15:21:07:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Validating transfer table set...
	20190515:15:21:07:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Using batch size of 2
	20190515:15:21:07:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Using sub-batch size of 24
	20190515:15:21:07:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Creating work directory '/home/gpadmin/gptransfer_143245'
	20190515:15:21:08:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Creating schema dim in database stagging...
	20190515:15:21:09:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Starting transfer of test.dim.test1 to stagging.dim.test1...
	20190515:15:21:09:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Creating target table stagging.dim.test1...
	20190515:15:21:09:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Retrieving schema for table test.dim.test1...
	20190515:15:21:12:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Transfering data test.dim.test1 -> stagging.dim.test1...
	20190515:15:30:00:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Finished transferring table test.dim.test1, remaining 0 of 1 tables
	20190515:15:30:00:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Running final table row count validation on destination tables...
	20190515:15:30:09:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Validation of stagging.dim.test1 successful
	20190515:15:30:09:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Removing work directories...
	20190515:15:30:10:143245 gptransfer:gpdev152:gpadmin-[INFO]:-Finished.


	在以上的日志可以看出执行的顺序是
	
	先校验参数的正确性
	检验数据源与目标源的数据库配置
	校验源数据库中的表
	检查gptransfer是否存在，如果存在回报gptransfer schema already exists on the source system 警告，在源数据库的schema手动删除掉即可
	检验源数据库集群映射文件
	把原始文件加载到转换器
	统计加载的数据源文件
	在本地磁盘创建转换目录
	在目标数据库中创建schema
	开启数据库员表到目标表的任务
	创建目标表
	开始到数据到目标表中
	统计导到目标表的详细信息
	 
	
	任务是从20190515:15:21:04到20190515:15:30:10用时大概9分钟，大概27G / 9m ≈ 3G/m
	
	大约51.2m/s，速度还可以


## 1.3.3 查看硬件详细信息

	查看master节点的详细信息
	查看master节点的cpu使用率
	查看数据节点一的网卡信息
	查看数据节点一的cpu使用率

## 1.3.4 验证数据的准确性
	查看表的大小
	select pg_size_pretty(pg_relation_size('dim.xiaoxu_test1'));
	-- 27 GB
	 
	查看表的行数
	select count(*) from dim.xiaoxu_test1;
	-- 182683056
	 
	在以上可以看出数据都准确无误

## 1.3.5 使用gptransfer总结
	在执行命令的服务器上执行ps -ef|grep gptransfer 会看到以下日志信息，表示在机器上启动gpfdist服务，供外表查询数据提供服务
	$ ps -ef|grep gptransfer
	gpadmin  143245  98695  2 15:21 pts/1    00:00:00 python /usr/local/greenplum-db/./bin/gptransfer --source-host=192.168.***.** --source-port=5432 --source-user=gpadmin -t test.dim.test1 --source-map-file=source_host_map_file -a --dest-host=192.168.***.** --dest-port=5432 --dest-database=stagging --drop
	gpadmin  144007      1 13 15:21 ?        00:00:01 gpfdist -d /home/gpadmin/gptransfer_143245/test.dim.test1 -p 8000 -P 9000 -m 10485760 -t 300
	gpadmin  144039      1 12 15:21 ?        00:00:01 gpfdist -d /home/gpadmin/gptransfer_143245/test.dim.test1 -p 8000 -P 9000 -m 10485760 -t 300
	gpadmin  144048      1 13 15:21 ?        00:00:01 gpfdist -d /home/gpadmin/gptransfer_143245/test.dim.test1 -p 8000 -P 9000 -m 10485760 -t 300
	gpadmin  144077      1 13 15:21 ?        00:00:01 gpfdist -d /home/gpadmin/gptransfer_143245/test.dim.test1 -p 8000 -P 9000 -m 10485760 -t 300
	gpadmin  144079      1 13 15:21 ?        00:00:01 gpfdist -d /home/gpadmin/gptransfer_143245/test.dim.test1 -p 8000 -P 9000 -m 10485760 -t 300
	gpadmin  144097      1 12 15:21 ?        00:00:01 gpfdist -d /home/gpadmin/gptransfer_143245/test.dim.test1 -p 8000 -P 9000 -m 10485760 -t 300
	gpadmin  144118 143610  0 15:21 ?        00:00:00 sh -c GP_MASTER_HOST='192.168.***.**' && export GP_MASTER_HOST && GP_MASTER_PORT='5432' && export GP_MASTER_PORT && GP_SEG_PG_CONF='/data/gpsegment/p6/gpseg5/postgresql.conf' && export GP_SEG_PG_CONF && GP_SEG_DATADIR='/data/gpsegment/p6/gpseg5' && export GP_SEG_DATADIR && GP_DATABASE='test' && export GP_DATABASE && GP_USER='gpadmin' && export GP_USER && GP_DATE='20190515' && export GP_DATE && GP_TIME='152112' && export GP_TIME && GP_XID='1556272948-0002059298' && export GP_XID && GP_CID='2' && export GP_CID && GP_SN='0' && export GP_SN && GP_SEGMENT_ID='5' && export GP_SEGMENT_ID && GP_SEG_PORT='40005' && export GP_SEG_PORT && GP_SESSION_ID='30883' && export GP_SESSION_ID && GP_SEGMENT_COUNT='24' && export GP_SEGMENT_COUNT && GP_HADOOP_CONN_JARDIR='lib//hadoop' && export GP_HADOOP_CONN_JARDIR && GP_HADOOP_CONN_VERSION='' && export GP_HADOOP_CONN_VERSION && cat > /home/gpadmin/gptransfer_143245/test.dim.test1/test.dim.test1.pipe.$GP_SEGMENT_ID
	************************
	在同步的schema的下会创建一个gptransfer的schema，但不会存放数据
	如果在执行的过程中kill掉进程请先在目标的schema下删除gptransfer否则回报以下的错误
	***************
	20190515:10:42:22:106113 gptransfer:gpdev152:gpadmin-[WARNING]:-The gptransfer schema already exists on the source system.
	20190515:10:42:22:106113 gptransfer:gpdev152:gpadmin-[WARNING]:-This is likely due to a previous run on gptransfer
	20190515:10:42:22:106113 gptransfer:gpdev152:gpadmin-[WARNING]:-being forcefully terminated and not properly cleaned up.
	20190515:10:42:22:106113 gptransfer:gpdev152:gpadmin-[WARNING]:-Removing existing gptransfer schema on source system.

# 1.4 不同集群之间同步数据
	gptransfer --source-host=192.168.***.** --source-port=5432 --source-user=gpadmin -f source_tb_list  --source-map-file=source_host_map_file -a --dest-host=192.168.***.** --dest-port=5432 --dest-database=stagging --truncate
	
	
	只需要修改: --source-host 与--source-map-file 即可
	在提示上输入目标master服务器的密码即可











