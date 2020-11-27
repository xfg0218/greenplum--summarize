# greenplum增加mirror镜像
	有时我们再搭建集群时没有配置mirror镜像节点，在生产中没有mirror是致命的,建议在安装完
	集群后及时查看mirror镜像的配置信息

# 查看是否配置了mirror镜像

	使用gpstate -m命令在master节点上查看配置mirror信息
	
	[gpadmin@gpmaster ~]$ gpstate -m
	*****4853 gpstate:gpmaster:gpadmin-[INFO]:-Starting gpstate with args: -m
	*****4853 gpstate:gpmaster:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.7.0 build commit:2fbc274bc15a19b5de3c6e44ad5073464cd4f47b'
	*****4853 gpstate:gpmaster:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.7.0 build commit:2fbc274bc15a19b5de3c6e44ad5073464cd4f47b) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Apr 16 2020 02:24:06'
	*****4853 gpstate:gpmaster:gpadmin-[INFO]:-Obtaining Segment details from master...
	*****4853 gpstate:gpmaster:gpadmin-[WARNING]:--------------------------------------------------------------
	*****4853 gpstate:gpmaster:gpadmin-[WARNING]:-Mirror not used
	*****4853 gpstate:gpmaster:gpadmin-[WARNING]:--------------------------------------------------------------

	在以上信息中Mirror not used可以看出没有配置mirror信息

	
	
# 创建保存Mirror数据的路径

	

	[gpadmin@gpmaster gpconfigs]$ gpssh -f all_host 
	=> mkdir /data/gpsegment/mirror
	[gpmaster]
	[  gpsdw2]
	[  gpsdw1]
	
	=> ll /data/gpsegment/mirror
	[gpmaster] total 0
	[  gpsdw2] total 0
	[  gpsdw1] total 0
	=> 

	
#  生成mirror映射的文件
	[gpadmin@gpmaster gpconfigs]$ gpaddmirrors -o ./addmirror
	********:255135 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Starting gpaddmirrors with args: -o ./addmirror
	********:255135 gpaddmirrors:gpmaster:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 6.7.0 build commit:2fbc274bc15a19b5de3c6e44ad5073464cd4f47b'
	********:255135 gpaddmirrors:gpmaster:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 9.4.24 (Greenplum Database 6.7.0 build commit:2fbc274bc15a19b5de3c6e44ad5073464cd4f47b) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Apr 16 2020 02:24:06'
	********:255135 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Obtaining Segment details from master...
	********:255135 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Heap checksum setting consistent across cluster
	Enter mirror segment data directory location 1 of 4 >
	/data/gpsegment/mirror
	Enter mirror segment data directory location 2 of 4 >
	/data/gpsegment/mirror
	Enter mirror segment data directory location 3 of 4 >
	/data/gpsegment/mirror
	Enter mirror segment data directory location 4 of 4 >
	/data/gpsegment/mirror
	********:255135 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Configuration file output to ./addmirror successfully.

	
# 查看mirror映射的文件的内容信息

	[gpadmin@gpmaster gpconfigs]$ cat addmirror 
	0|gpsdw1|7000|/data/gpsegment/mirror/gpseg0
	1|gpsdw1|7001|/data/gpsegment/mirror/gpseg1
	2|gpsdw1|7002|/data/gpsegment/mirror/gpseg2
	3|gpsdw1|7003|/data/gpsegment/mirror/gpseg3
	4|gpsdw2|7000|/data/gpsegment/mirror/gpseg4
	5|gpsdw2|7001|/data/gpsegment/mirror/gpseg5
	6|gpsdw2|7002|/data/gpsegment/mirror/gpseg6
	7|gpsdw2|7003|/data/gpsegment/mirror/gpseg7
	8|gpmaster|7000|/data/gpsegment/mirror/gpseg8
	9|gpmaster|7001|/data/gpsegment/mirror/gpseg9
	10|gpmaster|7002|/data/gpsegment/mirror/gpseg10
	11|gpmaster|7003|/data/gpsegment/mirror/gpseg11


# 执行添加Mirror镜像


	[gpadmin@gpmaster gpconfigs]$ gpaddmirrors -i addmirror 
	************************
	***********:19:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:----------------------------------------------------------
	
	Continue with add mirrors procedure Yy|Nn (default=N):
	> y
	***********:21:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Starting to modify pg_hba.conf on primary segments to allow replication connections
	***********:31:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Successfully modified pg_hba.conf on primary segments to allow replication connections
	***********:31:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-12 segment(s) to add
	***********:31:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Validating remote directories
	.
	***********:33:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Configuring new segments
	gpsdw2 (dbid 18): pg_basebackup: base backup completed
	gpsdw2 (dbid 19): pg_basebackup: base backup completed
	gpsdw2 (dbid 20): pg_basebackup: base backup completed
	gpsdw2 (dbid 21): pg_basebackup: base backup completed
	gpsdw1 (dbid 14): pg_basebackup: base backup completed
	gpsdw1 (dbid 15): pg_basebackup: base backup completed
	gpsdw1 (dbid 16): pg_basebackup: base backup completed
	gpsdw1 (dbid 17): pg_basebackup: base backup completed
	gpmaster (dbid 22): pg_basebackup: base backup completed
	gpmaster (dbid 23): pg_basebackup: base backup completed
	gpmaster (dbid 24): pg_basebackup: base backup completed
	gpmaster (dbid 25): pg_basebackup: base backup completed
	***********:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Updating configuration with new mirrors
	***********:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Updating mirrors
	***********:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Starting mirrors
	***********:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-era is 0e130b84d07aa6b2_201124113348
	***********:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Commencing parallel segment instance startup, please wait...
	.....
	***********:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Process results...
	***********:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-******************************************************************
	***********:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Mirror segments have been added; data synchronization is in progress.
	***********:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Data synchronization will continue in the background.
	***********:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-Use  gpstate -s  to check the resynchronization progress.
	***********:255266 gpaddmirrors:gpmaster:gpadmin-[INFO]:-******************************************************************


# 查看Mirror镜像配置信息
	[gpadmin@gpmaster gpconfigs]$ gpstate -m




