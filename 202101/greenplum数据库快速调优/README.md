# Greenplum数据库快速调优
	目录
	第一节 集群规划中影响性能的原因
		1、 架构设计
		2、服务器配置
		3、Segment 实例数量
	第二节 数据库性能优化内容
		1、内存管理
		2、资源队列的内存管理
		3、 资源队列
		4、资源组
		5、资源组与资源队列的区别
		6、表储存
		7、储存模式及对比
		8、数据加载
		9、其他优化点
	第三节 日常维护对性能的提升
		1、统计信息
		2、收集统计信息
		3、数据膨胀
		4、检测膨胀
		5、膨胀处理
		6、数据倾斜
		7、计算倾斜
		8、计算倾斜排查过程
		9、 系统表优化
		10、作业流程优化
	第四节 SQL优化技巧
		1、从执行计划中优化
		2、union 与 union  all
		3、Union 的优化
		4、分布键优化
		5、一些SQL 优化内容
	第五节 常见性能问题
		1、 用户查询慢
		2、数据库运行慢
		3、两段事务锁
		4、处理过程

# 第一节集群规划中影响性能的原因

	影响性能的因素
	1、并行处理的木桶效应
		- 节点服务器配置
		- 实例处理数据量不均衡
	2、镜像分布策略
		- GROUP 
		- SPPEAD
		
	2、服务器配置
	
		1、关注点
			1）、CPU 开启超线程
			2）、磁盘IO性能
			3）、万兆网络
		
		2、性能测试
			1）、gpcheckperf 检测
		
		3、Segment 实例数量
			1、考虑因素
			1）、CPU核数
			2）、物理内存
			3）、网络速度
			4）、主备实例同时工作
			5）、服务器有运行其他进程
			6）、预期的并发数
	
	
# 第二节数据库性能优化内容
	1、内存管理
		1）、操作系统参数设置
			内核不允许分配超过所有物理内存和交换内存空间总和的内存
			vm.overcommit_memory = 2
			
			
			为进程分配内存的百分比，默认是50，vm.overcommit_memory = 2 的情况下生效
			vm.overcommit_ratio = 95
		
		2）、数据库参数设置
			gp_vmem_protect_limit
			
			显示每个节点所有语句使用内存的上限，计算公式(SWAP + (RAM * vm.overcommit_ratio)) * 0.9 / number_Segments_per_server 
			
	2、资源队列的内存管理
		1）、gp_resqueue_memory_policy
		auto : 内存的消耗由参数statement_mem和资源队列的memory_limit限制
		eager_free : 内存消耗由参数max_statement_mem 和资源队列的memory_limit限制
		
		2）、max_statement_mem 
		限制每个查询最大使用的内存，默认2000MB
		(seghost_physical_memory) / (average_number_concurrent_queries)
		
		3）、statement_mem 
		节点数据库上单个查询可以使用的内存总量，默认125MB，如果需要更多内存完成操作，则会溢出到磁盘
		(gp_vmem_protect_limit * 0.9 ) /max_expected_concurrent_queries
		
		
	3、资源队列
		1）、限制并发的查询数
			ACTIVE_STATEMENTS
		
		2）、限时查询使用的内存总量
			MEMORY_LIMIT
		
		3）、控制查询的优先级
			PRIORITY
		
		4）、根据查询成本代价做限时
			MIN_COST
			MAX_COST
			COST_OVERCOMMIT
		
	4、资源组
		1、内存管理模型
			1)、基于角色（vmtracker）
			2)、基于外部组件(cgroup)
		
		2、CPU配额
			1）、按照百分比分配
			2）、按照CORE分配
		
		3、内存配额
			1）、按照百分比分配
		
		4、并发事务限制
			1）、基于角色的管理模型才有效
	
	5、资源组与资源队列的区别
| 参数 | 资源队列 | 资源组 |
|:----:|:----:|:----:|
| 并行 | 在查询级别管理 | 在事务级别管理 |
| CPU | 指定队列顺序 | 指定CPU的使用百分比，使用Linux控制组 |
|  内存 | 在队列和操作级别管理，用户可以过量使用 | 在事务级别管理，可以进一步分配和追踪，用户不可以过量使用。 |
| 内存隔离 | 无 | 同资源组下的事务使用的内存是隔离的，不同资源组使用的内存也是隔离的。 |
| 用户 | 仅非管理员用户有限制 | 非管理员用户和超级用户都有限制 |
| 排序 | 当没有可用槽位时，才开始排序 | 当槽位或内存不足时，开始排序 |
| 查询失效 | 当内存不足时，查询可能会立即失效 | 在没有更多的共享资源组内存的情况下，若事务到达了内存使用限制后仍然提出增加内存的申请，查询可能失效 |
| 避开限制 | 超级用具角色以及特定的操作者和功能不受限制。 | SET,RESET和SHOW指令不受限制 |
| 外部组件 | 无 | 管理PL/Container CPU和内存资源 |
	

	
	6、表储存
		1）、堆(HEAP)储存
		Postgresql 的堆储存，所有操作都会产生REDO记录，写到事务日志文件，并由它来控制磁盘的时间，适合OLTP性业务。
		
		2）、追加优化（AO）储存
		追加优化，删除更新数据时，通过BITMAP文件来标记被删除的行，事务结束时，需要调用FSYNC刷盘
		
		3）、行储存
			1）、一行为一个元组的形式，所有列都到一个文件上
			2）、读取任意列的成本不一样，越靠后的列成本越高
	
		4）、列储存
			1）、一列存一个单独的文件
			2）、读取任意列的成本一样
			3）、压缩比高于行储存
			4）、访问的列越多，开销越大
	7、储存模式及对比
		数据库中表储存的模式
		
		HEAP表           行存          不压缩 
		                 行存
	 AO表            (orientation=row)	可压缩
										(compresstype=zlib,COMPRESSLEVEL=5)
