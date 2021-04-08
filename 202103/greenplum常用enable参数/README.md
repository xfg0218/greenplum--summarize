# Greenplum常用查询优化参数
| 参数名字 | 默认值 | 参数中文含义 | 参数英文含义 |
|:----|:----|:----|:----|
| enable_bitmapscan | on | 启用或禁用位图查询优化器。 | Enables the planner's use of bitmap-scan plans. |
| enable_groupagg | on | 启用或禁用组聚集计划优化器。 | Enables the planner's use of grouping aggregation plans. |
| enable_hashagg | on | 启用或禁用哈希优化器。 | Enables the planner's use of hashed aggregation plans. |
| enable_hashjoin | on | 启用或者禁用散列聚集优化器。 | Enables the planner's use of hash join plans. |
| enable_indexscan | on | 启用或者禁用索引优化器。 | Enables the planner's use of index-scan plans. |
| enable_mergejoin | off | 启用或者禁用合并优化器。 | Enables the planner's use of merge join plans. |
| enable_nestloop | off | 启用或者禁用嵌套循环优化器。 | Enables the planner's use of nested-loop join plans. |
| enable_seqscan | on | 启用或者禁用顺序扫描优化器。 | Enables the planner's use of sequential-scan plans. |
| enable_sort | on | 启用或者禁用显示的排序优化器。 | Enables the planner's use of explicit sort steps. |
| enable_tidscan | on | 启用或者禁用使用元组标识符优化器。 | Enables the planner's use of TID scan plans. |
| gp_enable_agg_distinct | on | 启用或者禁用两阶段聚合以计算单个不同合格的聚合。 | Enable 2-phase aggregation to compute a single distinct-qualified aggregate. |
| gp_enable_agg_distinct_pruning | on | 启用或者禁用第三阶段聚合和连接来计算单个不同合格的聚合。 | Enable 3-phase aggregation and join to compute distinct-qualified aggregates. |
| gp_enable_direct_dispatch | on | 启用或者禁用针对访问单个段上的数据查询的目标查询计划的分派。 | Enable dispatch for single-row-insert targetted mirror-pairs. |
| gp_enable_exchange_default_partition | off | 控制 ALTER TABLE 的EXCHANGE DEFAULT PARTITION 子句的可用性。 | Allow DDL that will exchange default partitions. |
| gp_enable_fallback_plan | on | 允许使用禁用计划类型，当查询没有该类型不可行的时候。 | Plan types which are not enabled may be used when a query would be infeasible without them. |
| gp_enable_fast_sri | on | 当设置为 on，该查询优化器计划单行插入，因此他们被直接送到了segment上。 | Enable single-slice single-row inserts. |
| gp_enable_gpperfmon | on | 启用或者禁用数据收集代理，该代理为Greenplum链接 gpperfmon 数据库。 | Enable gpperfmon monitoring. |
| gp_enable_groupext_distinct_gather | on | 启用或禁用向单个节点收集数据，以便在组扩展查询上计算分别不同合格的聚集。 | Enable gathering data to a single node to compute distinct-qualified aggregates on grouping extention queries. |
| gp_enable_groupext_distinct_pruning | on | 启用或者禁用三阶段聚集和连接以在组扩展查询上计算不同合格的聚合。 | Enable 3-phase aggregation and join to compute distinct-qualified aggregates on grouping extention queries. |
| gp_enable_multiphase_agg | on | 启用或者禁用两或三阶段并行聚合方案的查询优化器（计划程序）。 | Enables the planner's use of two- or three-stage parallel aggregation plans. |
| gp_enable_predicate_propagation | on | 当被启用时,该查询优化器（计划器）会在表上分布键连接的地方将谓词应用于两个表的表达式。 | When two expressions are equivalent (such as with equijoined keys) then the planner applies predicates on one expression to the other expression. |
| gp_enable_preunique | on | 启用 SELECT DISTINCT 查询的两阶段重复删除（不是 SELECT COUNT(DISTINCT)） | Enable 2-phase duplicate removal. |
| gp_enable_query_metrics | on | 启用所有查询指标集合 | Enable all query metrics collection. |
| gp_enable_relsize_collection | off | 当统计数据不存在时，这个guc启用relsize集合。如果禁用且不存在统计信息，则使用默认值 | This guc enables relsize collection when stats are not present. If disabled and stats are not present a default value is used. |
| gp_enable_sequential_window_plans | on | 如果启用，启用包含窗口函数调用的查询的非并行查询计划。 | Experimental feature: Enable non-parallel window plans. |
| gp_enable_sort_distinct | on | 如果没有表的统计信息，则可以使遗传查询优化器使用表的估计大小。 | Enable duplicate removal to be performed while sorting. |
| gp_enable_sort_limit | on | 在排序时启用 LIMIT 操作。当计划最多需要前 limit_number 行时候排序会更有效。 | Enable LIMIT operation to be performed while sorting.