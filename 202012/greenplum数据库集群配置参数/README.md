# Greenplum数据库集群配置参数
| 参数名字 | 默认值 | 参数含义 |
|:----:|:----:|:----|
| enable_bitmapscan | on | 启用或禁用位图查询优化器。|
| enable_groupagg | on | 启用或禁用组聚集计划优化器。|
| enable_hashagg | on | 启用或禁用哈希优化器。|
| enable_hashjoin | on | 启用或者禁用散列聚集优化器。|
| enable_indexscan | on | 启用或者禁用索引优化器。|
| enable_mergejoin | off | 启用或者禁用合并优化器。|
| enable_nestloop | off | 启用或者禁用嵌套循环优化器。|
| enable_seqscan | on | 启用或者禁用顺序扫描优化器。|
| enable_sort | on | 启用或者禁用显示的排序优化器。|
| enable_tidscan | on | 启用或者禁用使用元组标识符优化器。|
| gp_enable_agg_distinct | on | 启用或者禁用两阶段聚合以计算单个不同合格的聚合。|
| gp_enable_agg_distinct_pruning | on | 启用或者禁用第三阶段聚合和连接来计算单个不同合格的聚合。|
| gp_enable_direct_dispatch | on | 启用或者禁用针对访问单个段上的数据查询的目标查询计划的分派。|
| gp_enable_exchange_default_partition | off | 控制 ALTER TABLE 的EXCHANGE DEFAULT PARTITION 子句的可用性。|
| gp_enable_fallback_plan | on | 允许使用禁用计划类型，当查询没有该类型不可行的时候。|
| gp_enable_fast_sri | on | 当设置为 on，该查询优化器计划单行插入，因此他们被直接送到了segment上。|
| gp_enable_gpperfmon | off | 启用或者禁用数据收集代理，该代理为Greenplum链接 gpperfmon 数据库。|
| gp_enable_groupext_distinct_gather | on | 启用或禁用向单个节点收集数据，以便在组扩展查询上计算分别不同合格的聚集。|
| gp_enable_groupext_distinct_pruning | on | 启用或者禁用三阶段聚集和连接以在组扩展查询上计算不同合格的聚合。|
| gp_enable_multiphase_agg | on | 启用或者禁用两或三阶段并行聚合方案的查询优化器（计划程序）。|
| gp_enable_predicate_propagation | on | 当被启用时,该查询优化器（计划器）会在表上分布键连接的地方将谓词应用于两个表的表达式。|
| gp_enable_preunique | on | 启用 SELECT DISTINCT 查询的两阶段重复删除（不是 SELECT COUNT(DISTINCT)）|
| gp_enable_sequential_window_plans | on | 如果启用，启用包含窗口函数调用的查询的非并行查询计划。|
| gp_enable_relsize_collection | off | 如果没有表的统计信息，则可以使遗传查询优化器使用表的估计大小。|
| gp_enable_sort_distinct | on | 排序的时候启用删除的重复项。|
| gp_enable_sort_limit | on | 在排序时启用 LIMIT 操作。当计划最多需要前 limit_number 行时候排序会更有效。|
| gp_external_enable_exec | on | 启用或禁用在segment主机上执行os命令或脚本的外部表的使用 |
| gp_external_max_segs | 64 | 设置在外部表操作期间将扫描外部表数据段的数量，目的是不使系统因扫描数据过载，并从其他并发操作中夺取资源。|
| escape_string_warning | | 出现反斜杠转义字符发出警告|
| explain_pretty_print | | 确定 EXPLAIN VERBOSE 是否使用缩进或非缩进格式显示详细的查询树存储 |
| extra_float_digits | | 调整浮点值显示的位数，包括float4，float8， 和几何数据类型。|
| filerep_mirrorvalidation_during_resync | | 该默认设置值 false 在段镜像增量重新同步期间可以提供数据库性能。|
| from_collapse_limit | | 如果生成的FROM列表不超过这么多项，则将把子查询合并到上层查询中。|
| gp_adjust_selectivity_for_outerjoins | | 启用对外连接的NULL测试的选择性。|
| gp_analyze_relative_error | | 设置表的基数的估计可接受的误差，0.5应该等于可50%的接受的误差。|
| gp_appendonly_compaction | | 在 VACUUM 命令期间启用压缩段文件。|
| gp_appendonly_compaction_threshold | 10 | 当在没有指定FULL选项情况下运行VACUUM，指明隐藏行和总行的阀值比率,该比率会触发段文件的压缩。|
| gp_autostats_mode | on_no_ stats | 指定使用 ANALYZE触发自动统计信息收集的模式。|
| gp_autostats_mode_in_functions | none | 指定使用过程语言函数中的 ANALYZE 语句触发自动统计信息收集的模式。 |
| gp_autostats_on_change_threshold | 2147483647 | 当 gp_autostats_mode 设定为 on_change时，指明自动统计信息收集的阀值。|
| gp_cached_segworkers_threshold | 5 | 当用户启动与Greenplum数据库的会话并发出查询时系统将在每个segment上创建工作进程。|
| gp_command_count | 1 | 显示主机从客户端收到的命令数量。|
| gp_connection_send_timeout | 3600s | 在查询处理期间发送数据到无响应的Greenplum数据库用户客户端的超时时间 |
| gp_connections_per_thread | 0 | 控制Greenplum数据库查询调度程序（QD）生成的异步线程（工作线程）的数量 |
| gp_debug_linger | 0 | 在致命内部错误之后，Greenplum进程停留的秒数。|
| gp_default_storage_options | ************ | 用户创建表时添加的后缀信息 |
| gp_dynamic_partition_pruning | on | 启用可以动态消除分区扫描的计划。|