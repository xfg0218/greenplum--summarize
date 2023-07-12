# Greenplum 常见的锁类型
| 锁类型 | 说明 | 
|:--------:|----|
| 共享锁(Shared Lock) | 允许多个事务同时获取锁并并发读取数据，共享锁之间不会相互阻塞。|
| 排他锁(Exclusive Lock	) | 只允许一个事务获取锁，用于保护写操作，避免并发写入冲突。|
| 更新锁(Update Lock) | 意向共享锁（IS）和意向排它锁（IX）的组合。事务要获取排它锁时，需要先获取意向排它锁，避免意向锁的冲突。|
| 行级锁(Row-level Lock	) | 用于保护数据行的锁类型，当事务要修改某些数据行时，可以获取这些数据行的排它锁，其他事务需要等待锁释放。|
| 表级锁(Table-level Lock) | 用于保护整个表的锁类型，当事务要对整个表进行修改时，会获取表级锁，其他事务需要等待锁释放。|
| 共享意向锁(Intent Share Lock) | 表示一个事务打算在某个表上获取共享锁，其他事务可以同时获取共享意向锁，但排它意向锁会阻止其他事务获取排它锁。|
| 排它意向锁(Intent Exclusive Lock) | 表示一个事务打算在某个表上获取排它锁，其他事务无法获取排它意向锁或共享意向锁，但可以获取共享锁或共享意向锁。|
| Share Update锁(Share Update Lock) | 一种特殊的锁类型，允许并发地读取数据并在特定条件下进行更新。|
| Access Share锁(Access Share Lock) |	用于表格元数据的锁类型，允许其他事务并发地读取表格的定义和结构。|


# Greenplum 等待事件
| 等待事件 | 说明 |
|:----:|----|
| Archiver | 等待归档进程完成操作，将WAL日志归档到存档目录。 |
| Async Append | 等待异步追加操作完成，例如异步追加到分布式表中。 |
| Async Consistency | 等待异步一致性操作完成，例如异步复制或数据同步。 |
| Async Drop | 等待异步删除操作完成，例如异步删除表或索引。|
| Async Flush | 等待异步刷新操作完成，例如异步刷新共享缓冲区。|
| Async Index | 等待异步索引操作完成，例如异步创建或修改索引。|
| Async Meta | 等待异步元数据操作完成，例如异步创建或修改表格元数据。|
| Async Truncate | 等待异步截断操作完成，例如异步截断表或分区。|
| Autovacuum Launcher | 等待自动清理进程完成操作，如自动VACUUM任务。|
| Autoanalyze Launcher | 等待自动分析进程完成操作，如自动ANALYZE任务。|
| Background Writer | 等待后台写入器完成操作，将缓冲区数据写入磁盘。|
| B-tree Vacuum Delay | 等待B树索引清理延迟，以便执行索引清理操作。|
| Barrier Lock | 等待障碍锁，用于同步并行查询中的阶段切换。|
| Buffer IO | 等待缓冲区IO完成，可能是从磁盘读取或写入缓冲区数据。|
| Buffer Pin | 等待缓冲区固定，缓冲区可能被其他事务锁定。|
| Checkpoint Completion | 等待检查点完成，将数据库的修改持久化到磁盘。|
| Data Queue | 等待数据队列可用，以便继续写入或读取数据。|
| Data Writer | 等待数据写入器完成操作，将数据写入到磁盘。|
| Distributed Deadlock | 等待分布式死锁解决，以避免分布式事务死锁。|
| Error Queue | 等待错误队列可用，以便继续处理错误。|
| Exclusive Lock | 等待获取排它锁，其他事务占用了需要的排它锁资源。|
| Extension Lock | 等待获取扩展模块的锁，可能是扩展模块资源被占用。|
| IO | 等待磁盘IO完成，可能是读取或写入磁盘数据。|
| IPC | 等待进程间通信（IPC）操作完成，如管道、消息队列等。|
| Lock | 等待获取锁，其他事务占用了需要的锁资源。|
| Metadata Update | 等待元数据更新完成，例如更改表格或索引的元数据。|
| Network | 等待网络操作完成，例如发送或接收数据。|
| Predicate Cache Update | 等待谓词缓存更新完成，以便获取最新的谓词缓存数据。|
| Process Startup | 等待进程启动完成，例如等待后台进程启动完成。|
| Parallel Query | 等待并行查询完成，可能是等待其他并行工作者的完成信号。|
| Predicate Lock | 等待获取谓词锁，用于保护特定查询条件下的数据。|
| Query Queue | 等待查询队列可用，以便继续执行查询操作。|
| Snapshot Creation | 等待快照创建完成，以便获取一致性的数据快照。|
| Share Lock | 等待获取共享锁，其他事务占用了需要的共享锁资源。|
| Subtransaction Lock | 等待子事务锁释放，可能是在子事务中等待父事务完成。|
| Transaction Commit | 等待事务提交完成，将事务的修改持久化到磁盘。|
| Transaction Rollback | 等待事务回滚完成，撤销事务的修改操作。|
| Tuple Lock | 等待元组锁，其他事务占用了需要的元组锁资源。|
| Vacuum Cleaner | 等待清理器完成操作，例如执行VACUUM操作。|
| WAL Insertion | 等待WAL插入操作完成，将WAL日志插入到WAL缓冲区。|
| WAL Writer Queue | 等待WAL写入队列可用，以便继续将WAL日志加入队列。|
| Wait Resource | 等待资源，如等待数据库对象的创建或修改完成。|
| WAL Buffer Full | 等待WAL缓冲区不再满，以便继续写入WAL日志。|
| WAL Insertion Lock | 等待WAL插入锁，用于同步WAL日志的写入操作。|
| WAL Writer | 等待WAL写入器完成操作，将WAL日志写入到磁盘。|
| WAL Writer Queue | 等待WAL写入队列空闲，以便继续将WAL日志加入队列。|
| Wait External Lock | 等待外部锁资源，如等待外部系统的锁释放。|
| Wait Lock Manager Lock | 等待锁管理器锁的释放，可能是其他事务占用了锁管理器的资源。|
| Wait Table Lock | 等待表级锁的释放，可能是其他事务占用了表级锁资源。|
| Wait Transaction Lock | 等待事务锁的释放，可能是其他事务占用了事务锁资源。|
| Wait Transform Lock | 等待转换锁的释放，可能是其他事务占用了转换锁资源。|
| Wait Visibility Lock | 等待可见性锁的释放，可能是其他事务占用了可见性锁资源。|






