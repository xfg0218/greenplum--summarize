# Greenplum 常见错误及解答方式

##  连接超时
``` 
问题描述:ERROR "failed to acquire resources on one or more segments", "could not connect to server: Connection timed out"
原因分析: 
	(1) 查看网络连接情况
	(2) 查看TCP/UDP连接情况
解答方式: sudo sysctl net.netfilter.nf_conntrack_buckets=262144
		sudo sysctl net.netfilter.nf_conntrack_max=1048576
```

## VMEM使用过高
``` 
问题描述：Canceling query because of high VMEM usage. Used: 6862MB, available 819MB, red rone: 7372MB (runaway_cleaner.c:202) (seg 16 slice1)
原因分析:
	(1) 使用dmesg和syslog命令分析日志情况
	(2) 查看 sysctl -a |grep overcommit 参数
解答方式:
	修改一下参数，修改的大小参考https://greenplum.org/calc/

	gpconfig -c  gp_vmem_protect_limit -m 10240 -v 10240
	gpconfig -c max_statement_mem -v 50MB
	gpconfig -c statement_mem -v 30MB
	gpconfig -c  runaway_detector_activation_percent -m 90 -v 90
```

## 位置的long_description_content_type选项
```
问题描述 unknown distribution option:"long_description_content_type'
原因分析:
	 setuptools 版本比较老
解答方式:
	sudo python3 -m pip install --upgrade setuptools
```

## 内存溢出
```
问题描述: failed to acquire resources on on or more segments ,fatal out of memory 
原因分析:
	(1) 查看配置的primary和mirror
	(2) 查看当前shared_buffer和work_mem参数大小
   （3） 按照任务的进程计算需要的内存和物理内存大小比较，如果进程过多则调小work_mem参数
解答方式:
	(1) 调小work_mem参数
   （2）调整/etc/sysctl.conf或/etc/sysctl.d/99-matrixdb.conf下的以下参数 
		vm.overcommit_memory = 2
		mxgate prepared=10改为prepared=5 
```



