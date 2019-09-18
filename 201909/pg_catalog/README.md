# 目录
	1、Greenplum  基本查询信息
		1.1、Greenplum 常用查询
		1.2、Greenplum 触发器,锁,类型等相关信息
		1.3、Greenplum 故障检测相关的信息
		1.4、Greenplum 分布式事务有关信息
		1.5、 Greenplum  segment 有关信息
		1.6、Greenplum 数据文件状态有关信息
		1.7、Greenplum 有关储存的信息
	2、Greenplum 插件相关信息
	3、Greenplum 分区表的相关信息
	4、Greenplum 资源队列相关信息  
	5、Greenplum 表,视图,索引等有关信息
		5.1、Greenplum 中支持的索引
		5.2、Greenplum 表的关系信息
	6、Greenplum 系统目录存储基本信息
		6.1、Greenplum 储存database,schema,table,view等的信息
	7、以下只有在进入到gpexpand扩展时,才可以查询

# Greenplum  基本查询信息

## Greenplum 常用查询
	
	--  pg_constraint 对存储对表的检查,主键,唯一和外键约束。
	select * from pg_catalog.pg_constraint;
	
	--  pg_compression 描述了可用的压缩方法
	select * from pg_catalog.pg_compression;
	
	-- pg_class 目录表和大多数具有列或其他类似于表的所有其他表（也称为关系）。
	select * from pg_catalog.pg_class;
	
	--  pg_conversion 系统目录表描述了可用的编码转换过程create转换。
	select * from pg_catalog.pg_conversion;
	
	--  pg_operator 存储有关运算符的信息,包括内置和由其定义的运算符CREATE OPERATOR
	select * from pg_catalog.pg_operator;
	
	--  pg_partition 用于跟踪分区表及其继承级别关系。
	select * from pg_catalog.pg_partition;
	
	--  pg_pltemplate 存储过程语言的模板信息。
	select * from pg_catalog.pg_pltemplate;
	
	--  pg_proc 有关函数（或过程）的信息，包括内置函数和由函数定义的函数CREATE FUNCTION。
	select * from pg_catalog.pg_proc;
	
	--  pg_roles 提供对数据库角色信息的访问
	select * from pg_catalog.pg_roles;
	
	--  pg_shdepend 记录数据库对象和共享对象（如角色）之间的依赖关系。
	select * from pg_catalog.pg_shdepend;
	
	--  pg_shdescription 存储共享数据库对象的可选描述（注释）。
	select * from pg_catalog.pg_shdescription;
	
	--  pg_stat_activity每个服务器进程显示一行，并显示有关用户会话和查询的详细信息。
	select * from pg_catalog.pg_stat_activity;
	
	-- pg_stat_last_operation 包含有关数据库对象（表，视图等）的元数据跟踪信息。
	select * from pg_catalog.pg_stat_last_operation;
	
	-- pg_stat_last_shoperation 包含有关全局对象（角色，表空间等）的元数据跟踪信息。
	select * from pg_catalog.pg_stat_last_shoperation;
	
	--  pg_auth_members 显示角色之间的成员关系。
	select * from pg_catalog.pg_auth_members;
	
	
##  Greenplum 触发器,锁,类型等相关信息
	
	--  pg_trigger 触发器查询信息。
	select * from pg_catalog.pg_trigger;
	
	--  pg_type 数据库中数据类型的信息。
	select * from pg_catalog.pg_type;
	
	--  pg_locks 数据库中打开的事务所持有的锁的信息的访问。
	select * from pg_catalog.pg_locks;
	
	--  pg_user_mappingcatalog表存储从本地用户到远程用户的映射。
	select * from pg_catalog.pg_user_mapping;
	
	--  pg_window 表存储有关窗口函数的信息。
	select * from pg_catalog.pg_window;
	
	
##  Greenplum 故障检测相关的信息
	
	--  gp_configuration_history 包含有关故障检测和恢复操作的系统更改的信息。
	select * from pg_catalog.gp_configuration_history order by time desc;
	
	--  gp_fault_strategy 指定故障动作。
	select * from pg_catalog.gp_fault_strategy;


## Greenplum 分布式事务有关信息
	
	--  gp_distributed_log 包含有关分布式事务及其关联的本地事务的状态信息。
	select * from pg_catalog.gp_distributed_log;
	
	--  gp_distributed_xacts 包含有关Greenplum Database分布式事务的信息。
	select * from pg_catalog.gp_distributed_xacts;
	
	
