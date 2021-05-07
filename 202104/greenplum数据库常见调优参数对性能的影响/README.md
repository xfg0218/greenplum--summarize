# Greenplum 数据库常见调优参数对性能的影响
| 参数名称 | 参数含义 | 优化建议 |
|:----:|:----:|:----:|
| gp_vmem_protect_limit | 每个segment数据库为所有运行的查询分配的内存总量。 | 每个节点的物理内存/每个节点primary segment数量。 |
| shared_buffers | 磁盘读写的内存缓冲区。 | 不宜设置过大。 |
| effective_cache_size | 设置优化器假设磁盘高速缓存的大小用于查询语句的执行计划判断，主要用于判断使用索引的成本。 | 设置越大，优化器越倾向于走索引。 |
| work_mem | 设置每个segment内存排序的大小。 | work_mem大小根据每个节点上的active segment设置，设置过大将导致swap。 |
| temp_buffers | 临时缓冲区，拥有数据库访问临时数据。 | 当需要访问大的临时表时，适当增加参数设置，可提升性能。 |
| gp_fts_probe_threadcount | 故障检测的线程数。 | 大于等于每个节点的segment数。 |
| gp_hashjoin_tuples_per_bucket | 使用Hashjoin操作设置哈希表的目标密度。 | 此参数越小，hash_tables越大，可提升join性能。 |
| gp_interconnect_setup_timeout | 指定等待Greenplum数据库互连在超时之前完成设置的时间量。 | 在负载较大的环境中，应该设置较大的值。 |
| gp_statement_mem | 控制segment数据库上单个查询可以使用的内存总量。 | 建议(gp_vmem_protect_limit*0.9) /segment数据库上最大查询数。 |
| gp_workfile_limit_files_per_query | 如果SQL查询分配的内存不足，Greenplum会创建溢出文件，该参数控制一个查询可以创建多少个溢出文件。 | 超出溢出文件上线时，建议先优化Sql，数据分布策略及内存配置。 | 
| max_connections | 最大连接数。 | Segment建议设置成Master的5-10倍。 |



#  greenplum大量插入数据和大量查询数据时优化
| 参数 | 参数值 | 说明 | 参数设置方式 |
|:----|:----:|:----|:----|
| optimizer | off | 关闭针对AP场景的orca优化器，对TP性能更友好。 | gpconfig -c optimizer -v off | 
| shared_buffers | 8GB | 将数据共享缓存调大。修改该参数需要重启实例。 | gpconfig -c shared_buffers -v 8GB |
| wal_buffers | 256MB | 将WAL日志缓存调大。修改该参数需要重启实例。 | gpconfig -c wal_buffers -v 256MB |
| log_statement | none | 将日志输出关闭。 | gpconfig -c log_statement -v none |
| random_page_cost | 10 | 将随机访问代价开销调小，有利于查询走索引。 | gpconfig -c random_page_cost -v 10 |
| gp_resqueue_priority | off | 将resource queue关闭。需要重启实例 | gpconfig -c gp_resqueue_priority -v off |
| resource_scheduler | off | 将resource queue关闭。需要重启实例 | gpconfig -c resource_scheduler -v off |
| gp_enable_global_deadlock_detector | on | 控制是否开启全局死锁检测功能，打开它才可以支持并发更新/删除操作 | gpconfig -c gp_enable_global_deadlock_detector -v on |
| checkpoint_segments | 2 | 影响checkpoint主动刷盘的频率，针对OLTP大量更新类语句适当调小此设置会增加刷盘频率，平均性能会有较明显提升； | gpconfig -c checkpoint_segments -v 2 –skipvalidation |
