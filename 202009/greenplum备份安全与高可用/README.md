# Greenplum备份安全与高可用
	1 Greenplum高可用
		1.1 管理节点
		1.2 数据节点
		1.3 交换机
		1.4 服务器
		1.5 Master高可用
		1.6 Segment高可用
		1.7 系统表高可用
		1.8 系统视图高可用
	2 Greenplum安全
		2.1 身份认证
			2.1.1 pg_hba.conf配置连接类型
			2.1.2 pg_hba.conf配置连接数据库
			2.1.3 pg_hba.conf配置连接用户
			2.1.4 pg_hba.conf配置连接网络地址
			2.1.5 pg_hba.conf配置用户的认证方法
		2.2 数据库连接和数据加密
			2.2.1 客户端和主数据库之间的链接使用SSL加密
			2.2.2 gpfdist加密数据和链接
			2.2.3 静态数据加密
		2.3 授权
			2.3.1 授权的对象及权限
			2.3.2 SHA-256加密用户密码
			2.3.3 设置用户的访问时间
		2.4 审计
	3 Greenplum 备份
		3.1 gpbackup 和gprestore
		3.2 Full Backups
		3.3 Incremental Bckups
			3.3.1 Supported  woth
			3.3.2 Back up an AO table if one of the following operations is performed
		3.4 gpbackup_manager 管理工具
		3.5 Other backup tools

# 1 Greenplum高可用
	Greenplum数据库软件自身具备多层次容错和冗余功能，同时对于底层硬件设备，
	Greenplum也提供了很多容错机制要求，以保证系统7*24不间断的运行处理:
	
## 1.1 管理节点
	1、部署2台管理节点，为1主1备(Standby)方式
	2、主管理节点和Standby管理节点自动数据同步。
	3、主管理节点失败时切换到Standby管理节点。
	
## 1.2 数据节点
	1、采用镜像技术，将数据节点的primary实例的数据自动镜像到位于其他数据节点的mirror实例中。
	2、Primary实例故障时，自动侦测并启动镜像实例，保证用户数据完整和服务不中断。

## 1.3 交换机
	1、系统一般部署2台网络交换机。
	2、正常情况下，2台交换机同时工作，另外1台将进行冗余保护。
	
## 1.4 服务器
	1、硬件组件冗余保护(Fan,PSU...)
	2、服务器硬盘Raid 5保护。
	3、更换新磁盘后Raid  5 data自动重建。

## 1.5 Master高可用

	Master与standby master之间是通过WAL机制实现日志的实时更新。可以通过gpstate -f查看详细信息。

## 1.6 Segment高可用

	在GP 6.x也是使用的WAL机制实现的流复制的机制，可以通过gpstate -m 查看信息以及gprecoverseg来恢复节点。

## 1.7 系统表高可用
	系统表gp_segment_configuration进行维护所有节点包括master，standby信息，可以通过select * from gp_segment_configuration where status = ‘d’ 查看
	
	字段名	描述
	dbid	每个节点的唯一ID
	content	每个pair组的id，master-standby为-1,primary-mirror从0开始递减
	role	p'primary，‘m’mirror
	preferred_role	初始化的值，对于一个被promote长primary的mirror节点，role为'p',preferred_role为‘m’
	mode	主从同步状态,'s'同步，‘n’不同步
	status	运行状态，‘u’在线，‘d’不在线
	port	该节点的运行端口
	hostname	节点的hostname
	address	通常和hostname相同
	datadir	该节点的数据目录
	
## 1.8 系统视图高可用
	系统视图gp_stat_replication包含walsender进程的复制状态统计信息。

# 2 Greenplum安全

## 2.1 身份认证
	1、Handles  the  user  anthentication
	2、The file is  located in $MASTER_DATA_DIRECTORY
	3、Comments  are ignored
	4、File is read line by  line 
	5、First  matching  line is used 
	6、All  subsequent lines are ignored
	7、Pessimistic - if no grants,then deny access
	8、To be able to access to a Greenplum database from a distant host,the couple role/host  has to be set in the configuration file pg_hba.conf