## Greenplum  segment 有关信息
	
	--  gp_distribution_policy 包含有关Greenplum数据库表及其segment分发表数据的策略的信息。
	select * from pg_catalog.gp_distribution_policy;
	
	--  gp_fastsequence 包含有关追加优化和面向列的表的信息
	select * from pg_catalog.gp_fastsequence;

	--  gp_global_sequence 包含事务日志中的日志序列号位置,文件复制过程使用位置来确定要从主段复制到镜像段的文件块。
	select * from pg_catalog.gp_global_sequence;


## Greenplum 数据文件状态有关信息
	
	--  gp_persistent_database_node 跟踪与数据库对象的事务状态相关的文件系统对象的信息。
	select * from pg_catalog.gp_persistent_database_node;
	
	--  gp_persistent_filespace_node 跟踪文件系统对象与文件空间对象的事务状态相关的信息。
	select * from pg_catalog.gp_persistent_filespace_node;
	
	--  gp_persistent_tablespace_node 跟踪与表空间对象的事务状态相关的文件系统对象的信息。
	select * from pg_catalog.gp_persistent_tablespace_node;
	
	--  gp_pgdatabase 显示有关Greenplum segment实例的状态信息，以及它们是作为镜像还是主要实例。
	select * from pg_catalog.gp_pgdatabase;


## Greenplum 有关储存的信息
	
	--  gp_transaction_log 包含有关特定segment本地事务的状态信息。
	select * from pg_catalog.gp_transaction_log;
	
	--  gp_version_at_initdb 在Greenplum数据库系统的主节点和每个segment上。
	select * from pg_catalog.gp_version_at_initdb;
	
	--  pg_appendonly 包含有关存储选项和附加优化表的其他特征的信息。
	select * from pg_catalog.pg_appendonly;
	
	--  pg_attrdef 存储列默认值。
	select * from pg_catalog.pg_attrdef;
	
	--  pg_attribute表存储有关表列的信息。
	select * from pg_catalog.pg_attribute;
	
	--  pg_authid表包含有关数据库授权标识符（角色）的信息。
	select * from pg_catalog.pg_authid;
	
	--  pg_cast里表存储数据类型转换路径，包括内置路径和使用的路径 创建CAST。
	select * from pg_catalog.pg_cast;
	
	--  pg_enum表包含将枚举类型与其关联值和标签匹配的条目。
	select * from pg_catalog.pg_enum;
	
	--  pg_exttable 系统目录表用于跟踪由中创建的外部表和Web表 创建外部表 命令。
	select * from pg_catalog.pg_exttable;
	
	--  pg_filespace表包含有关在Greenplum数据库系统中创建的文件空间的信息。
	select * from pg_catalog.pg_filespace;
	
	-- pg_filespace_entry 空间需要文件系统位置来存储其数据库文件。
	select * from pg_catalog.pg_filespace_entry;
	
	--  pg_inherits 系统目录表记录有关表继承层次结构的信息。
	select * from pg_catalog.pg_inherits;
	
	--  pg_largeobject系统目录表包含构成"large objects"的数据。
	select * from pg_catalog.pg_largeobject;
	
	--  pg_listener 系统目录表支持LISTENNOTIFY 通知命令。
	select * from pg_catalog.pg_listener;
	
	--  pg_max_external_files 显示使用外部表时每个段主机允许的最大外部表文件数file协议。
	select * from pg_catalog.pg_max_external_files;
	
	
	
# Greenplum 插件相关信息

	-- pg_extension 有关已安装扩展的信息
	select * from pg_catalog.pg_extension;
	
	-- pg_available_extension_versions 列出了可用于安装的特定扩展版本。
	select * from pg_catalog.pg_available_extension_versions;
	
	-- pg_available_extensions 列出了可用于安装的扩展。
	select * from pg_catalog.pg_available_extensions;
	
	--  pg_language系统目录表注册可以编写函数或存储过程的语言。
	select * from pg_catalog.pg_language;


#  Greenplum 分区表的相关信息

	--  pg_partition_columns 系统视图用于显示分区表的分区键列。
	select * from pg_catalog.pg_partition_columns;
	
	--  pg_partition_columns 系统视图用于显示分区表的分区键列。
	select * from pg_catalog.pg_partition_encoding;
	
	--  pg_partition_rule系统目录表用于跟踪分区表，检查约束和数据包含规则。
	select * from pg_catalog.pg_partition_rule;
	
	--  pg_partition_templates 系统视图用于显示使用子分区模板创建的子分区。
	select * from pg_catalog.pg_partition_templates;
	
	--  pg_partitions 系统视图用于显示分区表的结构。
	select * from pg_catalog.pg_partitions;


