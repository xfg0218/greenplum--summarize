	Greenplum集群Master与Standby相互切换
	1  概述
	2 查看集群的基本信息
		2.1 查看集群的配置信息
		2.2 快速查看down segments节点
		2.3 查看Master Standby节点的运行状态
		2.4  查看Master与Master Standby的配置
	3 移除掉Standby 节点
		3.1 移除掉Standby节点
		3.2 查看Standby的配制
	4 在Master节点上创建表
		4.1 创建一张测试表
	5 添加Standby节点
		5.1 添加Standby节点
		5.2 查看Standby信息
		5.3 查看Master与Standby同步的进程信息
	6 移除掉Master节点
		6.1 移除掉Master节点
		6.2 查看移除后的集群状态
	7 把Standby节点升级为Master
		7.1 把Standby 节点升级为Master
		7.2 查看切换后的集群的状态
		7.3 查看创建的表
	8 把当前的Master再次切换成Standby
		8.1 添加Standby节点
		8.2 关闭掉当前的master节点
		8.3 把Standby节点激活为Master节点
		8.4 查看激活后的集群的配置
		8.5 备份当前Master节点的数据
		8.6 添加Standby节点
		8.7 查看添加之后的集群的配置

# 1  概述
	本文档主要测试Greenplum集群的Master与Standby节点异常后数据同步问题，之相互切换的过程。
	在操作时通过手动停掉Master节点看Standby节点是否能正常的启动，期间是否有数据不同步的问题，
	再通过恢复原Master节点查看集群是否正常运行。在切换期间要注意Master与Standby脑裂的情况的发生。
	
# 2 查看集群的基本信息
	以下命令全部在Master节点上操作

## 2.1 查看集群的配置信息
	查看集群的mirror配置及同步状态
	gpstate -m
	
	
	查看集群的primary与mirror的安装目录及端口
	gpstate -p
	
## 2.2 快速查看down segments节点
	gpstate -s

## 2.3 查看Master Standby节点的运行状态
	20201012:16:05:59:070782 gpstate:gpmaster:gpadmin-[INFO]:-   Standby address          = smdw
	20201012:16:05:59:070782 gpstate:gpmaster:gpadmin-[INFO]:-   Standby data directory   = /data/master/gpseg-1
	20201012:16:05:59:070782 gpstate:gpmaster:gpadmin-[INFO]:-   Standby port             = 5432
	20201012:16:05:59:070782 gpstate:gpmaster:gpadmin-[INFO]:-   Standby PID              = 125235
	20201012:16:05:59:070782 gpstate:gpmaster:gpadmin-[INFO]:-   Standby status           = Standby host passive
	20201012:16:05:59:070782 gpstate:gpmaster:gpadmin-[INFO]:--------------------------------------------------------------
	20201012:16:05:59:070782 gpstate:gpmaster:gpadmin-[INFO]:--pg_stat_replication
	20201012:16:05:59:070782 gpstate:gpmaster:gpadmin-[INFO]:--------------------------------------------------------------
	20201012:16:05:59:070782 gpstate:gpmaster:gpadmin-[INFO]:--WAL Sender State: streaming
	20201012:16:05:59:070782 gpstate:gpmaster:gpadmin-[INFO]:--Sync state: sync
	20201012:16:05:59:070782 gpstate:gpmaster:gpadmin-[INFO]:--Sent Location: 0/EF0B8570
	20201012:16:05:59:070782 gpstate:gpmaster:gpadmin-[INFO]:--Flush Location: 0/EF0B8570
	20201012:16:05:59:070782 gpstate:gpmaster:gpadmin-[INFO]:--Replay Location: 0/EF0A7948
	20201012:16:05:59:070782 gpstate:gpmaster:gpadmin-[INFO]:--------------------------------------------------------------
	
	
	注意以上标红的信息，特别留意每次元数据改变Sent Location / Flush Location / Replay Location 值的变化。

## 2.4  查看Master与Master Standby的配置
	查看master的环境变量信息
	cat  ~/.bash_profile
	
	************
	$ greenplum  config info
	source /usr/local/greenplum-db/greenplum_path.sh
	export MASTER_DATA_DIRECTORY=/data/master/gpseg-1
	export GPPORT=5432
	export PGPORT=5432
	export PGDATABASE=123456
	
	
	查看Master Standby 的配置
	cat  ~/.bash_profile
	
	************
	$ greenplum  config info
	source /usr/local/greenplum-db/greenplum_path.sh
	export MASTER_DATA_DIRECTORY=/data/master/gpseg-1
	export GPPORT=5432
	export PGPORT=5432
	export PGDATABASE=123456
	

