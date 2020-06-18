# Greenplum6.x安装PXF插件
# 目录
	1 安装Hadoop与Hive的客户端
		1.1 在大数据平台的主节点(namenode)上打包客户端
		1.2 把文件scp到Greenplum的master节点上
	2 Greenplum的master节点解压文件配置环境变量
		2.1 解压文件
		2.2 对文件重命名
		2.3 为 gpadmin配置环境变量
	3  PXF安装
		3.1 PXF 初始化
		3.2 创建新的文件夹
		3.3 修改pxf-env.sh配置文件
		3.4 把配置文件复制到目录下
		3.5 PXF 同步文件
		3.6 开启PXF
	4 测试PXF
		4.1 查看hive与hdfs数据
		4.1 测试PXF连接Hive
		4.2 测试PXF连接Haddop
	5 PXF单节点安装说明

	
# 1 安装Hadoop与Hive的客户端
	以下实例是在ambari管理的大数据平台,hdp版本是2.6.5.0
	
## 1.1在大数据平台的主节点(namenode)上打包客户端

	1、登录到ambari的主节点，登录hdfs用户，进入到/usr/hdp/2.6.5.0-292下
	2、以此打包安装好的hadoop与hive与hbase的组件

	[hdfs@*** 2.6.5.0-292]$  zip  -r  hadoop-2.6.zip  hadoop
	[hdfs@*** 2.6.5.0-292]$  zip  -r  hive-2.6.zip  hive
	[hdfs@*** 2.6.5.0-292]$  zip  -r  hbase-2.6.zip  hbase
	
## 1.2把文件scp到Greenplum的master节点上

	[hdfs@*** 2.6.5.0-292]$ scp -r hadoop-2.6.zip  gpmaster@gpadmin:/home/gpadmin
	[hdfs@*** 2.6.5.0-292]$ scp -r hive-2.6.zip  gpmaster@gpadmin:/home/gpadmin
	[hdfs@*** 2.6.5.0-292]$ scp -r hbase-2.6.zip  gpmaster@gpadmin:/home/gpadmin
	
	
	gpmaster : 主节点的IP地址的映射
	gpadmin : master节点上的用户
	/home/gpadmin : 文件保存的路径

# 2 Greenplum的master节点解压文件配置环境变量

## 2.1 解压文件
	[gpadmin@*** ~]$ unzip hadoop-2.6.zip
	[gpadmin@*** ~]$ unzip hive-2.6.zip
	[gpadmin@*** ~]$ unzip hbase-2.6.zip

## 2.2 对文件重命名
	[gpadmin@*** ~]$ mv  hadoop  hadoop-2.6
	[gpadmin@*** ~]$ mv  hive  hive-2.6
	[gpadmin@*** ~]$ mv  hbase  hbase-2.6
	
## 2.3 为 gpadmin配置环境变量

	在以下文件中加入以下配置	
	
	[gpadmin@*** ~]$ vim  /home/gpadmin/.bashrc
	
	source /usr/local/greenplum-db/greenplum_path.sh
	export JAVA_HOME=/opt/java/jdk1.8.0_11
	
	export PXF_HOME=/usr/local/greenplum-db-6.1.0/pxf/
	export PXF_CONF=/usr/local/greenplum-db-6.1.0/pxf/conf
	
	export HADOOP_HOME=/home/gpadmin/hadoop-2.6
	export HIVE_HOME=/home/gpadmin/hive-2.6
	export HADOOP_CONF_DIR=/home/gpadmin/hadoop-2.6/conf
	export HIVE_CONF=/home/gpadmin/hive-2.6/conf
	
	export GP_HOME=/usr/local/greenplum-db-6.1.0/
	
	
	export PATH=$JAVA_HOME/bin:$GP_HOME/bin:$PATH
	
	export PATH=$JAVA_HOME/bin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$HADOOP_CONF_DIR:$HIVE_CONF:$PATH
	
	export PATH=$PXF_HOME/bin:$PXF_CONF:$PATH
	
	
# 3  PXF安装 
	在greenplum的master节点以gpadmin用户登录
	
## 3.1 PXF 初始化

	[gpadmin@***  ~ ]$ source /home/gpadmin/.bashrc
	[gpadmin@***  ~ ]$ pxf cluster init
	
	
	初始化之后会在$PXF_HOME目录下看到pxf-service新生产的文件夹
	
## 3.2 创建新的文件夹
	在$PXF_HOME/servers目录下创建hdp-prod文件夹
	
	在$PXF_HOME/conf/servers目录下创建hdp-prod文件夹
	
## 3.3 修改pxf-env.sh配置文件
	[gpadmin@***~]$ cd $PXF_HOME/conf/conf
	
	把
	export PXF_USER_IMPERSONATION=true
	
	改成
	export PXF_USER_IMPERSONATION=false

## 3.4 把配置文件复制到目录下

	1、把hadoop相关的hdfs-site.xml/core-site.xml/mapred-site.xml/yarn-site.xml 复制到$PXF_HOME/servers/hdp-prod与$PXF_HOME/conf/servers/conf下
	
	2、把hive相关的hive-env.sh/hive-site.xml/mapred-site.xml复制到$PXF_HOME/servers/hdp-prod与$PXF_HOME/conf/servers/conf下
	
	3、把hbase相关的hbase-env.sh/hbase-site.xml复制到$PXF_HOME/servers/hdp-prod与$PXF_HOME/conf/servers/conf下
	
## 3.5 PXF 同步文件
	[gpadmin@***~]$ pxf cluster sync

## 3.6 开启PXF
	[gpadmin@***  ~]$ pxf cluster start

# 4 测试PXF

## 4.1 查看hive与hdfs数据
	查看hive中的表
	
	hive> use udt;
	
	hive> select * from test;
	OK
	1	1
	2	2
	Time taken: 0.584 seconds, Fetched: 2 row(s)
	

	test是在udt的schema下
	查看hadoop上数据
	$ hadoop fs -cat  /hawq_data/test.txt
	dnsdde,ededed
	sddde,dedw
	swewd,wreref
	
	
	hadoop上的数据是以逗号分隔的数据

## 4.1 测试PXF连接Hive

	创建pxf插件
	CREATE  EXTENSION  pxf;
	
	创建测试外部表
	CREATE EXTERNAL TABLE hive_test(
	id text, 
	name text
	)
	LOCATION ('pxf://udt.test?PROFILE=Hive&SERVER=hdp-prod')
	FORMAT 'custom' (formatter='pxfwritable_import');
	
	
	
	查询数据
	select * from salesinfo_hiveprofile;
	id | name 
	----+------
	2  | 2
	1  | 1
	(2 rows)


## 4.2 测试PXF连接Haddop

	创建测试外部表
	CREATE EXTERNAL TABLE hadoop_test (
	a varchar(100),
	b varchar(100)
	) LOCATION (
	'pxf://hawq_data/test.txt?PROFILE=hdfs:text&SERVER=hdp-prod'
	) ON ALL FORMAT 'text' (delimiter E',')
	ENCODING 'UTF8'
	
	
	查看数据
	select * from test;
	a    |   b    
	--------+--------
	dnsdde | ededed
	sddde  | dedw
	swewd  | wreref
	(3 rows)

# 5 PXF单节点安装说明
	如果Greenplum是单节点的安装或者想单台机器运行pxf，可以把cluster命令是pxf init/pxf start/pxf stop等