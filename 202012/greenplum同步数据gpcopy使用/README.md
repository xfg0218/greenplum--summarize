# gpcopy 资料查看
	
	gpcopy下载网站
	https://network.pivotal.io/products/gpdb-data-copy
	
	GPDB对应的gpcopy版本查看
	https://network.pivotal.io/products/pivotal-gpdb#/releases/93896
	
	gpcopy参考资料
	https://gpdb.docs.pivotal.io/data-copy/2-3/gpcopy.html
	
	
# gpcopy命令说明
	gpcopy 该实用程序将对象从源Greenplum数据库系统中的数据库复制到目标Greenplum数据库系统中的数据库。
	
	该gpcopy 该实用程序仅在Pivotal Greenplum数据库的商业版本中可用
 
# gpcopy 命令安装
	1、解压
	tar xzvf gpcopy-version.tar.gz
	
	2、把解压出来的gpcopy和gpcopy_helper复制到/usr/local/greenplum-db/bin/ 下
	cp gpcopy /usr/local/greenplum-db/bin/
	cp gpcopy_helper /usr/local/greenplum-db/bin/
	
	3、把命令付给权限
	chmod 755 /usr/local/greenplum-db/bin/gpcopy*
	
	4、在同步的集群上安装gpcopy和gpcopy_helper命令
	在需要同步的集群上安装对应版本的gpcopy和gpcopy_helper命令
	
# gpcopy 命令帮助

	gpcopy --help
	gpcopy utility is for copying objects from a Greenplum cluster to another
	
	Usage:
	gpcopy [flags]
	
	Flags:
	-a, --analyze                          Analyze tables after copy
		--append                           Append destination table if it exists
		--data-port-range DashInt          The range of port number destination helper chooses to transfer data in
	-d, --dbname string                    The database to be copied
		--debug                            Print debug log messages
	-D, --dest-dbname string               The database in destination cluster to copy to
		--dest-host string                 The host of destination cluster
		--dest-mapping-file string         Use the host to IP map file in case of destination cluster IP auto-resovling fails
		--dest-port int                    The port of destination cluster (default 5432)
		--dest-table string                The renamed dest table(s) for include-table, separated by commas, supports regular expression
		--dest-user string                 The user of destination cluster (default "gpadmin")
		--drop                             Drop destination table if it exists prior to copying data
		--dry-run                          Just run for test without affecting gpdb schema or data
		--dumper string                    The dll dumper to be used. "pgdump" or "gpbackup" ("gpbackup" is an experimental option) (default "pgdump")
		--enable-receive-daemon            Use a daemon helper process with a single port on destination to receive data (default true)
	-e, --exclude-table string             Copy all tables except the specified table(s), separated by commas
	-E, --exclude-table-file ArrayString   Copy all tables except the specified table(s) listed in the file
	-F, --full                             Copy full data cluster
	-h, --help                             help for gpcopy
	-t, --include-table string             Copy only the specified table(s), separated by commas, supports regular expression
	-T, --include-table-file string        Copy only the specified table(s) listed in the file
		--include-table-json string        Copy only the specified table(s) listed in the json format, can contain destination table name and filter SQL.
		--jobs int                         The maximum number of tables that concurrently copies, valid values are between 1 and 64512 (default 4)
	-m, --metadata-only                    Only copy metadata, do not copy data
		--no-compression                   Transfer the plain data, instead of compressing as Snappy format
		--no-distribution-check            Don't check distribution while copying
		--no-ownership                     Don't copy owner and privileges for table or sequence
	-o, --on-segment-threshold int         Copy between masters directly, if the table has smaller or same number of rows (default 10000)
	-p, --parallelize-leaf-partitions      Copy the leaf partition tables in parallel (default true)
		--quiet                            Suppress non-warning, non-error log messages
		--skip-existing                    Skip tables that exist in destination cluster
		--source-host string               The host of source cluster (default "127.0.0.1")
		--source-port int                  The port of source cluster (default 5432)
		--source-user string               The user of source cluster (default "gpadmin")
		--timeout int                      The timeout in second to wait until source and destination are both ready for data transferring. '0' means waiting forever. (default 30)
		--truncate                         Truncate destination table if it exists prior to copying data
		--truncate-source-after            Truncate the source table after it's copied to release storage space
	-v, --validate string                  The method performing data validation on table data, "count" or "md5xor"
		--verbose                          Print verbose log messages
		--version                          version for gpcopy
		--yes                              Do not prompt
	
	
	
