# greenplum链接kafka导入与导出数据
	主要介绍kafka与greenplum结合,把kafka中的数据使用gpkafka工具导入到greenplum中以及把kafka的数据写入到greenplum,简单好用有简单,谁用谁知道
	
# 目录结构
	15 Greenplum 外接工具 1
	15.1 安装kafka 1
	15.1.1 安装kafka 1
	15.1.2 准备kafka的环境 1
	15.2 greenplum外表加载kafka数据 2
	15.2.1 准备测试数据 2
	15.2.2 编写加载kafka文件 2
	15.2.3 创建数据库表 3
	15.2.4 使用gpkafka命令插入数据 4
	15.2.5 查看数据库保存的偏移量 5
	15.2.6 测试复杂数据量的性能 5
	15.2.6.1 测试数据 5
	152.6.2 查看数据库数据 7
	15.3 greenplum数据写入到kafka 7
	15.3.1 在集群中安装kafka客户端 7
	15.3.2 创建写入kafka的外部可写表 7
	15.3.3 写入数据到kafka 7
	15.3.4 查看kafka 集群中的数据 8

# 15 Greenplum 外接工具
## 15.1 安装kafka
### 15.1.1 安装kafka
	安装教程请查看:https://www.jianshu.com/p/9d48a5bd1669
### 15.1.2 准备kafka的环境
	创建topic 
	# bin/kafka-topics.sh --create --zookeeper localhost:2181  --replication-factor 1 --partitions 1 --topic topic_for_gpkafka
	
	查看topic 集合
	$ bin/kafka-topics.sh --list --zookeeper localhost:2181
	topic_for_gpkafka
	
	生产kafka数据
	bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
	
	文件传输生产数据
	bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test < sample_data.csv
	
## 15.2 greenplum外表加载kafka数据
	
	Kafak作为数据流是比较常用的，接下来就用greenplum对接一下kafka，参考官方资料:
	https://gpdb.docs.pivotal.io/5180/greenplum-kafka/load-from-kafka-example.html
	
### 15.2.1 准备测试数据
	数据示例
	# head -n 10 sample_data.csv 
	"1313131","12","1313.13"
	"3535353","11","761.35"
	"7979797","10","4489.00"
	"7979797","11","18.72"
	"3535353","10","6001.94"
	"7979797","12","173.18"
	"1313131","10","492.83"
	"3535353","12","81.12"
	"1313131","11","368.27"
	"1313131","12","1313.13"
	****************
	
	数据的个数
	$ wc -l sample_data.csv 
	19558287 sample_data.csv
	
	数据的大小
	$ du -sh sample_data.csv 
	450M	sample_data.csv
### 15.2.2 编写加载kafka文件
	$  cat firstload_cfg.yaml 
	DATABASE: china***
	USER: gpmon
	HOST: 192.168.***.**
	PORT: 5432
	KAFKA:
	INPUT:
		SOURCE:
			BROKERS: localhost:9092
			TOPIC: topic_for_gpkafka
		COLUMNS:
			- NAME: cust_id
			TYPE: int
			- NAME: expenses
			TYPE: int
			- NAME: tax_due
			TYPE: decimal(9,2)
		FORMAT: csv
		ERROR_LIMIT: 200
	OUTPUT:
		SCHEMA: kafka_test
		TABLE: data_from_kafka
		MAPPING:
			- NAME: customer_id
			EXPRESSION: cust_id
			- NAME: expenses
			EXPRESSION: expenses
			- NAME: tax_due
			EXPRESSION: expenses * .0725
	COMMIT:
		MAX_ROW: 500000
	
	以上配置注意cust_id字段，MAX_ROW一定要比ERRROR_LIMIT大，否则会报以下错误
	'Debug.Granularity' is bigger than 'Kafka.Commit.Max_row'
	
