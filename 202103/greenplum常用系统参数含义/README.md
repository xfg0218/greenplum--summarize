# Greenplum常用系统参数含义
| 参数名字 | 默认值 | 参数含义 |
|:----|:----:|:----|
| add_missing_from | off | 自动向FROM子句添加缺少的表引用 |
| application_name |  | 设置要在统计信息和日志中报告的应用程序名称。 |
| archive_mode | off | 允许使用archive_command命令存档WAL文件。 |
| array_nulls | on | 启用数组中空元素的输入 |
| authentication_timeout | 1min | 设置完成客户端身份验证所允许的最长时间。 |
| autovacuum_max_workers | 3 | 设置同时运行的自动真空工作进程的最大数量 |
| autovacuum_max_workers | 3 | 设置同时运行的自动真空辅助进程的最大数目 |
| backslash_quote | safe_encoding | 设置字符串文本中是否允许反斜杠“\” |
| block_size | 32768 | 显示磁盘块的大小 |
| bonjour_name |  | 设置Bonjour  broadcast 服务名称 |
| bytea_output | escape | 设置bytea的输出格式。 |
| check_function_bodies | on | 在CREATE FUNCTION期间检查函数体。 |
| checkpoint_completion_target | 0.5 | 在检查点期间刷新脏缓冲区所用的时间，以检查点间隔的分数表示。 |
| client_encoding | UNICODE | 设置客户端的字符集编码。 |
| client_min_messages | notice | 设置发送到客户端的消息级别。 |
| cpu_index_tuple_cost | 0.005 | 设置计划员对索引扫描期间处理每个索引项的成本的估计。 |
| cpu_operator_cost | 0.0025 | 设置计划器对处理每个运算符或函数调用的成本的估计。 |
| cpu_tuple_cost | 0.01 | 设置计划器对处理每个元组（行）的成本的估计。 |
| cursor_tuple_fraction | 1 | 设置计划器对将检索的光标行的分数的估计。 |
| custom_variable_classes |  | 设置已知自定义变量类的列表。 |
| data_checksums | on | 显示是否为此群集启用了数据校验 |
| DateStyle | ISO, MDY | 设置日期和时间值的显示格式 |
| db_user_namespace | off | 启用每个数据库的用户名 |
| deadlock_timeout | 1s | 设置在检查死锁之前等待锁的时间 |
| debug_assertions | off | 打开各种断言检查。 |
| debug_pretty_print | off | 缩进分析和计划树显示。 |
| debug_print_parse | off | 将解析树打印到服务器日志。 |
| debug_print_plan | off | 将执行计划打印到服务器日志。 |
| debug_print_prelim_plan | off | 将初步执行计划打印到服务器日志。 |
| debug_print_rewritten | off | 在重写到服务器日志后打印解析树。 |
| debug_print_slice_table | off | 将切片表打印到服务器日志。 |
| default_statistics_target | 100 | 设置默认统计信息目标。 |
| default_tablespace |  | 设置要在其中创建表和索引的默认表空间。 |
| default_text_search_config | pg_catalog.english | 设置默认文本搜索配置。 |
| default_transaction_isolation | read committed | 设置每个新事务的事务隔离级别。 |
| default_transaction_read_only | off | 设置新事务的默认只读状态。 |
| dynamic_library_path | $libdir | 设置可动态加载模块的路径。 |
| effective_cache_size | 512MB | 设置规划器对磁盘缓存大小。 |
| escape_string_warning | on | 出现反斜杠转义字符发出警告 |
| explain_memory_verbosity | suppress | 实验特性: 使用EXPLAIN ANALYZE显示内存的使用情况 |
| explain_pretty_print | on | 确定 EXPLAIN VERBOSE 是否使用缩进或非缩进格式显示详细的查询树存储 |
| extra_float_digits | 0 | 调整浮点值显示的位数，包括float4，float8， 和几何数据类型。 |
| from_collapse_limit | 20 | 如果生成的FROM列表不超过这么多项，则将把子查询合并到上层查询中。 |
| gp_adjust_selectivity_for_outerjoins | on | 启用对外连接的NULL测试的选择性。 |
| gp_analyze_relative_error | 0.25 | 设置表的基数的估计可接受的误差，0.25应该等于可25%的接受的误差。 |
| gp_appendonly_compaction_threshold | 10 | 当在没有指定FULL选项情况下运行VACUUM，指明隐藏行和总行的阀值比率,该比率会触发段文件的压缩。 |
| gp_autostats_mode | ON_NO_STATS | 指定使用 ANALYZE触发自动统计信息收集的模式。 |
| gp_autostats_mode_in_functions | NONE | 指定使用 ANALYZE触发自动统计信息收集的模式。 |
| gp_autostats_on_change_threshold | 2147483647 | 当 gp_autostats_mode 设定为 on_change时，指明自动统计信息收集的阀值。 |
| gp_backup_directIO | off | 启用直接IO转储 |
| gp_backup_directIO_read_chunk_mb | 20 | directIO转储中读取区块缓冲区的大小 (in MB) |
| gp_cached_segworkers_threshold | 5 | 当用户启动与Greenplum数据库的会话并发出查询时系统将在每个segment上创建工作进程。 |
| gp_command_count | 10 | 显示主机从客户端收到的命令数量。 |
| gp_connection_send_timeout | 3600 | 在查询处理期间发送数据到无响应的Greenplum数据库用户客户端的超时时间 |
| gp_connections_per_thread | 0 | 控制Greenplum数据库查询调度程序（QD）生成的异步线程（工作线程）的数量 |
| gp_contentid | -1 | 此服务器使用的contentid |
| gp_create_table_random_default_distribution | off | 将表的默认分布设置为随机 |
| gp_dbid | 1 | 此服务器使用的dbid |
| gp_debug_linger | 0 | 在致命内部错误之后，Greenplum进程停留的秒数。 |
| gp_default_storage_options | appendonly=false,blocksize=32768,compresstype=none,checksum=true,orientation=row | 户创建表时添加的后缀信息 |
| gp_dynamic_partition_pruning | on | 启用可以动态消除分区扫描的计划。 |
| gp_external_enable_exec | on | 启用或禁用在segment主机上执行os命令或脚本的外部表的使用 |
| gp_external_max_segs | 64 | 设置在外部表操作期间将扫描外部表数据段的数量，目的是不使系统因扫描数据过载，并从其他并发操作中夺取资源。 |
| gp_filerep_ct_batch_size | 65536 | filerep重新同步工作进程一次从changetracking日志处理的最大块数。 |
| gp_filerep_tcp_keepalives_count | 2 | FileRep连接的TCP keepalive重新传输的最大次数。 |
| gp_filerep_tcp_keepalives_idle | 1min | 为FileRep连接发出TCP keepalives之间的秒数。 |
| gp_filerep_tcp_keepalives_interval | 30s | FileRep连接的TCP keepalive重新传输之间的秒数。 |
| gp_fts_probe_interval | 1min | 两次检测的时间间隔，默认为60s。如果一次检测时间使用10s，那么剩余50s将会sleep;如果超过60s，将会直接进入下一次检测 |
| gp_fts_probe_threadcount | 16 | 用来检测故障的segment线程数量 |
| gp_fts_probe_timeout | 20s | FTS完成探测segemnt所允许的最长时间,默认值: 20s |
| gp_gpperfmon_send_interval | 1 | 向gpperfmon发送消息的间隔. |
| gp_hadoop_home |  | Hadoop在每个段中的安装位置. |
| gp_hadoop_target_version | hadoop | 外部表连接到的Hadoop的发行版/版本. |
| gp_hashjoin_tuples_per_bucket | 5 | Hashjoin在执行期间使用的哈希表的目标密度 |
| gp_idf_deduplicate | auto | 设置模式以控制逆分布函数的重复消除策略 |
| gp_initial_bad_row_limit | 1000 | 当第一个错误行数超过此值时停止处理 |
| gp_instrument_shmem_size | 5MB | 设置分配给检测的shmem的大小 |
| gp_log_format | csv | 设置日志文件的格式。 |
| gp_max_csv_line_length | 1048576 | csv输入数据行允许的最大长度（字节） |
| gp_max_databases | 16 | 设置数据库的最大数量。 |
| gp_max_filespaces | 8 | 设置文件空间的最大数目。 |
| gp_max_local_distributed_cache | 1024 | 设置要缓存的本地分布式事务的数量，以便通过后端优化可见性处理。 |
| gp_max_packet_size | 8192 | 设置互连的最大数据包大小。 |
| gp_max_partition_level | 0 | 设置创建分区表时允许的最大级别数 |
| gp_max_plan_size | 0 | 设置要调度的计划的最大大小 |
| gp_max_tablespaces | 16 | 设置最大的表空间。 |
| gp_motion_cost_per_row | 0 | 设置计划员对在工作进程之间移动行的成本的估计 |
| gp_num_contents_in_cluster | 12 | 设置群集中segment数。 |
| gp_reject_percent_threshold | 300 | 拒绝限制百分比在处理此行数后开始计算 |
| gp_reraise_signal | on | 当出现严重问题时，我们是否尝试转储内核 |
| gp_resgroup_memory_policy | eager_free | 设置查询的内存分配策略。 |
| gp_role | dispatch | 设置会话的角色。 |
| gp_safefswritesize | 0 | 最小FS安全写入大小 |
| gp_segment_connect_timeout | 10min | 新工作进程启动或镜像响应所允许的最长时间（秒）。 |
| gp_segments_for_planner | 0 | 如果>0，计划人员在其成本和规模估计中要承担的分段dbs数量。 |
| gp_server_version | 5.7.0 build commit:f7c6eb5cc61b25a7ff9c5a657d6f903befbae013 | 显示Greenplum服务器版本 |
| gp_server_version_num | 50000 | 将Greenplum服务器版本显示为整数 |
| gp_session_id | 236760 | 用于唯一标识Greenplum数据库数组中特定会话的全局ID |
| gp_set_proc_affinity | off | 在postmaster启动时，尝试将postmaster绑定到处理器 |
| gp_snmp_community | public | 设置要向其发送警报（通知或trap 消息）的SNMP团体名称。 |
| gp_snmp_monitor_address |  | 设置要向其发送SNMP警报（通知或trap 消息）的网络地址。 |
| gp_snmp_use_inform_or_trap | trap | 如果“通知”，我们将以SNMP v2c通知消息的形式发送警报，如果是“trap”，则使用SNMP v2陷阱消息。。 |
| gp_standby_dbid | 0 | 设置备用主机的DBID。 |
| gp_statistics_pullup_from_child_partition | on | 这个guc使规划器能够在父对象的规划查询中利用分区的统计信息。 |
| gp_statistics_use_fkeys | on | 这个guc使规划器能够利用从外键关系派生的统计信息。 |
| gp_subtrans_warn_limit | 16777216 | 设置事务中子事务数的警告限制。 |
| gp_udp_bufsize_k | 0 | 为测试设置UDP互连的recv buf大小。 |
| gp_vmem_idle_resource_timeout | 18s | 设置在释放段数据库上的组以释放资源之前会话可以空闲的时间（毫秒）。 |
| gp_vmem_protect_limit | 8192 | Greenplum内存保护的虚拟内存限制（MB）。 |
| gp_vmem_protect_segworker_cache_limit | 500 | segworker可缓存的最大虚拟内存限制（MB）。 |
| gp_workfile_checksumming | on | 对executor工作文件启用校验和，以便捕获磁盘驱动程序可能导致的错误写入。 |
| gp_workfile_compress_algorithm | none | 指定查询执行器中工作文件使用的压缩算法。 |
| gp_workfile_limit_files_per_query | 100000 | 每个segment每个查询允许的最大工作文件数。 |
| gp_workfile_limit_per_query | 0 | 每个segment每个查询用于工作文件的最大磁盘空间（KB）。 |
| gp_workfile_limit_per_segment | 0 | 每个segment用于工作文件的最大磁盘空间（KB）。 |
| gpcc.enable_send_query_info | on | 启用查询信息metrics集合。 |
| gpcc.query_metrics_port | 9898 | 设置发送查询metrics的端口号。 |
| gpcc.query_tags |  | 自定义会话元数据作为键值对 |
| gpperfmon_log_alert_level | warning | 指定gpperfmon使用的日志警报级别。 |
| gpperfmon_port | 8888 | 设置gpperfmon的端口号。 |
| ignore_checksum_failure | off | 校验和失败后继续处理。 |
| integer_datetimes | on | 日期时间是基于整数的。 |
| IntervalStyle | postgres | 设置间隔值的显示格式。 |
| join_collapse_limit | 20 | 设置从列表大小超出其连接结构不平坦的设置。 |
| krb_caseins_users | off | 设置是否应将Kerberos和GSSAPI用户名视为不区分大小写。 |
| krb_server_keyfile | FILE:/usr/local/greenplum-db-devel/etc/postgresql/krb5.keytab | 设置Kerberos服务器密钥文件的位置。 |
| krb_srvname | postgres | 设置Kerberos服务的名称。 |
| lc_collate | en_US.utf8 | 显示排序规则顺序区域设置。 |
| lc_ctype | en_US.utf8 | 显示字符分类和大小写转换区域设置。 |
| lc_messages | en_US.utf8 | 设置显示消息的语言。 |
| lc_monetary | en_US.utf8 | 设置货币金额格式的区域设置。 |
| lc_numeric | en_US.utf8 | 设置数字格式的区域设置。 |
| lc_time | en_US.utf8 | 设置格式化日期和时间值的区域设置。 |
| listen_addresses | * | 设置要侦听的主机名或IP地址。 |
| local_preload_libraries |  | 列出要预加载到每个后端的共享库。 |
| logging_collector | on | 失效：启动子进程以将stderr输出和/或csvlog捕获到日志文件中。 |
| maintenance_work_mem | 64MB | 设置用于维护操作的最大内存。 |
| max_appendonly_tables | 10000 | 最多可同时参与写入数据的不同（无关）附加表的数量。 |
| max_connections | 250 | 设置最大并发连接数。 |
| max_files_per_process | 1000 | 设置每个服务器进程同时打开的最大文件数。 |
| max_fsm_pages | 200000 | 设置跟踪可用空间的最大磁盘页数。 |
| max_fsm_relations | 1000 | 设置跟踪可用空间的表和索引的最大数目。 |
| max_function_args | 100 | 显示函数参数的最大数目 |
| max_identifier_length | 63 | 显示最大identifier长度。 |
| max_index_keys | 32 | 显示索引键的最大数目。 |
| max_locks_per_transaction | 128 | 设置每个事务的最大锁数。 |
| max_prepared_transactions | 250 | 设置同时准备的最大事务数。 |
| max_resource_portals_per_transaction | 64 | 最大资源队列数。 |
| max_resource_queues | 9 | 最大资源队列数。 |
| max_stack_depth | 2MB | 设置最大堆栈深度（以KB为单位）。 |
| max_statement_mem | 2000MB | 设置statement_mem最大值。 |
| memory_spill_ratio | 20 | 设置资源组的内存溢出率。 |
| password_encryption | on | 加密密码 |
| password_hash_algorithm | MD5 | 在存储密码之前应用于密码的密码散列算法。 |
| pgstat_track_activity_query_size | 1024 | 要在pg_stat_activity活动中显示的查询的最大长度 |
| pljava_classpath |  | JVM使用的类路径 |
| pljava_classpath_insecure | off | 允许用户为每个会话设置pljava\U类路径 |
| pljava_release_lingering_savepoints | off | 如果为true，则函数退出时将释放延迟保存点；如果为false，则会回滚它们 |
| pljava_statement_cache_size | 0 | 准备好的语句MRU缓存的大小 |
| pljava_vmoptions |  | 创建JVM时发送到JVM的选项 |
| port | 5432 | 设置服务器侦听的TCP端口。 |
| random_page_cost | 100 | 设置计划器对非顺序获取的磁盘页的成本估计。 |
| readable_external_table_timeout | 0 | 如果N秒内没有读取数据，则取消查询。 |
| regex_flavor | advanced | 设置正则表达式“flavor”。 |
| repl_catchup_within_range | 1 | 设置允许延迟的xlog段的最大数目，当后端可以开始阻塞时，尽管WAL发送器处于catchup阶段。（Master Mirroring） |
| replication_timeout | 1min | 设置等待WAL复制的最大时间 (Master Mirroring) |
| resource_cleanup_gangs_on_wait | on | 在资源锁定等待之前启用空闲组清理。 |
| resource_scheduler | on | 启用资源调度。 |
| resource_select_only | off | 仅启用SELECT的资源锁定。 |
| runaway_detector_activation_percent | 90 | 如果使用的vmem超过vmem配额的这个百分比，失控检测器就会激活。设置为100以禁用失控检测。 |
| search_path | gp_toolkit, "$user", public | 为非架构限定的名称设置架构搜索顺序。 |
| seq_page_cost | 1 | 设置计划器对按顺序获取的磁盘页的成本估计。 |
| server_encoding | UTF8 | 设置服务器（数据库）字符集编码。 |
| server_version | 8.3.23 | 显示服务器版本 |
| server_version_num | 80323 | 将服务器版本显示为整数 |
| session_replication_role | origin | 为触发器和重写规则设置会话的行为 |
| shared_buffers | 125MB | 设置服务器使用的共享内存缓冲区数 |
| shared_preload_libraries | $libdir/metrics_collector,$libdir/gp_wlm | 列出要预加载到服务器的共享库 |
| ssl | off | 启用SSL连接 |
| ssl_ciphers | ALL:!ADH:!LOW:!EXP:!MD5:@STRENGTH | 设置允许的SSL密码列表 |
| ssl_renegotiation_limit | 512MB | 在重新协商加密密钥之前，设置要发送和接收的通信量。 |
| standard_conforming_strings | on | 使“…”字符串按字面意思处理反斜杠 |
| statement_mem | 125MB | 设置为语句保留的内存。 |
| statement_timeout | 0 | 设置任何语句允许的最大持续时间 |
| stats_queue_level | off | 收集数据库活动的资源队列级统计信息。 |
| superuser_reserved_connections | 3 | 设置为超级用户保留的连接插槽数。 |
| synchronize_seqscans | on | 启用同步的顺序扫描。 |
| synchronous_commit | on | 在提交时设置立即fsync。 |
| tcp_keepalives_count | 9 | TCP keepalive重传的最大数量。 |
| tcp_keepalives_idle | 7200 | 发出TCP keepalives之间的时间。 |
| tcp_keepalives_interval | 75 | TCP保持重新传输之间的时间。 |
| temp_buffers | 1024 | 设置每个会话使用的最大临时缓冲区数 |
| TimeZone | GMT | 设置显示和解释时间戳的时区。 |
| timezone_abbreviations | Default | 选择时区缩写的文件。 |
| track_activities | on | 收集有关执行命令的信息。 |
| track_counts | on | 收集数据库活动的统计信息。 |
| transaction_isolation | read committed | 设置当前事务的隔离级别 |
| transaction_read_only | off | 设置当前事务的只读状态。 |
| transform_null_equals | off | 将“expr=NULL”视为“expr为NULL”。 |
| unix_socket_directory |  | 设置将在其中创建Unix域套接字的目录。 |
| unix_socket_group |  | 设置Unix域套接字的所有者组 |
| unix_socket_permissions | 511 | 设置Unix域套接字的访问权限 |
| update_process_title | on | 更新进程标题以显示活动的SQL命令 |
| wal_buffers | 256kB | 为WAL设置共享内存中的磁盘页缓冲区数。 |
| wal_receiver_status_interval | 10s | 设置WAL接收器状态报告与主报告之间的最大间隔。 |
| wal_writer_delay | 200ms | 两次WAL之间的间隔 |
| work_mem | 32MB | 设置用于查询工作区的最大内存 |
| writable_external_table_bufsize | 64kB | 在将数据写入gpfdist之前，可写外部表的缓冲区大小（KB） |
| xmlbinary | base64 | 设置二进制值在XML中的编码方式。 |
| xmloption | content | 设置隐式解析和序列化操作中的XML数据是否被视为文档或内容片段。 |