# gpcopy 命令实例
	1、此命令使用以下命令将源系统中所有用户创建的数据库复制到目标系统： 
	-full 选项。如果目标中已经存在该表，则删除该表并再次创建它
	gpcopy --source-host mytest --source-port 1234 --source-user gpuser \ 
		--dest-host demohost --dest-port 1234 --dest-user gpuser \ 
		--full --drop
	
	2、此命令使用以下命令将源系统中的指定数据库复制到目标系统： --dbname选项。
	--truncate 选项从源表复制表数据之前将其截断。
		gpcopy --source-host mytest --source-port 1234 --source-user gpuser \
	--dest-host demohost --dest-port 1234 --dest-user gpuser \
	--dbname database1, database2 --truncate
		
	3、此命令使用以下命令将源系统中的指定表复制到目标系统： --include-table选项。
	的 --skip-existing 如果目标数据库中已经存在该表，则该选项将跳过该表。
		gpcopy --source-host mytest --source-port 1234 --source-user gpuser \
	--dest-host demohost --dest-port 1234 --dest-user gpuser \
	--include-table database.schema.table1, database.schema.table2 --skip-existing
		
	4、该命令将表从源数据库复制到目标系统，但不包括在/home/gpuser/mytables与--exclude-table-file选项。
	--truncate选项会截断目标系统中已经存在的表。带有--analyze and 
	--validat count，该实用程序对复制的表执行ANALYZE操作，并通过比较源表和目标表之间的行数来验证复制的表数据。
		
		gpcopy --source-host mytest --source-port 1234 --source-user gpuser \
	--dest-host demohost --dest-port 1234 --dest-user gpuser \
	--dbname database1 --exclude-table-file /home/gpuser/mytables \
	--truncate --analyze --validate count
	
	5、此命令指定 --full 和  --metadata-only 复制所有数据库模式的选项，包括所有源数据库中的所有表，
	索引，视图，用户定义的类型（UDT）和用户定义的函数（UDF）。没有数据被复制，
	--drop选项指定如果表在源数据库和目标数据库中都存在，则在重新创建该表之前将其删除到目标数据库中。
		
		gpcopy --source-host mytest --source-port 1234 --source-user gpuser \
	--dest-host demohost --dest-port 1234 --dest-user gpuser \
	--full --metadata-only --drop
	
	6、此命令使用以下命令将源系统中的指定数据库复制到目标系统： --dbname 选项，
	并指定8个并行进程 --jobs选项。该命令指定--truncat选项以截断该表，如果目标数据库中已存在该表，
	则重新创建该表，并使用2000-2010范围内的端口进行并行进程连接。
		gpcopy --source-host mytest --source-port 1234 --source-user gpuser \
	--dest-host demohost --dest-port 1234 --dest-user gpuser \
	--dbname database1, database2 --truncate --jobs 8 --data-port-range 2000-2010
		
	7、此命令使用以下命令将源系统中的指定数据库复制到目标系统： --dbname 选项，
	并指定16个并行进程 --jobs选项。--truncate如果目标数据库中已经存在该选项，
	则该选项将截断该表并再次创建它。的 --truncate-source-after 该选项在目标数据库中验证了表数据之后，
	将截断源数据库中的表。
		gpcopy --source-host mytest --source-port 1234 --source-user gpuser \
	--dest-host demohost --dest-port 1234 --dest-user gpuser \
	--dbname database1 --truncate --jobs 16 --truncate-source-after --validate count
	