# Greenplum 资源队列相关信息  

	--  pg_stat_partition_operations 视图显示有关在分区表上执行的上一个操作的详细信息
	select * from pg_catalog.pg_stat_partition_operations;
	
	--  pg_stat_replication 视图包含的元数据 walsender 用于Greenplum数据库主镜像的进程
	select * from pg_catalog.pg_stat_replication;
	
	--  pg_stat_resqueues 视图允许管理员随时查看有关资源队列工作负载的指标。
	select * from pg_catalog.pg_stat_resqueues;
	
	--  pg_resqueuecapability 包含有关现有Greenplum数据库资源队列的扩展属性或功能的信息
	select * from pg_catalog.pg_resqueuecapability;
	
	--  pg_resgroup 包含有关Greenplum数据库资源组的信息，这些资源组用于管理并发语句，CPU和内存资源。
	select * from pg_catalog.pg_resgroup;
	
	--  pg_resgroupcapability 包含有关已定义的Greenplum数据库资源组的功能和限制的信息
	select * from pg_catalog.pg_resgroupcapability;
	
	--  pg_resourcetype 包含有关可分配给Greenplum数据库资源队列的扩展属性的信息。
	select * from pg_catalog.pg_resourcetype;
	
	--  pg_resqueue 包含有关Greenplum数据库资源队列的信息，这些队列用于资源管理功能。
	select * from pg_catalog.pg_resqueue;
	
	--  pg_resqueue_attributes 视图允许管理员查看为资源队列设置的属性，例如其活动语句限制，查询成本限制和优先级。
	select * from pg_catalog.pg_resqueue_attributes;



# Greenplum 表,视图,索引等有关信息

## Greenplum 中支持的索引
	
	--  pg_am 有关索引方法的信息(btree,hash,gist,gin,bitmap索引)
	select * from pg_catalog.pg_am;
	
	--  pg_amop 有关与索引访问方法操作符类关联的运算符的信息
	select * from pg_catalog.pg_amop;
	
	--  pg_amproc 有关与索引访问方法操作符类关联的支持过程的信息。
	select * from pg_catalog.pg_amproc;
	
	--  pg_index 包含有关索引的部分信息。
	select * from pg_catalog.pg_index;
	
	--  pg_opclass记录系统目录表定义索引访问方法操作符类
	select * from pg_catalog.pg_opclass;


## Greenplum 表的关系信息
	
	--  pg_tablespace系统目录表存储有关可用表空间的信息。
	select * from pg_catalog.pg_tablespace;
	
	-- gp_persistent_relation_node 表跟踪与关系对象(表,视图,索引等)的事务状态相关的文件系统对象的状态
	select * from pg_catalog.gp_persistent_relation_node;
	
	--  gp_relation_node 表包含有关系（表,视图,索引等）的文件系统对象的信息。
	select * from pg_catalog.gp_relation_node;
	
	--  pg_stat_operations 显示有关对数据库对象（例如表,索引,视图或数据库）或全局对象（例如角色）执行的上一个操作的详细信息。
	select * from pg_catalog.pg_stat_operations;
	
	--  gp_segment_configuration 表包含有关mirroring和segment配置的信息
	select * from pg_catalog.gp_segment_configuration;
	
	--  pg_aggregate里table存储有关聚合函数的信息。
	select * from pg_catalog.pg_aggregate;



# Greenplum 系统目录存储基本信息

## Greenplum 储存database,schema,table,view等的信息
	
	--  pg_database里系统目录表存储有关可用数据库的信息。
	select * from pg_catalog.pg_database;
	
	--  pg_statistic里系统目录表存储有关数据库内容的统计数据。
	select * from pg_catalog.pg_statistic;
	
	-- pg_description系统目录表存储每个数据库对象的可选描述（注释）。
	select * from pg_catalog.pg_description;
	
	--  pg_depend系统目录表记录数据库对象之间的依赖关系。
	select * from pg_catalog.pg_depend;
	
	--  pg_namespace系统目录表存储schema的名称。
	select * from pg_catalog.pg_namespace;
	
	--  gp_id系统目录表标识Greenplum数据库系统名称和系统的segment数
	select * from pg_catalog.gp_id;
	
	--  pg_rewrite 系统目录表存储表和视图的重写规则。
	select * from pg_catalog.pg_rewrite;
	
	--  pg_type_encoding 系统目录表包含列存储类型信息。
	select * from pg_catalog.pg_type_encoding;
	
	--  pg_attribute_encoding 系统目录表包含列存储信息。
	select * from pg_catalog.pg_attribute_encoding;



# 以下只有在进入到gpexpand扩展时,才可以查询
	select * from gpexpand.expansion_progress;
	select * from gpexpand.status;
	select * from gpexpand.status_detail;
 
