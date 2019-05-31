# 目录
	概述
	1、greenplum  gpcheckperf  命令参数说明
	2、gpcheckperf  参数详解
	3 gpcheckperf 测试脚本
	4、gpcheckperf  测试结果
	5、查看产生的文件
	6、测试结果分析

# gpcheckperf 测试概述
	1、在以下测试时要在集群空闲的时间进行，测试的过程中会占用大量的资源
	2、需要准备大约250G大小的空间磁盘，在测试过程中会生成文件 
	3、测试过程中在DISK WRITE TEST，DISK READ TEST这两个阶段比较耗时
	4、测试完了会把gpcheckperf_$USER目录删掉

# 1、greenplum  gpcheckperf  命令参数说明
	以下列出了gpcheckperf  常用的一些参数

	gpcheckperf -d test_directory [-d test_directory ...]
	{-f hostfile_gpcheckperf | - h hostname [-h hostname ...]}
	[-r ds] [-B block_size] [-S file_size] [-D] [-v|-V]

	gpcheckperf -d temp_directory
	{-f hostfile_gpchecknet | - h hostname [-h hostname ...]}
	[ -r n|N|M [--duration time] [--netperf] ] [-D] [-v | -V]

	gpcheckperf -?

	gpcheckperf --version

# 2、gpcheckperf  参数详解
	-B block_size
 
	指定用于磁盘I/O测试的块大小（以KB或MB为单位）。缺省值是32KB，与Greenplum数据库页面大小相同。最大块大小是1 MB。
 
	-d test_directory
 
	对于磁盘I/O测试，指定要测试的文件系统目录位置。用户必须具有对性能测试中涉及的所有主机上测试目录的写入权限。用户可以多次使用-d选项指定多个测试目录（例如，测试主数据目录和镜像数据目录的磁盘I/O）。
 
	-d temp_directory
 
	对于网络和流测试，指定单个目录，测试程序文件在测试期间将被复制到该目录。用户必须具有对测试中涉及的所有主机上该目录的写入权限。
 
	-D （显示每台主机的结果）
 
	报告每个主机的磁盘I/O测试的性能结果。缺省情况下，仅报告具有最低和最高性能的主机的结果，以及所有主机的总体和平均性能。
 
	--duration time
 
	以秒（s）、分钟（m）、小时（h）或天数（d）指定网络测试的持续时间。默认值是15秒。
 
	-f hostfile_gpcheckperf
 
	对于磁盘I/O和流测试，请指定一个包含将参与性能测试的主机名的文件名称。主机名是必需的，用户可以选择指定每个主机的后补用户名和/或SSH端口号。主机文件的语法是每行一台主机，如下所示：
 
	[username@]hostname[:ssh_port]
	-f hostfile_gpchecknet
 
	对于网络性能测试，主机文件中的所有项都必须是同一子网内的主机地址。如果用户的Segment主机在不同子网上配置有多个网络接口，请为每个子网运行一次网络测试。例如（包含互连子网1的Segment主机地址名的主机文件）：
 
	sdw1-1
	sdw2-1
	sdw3-1
 
	-h hostname
 
	指定将参与性能测试的单个主机名（或主机地址）。用户可以多次使用-h选项来指定多个主机名。
 
	--netperf
 
	指定应该用netperf二进制文件来执行网络测试，而不是Greenplum网络测试。要使用此选项，用户必须从http://www.netperf.org下载netperf并且安装到所有Greenplum主机（Master和Segment）的$GPHOME/bin/lib目录中。
 
	-r ds{n|N|M}
 
	指定要运行的性能测试，默认是 dsn：
 
	磁盘I/O测试（d）
	流测试（s）
	网络性能测试，串行（n）、并行（N）或全矩阵（M）模式。可选的--duration 选项指定了运行网络测试的时间（以秒为单位）。要使用并行（N）模式，用户必须在偶数台主机上运行测试。
	如果用户宁愿使用netperf（http://www.netperf.org）而不是Greenplum网络测试，用户必须下载它并安装到所有Greenplum主机（Master和Segment）的$GPHOME/bin/lib目录中。然后，用户可以指定可选的--netperf选项来使用netperf二进制文件而不是默认的gpnetbench*工具。
 
	-S file_size
 
	指定用于-d所指定的所有目录的磁盘I/O测试的总文件尺寸。file_size应该等于主机上总RAM的两倍。如果未指定，则默认值是在执行gpcheckperf的主机上的总RAM的两倍，这确保了测试是真正地测试磁盘I/O而不是使用内存缓存。用户可以以KB、MB或GB为单位指定尺寸。
 
	-v （详细模式）| -V （非常详细模式）
 
	详细（Verbose）模式显示性能测试运行时的进度和状态信息。非常详细（Very Verbose）模式显示该工具生成的所有输出消息。
 
	--version
 
	显示该工具的版本
	 
	-? （帮助）
 
	显示在线帮助
