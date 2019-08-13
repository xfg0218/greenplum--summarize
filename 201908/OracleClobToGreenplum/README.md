# OracleClobToGreenplum 项目介绍
	此Java项目主要介绍把Oracle数据库中的clob字段同步到Greenplum中,作者测试的效率大概为:5000条/13s,详细的过程请查看下文分析

# OracleClobToGreenplum
	
	lib 主要存放以下依赖的jar,包含oracle与postgres的jdbc驱动
	
	src
		connectionUtils.properties : 配置文件信息,其中oraclesql取三个字段,最后一个字段的类型为clob
		                             gpsql是gp的一个临时表，包含三个字段,第三个字段为text类型保存oracle的clob类型
                			     batchsize : 按照自己的大小设置该值

		com.chinadaas.OracleToGreenplumMain : 程序启动的主类,在导出可运行JAR包是选择此类
		com.chinadaas.connection : 主要有链接Oracle与Greenplum的JDBC信息
		com.chinadaas.loaddata : 主要处理数据批量加载到Greenplum的逻辑
		com.chinadaas.utils : 此类下一个是读取配置文件的信息,一个主要是处理Oracle字段中的ascii值以及'的符号，'符号会影响SQL的拼接，导致插入数据错误
		
# 同步的效率统计
	查看Oracle中的数据量以clob字段的最大长度:
		select count(*) from xiaoxu_test;
		-- 524,0487
		select max(length(anntext)) from xiaoxu_test;
		-- 498981
	
	查看同步的效率及稳定性
		insert count:5000耗时  13s
		insert count:10000耗时  18s
		insert count:15000耗时  24s
		insert count:20000耗时  48s
		insert count:25000耗时  65s
		insert count:30000耗时  75s
		insert count:35000耗时  87s
		************
		insert count:5210000耗时  27335s
		insert count:5215000耗时  27365s
		insert count:5220000耗时  27394s
		insert count:5225000耗时  27421s
		insert count:5230000耗时  27451s
		insert count:5235000耗时  27479s
		insert count:5240000耗时  27504s
		insert count:5240489已全部入库完毕,耗时:27544s


	在以上可以看出同步了5240489行数据大概用时27544s,大概 5240489/27544s ≈ 190行/s 具体的要按照个人的clob的长度而定

