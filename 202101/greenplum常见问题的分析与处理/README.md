# 第一节 排查问题的方法
	1、 不能只看表象，要去看日志，找规律，去复现
	2、去哪看日志，有哪些日志
	3、管理工具的日志
	4、GP数据库日志
	5、 CSV日志
	6、遇到问题解决方式
# 第二节 数据库启动停止的问题分析
	1、gpstop 有哪些几步操作
	2、too many clients alrrady
	3、database is in recovery mode / is starting up
	4、gpstart 有哪些几步操作
	5、postmaster.pid 不存在
	6、postmaster.pid 不存在--原因分析及解决方法
	7、启动过程卡住
	8、启动过程卡住--配置文件有问题
	9、启动过程卡住--Segment启动问题排查
	10、启动过程卡住--分析Segment日志
	11、gpstart error:Do not have enough valid  segments to start the array
# 第三节 数据库状态不正常分析及处理
	1、gpstate 检查segment状态 -- gpstate e
	2、发现segment down后分析和收集日志方法
	3、 segment状态异常常见问题分析
	4、segment状态异常常见问题分析
	5、gprecoverseg 过程中无法启动被恢复的实例
	6、gprecoverseg 过程服务器再次宕机
	7、gprecoverseg 过程实例状态再变为down
	8、gpstate检查Standby master -- gpstate  -f
	9、Standby master 状态异常 -- 未启动
	10、Standby master状态异常  -- 未同步
# 第四节 扩容问题分析及处理
	1、gpexpand -- 集群新增segment的操作
	2、gpexpand 新增segment时一些常见问题处理
	3、gpexpand 新增segment时一些常见问题处理
# 第五节 运行中几类常见问题分析
	5.1 内存相关问题
		5.1.1 out of shared memory
		5.1.2 insufficient memory
		5.1.3 out of memory
		5.1.4 应用优化
	5.2 PANIC
		5.2.1 什么是PANIC
		5.2.2 发生PANIC 后，数据库实例会做什么
		5.2.3 PAINC 可能是BUG或认为kill进程货其他外部因素引起的
		5.2.4 发生PAINC 后如何应对
		5.2.5 如何定位问题
		5.2.6 辅助分析PANIC的方法
	5.3 Interconnect  encountered a network error

# 第一节 排查问题的方法
	
	1、不能只看表象，要去看日志，找规律，去复现
		PID file “/data/master/gpseg-1/postmaster.pid” does  not exist
		
		Unexpected  internal  error
		
		server closed the  connection  unexpectedly
		This probably  means  the  server termonated  abnormally
		Before  or  while processing  the  request
		
	2、去哪看日志，有哪些日志
		1、管理工具日志
		数据库管理工具：gpinitsystem, gpstate, gpstop,gpstart.gprecoverseg,gpcheckcat 等
		GP集群内所有服务器上：/User_home_directory/gpAdminLogs/
		
		
		2、GP数据库日志
		Master 实例日志：$MASTER_DATA_DIRECTORY/pg_log
		segment实例日志： /segment_datadir/pg_log
		CSV文件
		startup.log
		
	3、管理工具的日志
		1、日志文件是*.log,每天工具第一次被执行就会新生成一个log文件
		2、工具在屏幕上显示的信息会全部保存在文件中
		3、有部分工具日志文件中信息量回避屏幕上丰富，如：gpinitsystem, gpcheckcat, gpbackup等
		4、如需要更详细的日志，可以使用verbose参数，如：gprecoverseg  -v , gpcheckcat  -v  -A , gpstate -e -v
		5、工具内部调用的子命令日志
		gpstate : 在master上gpstate_YYYMMDD.log ，在Segment上
		gpstart : 在master上gpstart_YYYYMMDD.log 在Segment上
		gpstop : 在master上gpstop_YYYYMMDD.log 在Segment上
	
	4、GP数据库日志
		1、startup.log 
			1）、实例进程启动时写入的日志，一般每次启动写入几行，日志中的一些Warning可以忽略
			2）、如果实例启动既失败，可以先从startup.log日志中查找原因
		
		
		2、CSV日志
			1）、实例进程启动后，操作记录都会写入csv日志中。
			2）、log_rotation_age, log_rotation_size 可以调整日志文件切换的策略
			3）、log_min_duration_statement设置打印SQL运行时间
			4）、log_statement可以设置输出DDL,DML,或者ALL日志
			5）、log_connections,log_disconnections可以打开数据库连接和断开连接的日志
			6）、log_min_messages，可以设置不同的日志级别
		
	5、CSV日志
		1、CSV 日志详细的格式说明参考管理员手册
		2、CSV日志可以通过外部表的方式加载到GP数据库中，便于进一步分析
		3、外部表的定义可以参考gp_toolkit._gp_log_master_ext
	
	6、遇到问题解决方式
		1、找对日志
		2、凭经验，是否已知问题
		3、寻找规律
			- 经常出现还是偶尔出现
			- 是否集中在某个时间段
			- 是否发生在固定的机器
			- 是否发生在固定的实例
			- 报错时是否总会有某个SQL在运行
		4、可能需要测试和场景复现



