# Greenplum使用oralce_fdw连接oracle

	1 下载oracle客户端,放到/data目录下(主节点)
	2 在root和gpadmin用户下配置环境变量(主节点)
		2.1 配置环境变量
		2.2 建立软连接
		2.3 修改权限
	3 下载编译oracle_fdw(主节点)
	4 编译(主节点)
	5 复制编译文件到所有节点
	6 分发oracle客户端到所有节点
	7 动态连接库增加oracle客户端地址(所有节点执行)
	8 创建oracle_fdw并测试结果(主节点)
	
# 1 下载oracle客户端,放到/data目录下(主节点)
	instantclient-basic-linux.x64-12.2.0.1.0.zip 
	instantclient-sdk-linux.x64-12.2.0.1.0.zip
	instantclient-sqlplus-linux.x64-12.2.0.1.0.zip三个文件包
	#解压缩，并修改目录为instantclient
	mv instantclient_12_2 instantclient
	
	
	下载地址(永久有效):
	链接：https://pan.baidu.com/s/1qxLyMKUBnrjL960TGzMcZg 
	提取码：6pb9
	
	
	或者在作者已经编辑好的文件放在$GPHOME下对应的文件的路径即可
	链接：https://pan.baidu.com/s/1r12_2hw6B8U0dAdwxTV7Iw 
	提取码：8eh2
	
# 2 在root和gpadmin用户下配置环境变量(主节点)
## 2.1 配置环境变量
	export ORACLE_HOME=/data/instantclient
	export OCI_LIB_DIR=$ORACLE_HOME
	export OCI_INC_DIR=$ORACLE_HOME/sdk/include
	export LD_LIBRARY_PATH=$ORACLE_HOME:$LD_LIBRARY_PATH
## 2.2 建立软连接
	进入到$ORACLE_HOME 目录下执行
	ln -s  libclntsh.so.12.1  libclntsh.so
## 2.3 修改权限
	把文件的权限给gpadmin用户
	
	chown  -R   gpadmin:gpadmin   /data/instantclient
## 3 下载编译oracle_fdw(主节点)
	https://github.com/adam8157/oracle_fdw_greenplum

