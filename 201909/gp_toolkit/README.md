# gp_toolkit 说明

	Greenplum数据库提供了一个名为gp_tooikit的管理schema,该schema下有关于查询系统目录,日志文件,
	用户创建(databases,schema,table,indexs,view,function)等信息,也可以查询资源队列,表的膨胀表,表的倾斜,
	系统自己维护的ID等的相关信息。注意不要在该schema下创建任何对象,否则会影响系统对元数据维护的错误问题,
	同时再使用gpcrondump和gpdbrestore程序进行备份和恢复数据时,之前维护的元数据会发生更改。

## 1、表膨胀相关查询

	-- 该视图显示了那些膨胀的（在磁盘上实际的页数超过了根据表统计信息得到预期的页数）正规的堆存储的表。
	select * from gp_toolkit.gp_bloat_diag;
	
	-- 所有对象的膨胀明细
	select * from gp_toolkit.gp_bloat_expected_pages;


## 2、表倾斜的相关信息

	-- 该视图通过计算存储在每个Segment上的数据的变异系数（CV）来显示数据分布倾斜。
	select * from gp_toolkit.gp_skew_coefficients;
	
	-- 该视图通过计算在表扫描过程中系统空闲的百分比来显示数据分布倾斜，这是一种数据处理倾斜的指示器。
	select * from gp_toolkit.gp_skew_idle_fractions;


## 3、锁查询相关的信息

	-- 该视图显示了当前所有表上持有锁，以及查询关联的锁的相关联的会话信息。
	select * from gp_toolkit.gp_locks_on_relation;
	
	-- 该视图显示当前被一个资源队列持有的所有的锁，以及查询关联的锁的相关联的会话信息。
	select * from gp_toolkit.gp_locks_on_resqueue;


## 4、日志查询相关的信息

	-- 该视图使用一个外部表来读取来自整个Greenplum（Master、Segment、镜像）的服务器日志文件并且列出所有的日志项。
	select * from gp_toolkit.gp_log_system;
	
	-- 该视图用一个外部表来读取在主机上的日志文件同时报告在数据库会话中SQL命令的执行时间
	select * from gp_toolkit.gp_log_command_timings;
	
	-- 该视图使用一个外部表来读取整个Greenplum系统（主机，段，镜像）的服务器日志文件和列出与当前数据库关联的日志的入口。
	select * from gp_toolkit.gp_log_database;
	
	-- 该视图使用一个外部表读取来自Master日志文件中日志域的一个子集。
	select * from gp_toolkit.gp_log_master_concise;


## 5、资源队列相关查询信息

	-- gp_toolkit.gp_resgroup_config视图允许管理员查看资源组的当前CPU、内存和并发限制
	select * from gp_toolkit.gp_resgroup_config;
	
	-- gp_toolkit.gp_resgroup_status视图允许管理员查看资源组的状态和活动
	select * from gp_toolkit.gp_resgroup_status;
	
	-- 该视图允许管理员查看到一个负载管理资源队列的状态和活动。
	select * from gp_toolkit.gp_resqueue_status;
	
	-- 对于那些有活动负载的资源队列，该视图为每一个通过资源队列提交的活动语句显示一行。
	select * from gp_toolkit.gp_resq_activity;
	
	-- 对于有活动负载的资源队列，该视图显示了队列活动的总览。
	select * from gp_toolkit.gp_resq_activity_by_queue;
	
	-- 资源队列的执行优先级
	select * from gp_toolkit.gp_resq_priority_backend;
	
	-- 该视图为当前运行在Greenplum数据库系统上的所有语句显示资源队列优先级、会话ID以及其他信息
	select * from gp_toolkit.gp_resq_priority_statement;
	
	-- 该视图显示与角色相关的资源队列。
	select * from gp_toolkit.gp_resq_role;


## 6、查看磁盘上(database,schema,table,indexs,view)等的占用大小的相关信息

	-- 外部表在活动Segment主机上运行df（磁盘空闲）并且报告返回的结果
	select * from gp_toolkit.gp_disk_free;
	
	-- 该视图显示数据库的总大小。
	select * from gp_toolkit.gp_size_of_database;
	
	-- 该视图显示当前数据库中schema在数据中的大小
	select * from gp_toolkit.gp_size_of_schema_disk;
	
	-- 该视图显示一个表在磁盘上的大小。
	select * from gp_toolkit.gp_size_of_table_disk;
	
	-- 该视图查看表的索引
	select * from gp_toolkit.gp_table_indexes;
	
	-- 该视图显示了一个表上所有索引的总大小。
	select * from gp_toolkit.gp_size_of_all_table_indexes;
	
	-- 该视图显示分区子表及其索引在磁盘上的大小。
	select * from gp_toolkit.gp_size_of_partition_and_indexes_disk;
	
	-- 该视图显示表及其索引在磁盘上的大小。
	select * from gp_toolkit.gp_size_of_table_and_indexes_disk;
	
	-- 该视图显示表及其索引的总大小
	select * from gp_toolkit.gp_size_of_table_and_indexes_licensing;
	
	-- 该视图显示追加优化（AO）表没有压缩时的大小。
	select * from gp_toolkit.gp_size_of_table_uncompressed;