# 第二节数据库启动停止的问题分析
	1、gpstop 有哪些几步操作
		1、从master中获取所有Segment的地址，端口，实例状态等信息
		2、停止Master实例
		3、停止Standby master实例
		4、并发停止primary实例
		5、并发停止mirror实例
		6、清理共享内存
	
	
		建议：
		gpstop 执行完后，使用gpssh链接到所有服务器检查postgres进程数是否为0，如果进程数不为0，要具体分析排查

	2、too many clients alrrady
		1、由于连接数太多，gpadmin也无法链接数据库获取segment实例的信息，此时，使用gpstate也会遇到同样的报错，统计master上的postgres进程，可以评估当前客户端的连接数。
		
		2、首先考虑清理客户端的链接，可以让gpadmin连接上，就可以操作gpstop
			-  如果还有可用的客户端使用gpadmin链接着数据库，可以查看pg_stat_activity，通过	   pg_terminate_backend杀死会话释放部分可用的连接数。
			- 查看是否有很多starting_up的postgres进程  ps -ef|grep  postgres | grep  start 可以用kill ( 不能使用kill -9 )杀掉这些进程,确认是否释放部分可使用的链接。
		
		
		3、如果无法释放可用链接，使用pg_ctl停止master实例
			-  pg_ctl stop  -W -m fast -D $MASTER_DATA_DIRECTORY
			-  如果-m  fast 无法把进程停下来，就只能使用-m  immediate
			-  然后gpstart  -m 然后再次操作gpstop  -fa 
		
		4、参数superuser_reserved_connections
		- 默认值3，建议调大，保证gpadmin有足够的预留连接数
		

	3、database is in recovery mode / is starting up
		1、是由于master实例发生了PANIC，无法自动回复正常，此时用正常手段无法连接到数据库
		2、只能使用pg_ctl z停止master实例
			- pg_ctl  stop -W  -m fast  -D $MASTER_DATA_DIRECTORY
			- 如果-m  fast 无法把进程停下来，就只能使用-m   immediate
			- 然后gpstart -m 然后再次操作gpstop  -fa 
		
	4、gpstart 有哪些几步操作
		1、启动Master实例，获取所有segment的地址，端口，实例状态等信息。
		2、停止Master实例
		3、启动Segment实例（开始打开），primary 和mirror的进程都启动，并且启动Primary与mirror之间的同步进程，如果停库之间实例状态为down，启动时会忽略。
		4、再次启动Master实例
		5、启动Standby  master实例
	
	5、postmaster.pid 不存在
		1、报错的原因与该文件不存在无关，该文件用于保存该实例主进程号，由程序自行管理不需要人员干预，报错时代表实例的主进程刚启动就失败。
		2、Master 和Segment都有可能遇到这个错误
			- 如果Master报错通常在gpstart命令输出信息中可以看到
			- 如果是Segment报错可在gpstart  -v(version)的输出中看到，也可以在启动失败的主机的/<User_home_directory>/gpAdminLogs目录下，gpsegstart.py_<hostname>;<username>_YYYYMMDD.log 日志中可以看到类似信息
		3、问题定位方法
			- gpssh 到所有服务器检查进程启动状态，确定哪些实例未启动成功
			- 查看startup.log,通常在startup.log中就可以找到报错原因

	6、postmaster.pid 不存在--原因分析及解决方法
		1、导致这类报错的一些原因及解决方法
			1）、信号量设置偏小，可调整/etc/stsctl.conf中的参数kernel.sem，或者调低max_connections
			2）、共享内存设置不够大，可调整OS参数kernel.shmmax,或者调低使用共享聂村的一些参数配置
			3）、/tmp 目录(No  space  lefo  no  device ) 可能是磁盘满子(df  -h ) 或者inode用满了(df  -i ) 解决方法就是删除文件。


	7、启动过程卡住
		1、几种启动卡住的现状
			- 在第一步启动master时，长时间不向下走，这种情况就重点分析maste的问题
			- 启动时一直在打点，很长时间不结束，这通常是因为启动segment实例时出现了问题
			- gpstart命令执行到最后，看上去执行完了，但是命令一直不结束
		
		2、问题定位方法
			- 查看startup.log
			- 查看相对应的csv日志文件
			- gpssh 到左右的服务器，检查postgres进程数，检查服务器状态是否正常
			- gpssh 到所有的服务器，检查是否有starting up进程，如果有重点检查这些实例

	8、启动过程卡住--配置文件有问题
		1、pg_hba.conf 文件有问题
			- 在pg_hba.conf 文件中有格式错误的规则，会导致对应的实例启动时停住，从CSV日志中可以看到报错信息。
		
		2、postgresql.conf 中有不规则的信息
			- 在手工修改postgresql.conf 时，误操作遗留的错误，系统启动时读取时失败，从startup.log 中可以看到报错的信息
			- 如果是个别参数名或者参数写错，启动时正常，检查startup.log可以看到错误的报错信息。
		
		3、处理方法
			- gpstart 会有超时机制，等待一段时间后，会自动报错时推出
			- 可以把gpstart 命令内部调用的pg_ctl 命令进程杀掉，可使用kill，不能使用kill - 9
			- 修改配置文件后重启启动
	
	9、启动过程卡住--Segment启动问题排查
		1、首先凭经验判断，判断本次启动是不是比以往启动过程时间要慢的多
		2、检查每台服务器是否正常
			- 使用gpssh 连接到所有服务器，查看是否可以连通，如果gpssh 也会卡住，首先排查那台机器ssh有问题
			- gpssh 连通所有服务器后，先查看每台启动postgres进程数据量
			gpssh -f allhosts “ps -ef|grep  postgres|grep  -v  grep | wc -l ”
	
		3、对启动进程数明显减少的服务器，ssh到服务器上进行更详细的检查
			- 排查服务器状态，检查文件系统，内存等是否正常，检查文件系统使用率
			- 到/<User_home_directory>/gpAdminLogs/目录下，查看gpsegstart.py_<honemame>;<username>_YYYYMMDD.log 日志
			- 检查服务器上各个实例(primary和mirror)的端口，检查是否缺少某个端口，也就是某个实例未启动
			- 检查服务器上每个实例的进程数量，是否有实例数与别的实例不一致
			- 进入怀疑有问题的实例目录下，查看startup.log 和CSV文件
	
	10、启动过程卡住--分析Segment日志
		1、通过分析日志，排查上面所提到的一些问题，如：配置文件，系统信号量，/tmp 目录空间，/data 目录空间
		2、服务器端口占用的问题
			- 通常primary 和mirror实例端口不会被占用
			- GPS以及之前的版本，还有一个端口replication_port(在gp_segment_configuration中可查)，用于建立primary与mirror之间数据同(file  replication)的端口，这个端口有一定几率而被随机端口占用，导致primary与mirror之间无法建立数据同步关系，结果就是启动后又mirror实例down掉了。
			- 通过调整系统参数net.ipv4.ip_local_port_range和net_ipv4.ip_local_reseerved_ports，调整系统中端口使用的范围，规则随机端口与GP数据库使用的端口冲突。
		3、遇到系统表的相关报错
			- 部分系统表的问题，可能会导致实例启动失败，通常的方法是通过设置一些参数，让实例能够启动，然后修复系统表，最后做gprecoverseg
			- 一些系统表问题的处理参数及修复方法参见文章:
			
			https://mp.weixin.qq.com/s?__biz=Mzg4NzU1MzIzMA==&mid=2247529359&idx=1&sn=3a5e08a505a05c3e9b54f50cc37f4a07&source=41#wechat_redirect
			
			- 建议：找原厂的工程师协助解决
		
		
	11、gpstart error:Do not have enough valid  segments to start the array
		1、原因分析
			- 通常实在启动前就有down的实例，启动时对应的实例也没有启动成功
			- 也有可能刚好primary和mirror所在的服务器同事故障
		
		2、问题定位方法
			- 如果是服务器故障，则只能等到服务器修复后在启动
			- 排除服务器故障，则重点关注启动失败的实例，查看日志，逐一排查上述提到的一些报错情况。
	
	
