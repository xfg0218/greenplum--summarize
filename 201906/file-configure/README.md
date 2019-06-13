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


# 参数含义详解
	/etc/sysctl.conf [参数详解请查看](https://github.com/xfg0218/greenplum--summarize/blob/master/images/greenplum-images/sysctl-conf.png)