## 7、用户使用的工作空间大小信息

	-- 该视图为当前在Segment上使用磁盘空间作为工作文件的操作符包含一行。
	select * from gp_toolkit.gp_workfile_entries;
	
	-- GP工作文件管理器使用的磁盘空间
	select * from gp_toolkit.gp_workfile_mgr_used_diskspace;
	
	-- 每个查询的GP工作文件使用情况
	select * from gp_toolkit.gp_workfile_usage_per_query;
	
	-- 每个segment在GP工作文件中的使用量
	select * from gp_toolkit.gp_workfile_usage_per_segment;


## 8、查看用户创建的信息(数据库,schema,表,索引,函数,视图)等信息

	-- gp 中所有的名字(索引、表、视图、函数)等的名字
	select * from gp_toolkit."__gp_fullname";
	
	-- gp 中AO表的名字
	select * from gp_toolkit."__gp_is_append_only";
	
	-- gp 中segment的个数
	select * from gp_toolkit."__gp_number_of_segments";
	
	-- gp 中用户表的个数
	select * from gp_toolkit."__gp_user_data_tables";
	
	-- GP用户数据表可读
	select * from gp_toolkit."__gp_user_data_tables_readable";
	
	-- 用户自己创建的schema信息
	select * from gp_toolkit."__gp_user_namespaces";
	
	-- 用户自己创建的表信息
	select * from gp_toolkit."__gp_user_tables";
	

## 9、系统中维护的ID信息

	-- gp  本地维护的ID
	select * from gp_toolkit."__gp_localid";
	
	-- gp master外部的log信息
	select * from gp_toolkit."__gp_log_master_ext";
	
	-- gp segment外部的log信息
	select * from gp_toolkit."__gp_log_segment_ext";
	
	-- gp master 的id信息
	select * from gp_toolkit."__gp_masterid";


## 10、系统查用的查询信息

	-- 该视图显示那些没有统计信息的表，因此可能需要在表上执行ANALYZE命令。
	select * from gp_toolkit.gp_stats_missing;
	
	-- 该视图显示系统目录中被标记为down的Segment的信息。
	select * from gp_toolkit.gp_pgdatabase_invalid;
	
	-- 那些被分类为本地（local）（表示每个Segment从其自己的postgresql.conf文件中获取参数值）的服务器配置参数，应该在所有Segment上做相同的设置。
	select * from gp_toolkit.gp_param_settings_seg_value_diffs;
	
	-- 该视图显示系统中所有的角色以及指派给它们的成员（如果该角色同时也是一个组角色）。
	select * from gp_toolkit.gp_roles_assigned;

## 11、系统中常用查询的函数
	select * from gp_toolkit.gp_param_settings();
	select * from gp_toolkit.gp_skew_details(oid);
	select * from gp_toolkit."__gp_aocsseg"(IN  oid);
	select * from gp_toolkit."__gp_aovisimap"(IN  oid);
	select * from gp_toolkit.gp_param_setting(varchar);
	select * from gp_toolkit."__gp_skew_coefficients"();
	select * from gp_toolkit."__gp_workfile_entries_f"();
	select * from gp_toolkit."__gp_skew_idle_fractions"();
	select * from gp_toolkit."__gp_aocsseg_name"(IN  text);
	select * from gp_toolkit."__gp_aovisimap_name"(IN  text);
	select * from gp_toolkit."__gp_aocsseg_history"(IN  oid);
	select * from gp_toolkit."__gp_aovisimap_entry"(IN  oid);
	select * from gp_toolkit."__gp_aovisimap_hidden_typed"(oid);
	select * from gp_toolkit."__gp_param_local_setting"(varchar);
	select * from gp_toolkit."__gp_aovisimap_entry_name"(IN  text);
	select * from gp_toolkit."__gp_aovisimap_hidden_info"(IN  oid);
	select * from gp_toolkit."__gp_workfile_mgr_used_diskspace_f"();
	select * from gp_toolkit."__gp_aovisimap_hidden_info_name"(IN  text);
	select * from gp_toolkit.gp_skew_coefficient(IN targetoid oid, OUT skcoid oid, OUT skccoeff numeric);
	select * from gp_toolkit.gp_skew_idle_fraction(IN targetoid oid, OUT sifoid oid, OUT siffraction numeric);
	select * from gp_toolkit.gp_bloat_diag(IN btdrelpages int4, IN btdexppages numeric, IN aotable bool, OUT bltidx int4, OUT bltdiag text);
	select * from gp_toolkit."__gp_aovisimap_compaction_info"(IN ao_oid oid, OUT content int4, OUT datafile int4, OUT compaction_possible bool, OUT hidden_tupcount int8, OUT total_tupcount int8, OUT percent_hidden numeric);