# 第三节数据库状态不正常分析及处理
	1、gpstate 检查segment状态 -- gpstate e 
		1、segment状态正常，会显示“ALL segment are  running  normally”
		2、凡是查询结果不显示这个信息，都代表有问题，需要进一步协查，gpstate  -e 的结果可以作为监控数据库状态的重要手段之一，可对接客户监控平台调用。
		3、如果发现无法获取某些segment状态，可以反复检查2-3次，检查是否由于网络闪断，服务器暂无相应导致的不正常。
		4、如果遇到gpstart 一直打点，不输出结果，可以用gpssh链接所有服务器，检查连接性，定位是否有服务器ssh不同。
	
	2、发现segment down后分析和收集日志方法
		1、使用gpstate  -e 确定down状态实例的情况，确定设计哪些主机和端口
		2、从系统表gp_segment_configuration中检查状态为down的实例，记录dbid,content,端口号
			- select * from gp_segment_configuration order by 2,1;
			- select * from gp_segment_configuration  where status = ‘d’ order by 1;
	
		3、从系统表gp_configuration_history中检查实例状态变更的具体时间点
			- select * from gp_configuration_history order by 1 desc;
		4、先检查master的日志
			- 依据具体的实例变更的时间点，查找相应的CSV日志
			- 通过FTS关键字查找日志，如:grep “FTS” : gpdb-YYYY-MM-DD_000000.csv
			- 通过FTS的信息可以判断，是否为master的ftsprobe进程主动探测到的，默认情况下FTS探测实例状态异常，会重试5次
			- 对于链接超时，服务器宕机，网络中断等情况，可以在FTS的日志信息中看到明细的报错信息。
			- primary与mirror之间断链（如：gp_segment_connect_timeout超时，mirror空间满等），primary实例会向FTS进程汇报，FTS日志中会显示相关的信息。
		
		5、进一步去检查Segment的日志，依据前两部中定位到的实例ID，登录对应的服务器中的检查
			- 一对primary和mirror实例的日志都应该关注
			- ps -ef|grep green检查对应实例目录（关注端口号和contentID）,进入实例目录查看CSV日志
			- 检查出问题时间点前后的日志，查找可疑的，异常的信息。
			
	3、segment状态异常常见问题分析
		1、gp_segment_connect_timeout 相关
			- “threshold  ‘75’ percent  of  ‘gp_segment_connect_timeout=6000’ is reached , mirror may not be able to keep up with primary , primary may transition to change tracking”
			- primary 日志中看到上述信息，代表primary会主动与mirror断开连接，mirror会被置为down
			- 日志中会提示，调大gp_segment_connect_timeout 的设置值，可适当调大参数值，但不能一味通过调大该参数来规避同类的问题，必须要排查是什么原因导致的服务器资源消耗过大。
			- 分析报错规律：是否集中在某些或某台服务器上？出现时间点是否有规律，出现时是否有相同的SQL在运行，出现时系统并发数高不高？
			- 常见集中原因：
				-- 因为mirror所在的服务器资源消耗过高，Workload过高，甚至服务器hang住无响应，导致primary与mirror之间的通讯大量超时。
				-- 故障期间服务器网络有较长时间大流量，把带宽基本用满，导致网络输出大量超时。
				-- IO性能是否存在问题，故障期间硬盘故障并伴随着大量的IO读写操作，也可以导致mirror响应慢导致超时。
	
	4、segment状态异常常见问题分析
		1、Cannot allocate  memory
			- 如果是SQL执行过程中遇到内存不足，SQL报错结束，报错信息是out of  memory，不会影响实例状态。
			- 如果是primarry的服务进程，如：checkpoint等进程遇到内存不足时，primary状态会down，master会切换mirror实例
			- 检查当时的并发数
			- 检查gp_vmem_protect_limit和系统参数vm.overcommit_ratio等配置是否合理
		
		2、I/O error
			- 如果只是某个表的数据文件发生损坏，设计该表的SQL回报错，这不会影响segment实例状态
			- 如果由于阵列卡等问题，导致整个盘无法访问，IO error报错，则会导致盘上的segment实例down掉
	
	5、gprecoverseg 过程中无法启动被恢复的实例
		1、在gprecoverseg命令执行过程中，启动被恢复的实例时就报错
		2、参考上面gpstart失败的分析方法，分析启动不成功的实例的startup.log和csv日志
		3、几类常见的问题
			- 与gpstart类似的问题，/tmp/空间满子，配置文件中有错误，OS参数问题等
			- 如果一次操作恢复的实例比较多时，在primary与mirror之间建立数据复制连接时，有可能会超时
			- 如果系统表元数据有问题，也有可能导致实例启动失败
	
	6、gprecoverseg 过程服务器再次宕机
		1、如果在gprecoverseg过程中，服务器反复宕机，建议认真检修故障服务器，不要没搞清楚问题就反复尝试恢复。
		2、如果无法修复，或者无法找到问题根源，可考虑更换服务器，或重装操作系统
		3、如果遇到阵列卡故障，需要由硬件厂商确认文件系统不会损坏，数据不会丢失，如果相关方面无法保证，可考虑采用重新格式化磁盘，做全部恢复。
		
	7、gprecoverseg 过程实例状态再变为down
		1、gprecoverseg命令正常结束，已经开始恢复数据，隔一阵发现恢复的实例又变成了down
		2、建议先排查实例的down的原因，不要盲目重试gprecoverseg
		3、排查方法，跟上面gpstate发现segment状态不正常的检查方法相同，一对primary和mirror实例的CSV日志都需要分析。
		4、gprecoverseg命令结束，实例已正常启动，primary与mirror之间开始resync，此时primary和mirror的CSV日志中会打印很多resync的LOG信息，可重点查找WARNING信息。
		5、几种错误实例
			- primary实例上数据文件不存在，情况一：对应表确实已经不存在，可能方式系统繁忙，正准备恢复的表刚好被drop掉了，重做gprecoverseg一般不会碰到同样的问题，但建议在系统压力较小的时候再做gprecoverseg。
			- primary实例上数据文件不存在，情况二:对应表时存在的，但实例上数据文件不存在，这时候已经不可用，推荐方案是重建表，从其他系统或者备份中恢复表数据，问题表drop掉，然后再做gprecoverseg，系统闲时还可以做一次gpcheckcat，查看是否还有其他系统表的问题。
			- mirror实例上数据文件不存在，如果primary实例上数据文件值正常的，表时可用的，可以考虑两个方案：
			-- alter table tablename set  with (reorganize = true)
			-- 原表rename，新建表并导入数据，drop表
			- 如果有人建议遇缺文件就touch一个空文件，建议咨询原厂工程师后再操作
	
	8、gpstate检查Standby master -- gpstate  -f 
		1、Standby master 状态正常时，显示信息如下:
			--  Standby  status  = Standby host  passive 
	
	9、Standby master 状态异常 -- 未启动
		1、Standby  master 的状态未启动时，显示如下：
			-- Satndby  status  = Standby process not running 
		
	10、Standby master状态异常  -- 未同步
		1、Standby master 与master之间不同步
			- No entries  found
		
		2、重点查看Standby master的CSV日志
			- 主机名，网络等问题
			- Master的pg_hba.conf 配置有问题，在master上，针对Standby主机IP,replication的配置行，必须是trust
			- Standby master 可能长时间未tongxin，master上较老的WAL已经丢弃，此时就要删除Standby master然后重建
	
