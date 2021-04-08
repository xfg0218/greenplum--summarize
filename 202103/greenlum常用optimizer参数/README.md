# Greenlum常用optimizer参数含义
| 参数名字 | 默认值 | 参数中文含义 | 参数英文含义 |
|:----|:----|:----|:----|
| optimizer | on | 启用Optimizer查询优化器 | Enable Pivotal Query Optimizer. |
| optimizer_analyze_root_partition | on | 使用ANALYZE在root分区期间开启统计信息 | Enable statistics collection on root partitions during ANALYZE |
| optimizer_control | on | 允许/不允许打开或关闭优化器。 | Allow/disallow turning the optimizer on or off. |
| optimizer_enable_associativity | off | 在优化器中启用联接关联性 | Enables Join Associativity in optimizer |
| optimizer_join_arity_for_associativity_commutativity | 18 | 在不禁用交换性和结合性变换的情况下，n元联接具有的最大子级数 | Maximum number of children n-ary-join have without disabling commutativity and associativity transform |
| optimizer_join_order | exhaustive | 设置优化器连接启发式模型。 | Set optimizer join heuristic model. |
| optimizer_join_order_threshold | 10 | 最大联接子数采用基于动态规划的联接排序算法。 | Maximum number of join children to use dynamic programming based join ordering algorithm. |
| optimizer_mdcache_size | 16MB | 设置MDCache的大小。 | Sets the size of MDCache. |
| optimizer_metadata_caching | on | 这个guc使优化器能够缓存和重用元数据。 | This guc enables the optimizer to cache and reuse metadata. |
| optimizer_minidump | onerror | 生成optimizer储存 | Generate optimizer minidump. |
| optimizer_parallel_union | off | 为联合/联合所有查询启用并行执行。 | Enable parallel execution for UNION/UNION ALL queries.