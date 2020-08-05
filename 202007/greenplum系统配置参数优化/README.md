# 系统配置参数优化目录
	1.1 查看每个segment的内存配置参数
	1.2 查看shared_buffers(共享缓冲区)的内存
	1.3 查看max_connections(最大连接数)
	1.4 查看block_size(磁盘块)的大小
	1.5 查看work_mem的值
	1.6 查看statement_mem的值
	1.7 查看gp_workfile_limit_files_per_query的值
	1.8 查看gp_resqueue_priority_cpucores_per_segment的值
	1.9 查看gp_interconnect_setup_timeout的值
	1.10 查看effective_cache_size的值
	1.11 查看temp_buffers参数
	1.12 JDBC数据插入参数修改
	
# 1 系统配置参数优化
## 1.1 查看每个segment的内存配置参数
### 1.1.1 查看分配内存信息
	gpconfig -s gp_vmem_protect_limit
	
	在以上可以看出segment使用了系统默认的内存配置8192MB,改参数按照机器的内存大小可以适当的调大，详见计算如下:
	1、计算公式可参考如下：(mem+swap)* 0.9 /单个节点 segment 数量
	2、例如master节点上有252G的内存，segment个数为2个，分配最高的内存为:
	252*0.9 / 2 ≈ 110GB（112640 MB）
	3、例如数据节点上有252G的内存，segment个数为12个，分配最高的内存为:
	252*0.9/12 ≈ 18GB（18432MB）

### 1.1.2 修改内存参数
	登录到master节点上执行以下命令即可
	
	gpconfig -c gp_vmem_protect_limit -m 112640 -v  18432
	
	-c ： 改变参数的名称
	-m :  修改主备master的内存的大小一般的和-v一块使用
	-v ： 此值用于所有的segments，mirrors和master的修改

## 1.2 查看shared_buffers(共享缓冲区)的内存
### 1.2.1 查看系统配置的参数
	$ gpconfig -s shared_buffers

### 1.2.2 参数详解
	只能配置segment节点，用作磁盘读写的内存缓冲区,开始可以设置一个较小的值，比如总内存的15%，然后逐渐增加，过程中监控性能提升和swap的情况。以上的缓冲区的参数为125MB，此值不易设置过大，过大或导致以下错误
	[WARNING]:-FATAL:  DTM initialization: failure during startup recovery, retry failed, check segment status (cdbtm.c:1603)，详细的配置请查看
	http://gpdb.docs.pivotal.io/4390/guc_config-shared_buffers.html
	
### 1.2.3 修改参数
	修改配置
	gpconfig -c shared_buffers -v 1024MB
	
	gpconfig -r shared_buffers -v 1024MB
	
## 1.3 查看max_connections(最大连接数)
### 1.3.1 查看最大连接数参数
	$ gpconfig -s max_connections

### 1.3.2 参数详解
	此参数为客户端链接数据库的连接数，按照个人数据库需求配置，参数详解请查看:
	https://gpdb.docs.pivotal.io/4380/guc_config-max_connections.html
	
## 1.4 查看block_size(磁盘块)的大小
### 1.4.1 查看磁盘块的大小
	$ gpconfig -s block_size
	
### 1.4.2 参数详解
	此参数表示表中的数据以默认的参数32768 KB作为一个文件，参数的范围8192KB - 2MB ,范围在8192 - 2097152 ，值必须是8192的倍数，使用时在blocksize = 2097152即可

## 1.5 查看work_mem的值
### 1.5.1 查看集群中work_mem的配置大小
	$ gpconfig -s work_mem
	
### 1.5.2 参数详解
	work_mem 在segment用作sort,hash操作的内存大小当PostgreSQL对大表进行排序时，数据库会按照此参数指定大小进行分片排序，将中间结果存放在临时文件中，这些中间结果的临时文件最终会再次合并排序，所以增加此参数可以减少临时文件个数进而提升排序效率。当然如果设置过大，会导致swap的发生，所以设置此参数时仍需谨慎。刚开始可设置总内存的5%
### 1.5.3 修改参数
	修改系统配置文件,重启集群使之生效
	gpconfig -c work_mem  -v 128MB
	
	或在客户端session设置此参数
	SET work_mem TO '64MB'
	销毁session参数为:
	reset  work_mem;
	
## 1.6 查看statement_mem的值
### 1.6.1 查看集群中statement_mem的值
	$ gpconfig -s statement_mem

