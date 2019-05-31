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