### 2.1.1 pg_hba.conf配置连接类型
	Type of connection:
	local : Connection is coming in over the Unix Domain Socket
	host : Connection over the network ,encryption is optional
	hostssl : Connection over the network ,encryption is enforced
	hostnossl: Connection over the network ,no encrytion
	
### 2.1.2 pg_hba.conf配置连接数据库
	Name of database:
	1、Database name, or list of database names separated by comma
	2、‘all’ for all databases
	3、@followed by filename : file containing  databases , one per line
	
### 2.1.3 pg_hba.conf配置连接用户
	Name of the user:
	1、Role name,or list of role names separated by comma
	2、‘all’ for all roles
	3、@followed by filename,file containing role names, one per line
	4、+role name: a group where access is granted all members of this group
	
### 2.1.4 pg_hba.conf配置连接网络地址
	Network address
	1、only for host ,hostssl and hostnossl(1st   column)
	2、Network address might be  an IPv2 or IPv6 address
	
	
	CIDR-Address	IP-Address + IP-Mask	Comment
	192.107.2.89/32	192.107.2.89  255.255.255.255	Single network
	192.107.2.0/24	192.107.2.0  255.255.255.0	Small  network
	192.107.0.0/16	192.107.0.0  255.255.0.0	Large  network
	0.0.0.0/0	0.0.0.0      0.0.0.0  	Full   network
	
### 2.1.5 pg_hba.conf配置用户的认证方法
	Authentication method:
	trust : 该模式可以不用密码直接连接数据库，不安全，一般用于集群内部局域网内
	reject：该模式表示拒绝所有请求
	md5 : 该模式较常用，发送之前使用md5算法加密的密码
	password : 该模式是使用明文密码进行身份认证
	ldap : 使用LDAP服务器认证
	gss : 用GSSAPI和Kerberos认证用户，只对TCP/IP链接可用
	pam: 使用操作系统提供的可插入认证模块服务(PAM)认证
	redius:用RADIUS服务器认证
	cert : 使用SSL客户端证书认证
	Ident: 通过获取客户端的操作系统用户名，检查是否与被访问的数据库用户名匹配
	
## 2.2 数据库连接和数据加密
### 2.2.1 客户端和主数据库之间的链接使用SSL加密
	OpenSSL
	$GP_HOME/etc/openssl.cnf
	
	Configuring  postgresql.conf
	1、ssl  boolean Enables  SSL  connections
	2、ssl_ciphers string
	3、ssl_cert_file = ‘server.crt’
	4、ssl_key_file = ‘server.key’
	
	
	SSL server files in the Master and all Segment Data Directory
	1、server.crt  Server certificate
	2、server.key Server private key
	3、root.crt Trusted certificate authorities
	
