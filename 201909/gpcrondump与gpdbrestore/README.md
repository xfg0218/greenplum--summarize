# 目录结构
	1、gpcrondump 详细介绍
	2、gpcrondump 常用参数
	3、备份数据库中的数据
		3.1 备份databases  下的所有的表
		3.2 备份 schema  下的所有的表
		3.3 备份制定tablename的数据
	4 使用gpdbrestore恢复数据
		4.1 恢复databases数据库下所有的数据
		4.2 恢复指定schema下的所有表的数据
		4.3 恢复指定tablename的数据

# 参考资料
	参考资料:http://www.dbaref.com/gpcrondump
	https://gp-docs-cn.github.io/docs/admin_guide/managing/backup-gpcrondump.html

# 注意事项
	1、如果使用命令gpcrondump时,默认的数据存放路径在echo $MASTER_DATA_DIRECTORY 下面的db_dumps下,并不会备份实体数据，只会备份源数据保存的点
	2、gpcrondump 命令-s不能与-t或-T同事使用
	3、gpcrondump备份增量表时会判断全量的表明,在文件gp_dump_<timestamp_key>_table_list
	4、在gpdbrestore 恢复数据时如果重复恢复同一个时间戳的批次，会以此追加数据到表中,使用truncate即可解决
	   
# 1、gpcrondump 详细介绍
	1、使用gpcrondump来备份数据库、数据以及数据库角色和服务器配置文件之类的对象。
	2、gpcrondump工具在Master和每个Segment上转储一个Greenplum数据库的内容为SQL脚本文件。
	3、这些脚本文件接下来可以被用来恢复这个数据库。
	4、Master的备份文件包含用于创建数据库模式的SQL命令。
	5、Segment的数据转储文件包含将数据装载到表中的SQL语句。Segment的转储文件被使用gzip压缩。
	6、可选地，服务器配置文件postgresql.conf、pg_ident.conf和pg_hba.conf以及角色和表空间这类全局数据可以被包括在备份中。
	
