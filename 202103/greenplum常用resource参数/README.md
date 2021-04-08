# Greenplum常用resource参数含义
| 参数名字 | 默认值 | 参数中文含义 | 参数英文含义 |
|:----|:----|:----|:----|
| gp_resource_group_cpu_limit | 0.9 | 分配给群集的CPU资源的最大百分比。 | Maximum percentage of CPU resources assigned to a cluster. |
| gp_resource_group_cpu_priority | 10 | 设置资源组启用时postgres进程的cpu优先级。 | Sets the cpu priority for postgres processes when resource group is enabled. |
| gp_resource_group_memory_limit | 0.7 | 分配给群集的内存资源的最大百分比。 | Maximum percentage of memory resources assigned to a cluster. |
| gp_resource_manager | queue | 设置资源管理器的类型。 | Sets the type of resource manager. |
| gp_resqueue_memory_policy | eager_free | 设置查询的内存分配策略。 | Sets the policy for memory allocation of queries. |
| gp_resqueue_priority | on | 启用优先级调度。 | Enables priority scheduling. |
| gp_resqueue_priority_cpucores_per_segment | 4 | 与segment关联的处理单元数。 | Number of processing units associated with a segment. |
| gp_resqueue_priority_sweeper_interval | 1000 | 扫描进程重新评估CPU共享的频率（毫秒）。 | Frequency (in ms) at which sweeper process re-evaluates CPU shares. |