# 3 移除掉Standby 节点
## 3.1 移除掉Standby节点
	[gpadmin@gpmaster ~]$ gpinitstandby  -r
	
	20201015:11:17:54:199737 gpinitstandby:gpmaster:gpadmin-[INFO]:------------------------------------------------------
	20201015:11:17:54:199737 gpinitstandby:gpmaster:gpadmin-[INFO]:-Warm master standby removal parameters
	20201015:11:17:54:199737 gpinitstandby:gpmaster:gpadmin-[INFO]:------------------------------------------------------
	20201015:11:17:54:199737 gpinitstandby:gpmaster:gpadmin-[INFO]:-Greenplum master hostname               = gpmaster
	20201015:11:17:54:199737 gpinitstandby:gpmaster:gpadmin-[INFO]:-Greenplum master data directory         = /data/master/gpseg-1
	20201015:11:17:54:199737 gpinitstandby:gpmaster:gpadmin-[INFO]:-Greenplum master port                   = 5432
	20201015:11:17:54:199737 gpinitstandby:gpmaster:gpadmin-[INFO]:-Greenplum standby master hostname       = gpsdw1
	20201015:11:17:54:199737 gpinitstandby:gpmaster:gpadmin-[INFO]:-Greenplum standby master port           = 5432
	20201015:11:17:54:199737 gpinitstandby:gpmaster:gpadmin-[INFO]:-Greenplum standby master data directory = /data/master/gpseg-1
	Do you want to continue with deleting the standby master? Yy|Nn (default=N):
	> y
	20201015:11:18:04:199737 gpinitstandby:gpmaster:gpadmin-[INFO]:-Removing standby master from catalog...
	20201015:11:18:04:199737 gpinitstandby:gpmaster:gpadmin-[INFO]:-Database catalog updated successfully.
	20201015:11:18:04:199737 gpinitstandby:gpmaster:gpadmin-[INFO]:-Stopping standby master on gpsdw1
	20201015:11:18:04:199737 gpinitstandby:gpmaster:gpadmin-[INFO]:-Removing data directory on standby master...
	20201015:11:18:06:199737 gpinitstandby:gpmaster:gpadmin-[INFO]:-Successfully removed standby master

## 3.2 查看Standby的配制
	[gpadmin@gpmaster ~]$ gpstate  -f
	20201015:11:18:17:199788 gpstate:gpmaster:gpadmin-[INFO]:-Starting gpstate with args: -f
	20201015:11:18:17:199788 gpstate:gpmaster:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.1.0 build commit:6788ca8c13b2bd6e8976ccffea07313cbab30560'
	20201015:11:18:17:199788 gpstate:gpmaster:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.1.0 build commit:6788ca8c13b2bd6e8976ccffea07313cbab30560) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Nov  1 2019 22:06:07'
	20201015:11:18:17:199788 gpstate:gpmaster:gpadmin-[INFO]:-Obtaining Segment details from master...
	20201015:11:18:17:199788 gpstate:gpmaster:gpadmin-[INFO]:-Standby master instance not configured
	20201015:11:18:17:199788 gpstate:gpmaster:gpadmin-[INFO]:--------------------------------------------------------------
	20201015:11:18:17:199788 gpstate:gpmaster:gpadmin-[INFO]:--pg_stat_replication
	20201015:11:18:17:199788 gpstate:gpmaster:gpadmin-[INFO]:--------------------------------------------------------------
	20201015:11:18:17:199788 gpstate:gpmaster:gpadmin-[INFO]:-No entries found.
	20201015:11:18:17:199788 gpstate:gpmaster:gpadmin-[INFO]:--------------------------------------------------------------

	
# 4 在Master节点上创建表
## 4.1 创建一张测试表
	[gpadmin@gpmaster ~]$ psql -d postgres
	psql (9.4.24)
	Type "help" for help.
	postgres=$ create table test (id  int) DISTRIBUTED BY(id);
	CREATE TABLE
	postgres=$ insert into test  select generate_series(1,50000,1);
	INSERT 0 50000
	postgres=$ select count(*) from test;
	count 
	-------
	50000
	(1 row)
	
	创建了一张test表并插入到5W数据。

# 5 添加Standby节点
	在master上执行添加standby操作，并查看添加后时候即使同步了元数据信息。
	
## 5.1 添加Standby节点
	
	[gpadmin@gpmaster ~]$ gpinitstandby -s  smdw
	
	smdw : standby节点的主机名字
	
## 5.2 查看Standby信息

	[gpadmin@gpmaster ~]$ gpstate -f
	
	***************************
	20201015:12:16:09:207211 gpstate:gpmaster:gpadmin-[INFO]:--pg_stat_replication
	20201015:12:16:09:207211 gpstate:gpmaster:gpadmin-[INFO]:--------------------------------------------------------------
	20201015:12:16:09:207211 gpstate:gpmaster:gpadmin-[INFO]:--WAL Sender State: streaming
	20201015:12:16:09:207211 gpstate:gpmaster:gpadmin-[INFO]:--Sync state: sync
	20201015:12:16:09:207211 gpstate:gpmaster:gpadmin-[INFO]:--Sent Location: 1/2800DE68
	20201015:12:16:09:207211 gpstate:gpmaster:gpadmin-[INFO]:--Flush Location: 1/2800DE68
	20201015:12:16:09:207211 gpstate:gpmaster:gpadmin-[INFO]:--Replay Location: 1/2800DDB0
	20201015:12:16:09:207211 gpstate:gpmaster:gpadmin-[INFO]:--------------------------------------------------------------
	
	
	在以上可以看到数据已经元数据已经更新为了2800DDB0版本了说明元数据以及时更新了。