### 15.2.3 创建数据库表
	CREATE TABLE "kafka_test"."data_from_kafka" (
	"customer_id" varchar,
	"expenses" numeric(9,2),
	"tax_due" numeric(7,2)
	)with (appendonly = true, compresstype = zlib, compresslevel = 5
	,orientation=column, checksum = false,blocksize = 2097152)
	Distributed by (customer_id)
	15.2.4 使用gpkafka命令插入数据
	参数详解
	$ gpkafka load --help
	Load data from kafka into greenplum
	
	Usage:
	gpkafka load [config file] [flags]
	
	Flags:
		--debug-port int   enable pprof debug server at specified port
	-h, --help             help for load
		--quit-at-eof      gpkafka load will quit after reading kafka EOF
	
	
	加载数据命令
	#  gpkafka load --quit-at-eof  firstload_cfg.yaml
	20190410:15:37:50.641 gpkafkaload:gpadmin:gpdev152:164064-[INFO]:-target column (customer_id, expenses, tax_due), ext column cust_id, expenses, expenses * .0725
	20190410:15:37:51.774 gpkafkaload:gpadmin:gpdev152:164064-[INFO]:-Check insert SQL: EXPLAIN INSERT INTO "kafka_test"."data_from_kafka" (customer_id, expenses, tax_due) SELECT cust_id, expenses, expenses * .0725 FROM "kafka_test"."gpkafkaloadext_f392d7b099f89be0c047f8872aee4fa2"
	20190410:15:37:51.887 gpkafkaload:gpadmin:gpdev152:164064-[INFO]:-gpfdist listening on gpdev152:8080
	20190410:15:37:51.920 gpkafkaload:gpadmin:gpdev152:164064-[INFO]:-partition num=1
	20190410:15:37:52.023 gpkafkaload:gpadmin:gpdev152:164064-[INFO]:-Worker:0 set topic 'topic_for_gpkafka', partition 0, offset 0
	20190410:15:37:52.034 gpkafkaload:gpadmin:gpdev152:164064-[INFO]:-Start batch 0
	20190410:15:37:55.588 gpkafkaload:gpadmin:gpdev152:164064-[INFO]:-Batch flow read 500000 rows in 2488 ms
	20190410:15:37:55.588 gpkafkaload:gpadmin:gpdev152:164064-[INFO]:-End batch 0: load 500000 rows
	20190410:15:37:55.588 gpkafkaload:gpadmin:gpdev152:164064-[INFO]:-Start batch 1
	20190410:15:37:58.456 gpkafkaload:gpadmin:gpdev152:164064-[INFO]:-Batch flow read 500000 rows in 2452 ms
	20190410:15:37:58.456 gpkafkaload:gpadmin:gpdev152:164064-[INFO]:-End batch 1: load 500000 rows
	20190410:15:37:58.456 gpkafkaload:gpadmin:gpdev152:164064-[INFO]:-Start batch 2
	*****************
	
	在以上日志中可以看出列出了外表与内表的映射字段，使用gpfdist 创建了外表，大概每2488 ms 插入500000行的数据，创建外表的语句为:
	CREATE EXTERNAL TABLE "kafka_test"."gpkafkaloadext_b052c8fb3e8713970df460f00f20b81c"(customer_id int, expenses int, tax_due decimal(9,2)) LOCATION('gpfdist://gpdev152:8080/gpkafkaload/%22kafka_test%22.%22gpkafkaloadext_b052c8fb3e8713970df460f00f20b81c%22') FORMAT 'CSV'LOG ERRORS SEGMENT REJECT LIMIT 200 ROWS
	
	
### 15.2.5 查看数据库保存的偏移量
	select * from kafka_test.gpkafka_data_from_kafka_12ead185469b45cc8e5be3c9f0ea14a2 limit 10;
	
	
### 15.2.6 测试复杂数据量的性能
#### 15.2.6.1 测试数据
	文件的字段信息
	$ head -n 2 s_std_rs_da_map.csv 
	"2017071906","DW01","外商承包","C3"
	"2017071906","CB18","董事、副董事长","4B"
	*******
	
	文件的大小
	1021M	s_std_rs_da_map.csv
	
	
	文件的个数
	$ wc -l s_std_rs_da_map.csv 
	18228540 s_std_rs_da_map.csv
	
	
	开始导数据
	gpkafka load --quit-at-eof  s_std_rs_da_map.yaml
	***************
	20190410:18:12:34.940 gpkafkaload:gpadmin:gpdev152:285538-[INFO]:-Batch flow read 55882 rows in 159 ms
	20190410:18:12:34.940 gpkafkaload:gpadmin:gpdev152:285538-[INFO]:-End batch 445: load 52870 rows
	20190410:18:12:34.947 gpkafkaload:gpadmin:gpdev152:285538-[INFO]:-SELECT count(*) from gp_read_error_log('"kafka_test"."gpkafkaloadext_41f56d1be64723849329c8b0ed3b8609"')
		WHERE cmdtime >= '2019-04-10 17:51:16.857641+08'
		AND cmdtime <= '2019-04-10 18:12:34.940751+08'
	20190410:18:12:35.022 gpkafkaload:gpadmin:gpdev152:285538-[INFO]:-Job finished
	20190410:18:12:35.022 gpkafkaload:gpadmin:gpdev152:285538-[INFO]:-Target table: "kafka_test"."s_std_rs_da_map"
	20190410:18:12:35.022 gpkafkaload:gpadmin:gpdev152:285538-[INFO]:-Inserted 212611939 rows
	20190410:18:12:35.022 gpkafkaload:gpadmin:gpdev152:285538-[INFO]:-Rejected 2683 rows
	20190410:18:12:35.022 gpkafkaload:gpadmin:gpdev152:285538-[INFO]:-Broker: localhost:9092
	20190410:18:12:35.022 gpkafkaload:gpadmin:gpdev152:285538-[INFO]:-Topic: s_std_rs_da_map
	20190410:18:12:35.022 gpkafkaload:gpadmin:gpdev152:285538-[INFO]:-Partition 0 at offset 232696081
	
	real	21m18.437s
	user	14m50.773s
	sys	2m3.872s
	
	
	在以上可以看出55882大约用时159ms，212611939 行数据大约用时21m18.437s,平均212611939 / 1278s ≈ 166363 行/s
#### 15.2.6.2 查看数据库数据
	select count(*) from kafka_test.s_std_rs_da_map;
	-- 212611939
	
	select * from kafka_test.s_std_rs_da_map limit 10;