# 3 gpcheckperf 测试脚本
	在以下脚本中可以看出列出了测试开始时间与结束时间，测试的机器是gpsdw1，gpsdw2，gpsdw3，测试存放临时目录为/greenplum/soft/，每个节点大概需要空间250G左右，请做好空间的准备
	$ cat seg_host 
	gpsdw1
	gpsdw2
	gpsdw3
	
	
	$ cat  gpcheckperf-test.sh 
	#!bin/bash
 
	echo "--------- start ----------- "
	a=`date +"%Y-%m-%d %H:%M:%S"`
	echo $a
 
	gpcheckperf -f seg_host -d /greenplum/soft/ -v
 
	echo "------------- end ----------"
	b=`date +"%Y-%m-%d %H:%M:%S"`
	echo $b


# 4、 gpcheckperf  测试结果
	--------- start -----------
	2019-05-31 01:13:25
	[Info] sh -c 'cat /proc/meminfo | grep MemTotal'
	MemTotal:       131782212 kB
	 
	/greenplum/soft/greenplum-db/./bin/gpcheckperf -f seg_host -d /greenplum/soft/ -v
	--------------------
	  SETUP
	--------------------
	[Info] verify python interpreter exists
	[Info] /greenplum/soft/greenplum-db/./bin/gpssh -f seg_host 'python -c print'
	[Info] making gpcheckperf directory on all hosts ...
	[Info] /greenplum/soft/greenplum-db/./bin/gpssh -f seg_host 'rm -rf  /greenplum/soft/gpcheckperf_$USER ; mkdir -p  /greenplum/soft/gpcheckperf_$USER'
	[Info] copy local /greenplum/soft/greenplum-db-5.11.1/bin/lib/multidd to remote /greenplum/soft/gpcheckperf_$USER/multidd
	[Info] /greenplum/soft/greenplum-db/./bin/gpscp -f seg_host /greenplum/soft/greenplum-db-5.11.1/bin/lib/multidd =:/greenplum/soft/gpcheckperf_$USER/multidd
	[Info] /greenplum/soft/greenplum-db/./bin/gpssh -f seg_host 'chmod a+rx /greenplum/soft/gpcheckperf_$USER/multidd'
	 
	--------------------
	--  DISK WRITE TEST
	--------------------
	 
	--------------------
	--  DISK READ TEST
	--------------------
	 
	--------------------
	--  STREAM TEST
	--------------------
	[Info] copy local /greenplum/soft/greenplum-db-5.11.1/bin/lib/stream to remote /greenplum/soft/gpcheckperf_$USER/stream
	[Info] /greenplum/soft/greenplum-db/./bin/gpscp -f seg_host /greenplum/soft/greenplum-db-5.11.1/bin/lib/stream =:/greenplum/soft/gpcheckperf_$USER/stream
	[Info] /greenplum/soft/greenplum-db/./bin/gpssh -f seg_host 'chmod a+rx /greenplum/soft/gpcheckperf_$USER/stream'
	[Info] /greenplum/soft/greenplum-db/./bin/gpssh -f seg_host /greenplum/soft/gpcheckperf_$USER/stream
	 
	-------------------
	--  NETPERF TEST
	-------------------
	[Info] copy local /greenplum/soft/greenplum-db-5.11.1/bin/lib/gpnetbenchServer to remote /greenplum/soft/gpcheckperf_$USER/gpnetbenchServer
	[Info] /greenplum/soft/greenplum-db/./bin/gpscp -f seg_host /greenplum/soft/greenplum-db-5.11.1/bin/lib/gpnetbenchServer =:/greenplum/soft/gpcheckperf_$USER/gpnetbenchServer
	[Info] /greenplum/soft/greenplum-db/./bin/gpssh -f seg_host 'chmod a+rx /greenplum/soft/gpcheckperf_$USER/gpnetbenchServer'
	[Info] /greenplum/soft/greenplum-db/./bin/gpssh -f seg_host 'F=gpnetbenchServer && (pkill $F || pkill -f $F || killall -9 $F) > /dev/null 2>&1 || true'
	[Info] /greenplum/soft/greenplum-db/./bin/gpssh -f seg_host '/greenplum/soft/gpcheckperf_$USER/gpnetbenchServer -p 23000 > /dev/null 2>&1'
	[Info] copy local /greenplum/soft/greenplum-db-5.11.1/bin/lib/gpnetbenchClient to remote /greenplum/soft/gpcheckperf_$USER/gpnetbenchClient
	[Info] /greenplum/soft/greenplum-db/./bin/gpscp -f seg_host /greenplum/soft/greenplum-db-5.11.1/bin/lib/gpnetbenchClient =:/greenplum/soft/gpcheckperf_$USER/gpnetbenchClient
	[Info] /greenplum/soft/greenplum-db/./bin/gpssh -f seg_host 'chmod a+rx /greenplum/soft/gpcheckperf_$USER/gpnetbenchClient'
	[Info] ssh -o 'BatchMode yes' -o 'StrictHostKeyChecking no' gpsdw1 '/greenplum/soft/gpcheckperf_$USER/gpnetbenchClient -H gpsdw2 -p 23000 -t TCP_STREAM -l 15 -f M -P 0 '
	[Info] ssh -o 'BatchMode yes' -o 'StrictHostKeyChecking no' gpsdw3 '/greenplum/soft/gpcheckperf_$USER/gpnetbenchClient -H gpsdw1 -p 23000 -t TCP_STREAM -l 15 -f M -P 0 '
	[Info] Connected to server
	0     0        32768       14.24     1075.19
	 
	[Info] gpsdw1 -> gpsdw2 : ['0', '0', '32768', '14.24', '1075.19']
	[Info] Connected to server
	0     0        32768       14.26     1047.93
	 
	[Info] gpsdw3 -> gpsdw1 : ['0', '0', '32768', '14.26', '1047.93']
	[Info] ssh -o 'BatchMode yes' -o 'StrictHostKeyChecking no' gpsdw2 '/greenplum/soft/gpcheckperf_$USER/gpnetbenchClient -H gpsdw1 -p 23000 -t TCP_STREAM -l 15 -f M -P 0 '
	[Info] ssh -o 'BatchMode yes' -o 'StrictHostKeyChecking no' gpsdw1 '/greenplum/soft/gpcheckperf_$USER/gpnetbenchClient -H gpsdw3 -p 23000 -t TCP_STREAM -l 15 -f M -P 0 '
	[Info] Connected to server
	0     0        32768       14.97     999.18
	 
	[Info] gpsdw2 -> gpsdw1 : ['0', '0', '32768', '14.97', '999.18']
	[Info] Connected to server
	0     0        32768       14.86     1113.28
	 
	[Info] gpsdw1 -> gpsdw3 : ['0', '0', '32768', '14.86', '1113.28']
	--------------------
	  TEARDOWN
	--------------------
	[Info] /greenplum/soft/greenplum-db/./bin/gpssh -f seg_host 'rm -rf  /greenplum/soft/gpcheckperf_$USER'
	[Info] /greenplum/soft/greenplum-db/./bin/gpssh -f seg_host 'F=gpnetbenchServer && (pkill $F || pkill -f $F || killall -9 $F) > /dev/null 2>&1 || true'
	 
	====================
	==  RESULT
	====================
	 
	 disk write avg time (sec): 780.88
	 disk write tot bytes: 809669885952
	 disk write tot bandwidth (MB/s): 988.89
	 disk write min bandwidth (MB/s): 326.89 [gpsdw2]
	 disk write max bandwidth (MB/s): 332.78 [gpsdw1]
	 disk read avg time (sec): 499.80
	 disk read tot bytes: 809669885952
	 disk read tot bandwidth (MB/s): 1545.86
	 disk read min bandwidth (MB/s): 500.90 [gpsdw1]
	 disk read max bandwidth (MB/s): 531.78 [gpsdw3]
	 stream tot bandwidth (MB/s): 36280.66
	 stream min bandwidth (MB/s): 8890.95 [gpsdw2]
	 stream max bandwidth (MB/s): 18413.74 [gpsdw3]
	Netperf bisection bandwidth test
	gpsdw1 -> gpsdw2 = 1075.190000
	gpsdw3 -> gpsdw1 = 1047.930000
	gpsdw2 -> gpsdw1 = 999.180000
	gpsdw1 -> gpsdw3 = 1113.280000
	 
	Summary:
	sum = 4235.58 MB/sec
	min = 999.18 MB/sec
	max = 1113.28 MB/sec
	avg = 1058.89 MB/sec
	median = 1075.19 MB/sec
	 
	[Warning] connection between gpsdw2 and gpsdw1 is no good
	------------- end ----------
	2019-05-31 01:36:57
	--------------------- 

