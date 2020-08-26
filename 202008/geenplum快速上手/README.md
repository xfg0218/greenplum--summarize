# Greenplum快速上手
	目录
	1 Greenplum的介绍
		1.1 Greenplum产品发展历程
	2 Greenplum市场地位
	3 Greenplum架构设计
		3.1 Scale up架构
		3.2 Greenplum架构图
		3.3 Greenplum架构组成
			3.3.1 Master Hosts功能
			3.3.2 Interconnect功能
			3.3.3 Segment Hosts功能
		3.4 Greenplum DB真正完全无共享的MPP数据库
	4 Greenplum机器选型
		4.1 机器选型一般的配置
	5 Greenplum安装部署
		5.1 系统准备-储存
		5.2 容量估算
		5.3 禁用SELinux and Firewall
		5.4 时钟设置
		5.5 修改系统资源限制
		5.6 磁盘I/O 及其他参数
		5.7 创建用户
		5.8  Greenplum软件安装
		5.9 Greenplum 软件安装(简历互信和目录)
		5.10 Greenplum 软件安装(校验性能)
		5.11 Greenplum 数据库初始化
		5.12 配置standby
		5.13 Master Failover和Restoration
		5.14 配置Segment实例镜像
		5.15 配置环境变量
	6 Greenplum使用技巧
		6.1 性能测试参考值
		6.2 日志输出与查看
		6.3 程序调试监控工具安装
		6.4 常见问题
			6.4.1、切换环境变量
			6.4.2、RH 6 / Cents 6 防火墙禁掉后服务器重启后又Active
			6.4.3、磁盘读写性能

# 1 Greenplum的介绍
## 1.1 Greenplum产品发展历程

	1、Greenplum公司成立于2003年，产品基于开源的PostgreSQL数据库开发，2006年推出了首款产品。
	2、2013年Pivotal公司成立后，Greenplum研发团队并入到Pivotal研发中心，目前Greenplum全球内核研发人员一百多人，遍布美国硅谷，北京，上海以及欧洲，以及PostgreSQL数据库社区的核心开发人员。
	3、Greenplum研发团队将敏捷软件开发方法学引到分布式数据库的开发中，通过使用站立会议，回顾会议，结对编程，持续集成，测试驱动，单周迭代等敏捷方法建立了高效的快速反馈系统，例如:目前可以实现2个月左右时间高质量合并PostgreSQL内核一个大版本近2000多个commits


# 2 Greenplum市场地位

	1、经典数据分析领域排名第三
	Greenplum在经典数据分析领域排名第三，仅次于Teradata和Oracle，逻辑数据分析领域排名第四
	
	2、实时数据分析领域排名第四
	随着换联网，工业互联网等流行数据分析需求的兴起，实时数据分析能力越来越受重视，Greenplum凭借卓越的性能，在此领域排名和Oracle Exadata并列第四
	
	3、前十唯一开源
	Greenplum是全球十大经典和实时数据分析产品中唯一的开源数据库，这就意味着如果选择开源，前十名中别无选择，仅此一家。
	
	4、一直被模仿，从来未超越
	Greenplum是首个商业开源MPP数据库，据中国信通院研究院数据，参与信通院评测的14款数据库43%都是基于Greenplum的。
	
# 3 Greenplum架构设计
## 3.1 Scale up架构
## 3.2 Greenplum架构图
## 3.3 Greenplum架构组成

### 3.3.1 Master Hosts功能
	1、系统入口点
	2、数据库监听器进程
	3、处理所有用户连接
	4、创建查询计划
	5、系统管理工具
	6、不包含用户数据

### 3.3.2 Interconnect功能
	1、Greenplum数据库连接层
	2、元组重新清洗和运输
	3、1GB/10GB/20GB网络基础建施
	4、私有LAN配置

### 3.3.3 Segment Hosts功能
	1、每个主机包括用户数据的一部分
	2、每个都有自己的CPU，磁盘和内存(Shared   Nothing)
	3、用户无法直接访问
	4、所有客户端链接都通过Master进入
	5、数据库侦听进程侦听来自于主服务器的链接

## 3.4 Greenplum DB真正完全无共享的MPP数据库

	1、真正的完全无共享的并行处理架构支持工业标准X86服务器
	2、数据跨越所有节点均匀分布，所有节点以并行方式工作，支持PB级以上的海量储存处理。
	3、每个Rack(16节点)每小时16TB加载性能
	4、集群以搭积木方式横向扩展，目前国内客户单一集群200个节点左右。
	