# 第四节扩容问题分析及处理
	1、gpexpand -- 集群新增segment的操作
	
		1、检查GP集群中各数据库的表
		2、检查新服务器配置的一致性
		3、在master上打包元数据
		4、将元数据包分发到所有服务器上
		5、配置新的Segment实例(包括primary和mirror)
		6、清理临时文件
		7、配置新的Segment实例的filespace/tablespace
		8、清理新的Segment上多余的元数据
		9、重启数据库
		10、创建gpexpand模式，修改所有数据库下的所有表(除根分区)的分布键为random(GP5及之前版本)，把表信息插入gpexpand.status_detail表中
		11、重启数据库
		12、执行gprecoverseg -F 对新服务器上的mirror实例进行全量恢复
	
	2、gpexpand 新增segment时一些常见问题处理
		1、目录权限问题
			-- 需要确认扩容服务器上各个数据目录的权限，如:/data1/primary, /data1/filespace等
		
		2、目录空间问题
			- master空间是否足够
				-- 提前统计master实例上元数据的空间，包括$MASTER_DATA_DIRECTORY及各个Filespace(GP6是Tablespace)的空间容量。
				-- 程序在Master数据目录($MASTER_DATA_DIRECTORY)下创建临时目录暂存所有扩容需要的元数据，需确保空间足够
				-- 程序会在当前目录下打包元数据(创建gpexpand_schema.tat)，文件不做压缩，需确保当月目录空间足够
		
		3、新扩容服务器上空间是否足够
			- 建议使用-t参数制定在服务器上接受gpexpand_schema.tat文件的目录
			- 确保接受gpexpand_schema.tat文件的目录空间充足
		
		4、关注Master实例目录大小
			- 元数据打包时会忽略$MASTER_DATA_DIRECTORY/pg_log和$MASTER_DATA_DIRECTORY/gpperfmon/data两个目录，建议提前清理CSV日志让gpexpand更高效
			- 扩容前需确认，$MASTER_DATA_DIRECTORY是否有其他不合理的文件或者目录，如：coredump文件，备份的文件等，提前做好清理工作。
			- 关注系统表膨胀情况，如果系统表膨胀比较厉害，建立在gpexpand之前，安排专门的停机窗口做vacuum fuu操作
			- 不建议在gpexpand过程中自动vacuum  fuu系统表
		
	3、gpexpand 新增segment时一些常见问题处理
		1、扩容前建议进行gpcheckcat检查
			- 建议gpexpand 之前，安排专门的停机窗口，做系统表一致性检查(gpcheckcat)
			- 可与系统表vacuum full安排在一次停机窗口内操作
			- 系统表一致性检查覆盖所有Database，包括gpperfmon库
			- 如gpcheckcat发现问题，请及时修复，需要修复好之后才可以进行gpexpand
		
		2、检查是否安装perl和rsync
			- which perl, which  rsync
			- 可通过安装磁盘或者yum源可安装
		
		3、参数-S | --simple_progress
			- gpexpand 默认统计每张表的size，如果库内表数量很多，会导致gpexpand耗时很长
			- 可使用-S参数，忽略计算表size的过程，效率可大幅度提升
	
	4、部分用户操作窗口(如：CRT)会超时退出甚至挂死，有可能会导致gpexpand命令被退出，如果类似情况，需要分析日志(~/gpAdminLogs/gpexpand_YYYYMMDD.log)看操作停在哪里，一般需要回滚重做，同时建议用nohup提交gpexpand命令
	
	5、gpexpand -- 表重分布
		1）、操作步骤
			-- 再次启动gpexpand命令，制定运行时长，制定处理并发，自动执行表重分布操作
			-- 依据gpexpand.status_detail表中的信息，按照优先级排序(rank)，逐个表执行重分布操作
			-- 使用nohup把gpexpand放后台操作，重分布操作随时可以杀掉重调。
		
		2）、常见问题
			-- 部分表被删除，重分布(alter  table)的SQL报错，该报错忽略即可
			-- 如果在重分布过程中遇到宕机等硬件故障，导致重分布(alter table)的SQL报错，后续重新启动gpexpand重分布即可
			-- 如果一张超大表并且严重倾斜，表的重分布操作会十分慢，建议直接alter table 修改分布键，修改为合理的数据可均衡分布的分布键字段
		
		3）、其他建议
			- 扩容前先做一次全面系统巡检，把严重倾斜的表修正过来。
			- 扩容前务必做好新服务器的IO,网络性能测试，如果集群较大，老机器之间也需要做网络压测