# 5、查看产生的文件
	
	$ ll -h
	total 245G
	-rw-rw-r-- 1 gpadmin gpadmin 245G May 21 13:07 ddfile
	-rwxr-xr-x 1 gpadmin gpadmin 3.8K May 21 13:03 multidd
	 
	 
	在以上可以看出生成了252GB的空文件ddfile，multidd只是greenplum测试的脚本
	
# 6、测试结果分析
	1、在以上的时间可以看出整个的测试大概用23分钟左右
	 
	2、在以上可以看出磁盘的写的速度总共是988.89MB/s，其中最小的是在gpsdw2机器上是326.89MB/s，最大的是在gpsdw1机器上是332.78MB/s
	 
	3、在以上可以看出磁盘的读的速度总共是1545.86MB/s，其中最小的是在gpsdw1机器上是500.90MB/s，最大的是在gpsdw3机器上是531.78MB/s
	 
	4、在以上可以看出网卡速度总共是36280.66MB/s，其中最小的是在gpsdw2机器上是8890.95MB/s，最大的是在gpsdw3机器上是18413.74MB/s
	 
	5、测试的机器的方向是:
	    gpsdw1 -> gpsdw2 = 1075.190000
	    gpsdw3 -> gpsdw1 = 1047.930000
	    gpsdw2 -> gpsdw1 = 999.180000
	    gpsdw1 -> gpsdw3 = 1113.280000
	 
	6、统计记过如下:
	    sum = 4235.58 MB/sec
	    min = 999.18 MB/sec
	    max = 1113.28 MB/sec
	    avg = 1058.89 MB/sec
	    median = 1075.19 MB/sec
	 
	7、在测试时出现了一个警告connection between gpsdw2 and gpsdw1 is no good，说明gpsdw2 和gpsdw1之间的链接不是很好，这项需要检查
	 
	8、等测试完程序会自动的把数据和gpcheckperf_$USER目录删掉