# 4 Greenplum机器选型
## 4.1 机器选型一般的配置
	型号	产品类型	数量	主要配置要求
	1	计算节点PC服务器	X台	外形	2U高机架服务器
				处理器	2颗CPU，每颗12核（启用超线程每颗24核）、主频不低于2.5G，L3缓存不低于20MB，支持DDR4-1866或以上标准内存。注:购买时服务器主流配置即可。
				内存	256GB RDIMM DDR4-1866或以上标准内存
				硬盘	24块1.2TB，10K PRS,2.5，热插拔SAS硬盘
				RAID卡	1块AID卡，不低于双通道，每通道性能不低于6Gb/s,缓存不低于1GB，支持RAID10或RAID5，支持回写和预读模式，支持电容级掉电保护。注:Raid卡型号建议Megcli OEM
				网络接口	2块非板载，同生产厂商(Intel或博科优先)，同型号万兆网卡，每块包含2个万兆光纤以太网接口，与所配万兆光纤交换机完全兼容
				兼容性	支持RedHat/CentOS 7以上版本
				服务	上架安装服务，3年7*24*4小时生产厂商免费带备件上门推荐服务。3年硬盘保留服务。
	2	万兆光纤交换机	2台	网络接口	不低于28个万兆以太网光纤接口并满配置SFP+模块，与
	所配PC服务器完全兼容。
				服务	上门安装服务，3年7*24*4小时生产厂商免费带备件上门担保服务
	3	千兆交换机	1台	网络接口	不低于48个千兆以太网RJ45接口
				服务	上门安装服务，3年7*24*4小时生产厂商免费带备件上门担保服务
	
	
	磁盘配置注意事项
	1、留出2块为Hot Spare盘
	2、剩下22块盘分为两组并做Raid 5
	3、每个RAID组的条带大小都为256K，写cache策略为’FORCE WRITE BACK’，读磁盘策略设置为’READ AHEAD’。
	
	网络配置注意事项
	1、网卡配置建议采用双网卡绑定模式，采用Mode4，支持802.3ad协议，实现动态链路聚合，Active-Active方式，同时需要交换机的链路聚合LACP方式配合支持。
	2、千兆交换机仅用于管理。
	3、万兆交换机用于集群内部节点通信。
	
	
# 5 Greenplum安装部署
## 5.1 系统准备-储存
	1、GP仅支持XFS文件系统
	2、如果共享储存使用块设备储存提供给运行Greenplum数据库的服务器享，并且挂载到XFS问价系统，则网络或共享储存支持Greenplum数据库，不支持网络伟岸系统(NFS)
	3、Greenplum数据库不直接支持共享储存的其他功能(如重复数据消除或复制)，但只要不干预Greenplum数据库的预期操作，就可以在储存供应商的纸下使用这些功能。
	4、Greenplum数据库可以部署在虚拟化系统中，前提使用块设备储存，并且可以挂载为XFS文件系统。
	
	警告:在超融合(HCI)上运行Greenplum数据库存在性能，可伸缩和稳定性发蔫的已知问题，不建议将其作为挂件Greenplum数据库的可伸缩解决方案。
	
## 5.2 容量估算
	计算可用磁盘容量
	1、磁盘容量:disk_size * number_of_disks
	2、计算Raid 后及格式化后容量:(raw_capacity * 0.9 ) * number_of_actual_disks
	3、性能最佳容量:formatted_disk_space * 0.7
	4、配置Mirror及临时空间可用容量:( 2 *U ) + U/3 = usable_disk_space
	5、压缩比:3:1
	
	计算用户数据大小
	1、Page Overhead
	2、Row Overhead
	3、Attribute Overhead
	4、Indexes
	
	
	计算元数据和日志大小
	1、System Metadata
	2、Write Ahead Log ( 2 * cheakpoint_segment + 1 )
	3、Database Log Files
	4、Command Center Data

## 5.3 禁用SELinux and Firewall
	1、禁用SELinux
	/etc/selinux/config  file(As root)
	SELINUX=disabled
	
	2、禁用防火墙
	/sbin/chkconfig iptables  off
	
	3、Disable firewalld
	systemctl  stop  firewalld.service
	systemctl  disable firewalld.service
	
## 5.4 时钟设置
	1、配置NTP
	on the master host:
	server xx.xx.xx.xx
	
	On each segment host:
	server mdw prefer
	server smdw
	
	On the standby master host:
	server mdw prefer
	server xx.xx.xx.xx

	2、验证NTP
	gpssh -f hostfile_gpssh_allhosts  -v -e ‘ntpd’

## 5.5 修改系统资源限制
	1、修改/etc/security/limits.conf
	* soft nofile 1048576
	* hard nofile 1048576
	* soft nproc 1048576
	* hard nproc 1048576
	
	2、修改/etc/security/limits.d/90-nproc.conf file(RHEL/CentOS 6)
		/etc/security/limits.d/20-nproc.conf file(RHEL/CentOS 7)
	
	* soft nproc 1048576
	* hard nproc 1048576
	* soft nofile 1048576
	* hard nofile 1048576