## 5.3 查看Master与Standby同步的进程信息
	[gpadmin@gpmaster ~]$ ps -ef|grep streaming
	gpadmin  204223 204143  0 12:06 ?        00:00:04 postgres:  7001, wal receiver process   streaming 1/1DF892A8
	gpadmin  204224 204150  0 12:06 ?        00:00:00 postgres:  6001, wal sender process gpadmin 192.168.58.16(21448) streaming 1/1E361700
	gpadmin  204225 204148  0 12:06 ?        00:00:00 postgres:  6002, wal sender process gpadmin 192.168.58.16(38264) streaming 1/1E16D648
	gpadmin  204226 204146  0 12:06 ?        00:00:04 postgres:  7002, wal receiver process   streaming 1/1DF7BB18
	gpadmin  204227 204149  0 12:06 ?        00:00:00 postgres:  6000, wal sender process gpadmin 192.168.58.16(12705) streaming 1/1E839380
	gpadmin  204228 204147  0 12:06 ?        00:00:00 postgres:  6003, wal sender process gpadmin 192.168.58.16(34466) streaming 1/1DB314C0
	gpadmin  204229 204145  0 12:06 ?        00:00:04 postgres:  7003, wal receiver process   streaming 1/1E1C8B90
	gpadmin  204231 204144  0 12:06 ?        00:00:04 postgres:  7000, wal receiver process   streaming 1/1EAD05F8
	gpadmin  207140 204234  0 12:15 ?        00:00:00 postgres:  5432, wal sender process gpadmin 192.168.58.16(53979) streaming 1/293CB8B0
	gpadmin  227768 201661  0 14:06 pts/23   00:00:00 grep --color=auto streaming
	
	
	在以上可以看出master以sender process进程向standby发送WAL同步日志。Standby节点正在以wal receiver process进程接受WAL日志。

	
# 6 移除掉Master节点
## 6.1 移除掉Master节点
	$ pg_ctl stop -D /data/master/gpseg-1
	waiting for server to shut down.... done
	server stopped
	
## 6.2 查看移除后的集群状态
	
	$ gpstate -f
	***************
		Is the server running on host "localhost" (::1) and accepting
		TCP/IP connections on port 5432?
	could not connect to server: Connection refused
		Is the server running on host "localhost" (127.0.0.1) and accepting
		TCP/IP connections on port 5432?
	') exiting...
	

# 7 把Standby节点升级为Master
## 7.1 把Standby 节点升级为Master
	在standby节点上执行以下命令
	
	
	$ gpactivatestandby -d /data/master/gpseg-1
	

## 7.2 查看切换后的集群的状态
	$ gpstate -s
	
	**************
	******  Master host                    = smdw
	******  Master postgres process ID     = 208590
	******  Master data directory          = /data/master/gpseg-1
	******  Master port                    = 5432
	******  Master current role            = dispatch
	******  Greenplum initsystem version   = 6.1.0 build commit:6788ca8c13b2bd6e8976ccffea07313cbab30560
	******  Postgres version               = 9.4.24
	******  Master standby                 = No master standby configured

## 7.3 查看创建的表
	postgres=$ select count(*) from test;
	count 
	-------
	50000
	(1 row)
	
# 8 把当前的Master再次切换成Standby
## 8.1 添加Standby节点
	在原始master机器上备份master数据的目录
	$ mv  /data/master/gpseg-1   /data/master/gpseg-1-back
	
	
	在当前的master的节点上执行以下命令
	$ gpinitstandby  -s  mdw
	*****************************
	[INFO]:-Successfully created standby master on gpmaster

## 8.2 关闭掉当前的master节点
	$ pg_ctl stop -D /data/master/gpseg-1
	waiting for server to shut down.... done
	server stopped

## 8.3 把Standby节点激活为Master节点
	$ gpactivatestandby -d /data/master/gpseg-1

## 8.4 查看激活后的集群的配置
	$ gpstate -s

## 8.5 备份当前Master节点的数据
	在当前master机器上备份master数据的目录
	$ mv  /data/master/gpseg-1   /data/master/gpseg-1-back
	
## 8.6 添加Standby节点
	$ gpinitstandby -s  smdw

## 8.7 查看添加之后的集群的配置
	
	$ gpstate - f