（appendonly=true）	      列存
					 (orientation=column)	
		
		
		
		储存大小对比
		
| 类型 | 文件 | 堆储存 | AO表行存 | AO表列存 | AO表行存压缩 | AO表列存压缩 |
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
| 大小 | 35G | 32G | 34G | 30G | 13G | 6822MB  |
		
		
		建立压缩表的例子
		create  table   temp  with (appendonly = true,orientation = row,compresstype = zlib , COMPRESSLEVEL = 5 ) as select *  from pg_tables distributed  randomly;
	
	8、数据加载
		1、加载方式的性能
			GPFDIST > COPY > 批量INSERT > 单挑INSERT 
		
		2、GPFDIST 优化的参数
		
| 参数名 | 说明 |
|:----:|:----:|
| writable_external_table_bufsize | 控制主实例向文件服务器发送数据包的大小，默认64kb |
| gp_external_max_segs | 控制访问文件服务器的实例数量，默认64 |
		
		
		
		以下测试的集群环境
			1、服务器数量20
			2、主备实例数：160
			3、网络速率：万兆
		

		gpfdist 导出控制参数writable_external_table_bufsize
| 文件大小（MB）| 导出耗时(s) | 速度(MB/s) | 参数值(kb) |
|:----:|:----:|:----:|:----:|
| 45441 | 201 | 226.07 | 512 |
| 45441 | 56 | 811.45 | 16384 |
		
		
		gpfdist 加载控制参数gp_external_max_segs
| 文件大小（MB） | 导出耗时(s) | 速度(MB/s) | 参数值(kb) |
|:----:|:----:|:----:|:----:|
| 45441 | 108 | 420.75 | 20 |
| 45441 | 59 | 770.19 | 40 |
	
	9、其他优化点
		1、表设计
			尽量设计仅允许插入的表
		
		
		2、表分布键
			选择唯一性比较高的单个字段作为分布键
		
		
		3、表分区
			对大的表进行分区，优化不同的分区储存模式
		
		
		4、索引
			注意索引的膨胀维护
		
		
		5、膨胀表
			注意膨胀表及时清理
		
	
