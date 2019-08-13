# OracleClobToGreenplum 项目介绍
	此Java项目主要介绍把Oracle数据库中的clob字段同步到Greenplum中,作者测试的效率大概为:5000条/13s,详细的过程请查看下文分析

# OracleClobToGreenplum
	
	lib 主要存放以下依赖的jar,包含oracle与postgres的jdbc驱动
	
	src
		connectionUtils.properties : 配置文件信息,其中oraclesql取三个字段,最后一个字段的类型为clob
		                             gpsql是gp的一个临时表，包含三个字段,第三个字段为text类型保存oracle的clob类型