# 4 编译(主节点)

	$ make
	报错如下：这里的意思是没有初始化事务隔离级别，那么需要修改源码
	
	$ vi oracle_utils.c
	
	*oracleGetSession(const char *connectstring, oraIsoLevel isolation_level, char *user, char *password, 
	const char *nls_lang, const char *tablename, int curlevel)
	{
			OCIEnv *envhp = NULL;
			OCIError *errhp = NULL;
			OCISvcCtx *svchp = NULL;
			OCIServer *srvhp = NULL;
			OCISession *userhp = NULL;
			OCITrans *txnhp = NULL;
			oracleSession *session;
			struct envEntry *envp;
			struct srvEntry *srvp;
			struct connEntry *connp;
			char pid[30], *nlscopy = NULL;
			ub4 is_connected;
			int retry = 1;
			ub4 isolevel = OCI_TRANS_NEW;//修改事务隔离级别，否则报错未初始化
	
			/* convert isolation_level to Oracle OCI value */
			switch(isolation_level)
			{
					case ORA_TRANS_SERIALIZABLE:
							isolevel = OCI_TRANS_SERIALIZABLE;
							break;
					case ORA_TRANS_READ_COMMITTED:
							isolevel = OCI_TRANS_NEW;
							break;
					case ORA_TRANS_READ_ONLY:
							isolevel = OCI_TRANS_READONLY;
							break;
			}

	$ make
	gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -fno-aggressive-loop-optimizations -Wno-unused-but-set-variable -Wno-address -O3 -std=gnu99   -Werror=uninitialized -Werror=implicit-function-declaration -fPIC -shared -o oracle_fdw.so oracle_fdw.o oracle_utils.o oracle_gis.o -L/usr/local/greenplum-db-6.5.0/lib    -Wl,--as-needed -Wl,-rpath,'/usr/local/greenplum-db-6.5.0/lib',--enable-new-dtags  -L/data/instantclient -L/data/instantclient/bin -L/data/instantclient/lib -L/data/instantclient/lib/amd64 -lclntsh -L/usr/lib/oracle/19.6/client/lib -L/usr/lib/oracle/19.6/client64/lib -L/usr/lib/oracle/19.3/client/lib -L/usr/lib/oracle/19.3/client64/lib -L/usr/lib/oracle/18.5/client/lib -L/usr/lib/oracle/18.5/client64/lib -L/usr/lib/oracle/18.3/client/lib -L/usr/lib/oracle/18.3/client64/lib -L/usr/lib/oracle/12.2/client/lib -L/usr/lib/oracle/12.2/client64/lib -L/usr/lib/oracle/12.1/client/lib -L/usr/lib/oracle/12.1/client64/lib -L/usr/lib/oracle/11.2/client/lib -L/usr/lib/oracle/11.2/client64/lib -L/usr/lib/oracle/11.1/client/lib -L/usr/lib/oracle/11.1/client64/lib -L/usr/lib/oracle/10.2.0.5/client/lib -L/usr/lib/oracle/10.2.0.5/client64/lib -L/usr/lib/oracle/10.2.0.4/client/lib -L/usr/lib/oracle/10.2.0.4/client64/lib -L/usr/lib/oracle/10.2.0.3/client/lib -L/usr/lib/oracle/10.2.0.3/client64/lib


	$ make install
	/usr/bin/mkdir -p '/usr/local/greenplum-db-6.5.0/lib/postgresql'
	/usr/bin/mkdir -p '/usr/local/greenplum-db-6.5.0/share/postgresql/extension'
	/usr/bin/mkdir -p '/usr/local/greenplum-db-6.5.0/share/postgresql/extension'
	/usr/bin/mkdir -p '/usr/local/greenplum-db-6.5.0/share/doc/postgresql/extension'
	/usr/bin/install -c -m 755  oracle_fdw.so '/usr/local/greenplum-db-6.5.0/lib/postgresql/oracle_fdw.so'
	/usr/bin/install -c -m 644 oracle_fdw.control '/usr/local/greenplum-db-6.5.0/share/postgresql/extension/'
	/usr/bin/install -c -m 644 oracle_fdw--1.2.sql oracle_fdw--1.0--1.1.sql oracle_fdw--1.1--1.2.sql '/usr/local/greenplum-db-6.5.0/share/postgresql/extension/'
	/usr/bin/install -c -m 644 README.oracle_fdw '/usr/local/greenplum-db-6.5.0/share/doc/postgresql/extension/'

# 5 复制编译文件到所有节点
	将主节点/usr/local/greenplum-db-6.5.0/lib/postgresql/oracle_fdw.so放到所有节点相应目录下
	将主节点/usr/local/greenplum-db-6.5.0/share/postgresql/extension下的所有oracle_fdw相关的文件放到所有节点相应目录下
# 6 分发oracle客户端到所有节点
	1、用gpadmin用户把 /data/instantclient 发送到其他的segment节点上的相同目录下
	2、并把master节点上的环境变量发送到其他的segment的节点上
	
# 7 动态连接库增加oracle客户端地址(所有节点执行)

	所有节点执行下列操作：
	每个节点加入oracle客户端的库路径（root用户），让pg
	$ cd /etc/ld.so.conf.d/
	$ vi oracle-x86_64.conf
	$ /data/instantclient
	$ ldconfig

	注:如果不执行上述步骤，在create extension时会报错：

# 8 创建oracle_fdw并测试结果(主节点)
	postgres=$ create extension oracle_fdw;
	CREATE EXTENSION
	
	创建名称为oradb 的oracle_fdw
	postgres=$ CREATE SERVER oradb FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver '//IPADDR:1521/amrdb');
	CREATE SERVER
	
	IPADDR : 是链接oracle的IP地址 
	
	
	
	为用户gpadmin创建基于oradb的mapping
	postgres=$ CREATE USER MAPPING FOR gpadmin SERVER oradb  OPTIONS (user 'amr', password 'amr');
	CREATE USER MAPPING
	
	
	创建外部表，其中schema 'AMR', table 'T_FDW'为oracle的用户名和表名
	postgres=$ CREATE FOREIGN TABLE t_fdw_ora(id int)SERVER oradb OPTIONS (schema 'AMR', table 'T_FDW');
	CREATE FOREIGN TABLE
	
	
	测试连接成功
	postgres=$ select * from t_fdw_ora;
	id 
	----
	1