## 5.6 磁盘I/O 及其他参数
	1、挂载XFS文件系统
	rw,nodev,noatime,nobarrier,inode64
	
	2、设置read-ahead
	/sbin/blockdev   --setra  16384 devname
	
	3、设置I/O调度策略
	echo  deadline > /sys/block/devname/queue/scheduler
	grubby --update-kernel = ALL --args=”elevator=deadline”
	
	4、禁用Transparent Huge Pages(THP)
	grubby --update-kernel =ALL --args = “transparent_hugepage=never”
	
	5、设置RemoveIPC
	/etc/systemd/logind.conf
	RemoveIPC=no
	
	6、设置SSH链接阈值
	Max Startups 10000:30:20000

## 5.7 创建用户
	1、创建组
	groupadd -g 599 gpadmin
	
	2、创建用户
	useradd -g gpadmin -u 600 gpadmin
	echo ‘password’ |passwd - gpadmin --stdin
	
## 5.8  Greenplum软件安装
	1、商业版
	https://network.pivotal.io/products/pivotal-gpdb
	
	2、开源版
	https://github.com/greenplum-db/gpdb
	https://github.com/greenplum-db/gpdb/blob/master/README.linux.md
	
## 5.9 Greenplum 软件安装(简历互信和目录)
	1、确认GP软件安装成功并使用gpadmin用户登录
	source /usr/local/greenplum-db/greenplum_path.sh
	
	2、确认所有服务器/etc/hosts包含割主机名，并创建一个包含所有主机名的文件all_hosts
	
	3、使用gpssh-exkeys工具建立互信
	gpssh-exkeys -f all_hosts
	
	4、使用gpssh工具登录无输入密码提示
	gpssh -f all_hosts -e ‘-ls $GPHOME’
	
	5、在master&standby master 创建数据目录
	mkdir /data/master
	chown gpadmin /data/master
	
	6、在所有segment主机创建数据目录
	gpssh -f all_segs  -e ‘mkdir /data/primary’
	gpssh -f all_segs  -e ‘mkdir /data/mirror’
	gpssh -f all_segs  -e ‘chown /data/primary’
	gpssh -f all_segs  -e ‘chown /data/primary’
	

## 5.10 Greenplum 软件安装(校验性能)
	1、检验Disk I/O性能和内存宽带
	gpcheckperf  -f  hostfile_gpcheckperf  -r ds  -D -d /data/promary -d /data/mirror
	
	2、检验网络性能
	gpcheckperf  -f hostfile_gpchecknet_ic  -r N -d /tmp > subnet.out
	gpcheckperf  -f hostfile_gpchecknet_ic  -r M --duration=3m -d /tmp > checknet.m.log
	
## 5.11 Greenplum 数据库初始化
	1、创建数据库初始化文件
	cp  $GPHOME/docs/cli_help/gpconfigs/gpinitsystem_config  ~ /gpconfigs/gpinitsystem_config
	
	然后编辑~ /gpconfigs/gpinitsystem_config
	
	2、运行初始化命令
	gpinitsystem  -c  gpconfigs/gpinitsystem_config -h gpconfigs/hostfile_gpinitsystem
	或者
	gpinitsystem  -c gpconfigs/gpinitsystem_config -h gpconfigs/hostfile_gpinitsystem -s standby_master_hostname
	
## 5.12 配置standby

## 5.13 Master Failover和Restoration

## 5.14 配置Segment实例镜像

	1、镜像是主实例的副本，用于高可用。
	2、初始化数据库时可以启用
	3、可使用gpaddmirrors -i config_file(gpaddmirrors  -o)
	4、镜像分布策略分为group和spread
	
## 5.15 配置环境变量
	1、Master数据目录
	MASTER_DATA_DIRECTORY=/data/master/gpseg-1
	
	2、GP基础目录
	GPHOME=/usr/local/greenplum-db
	
	3、默认登录数据库名
	PGDATABASE=edw
	
	4、默认登录端口
	PGPORT=5432
	
	5、GP环境变量
	source the /usr/local/greenplum-db/greenplum_path.sh
	
# 6 Greenplum使用技巧
## 6.1 性能测试参考值
	
	IO读的性能3561.67MB/s
	IO写的性能2808.42MB/s
	网络接受发送2237.13 Tx
	
## 6.2 日志输出与查看
	1、-D  --debug或-v  --verbose 详细日志输出
	2、GP命令中利用print函数打印变量值
	3、$MASTER_DATA_DIRECTORY/pg_log/startup.log
	4、$MASTER_DATA_DIRECTORY/pg_log/*.csv

## 6.3 程序调试监控工具安装
	常用查看工具
	strace
	pstat
	gcore
	gdb
	nmon
	netperf
	netserver
	
	
	GP提供的命令
	packcore
	gpmt
	
	GPCC
	gpcc
	

## 6.4 常见问题

	1、切换环境变量
	su - 
	
	2、RH 6 / Cents 6 防火墙禁掉后服务器重启后又Active
	
	chkconfig  libvirtd  off
	
	3、磁盘读写性能
	vm.dirty_background_bytes = 1610612736 # 1.5GB
	vm.dirty_bytes = 4294967296 # 4GB
	