# 第三节 日常维护对性能的提升
	1、统计信息
		统计信息作用
			- 估算表大小及数据膨胀情况
			- 帮助优化器生成最优的执行计划
		
		
		使用analyze 手机统计信息
			-  运行命令 : analyze tablename;
			-  相关参数：default_statistics_target ，默认25
			- 选择列来手机统计信息 
	
	2、收集统计信息
		什么时候运行analyze 手机统计信息？
			- 加载数据后
			- 创建索引后
			- 大批量的DML 操作后
		
		
		统计信息收集的参数设置
		gp_autostats_mode	on_no_stats	如果表没有统计数据，则CREATE TABLE INSERT,COPY 操作会触发统计信息的收集
			on_change	当更新的行超过gp_autostats_on_change_threshold
		定义的阈值时才触发统计信息收集，其默认是2147483647
			none	禁用自动统计信息收集功能
		
	3、数据膨胀
		1）、膨胀原因
	
		Greenplum 数据库使用多版本并发控制(MVCC)的储存机制，删除和刚更新的行仅是逻辑删除，其实实际数据仍然储存在表红，只是不可见。
	
		2）、膨胀造成影响
			- 占用磁盘储存空间
			- 查询表时扫描更多的文件快，浪费IO资源
	
	4、检测膨胀
		HEAP表
		
		select * from gp_toolkit.gp_bloat_expected_pages where btdrelid = lower(‘public.tem_heap’)::regclass;
		
		AO表
		select * from gp_toolkit._gp_aovisimap_compaction_info(‘public.tep_ao’::regclass);
		
	5、膨胀处理
		1）、HEAP 表
			- vacuum 
			vacuum 回收不了超过空闲映射空间的过期时
			- vacuum 不能回收时，用一下方法：
			vacuum full
			调优参数maintenance_work_mem ,默认64MB
			强制重分布
			altr  table $TB set WITH (REORGANIZE = TRUE) $DK
			
		2）、AO表
			- vacuum 
			相关参数: gp_appendonly_compaction_threshold , 默认是10
			
	6、数据倾斜
		1）、数据倾斜是很多性能问题和内存溢出问题的根本原因
		2）、集群的数据倾斜
			gpssh -f allhost   -e  “df|grep $datadir”
		
		3）、查询某一个表的倾斜
			select gp_segmet_id,pg_relation_size(oid), size from gp_dist_random(‘pg_class’) where oid = ‘public.demo’::regclass  order by size  desc;
		
	7、计算倾斜
		1）、计算倾斜在表关联，排序，聚合等操作中容易出现
		2）、有计算倾斜，但是没有溢出临时文件，则不会影响性能
		3）、控制溢出文件的参数
			gp_workfile_limit_files_per_query 
			SQL 查询分配的内存不足，数据库会创建溢出文件，默认值是100000, 0 表示无限制
			
			
			gp_workfile_compress_algorithm
			设置溢出的临时文件是否压缩
			
			
	8、计算倾斜排查过程
		gpssh  -f  allseg  -e ‘du  -sh /primary/gpseg*/base/17146/pgsql_tmp’ | sort -k 2 |grep -v du
		
		ls  -lhSr  /primary/pg_system/gpseg2/base/17146/pgsql_tmp
		
		lsof  /data2/primry/pg_system/gpseg2/base/17146/pgsql_tmp/pgsql_tmp_slicce10_sort_15673_002
		
		ps -ef|grep   15673
		
	9、系统表优化
		1）、系统表
			- 系统表也是head 表，随着对象的创建，修改，删除好造成数据膨胀
			- 系统表索引同事也会膨胀，且不能被vacuum回收空间
			
		2）、优化内容
			- 每天定时对系统表进行vacuum
			- 定期监控系统表的索引膨胀情况及reindex
			- 避免元数据数量过多
			
	10、作业流程优化
		1、避免祖业拥堵
			记录pg_stat_activity和pg_locks的快照，查询历史事件里存在锁的作业，根据实际情况层业务逻辑上优化。
	
# 第四节SQL优化技巧
	1、从执行计划中优化
		1）、看到过执行计划
		2）、两个重要概念
		- 重分布  (Redistribution)
		- 广播 (broadcast)
	
	2、union 与 union  all
		1）、使用union 时会去重，去重会发生重分布，而union  all 不会去重

	3、Union 的优化
		1、使用union 时数据会发生重分布
		2、分开插入会避免数据重分布
	
	4、分布键优化
		1）、多表关联时，尽量使用分布键作为关联条件
	
	5、一些SQL 优化内容
		1、避免出现笛卡尔积
		2、避免出现计算倾斜
		3、尽量避免向客户返回大数据量
		4、在子查询中尽可能过滤掉多余的行
		5、避免不必要的排序

# 第五节常见性能问题
	1、用户查询慢
		1）、注意使用limit的限制
		2）、进程是否被锁
		3）、SQL是否可优化
		4）、使用的表数据是否有倾斜
		5）、表关联中是否有计算倾斜
		6）、数据库资源是否繁忙
		
	2、数据库运行慢
		1、问题案例
		数据正常使用时，突然性能慢，用户体验很卡，正常的简单查询耗时长
		
	2、原因分析
		1）、内存不足，使用swap交换空间
		2）、CPU负载高
		3）、磁盘IO繁忙
		
	3、快速定位
		根据节点服务器占用系统资源最大的进程，回溯查询到数据库进程
	3、两段事务锁
		1、问题案例
			1）、执行删除表命令时，一直在执行中，链接数据库查询并没有锁
			2）、永久不处理后，wal文件堆积
			drop   table  test;  -- pid 7511
			select  procpid,sess_id,waiting from pg_stat_activity  where procpid = 7511;
			procpid  |   sess_id  |  waiting 
			------------+ ------------------+ ------------
			7511  |   1741873 | f 
			
		2、分析原因
		segment 节点有参与的事务
	
	4、处理过程
		1、根据sess_id查询各segment 的状态，发现seg01的seg0在等待状态
			gpssh  -f  allsegs  -e  ‘ps  -ef|grep 1741873’
			[seg01] ... con1741873’ seg0  cmd13  MPPEXEC UTILITY  waiting
		
		2、使用PGOPTIONS 方式连接到seg01的seg0节点，根据当前sess_id 查询segment节点的pid
		
			PGOPTIONS = “-c  gp_session_role =utility” -psql -h seg01  -d dnname gpadmin -p  port
			select procpid from pg_stat_activity where sess_id = 1741873
		
		3、根据pid找锁源并清理残余的在线事务
			select pg_terminate_backend(pid);
		
			残余的预备事务
			select relation = 62542114 from pg_locks where pid = 7511;
			select transaction from pg_locks where relation = 62542114;
			select gid from pg_prepared_xacts  where transaction = 98158175;
			
			ROLLBACK PREPARED ‘gid’;