### 2.2.2 gpfdist加密数据和链接
	Greenplum 数据允许对分发服务器，gpfdist和segment主机之间传输的数据进行SSL加密
	
	gpfdist --ssl  <certificate_path>
	gpload.yaml  SSL_
	
	CREATE EXTERNAL TABLE ext_expenses (name  text,date  date,amount  float4,category text,desc1   text) LOCATION(‘gpfdist://etlhost-1:8081/*.txt’,’gpfdist://etlhost-2:8082/*.txt’) FORMAT ‘TEXT’(DELIMITER  ‘|’ NULL  ‘’);
	
### 2.2.3 静态数据加密
	使用pgcrypto模块，加密/解密 功能的保护数据库中的静态数据
	1、pgcrypto  Supported Encryption Functions
	Valus  Functionality	Built-in	With OpenSSL
	MD5	yes	yes
	SHA1	yes	yes
	SHA224/256/384/512	yes	yes
	Other digest algorithms	no	yes
	Blowfish	yes	yes
	AES	yes	yes
	DES/3DES/CAST5	no	yes
	Raw Encryption	yes	yes
	PGP Symmetric-key	yes	yes
	PGP Public Key	yes	yes
	
	
	2、General Hashing Functions
	digest()
	hmac()
	
	3、Password Hashing Functions
	crypt()
	gen_salt()
	
	4、PGP Encryption Functions
	pgp_sym_encrypt()
	pgp_sym_decrypt()
	pgp_pub_encrypt()
	pgp_pub_decrypt()
	
	
	5、Raw Encryption Functions
	encrypt()
	decrypt()
	
	
## 2.3 授权
### 2.3.1 授权的对象及权限

	对象类型	特权
	表、视图、序列	SELECT
		INSERT
		UPDATE
		DELETE
		RULE
		ALL
		
	外部表	SELECT
		RULE
		ALL
		
	数据库	CONNECT
		CREATE
		TEMPORARY | TEMP
		ALL
		
	函数	EXECUTE
	过程语言	USAGE
	方案	CREATE
		USAGE
		ALL
		

### 2.3.2 SHA-256加密用户密码
	show  password_encryption;
	password_encryption
	----------------------------
	on
	
	
	set password_hash_algorithm = ‘SHA-256’;
	show  password_hash_algorithm;
	password_hash_algorithm
	-------------------------------
	SHA-256
	
	
	select rolpassword from pg_authid where rolname = ‘testdb’;
	rolpassword
	----------------------
	md5cd60468d9c0660a0b414b77befc289a3
	
	drop  role  testdb;
	create  role testdb  with password ‘123456’ login;
	select rolpassword from pg_authid where rolname = ‘testdb’;
	rolpassword
	-----------------------------------------------------
	sha2562f3d7e9c0c03e6dfc8b3caffac9d20508132d11ef1da985dbb5152d04e100f19
	
	
### 2.3.3 设置用户的访问时间
	
	alter role testdb deny between day ‘Monday’ TIME ‘02:00’ AND DAY ‘Monday’ TIME ‘04:00’;
	
	alter role testdb drop deny  for day ‘Monday’;
	
	
## 2.4 审计
	pg_log/gpdb-2020-*.csv
	1、startup and shutdown  of  the  system
	2、segment  database failures
	3、SQL statements and information
	4、SQL statements that result in an error
	5、all connection attempts and disconnections
	
	gplogfilter  -f ‘panic’ 2020-08*.csv > log.panic
	
	
# 3 Greenplum 备份
## 3.1 gpbackup 和gprestore 
	1、Designed  to  improve  performance , funcctionality ,and  reliability of backups
	2、gpbackup utilizes ASSECC SHARE LOCK at  the individual table level instead of EXCLUSIVE LOCK on pg_class  catalog  table。
	3、This enables to run DDL statements during the backup like CREATE,ALTER,DROP,,and TRUNCATE as long as these aren`t  on the table currently  being backed up.

## 3.2 Full Backups 
	全备份
	gpbackup  --dbname  mytest    --backup-dir /mybackup
	
	增量备份的全备份
	gpbackup --dbname mytest --backup-dir  /mybackup  --leaf-partition-data
	
	
	DataDomain备份
	gpbackup --dbname  demo --single-data-file  -plugin-config  /home/gpadmin/ddboost-test-config.yaml
	
	
## 3.3 Incremental Bckups
	Incremental  backups are efficient  when the total  amount  of data in append-optimized  table  partitions  or column-oriented  tables  that changed  is  small compared  to the  data  has not  changed 
	
### 3.3.1 Supported  woth
	Column-and  row-oriented  append-only  tables
	At  the partition  level of  AO tables
	
### 3.3.2 Back up an AO table if one of the following operations is performed
	ALTER   TABLE
	DELETE
	INSERT
	TRUNCATE
	UPDATE
	DROP and  then  re-create the table
	
	gpback  --dbname mytest  --backup-dir  /mybackup  --leaf-partition-data  --incremental
	
	
## 3.4 gpbackup_manager 管理工具
	显示有关现有设备的信息，删除现有备份或加密安全储存
	gpbackup_manager  list-backups
	gpbackup_manager  display-report  20190612154608
	gpbackup_manager  delete-backup  20190612154608
	gpbackup_manager delete-backup  20190612154608 --plugin-config  ~/ddboost_config.yaml

## 3.5 Other backup tools
	1、pg_dump
	2、pg_dumpall