# 第五节运行中几类常见问题分析
	5.1 内存相关问题
		5.1.1 out of shared memory
			1、通常是由于某个参数设置值无法满足实际的需求
			2、查看相关的报错日志，日志中通常会提示需要更加哪个参数值
			3、参数不是调的越大越好，参数调的太大也会可能会导致共享内存不足，会导致启动失败。
		5.1.2 insufficient memory
			1、报错发生在生成执行计划阶段，一般调大statement_mem可解决
			2、什么情况下容易出现“insufficient  memory”
				- 使用了一张子分区个数超多的分区表，对全表进行操作
				- 生成一个很复杂的执行计划，其中切片(clice)很多
			3、优化建议
				- 合理规划和设计分区表，控制子分区的粒度和个数
				- 分析执行计划是否可以优化，SQL是否可以拆分
		5.1.3 out of memory
			1、常见报错信息
				- Cannot  allocate  memory
				- Out of memory
				- Canceling  query bacause  of  high VMEM usage
				
			2、分析日志
				- Master 和segment都可能发生OOM，所有实例的日志都可能需要关注
				- 发生OOM时，日志中会出现的大量的内存信息，可忽略
				- 检查报错时刻系统的并发度
				- 内存严重不足的情况，服务进程可能都无法获取内存，会引起down实例
				
			3、分析报错的SQL
				- 对于简单的SQL，维护的SQL，则可排除嫌疑
				- 对于日常能正常运行的SQL，如果出现OOM，可分析统计信息和数据是否有问题，如果重新提交SQL，可以正常执行则可排除嫌疑。
				- 重点关注非日常运行的SQL，查看执行计划。
				
			4、内存相关配置
				1）、OS参数
					vm.overcommit_memory = 2
					vm.overcommit_ratio = 95
					OS总可用内存计算方法:RAW * ( vm.overcommit_ratio / 100 ) +SWAP
					
				2）、Resource Queue
					-- gp_vmem_protect_limit -- 限制每个instance上所有语句可以使用的内存总量的上限制
					-- resource_queue中的memory_limit建议如果加多大SQL在运行的队列，都建议设置memory limit，所有多些的memory limit 总和不要超过gp_vmem_protect_limit 
					-- 为了提升效率减少workfile的输出，可调大statement_mem但不能滥用，以避免造成浪费
					-- 内存配置计算指引：https://greenplum.org/calc/
				
				3）、Resource Group 
					-- gp_resource_group_memory_limit 设置了每个GP Host主机上可以分配给资源组的系统内存的最大百分比，缺省值为0.7(70%)
					-- 每个Instance能获得的内存算法，rg_perseg_mem = ((RAM * (vm.overcommit_ratio / 100 ) + SWAP) * gp_resource_group_memory_limit) / mum_active_primary_segments
					-- 每个资源组可设置专用的内存MEMORY_LIMIT ，其中在设置每个组内共享内存MEMORY_SHARED_QUOTA，当资源组内共享内存用尽，全局共享内存也用尽，SQL还需要内存则会报错。
		5.1.4 应用优化
			1）、并发控制
				-- 系统并发没有控制好，或者不做控制，OOM和系统不稳定的风险就会增加
				-- 通过Resource Queue 或Resource  Group 做好并发控制
				
			2）、分区表设计和应用
				- 要控制好单表子分区的数目
				- 分区表的维护策略，如: 添加分区策略，删除旧分区策略，合并就分区的策略
				- 及时收集统计信息
			
			3）、SQL 优化
				- 分区表全表关联delete或update，保证分布键一致及用于分布键关联
				- 注意执行计划中分区裁剪是否合理，分区字段过滤条件是否不生效
				- 减少超复杂超长的SQL，合理的简化和拆分SQL,效率可大幅度提升
				
			4）、可调整参数
				- gp_max_slices
		
	5.2 PANIC
		5.2.1 什么是PANIC
			- 有postgres 进程异常退出或被kill
			- Master或者Segment实例都可能发生PANIC
			- 通常会查到”PANIC”这个关键字(注意不是ERROR/FATAL)
			- 如果没找到”PANIC”,还可以超找”process (PID XXXXX) was terminated  by  signal X” 类似的关键字
			
		5.2.2 发生PANIC 后，数据库实例会做什么
			- 终止所有活动链接(包括所有在运行的SQL)，在运行的SQL都会报错，报错信息是“server closed the connection  unexxpectedly ” 或者“Unexpected  internal  error”
			- 服务进程都被停止，清理临时文件等操作，此时新发起的SQL会收到报错”the databases system is in  recovery  mode”
			- 服务进程自动重启，启动期间新发起的SQL会收到报错”the database  system  is  starting  up”
			- 服务进程启动完成后，重新恢复可接受链接，从日志中会看到信息”database  system  in  ready  to  accept  connections”
			
		5.2.3 PAINC 可能是BUG或认为kill进程货其他外部因素引起的
			-  如果从日志中发现was terminated  by  signal  9 , 则可以确定是被kill或者其他的外因导致的
		
		5.2.4 发生PAINC 后如何应对
			- 分析日志，找到导致PANIC的根源
			- 如果是人为操作导致，请找相关负责人，完善操作步骤
			- 如果初步判断 是BUG，避免类似的SQL，建议寻求原厂协助，提供日志和core文件开case或者ticket
			
		5.2.5 如何定位问题
			1）、可以怀疑发生了PANIC的报错信息
			- server closed the  connection unexpectedly
			- Unexpected internal  error
			- the database system is in recovery  mode
			- the database  system  is  staring  up
			
			2）、分析日志技巧
			- Master 和segment实例日志都需要检查
			- 以”PANIC”关键字查找，定位到PANIC的日志后就可能看到会话号，根据会话号往前就能找到是什么SQL
			- 如果找不到PANIC关键字，按照”process (PID XXXXX) was  terminated by signal  X” 查找，定位到那个进程号被终止，依据关键字”p+进程号”往前查找，也可以查找到是什么进程
			- 如果SQL在master上发生PANIC，可能是生产执行计划阶段产生PANIC
			- 如果SQL在segment上发生的PANIC，可能是SQL执行过程中产生PANIC
			
		5.2.6 辅助分析PANIC的方法
			1）、开case或ticket，需要提供core文件和数据库日志帮助分析
			2）、操作系统允许输出进程的core文件
			- 在/etc/sysctl.conf中社会core位置，如: kernel.core_pattern = /data2/coredump/core.%e.%p.%t.%s.%u.%g
			- 在/etc/security/limits.conf中设置gpadmin不限制core文件的大小”gpadmin  -core  unlimited” ，或者在环境变量中设置”ulimit  -c  unlimited”
			3）、打包core文件的工具
			- packcore
			- gpmt
			
			4）、SQL问题重现工具minirepro
			- 收集问题SQL设计表的元数据以及统计信息，方便在其他环境上分析和重现问题
			- 参考社区文章<Greenplum SQL问题重现利器Minirepro> https://mp.weixin.qq.com/s/a505azzg7QduqIhI-kPmBA
			
			
	5.3 Interconnect  encountered a network error
	
		1、Interconnect  encountered a network error 是一种发生在SQL执行过程中的实例之间通讯的报错
		2、从某个实例另一个实例的通讯链路上的阻塞，跟普通的网络丢包无关
		3、几类遇到过的问题
			-- 交换机
			-- 某些特殊的端口不可用，但在主机上看不到端口侦听
			-- 一些复杂的SQL或者写法待优化的SQL，导致服务器负荷过高
		4、应对方法
			-- 提前做好网络压力测试，提前发现问题，建议使用能够测试UDP的工具，如：iperf3,netperf
			-- 通过net.ipv4.ip_local_reserved_ports跳过某些特殊端口，通过net.ipv4.ip_local_port_range限制端口范围
			-- 优化SQL