# 2、gpcrondump 常用参数

	$ gpcrondump  --help
	gpcrondump -x database_name 
	     [-s <schema> | -S <schema> | -t <schema>.<table> | -T <schema>.<table>] 
	     [--table-file=<filename> | --exclude-table-file=<filename>] 
	     [--schema-file=<filename> | --exclude-schema-file=<filename>] 
	     [-u backup_directory] [-R post_dump_script] [--incremental] 
	     [ -K <timestamp> [--list-backup-files] ] 
	     [--prefix <prefix_string> [--list-filter-tables] ]
	     [ -c  [ --cleanup-date yyyymmdd  |  --cleanup-total n ] ]
	     [-z] [-r] [-f <free_space_percent>] [-b] [-h] [-H] [-j | -k]
	     [-g] [-G] [-C] [-d <master_data_directory>] [-B <parallel_processes>] 
	     [-a] [-q] [-l <logfile_directory>]
	     [--email-file <path_to_file> ] [-v]
	     { [-E encoding] [--inserts | --column-inserts] [--oids]
	     [--no-owner | --use-set-session-authorization] 
	     [--no-privileges] [--rsyncable] 
	     { [--ddboost [--replicate --max-streams <max_IO_streams> 
	     [--ddboost-skip-ping] ] 
	     [--ddboost-storage-unit=<storage_unit_name>] ] } |
	     { [--netbackup-service-host <netbackup_server> 
	     --netbackup-policy <netbackup_policy> 
	     --netbackup-schedule <netbackup_schedule> 
	     [--netbackup-block-size <size> ] 
	     [--netbackup-keyword <keyword> ] } }
	 
	gpcrondump --ddboost-host <ddboost_hostname>
	     [--ddboost-host ddboost_hostname ... ]
	     --ddboost-user <ddboost_user>
	     --ddboost-backupdir <backup_directory>
	     [--ddboost-storage-unit=<storage_unit_name>]
	     [--ddboost-remote] [--ddboost-skip-ping]
	 
	gpcrondump --ddboost-config-remove
	 
	gpcrondump --ddboost-show-config [--ddboost-remote]
	 
	gpcrondump -o  [ --cleanup-date yyyymmdd  |  --cleanup-total n ]
	 
	gpcrondump -? 
	 
	gpcrondump --version
	 
	 
	-a（不要提示）
	不要提示用户进行确认。
	 
	-b（绕过磁盘空间检查）
	绕过磁盘空间检查。默认设置是检查可用磁盘空间。
	 
	-B parallel_processes
	要进行转储前/转储后验证的并行检查段数。如果未指定，该实用程序将启动多达60个并行进程，具体取决于数量
	需要转储的段实例。
	 
	-c（首先清除旧的转储文件）
	在执行转储之前清除旧的转储文件。默认情况下不清除旧转储文件。这将删除db_dumps目录中的所有旧转储目录，
	除了当前日期的转储目录。
	 
	-C（清理旧目录转储）
	在创建之前清除旧目录模式转储文件。
	 
	--column-inserts
	将数据转储为具有列名称的INSERT命令。
	 
	-d master_data_directory
	主主机数据目录。如果未指定，将使用为$ MASTER_DATA_DIRECTORY设置的值。
	 
	-D（调试）
	将日志记录级别设置为debug。
	 
	-E encoding
	转储数据的字符集编码。默认为要转储的数据库的编码。
	 
	-f free_space_percent
	在进行检查以确保有足够的可用磁盘空间来创建转储文件时，指定在应用之后应保留的可用磁盘空间的百分比。
	转储完成。默认值为10％。
	 
	-g（复制配置文件）
	保护主要和段配置文件postgresql.conf，pg_ident.conf和pg_hba.conf的副本。这些配置文件被转储到
	master或segment数据目录到db_dumps / YYYYMMDD / config_files_ <timestamp> .tar
	 
	-G（转储全局对象）
	使用pg_dumpall转储角色和表空间等全局对象。全局对象在主数据目录中转储到db_dumps / YYYYMMDD / gp_global_1_1_ <timestamp>。
	 
	-i（忽略参数检查）
	忽略初始参数检查阶段。
	 
	--inserts
	将数据转储为INSERT，而不是COPY命令。
	 
	-j（转储前真空）
	在转储开始之前运行VACUUM。
	 
	-k（转储后真空）
	转储成功完成后运行VACUUM。
	 
	-l logfile_directory
	写入日志文件的目录。默认为〜/ gpAdminLogs。
	 
	--no所有者
	不输出命令来设置对象所有权。
	 
	--no-特权
	不要输出命令来设置对象权限（GRANT / REVOKE命令）。
	 
	-o（仅清除旧转储文件）
	仅清除旧转储文件，但不运行转储。这将删除除当前日期的转储目录之外的最旧的转储目录。其中的所有转储集
	目录将被删除。
	 
	--oids
	在转储数据中包含对象标识符（oid）。
	 
	-p（仅限主要部分）
	转储所有主要段，这是默认行为。注意：不推荐使用此选项。
	 
	-q（无屏幕输出）
	以安静模式运行。命令输出不会显示在屏幕上，但仍会写入日志文件。
	 
	-r（失败时无回滚）
	如果检测到故障，请勿回滚转储文件（删除部分转储）。默认是回滚（删除部分转储文件）。
	 
	-R post_dump_script
	成功转储操作后要运行的脚本的绝对路径。例如，您可能需要一个脚本将完成的转储文件移动到备份主机。此脚本必须位于主服务器和所有段主机上的相同位置。
	 
	-s schema_name
	仅转储指定数据库中的命名模式。
	 
	-t schema.table_name
	仅转储此数据库中的指定表。-t选项可以多次指定。
	 
	-T schema.table_name
	要从数据库转储中排除的表名。-T选项可以多次指定。
	 
	-u backup_directory
	指定备份文件将放置在每个主机上的绝对路径。如果路径不存在，则会创建该路径（如果可能）。如果未指定，则默认为要备份的每个实例的数据目录。如果每个段主机具有多个段实例，则可能需要使用此选项，因为它将在集中位置而不是段数据目录中创建转储文件。
	 
	--use设置会话授权
	使用SET SESSION AUTHORIZATION命令而不是ALTER OWNER命令来设置对象所有权。
	 
	-v（显示实用程序版本）
	显示此实用程序的版本，状态，上次更新日期和校验和。
	 
	-w dbid [，...]（仅备份某些段）
	指定要备份为段的dbid的逗号分隔列表的一组活动段实例。主服务器自动添加到列表中。默认设置是备份所有活动的段实例。
	 
	-x database_name
	需要。要转储的Greenplum数据库的名称。
	 
	-y reportfile
	指定备份作业日志文件将放置在主控主机上的完整路径名。如果未指定，则默认为主数据目录或正在运行
	远程，当前的工作目录。
	 
	-z (no compression)
	不要使用压缩。默认是使用gzip压缩转储文件。
	 
	-? (help)
	显示在线帮助。


# 3、备份数据库中的数据
	3.1 备份databases  下的所有的表
	gpcrondump -a -x databases
 
	-a : 不需要确认
	databases : 数据库的名字
	
	3.2    备份 schema  下的所有的表
		1、备份文件不加前缀的如下
		gpcrondump -a -x databases -s schemaname
		schemaname : schema 的名字
 
		2、备份文件添加前缀
		gpcrondump -a -x databases -s schemaname --prefix prefixname
		prefixname: 需要制定的前缀的信息
 
		3、按照全量的文件备份增量数据表
		gpcrondump -a -x databases --prefix prefixname --incremental
		--incremental : 增量关键字

	3.3 备份制定tablename的数据
	1、制定单个表的名字
		gpcrondump -a -x  databases   --prefix  prefixname  -t  schemaname.tablename
 
		schemaname.tablename : 表名
		prefixname  : 前缀名字
 
		注意-t或-T不能同时与-s使用
 
	2、备份指定文件表的集合
		gpcrondump -a -x  databases   --prefix  prefixname  --table-file=filename
		filename: 文件的名字

# 4、使用gpdbrestore恢复数据
	4.1 恢复databases数据库下所有的数据
		gpdbrestore -a -s databases -t <timestamp_key>
 
		databases:恢复的数据库
		timestamp: 备份数据库的时间戳
		
	4.2 恢复指定schema下的所有表的数据
		gpdbrestore  -a  -S schemaname --prefix prefixname   -t  <timestamp_key>
 
		-S : 需要恢复的schema下的所有表的数据
		prefixname   : 备份文件的前缀
		<timestamp_key>: 含有schema的时间戳
		
	4.3 恢复指定tablename的数据
		
		1、指定单个表的名字恢复
		gpdbrestore -a  -S schemaname  --prefix prefixname  -T schema.tablename  -t <timestamp_key>
 
		schema.tablename : 需要恢复的表
		<timestamp_key>: 时间戳

		2、恢复之前清空原始表的数据
		gpdbrestore -a -S  schemaneme --truncate  -T  schema.tablename  -t  <timestamp_key>
 
		schemaneme  : schema的名字
		schema.tablename : truncate 掉原始的表数据
 
 
		3、恢复制定在文件中的表的名字
		gpdbrestore -a --truncate --table-file=filename  --prefix  prefixname  -t <timestamp_key>
 
		filename : 文件的名字
		prefixname : 前缀的名字
		<timestamp_key> : 时间戳









