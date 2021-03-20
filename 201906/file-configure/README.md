# 主要介绍一下安装greenplum时的/etc/sysctl.conf配置选项及含义

# sysctl.conf 参数列表

	$ cat /etc/sysctl.conf
	kernel.shmmax = 1800000000000
	kernel.shmmni = 8192
	kernel.shmall = 1800000000000
	kernel.sem = 1000 10240000 400 10240
	kernel.sysrq = 1
	kernel.core_uses_pid = 1
	kernel.msgmnb = 65536
	kernel.msgmax = 65536
	kernel.msgmni = 2048
	net.ipv4.tcp_syncookies = 1
	net.ipv4.ip_forward = 0
	net.ipv4.conf.default.accept_source_route = 0
	net.ipv4.tcp_tw_recycle = 1
	net.ipv4.tcp_max_syn_backlog = 4096
	net.ipv4.conf.all.arp_filter = 1
	net.ipv4.ip_local_port_range = 1025 65535
	net.core.netdev_max_backlog = 10000
	net.core.rmem_max = 2097152
	net.core.wmem_max = 2097152
	vm.overcommit_memory = 2
	vm.swappiness = 1
	kernel.pid_max = 655360


# /etc/sysctl.conf 参数含义详解
| 参数名称 | 设置值 | 参数说明 |
|:----:|:----:|:----:|
| kernel.shmmax | 185757335552 | 表示单个共享内存段的最大值，以字节为单位，此值一般为物理内存的一半，不过大一点也没关系，这里设定的为173G，即"185757335552/1024/1024/1024=173G" |
| kernel.shmmni | 8092 | 表示单个共享内存段的最小值，一般为4kB，即4096bit，也可适当调大，一般为4096的2-3倍 |
| kernel.shmall | 185757335552 | 表示可用共享内存的总量,单位是页,一般此值与kernel.shmmax相等 |
| kernel.sem | 1000 10240000 400 10240 | "该文件用于控制内核信号量,信号量是System VIPC用于进程间通讯的方法。建议设置:250 32000 100 128第一列,表示每个信号集中的最大信号量数目。第二列,表示系统范围内的最大信号量总数目。第三列,表示每个信号发生时的最大系统操作数目。第四列,表示系统范围内的最大信号集总数目。所以,（第一列）*（第四列）=（第二列）" |
| kernel.sysrq | 1 | 内核系统请求调试功能控制,0表示禁用,1表示启用 |
| kernel.core_uses_pid | 1 | 这有利于多线程调试,0表示禁用,1表示启用 |
| kernel.msgmnb | 65536 | 该文件指定一个消息队列的最大长度（bytes）。缺省设置：16384 |
| kernel.msgmax | 65536 | 该文件指定了从一个进程发送到另一个进程的消息的最大长度（bytes）。进程间的消息传递是在内核的内存中进行的，不会交换到磁盘上，所以如果增加该值，则将增加操作系统所使用的内存数量。缺省设置：8192 |
| kernel.msgmni | 2048 | 该文件指定消息队列标识的最大数目，即系统范围内最大多少个消息队列。 |
| net.ipv4.tcp_syncookies | 1 | 表示开启SYN Cookies,当SYN等待队列溢出时,启用cookies来处理,可以防范少量的SYN攻击,默认为0,表示关闭。1表示启用 |
| net.ipv4.ip_forward | 0 | 该文件表示是否打开IP转发。0:禁止 1:转发 缺省设置:0 |
| net.ipv4.conf.default.accept_source_route | 0 | 是否允许源地址经过路由。0:禁止 1:打开 缺省设置:0 |
| net.ipv4.tcp_tw_recycle | 1 | 减少time_wait的时间，允许将TIME_WAIT sockets快速回收以便利用。0表示禁用,1表示启用 |
| net.ipv4.tcp_max_syn_backlog | 4096 | 增加TCP SYN队列长度，使系统可以处理更多的并发连接。一般为4096，可以调大，必须是4096的倍数，建议是2-3倍 |
| net.core.somaxconn | 16384 | net.core.somaxconn是Linux中的一个kernel参数，表示socket监听（listen）的backlog上限，按照机器的性能参数可以配置为:16384,128或1000都可以 |
| net.ipv4.conf.all.arp_filter | 1 | 表示控制具体应该由哪块网卡来回应arp包,缺省设置0, 建议设置为1 |
| net.ipv4.ip_local_port_range | 40000 65535 | 禁用 numa, 或者在vmlinux中禁止，指定端口范围的一个配置,默认是32768 61000，可调整为1025 65535或40000 65535 |
| net.core.netdev_max_backlog | 10000 | 进入包的最大设备队列.默认是1000,对重负载服务器而言,该值太低,可调整到16384/32768/65535 |
| net.core.rmem_max | 2097152 | 最大socket读buffer,可参考的优化值:1746400/3492800/6985600 |
| net.core.wmem_max | 2097152 | 最大socket写buffer,可参考的优化值:1746400/3492800/6985600 |
| vm.overcommit_memory | 2 | Linux下overcommit有三种策略，0:启发式策略，1:任何overcommit都会被接受。2:当系统分配的内存超过swap+N%*物理RAM(N%由vm.overcommit_ratio决定)时，会拒绝commit，一般设置为2 |
| vm.swappiness | 1 | 当物理内存超过设置的值是开始使用swap的内存空间,计算公式是100-1=99%表示物理内存使用到99%时开始交换分区使用 |
| kernel.pid_max | 655360 | 用户打开最大进程数,全局配置的参数 |
| fs.nr_open | 20480000 | 本地自动分配的TCP, UDP端口号范围 |
| vm.zone_reclaim_mode | 0/1/2/4 | "echo 0 > /proc/sys/vm/zone_reclaim_mode：意味着关闭zone_reclaim模式，可以从其他zone或NUMA节点回收内存。echo 1 > /proc/sys/vm/zone_reclaim_mode：表示打开zone_reclaim模式，这样内存回收只会发生在本地节点内。echo 2 > /proc/sys/vm/zone_reclaim_mode：在本地回收内存时，可以将cache中的脏数据写回硬盘，以回收内存。echo 4 > /proc/sys/vm/zone_reclaim_mode：可以用swap方式回收内存。" |
| vm.mmap_min_addr | 65536 | "pdflush（或其他）后台刷脏页进程的唤醒间隔，100表示1秒。" |
| vm.overcommit_memory | 0 | |
| vm.dirty_expire_centisecs | 3000 | 系统脏页到达这个值，系统后台刷脏页调度进程 pdflush（或其他） 自动将(dirty_expire_centisecs/100）秒前的脏页刷到磁盘 |
| vm.dirty_ratio | 95 | 比这个值老的脏页，将被刷到磁盘。3000表示30秒。 |
| vm.dirty_writeback_centisecs | 100 | 有效防止用户进程刷脏页，在单机多实例，并且使用CGROUP限制单实例IOPS的情况下非常有效。 |