### 1.6.2 参数详解
	设置每个查询在segment主机中可用的内存，该参数设置的值不能超过max_statement_mem设置的值，如果配置了资源队列，则不能超过资源队列设置的值。
### 1.6.3 修改参数
	修改配置后重启生效
	gpconfig -c statement_mem  -v 256MB
	
## 1.7 查看gp_workfile_limit_files_per_query的值
### 1.7.1 查看此值的大小
	$ gpconfig -s gp_workfile_limit_files_per_query
	
### 1.7.1 参数详解
	SQL查询分配的内存不足，Greenplum数据库会创建溢出文件（也叫工作文件）。在默认情况下，一个SQL查询最多可以创建 100000 个溢出文件，这足以满足大多数查询。 
	该参数决定了一个查询最多可以创建多少个溢出文件。0 意味着没有限制。限制溢出文件数据可以防止失控查询破坏整个系统。
	如果数据节点的内存是512G的内存,表的压缩快的大小(block_size)是2M的话，计算为: 512G + 2 * 1000000 / 1024 ≈ 707 G 的空间，一般的表都是可以的，一般的此值不需要修改
	
## 1.8 查看gp_resqueue_priority_cpucores_per_segment的值
### 1.8.1 查看此值的大小
	$ gpconfig -s gp_resqueue_priority_cpucores_per_segment

### 1.8.2 参数详解
	每个segment分配的分配的cpu的个数，例如:在一个20核的机器上有4个segment,则每个segment有5个核，而对于master节点则是20个核，master节点上不运行segment的信息，因此master反映了cpu的使用情况

### 1.8.3 修改参数
	按照不同集群的核数以及segment修改此参数即可，下面的实例是修改成8核
	
	gpconfig -c gp_resqueue_priority_cpucores_per_segment  -v  8 
	
## 1.9 查看gp_interconnect_setup_timeout的值
### 1.9.1 查看此值的大小
	$  gpconfig -s gp_interconnect_setup_timeout
	Values on all segments are consistent
	GUC          : gp_interconnect_setup_timeout
	Master  value: 2h
	Segment value: 2h
### 1.9.2 参数详解
	此参数在负载较大的集群中，应该设置较大的值。
### 1.9.3 修改参数
	gpconfig -c gp_interconnect_setup_timeout  -v  2h
	
## 1.10 查看effective_cache_size的值
### 1.10.1 查看此值的大小
	$ gpconfig -s effective_cache_size
	Values on all segments are consistent
	GUC          : effective_cache_size
	Master  value: 16GB
	Segment value: 16GB
### 1.10.2 参数详解
	这个参数告诉PostgreSQL的优化器有多少内存可以被用来缓存数据，以及帮助决定是否应该使用索引。这个数值越大，优化器使用索引的可能性也越大。 因此这个数值应该设置成shared_buffers加上可用操作系统缓存两者的总量。通常这个数值会超过系统内存总量的50%。
#### 1.10.3 修改参数
	gpconfig -c effective_cache_size  -v  32GB
	
## 1.11 查看temp_buffers参数
### 1.11.1 查看此值的大小
	$ gpconfig -s temp_buffers
	Values on all segments are consistent
	GUC          : temp_buffers
	Master  value: 32MB
	Segment value: 32MB
### 1.11.2 参数详解
	即临时缓冲区，拥有数据库访问临时数据，GP中默认值为1M，在访问比较到大的临时表时，对性能提升有很大帮助。
### 1.11.3 修改参数
	gpconfig -c temp_buffers  -v  2GB
	
## 1.12 JDBC数据插入参数优化

	参考地址:
	https://weibo.com/ttarticle/p/show?id=2309404455258339279060

	
	greenplum-jdbc-5.1.4.jar 下载地址
	https://network.pivotal.io/products/pivotal-gpdb#/releases/526878/file_groups/2340
	
	
	Greenplum调整的参数如下：
	
	(1)全局死锁检测开关
	在Greenplum 6中其默认关闭，需要打开它才可以支持并发更新/删除操作；
	gpconfig -c gp_enable_global_deadlock_detector -v on
​	
	(2) 禁用GPORCA优化器（据说GPDB6默认的优化器为：GPORCA）
	gpconfig -c optimizer -v off
​	
	(3)关闭日志
	此GUC减少不必要的日志，避免日志输出对I/O性能的干扰。
	gpconfig -c log_statement -v none

	
	
	
	