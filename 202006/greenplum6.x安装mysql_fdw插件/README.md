# greenplum集成mysql_fdw插件
	1 安装说明
	2 编译安装PostgreSQL 与mysql
		2.1 把下载的PostgreSQL\mysql\MYSQL_FDW放在同目录下
		2.2 编译PostgreSQL 9.4.24
		2.3 复制mysql_fdw-master插件
	3 编译mysql_fdw插件
		3.1 建立libmysqlclient.so的软连接
		3.2 导入环境变量
		3.3 编译mysql_fdw插件
	4 greenplum集成mysql_fdw插件
	5 greenplum链接mysql

# 1 安装说明
	1、先查看安装的greenplum集群的版本，select version()命令得到postgresql的版本,在以下信息中可以看出使用的PostgreSQL 9.4.24的代码
	
	PostgreSQL 9.4.24 (Greenplum Database 6.1.0 build commit:6788ca8c13b2bd6e8976ccffea07313cbab30560)
	
	2、在以下网站上下载对应的PostgreSQL 9.4.24的源代码
	3、在mysql官网上下载源码
	4、在github上下载mysql_fdw插件
	5、下载作者编译好的mysql_fdw插件
	链接：https://pan.baidu.com/s/16faTozfXgD4l4lP0DGoknQ 
	提取码：xcl8
	6、libmysqlclient.so 文件下载
	链接: https://pan.baidu.com/s/1EB-zWTS0shjMKB6iq2NWsw?pwd=k3m0 提取码: k3m0
	
	
	
	下载网站:
	https://www.postgresql.org/ftp/source/
	https://downloads.mysql.com/archives/community/
	https://github.com/EnterpriseDB/mysql_fdw
	
	Mysql请选择linux-Generic版本
	

# 2 编译安装PostgreSQL 与mysql
## 2.1 把下载的PostgreSQL\mysql\MYSQL_FDW放在同目录下
	$  ls
	mysql-5.6.48-linux-glibc2.12-x86_64  mysql-5.6.48-linux-glibc2.12-x86_64.tar.gz  mysql_fdw  PostgreSQL 9.4.24
## 2.2 编译PostgreSQL 9.4.24
	$  cd  PostgreSQL 9.4.24
	$  ./configure
	$  make & make install
	
## 2.3 复制mysql_fdw-master插件
	
	把mysql_fdw-master插件到postgresql-9.5.0/contrib下
	
# 3 编译mysql_fdw插件
## 3.1 建立libmysqlclient.so的软连接
	ln -s /usr/lib/mysql/libmysqlclient.so.20  /usr/lib/mysql/libmysqlclient.so
	或
	sudo yum install libmysqlclient-dev
	或
	yum install -y mysql-libs
	ln -s /usr/lib64/mysql/libmysqlclient.so.18 /usr/local/matrixdb/lib/libmysqlclient.so


## 3.2 导入环境变量
	export PATH=/home/postgresql-9.5.0/src/bin:$PATH
	export PATH=/home/mysql-5.6.48-linux-glibc2.12-x86_64/bin:$PATH
	
## 3.3 编译mysql_fdw插件
	cd /home/mysql_fdw 
	
	$ make USE_PGXS=1
	
	$ make USE_PGXS=1 install
	
# 4 greenplum集成mysql_fdw插件
	复制制定的文件到greenplum指定的目录下
	cp mysql_fdw.so /usr/local/greenplum-db/lib/postgresql/
	cp mysql_fdw.control  /usr/local/greenplum-db/share/postgresql/extension/
	
	cp mysql_fdw--1.0.sql /usr/local/greenplum-db/share/postgresql/extension/
	cp mysql_fdw--1.1.sql /usr/local/greenplum-db/share/postgresql/extension/
	cp mysql_fdw--1.0--1.1.sql /usr/local/greenplum-db/share/postgresql/extension/
	
# 5 greenplum链接mysql
	-- 创建mysql_fdw外部插件
	CREATE EXTENSION mysql_fdw;
	
	-- 创建链接server源
	CREATE SERVER mysql_server
		FOREIGN DATA WRAPPER mysql_fdw
		OPTIONS (host '192.168***', port '3306');
	
	
	-- 添加用户的映射
	CREATE USER MAPPING FOR gpadmin
	SERVER mysql_server
	OPTIONS (username 'root', password '123456');
	
	gpadmin : 映射的gp的用户
	
	
	-- 创建映射外部表
	CREATE FOREIGN TABLE test_tabase(
		id int,
		name text)
	SERVER mysql_server
		OPTIONS (dbname 'tabase', table_name 'test_tabase');
	
	-- 查询表的数据
	select count(*) from test_tabase;
	
	-- 删除信息
	drop SERVER mysql_server CASCADE;

# 6 greenplum 把数据写入到mysql
	-- 创建有主键的mysql表
	mysql> create table test1(t1 int,t2 int,primary key(t1));


	-- greenplum创建表
	create table t1(t1 int,t2 int);
	
	-- 生成大量的数据
	insert into t1 select id as t1,id as t2 from generate_series(1,10000000) t(id);

	-- 把greenplum表导入到mysql中
	insert into test1 select * from t1;


# 7 常见问题
##  找不到 libmysqlclient.so 库
        -- 问题描述
	postgres=# create extension mysql_fdw;
	psql: ERROR:  failed to load the mysql query:
	libmysqlclient.so: cannot open shared object file: No such file or directory
	HINT:  Export LD_LIBRARY_PATH to locate the library.
	
	-- 解答
	链接: https://pan.baidu.com/s/1EB-zWTS0shjMKB6iq2NWsw?pwd=k3m0 提取码: k3m0
	
	ln -s /usr/lib64/mysql/libmysqlclient.so  /usr/lib64/libmysqlclient.so
	
##  远程插入数据不支持
	-- 问题描述
	postgres=# insert into test1 select id as t1,id as t2 from generate_series(1,10) t(id);
	psql: ERROR:  first column of remote table must be unique for INSERT/UPDATE/DELETE operation
 
 	-- 解答
	在mysql数据库上创建有主键的表
