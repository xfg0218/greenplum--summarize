# Greenplum生态与工具
	目录
	第一节 Greenplum 生态介绍
		1、Greenplum 发展历史
		2、商业版与开源版的差异
		3 Greenplum 生态软件
	第二节 Greenplum 运维工具
		1、 商业监控--GPCC
		2、开源监控Prometheus+Grafana
		3、gpxxx 运维工具
	第三节 Greenplum 管理工具
		1、常用的管理工具datagrip
		2、常用的管理工具navicat
		3、常用的管理工具dbeaver
		4、度版本比较
	第四节 Greenplum BI/ETL 工具
		1、 商业BI--Tableau
		2、 商业BI--帆软
		3、开源BI--Superset
		4、可视化选型比较
		5、 商业ETL-HVR
		6、 商业ETL-Informatica
		7、开源ETL-kettle
		8、ETL 选型比较
	第五节 Greenplum 测试工具
		1、tpc.org  下的测试软件
		2、TPC-H/TPC-DS与TPC-C比较
		3、HammerDB 测试
		4、JMeter 测试

# 第一节Greenplum 生态介绍
	1、Greenplum 发展历史
		2005 年
			1、Greenplum 数据库第一个版本发布
			2、基于强大的开源数据库PostgreSQL
		
		
		2015 年
			1、Greenplum 开源，世界上第一款开源MPP数据库
			2、开源版本基于Greenplum4.3
		
		2017 年
			1、Greenplum 5.0发布
			2、PostgreSQL 内核由8.2升级为8.3，升级工作加速
		
		2018年
			1、Greenplum中文社区成立
			2、专心运营Greenplum中国生态，服务广大爱好者
		
		2019年
			1、Greenplum 6.0发布
			2、PostgreSQL 内核由8.3升级为9.4
		
		2021年
			1、预计Greenplum 7.0发布
			2、开源代码已经完成PostgreSQL12 代码合并工作

		开源裂变的原因
		1、语言接口丰富，北向应用厂商积极适配集成
		2、申诉的PG内核合并工作，让GP越来越强大
		3、MADLib  zedstore等贡献，回馈PG
		4、pxf/fdw 等组件，使数据集成更容易
	
	2、商业版与开源版的差异
		商业版包含了开原版本的所有的功能，此外，还包含如下内容
		1、支持QuickLZ压缩
		2、支持如下的data connectors:
			Greenplum-Spark Connector
			Greenplum-Informatica Connector
			Greenplum-Kafka Connector (gpkafka)
			Greenplum Stream Server (gpss)
		
		3、支持Data Direct ODBC/JDBC Drivers
		4、支持gpcopy
		5、支持gpcc
		6、支持gptext
		7、支持原厂服务
		
		商业版下载地址:https://network.pivotal.io/products/pivotal-gpdb
		社区版本下载地址:https://github.com/greenplum-db/gpdb
		

	3 Greenplum 生态软件

		1、Greenplum 生态完善，得益于对SQL标准的出色支持。
		2、基于PostgreSQL ,使其一出生便与众不同
		3、提供几乎所有语言的访问接口，像使用PG一样使用GP
		4、支持数据库内核数据挖掘，支持空间数据引擎
		5、支持多种外部数据集成
		

# 第二节Greenplum 运维工具
	1、商业监控--GPCC
	
		1、GPCC 全程是Greenplum Command Center ，属于企业版Greenplum的配套监控组件，不支持开原版本。
		2、由于Pivotal 开放的态度，大家可以免费下载GPDB和GPCC进行个人测试，出于对商业版权的保护，建议大家再选用企业版时，通过正规途径购买。
		3、GPCC提供数据库状态，机器负载情况，查询运行状态等多种参数的全面监控展示。

	2、开源监控Prometheus+Grafana
		
		1、Prometheus+Grafana 是目前较为主流的监控方案，很多大公司都基于此方案构建整体系统，适配的GPOSS5/6,exporter 地址如下:
		https://github.com/ChrisYuan/greenplum_exporter/tags
		该组件基本配置了一些常用的集群状态监控。
	3、gpxxx 运维工具
		gpactivatestandby 
		作用：用于激活一个备用主节点，使其代替原来的主节点对外提供服务。
		场景：主节点异常宕机
		常用命令：备节点机器上执行gpactivatestandby  -d  $MASTER_DATA_DIRECTORY
		
		gpcheckcat
		作用: 用于检测master和segment的catalog表并提供修复的脚本
		场景:周期性检测catalog 一致性
		常用命令：gpcheckcat [dbname]
		
		gpaddmirrors
		作用: 用于对现有的集群增加镜像节点
		场景：初始化集群不带有镜像，需要手动添加，需要制定灵活的镜像添加方式
		常用命令：输出配置文件 gpaddmirrors -o mirror_config_file 根据自定义镜像配置规则，修改配置文件，初始化镜像 - gpaddmirrors -i mirror_config_file 
		
		
		gpcheckperf 
		作用：用于在GPDB主机集群执行内存/网络/磁盘性能测试
		场景: 基础环境搭建好后，进行一遍性能验证，集群运行出现性能问题时，用该工具检测内存/网络/磁盘性能是否有所下降
		
		
		gpconfig
		作用：用于修改集群配置参数
		场景: 修改配置参数，gpconfig 修改出错集群启动失败，单独修改master配置并启动master节点重新配置集群。常用命令:
		gpconfig  -s xx
		gpconfig  -c xxx -v xx [-m xxx]
		
		
		gpfdist 
		作用：用于并行数据加载
		场景：数据批量钙素入库
		常用命令:  gpfdist -d /var/load_files  -p  8081  & 配合数据库外部表一起使用
		
		
		gpexpand 
		作用: 用于扩展现有集群
		场景: 集群增加机器，集群增加节点
		常用命令: gpexpand -i input_file
		
		
		gpinitstandby
		作用:用于初始化一个备用master
		场景: 集群初始化后未添加standby master, standby master 切换后，重新增加一个standby master
		常用命令：
		gpinitstandby -s host09
		
		
		gpbackup/gprestore
		作用：备份/恢复集群
		场景：数据备份及恢复场景
		详细的请查看:https://github.com/greenplum-db/gpbackup
		
		
		gpinitsystem 
		作用：用于初始化集群
		场景：集群初始化
		常用命令：gpinitsystem  -c gpinitsystem_config -h hostfile_gpinitsystem --mirror-mode=spread 
		
		gprecoverseg
		作用：用于恢复故障节点
		场景：集群拥有mirror，当有p或m宕机，但集群依然可用
		常用命令:gprecoverseg  / gprecoverseg -F
		
		
		gpload 
		作用：用于并行数据加载，是对gpfdist的封装
		场景：替换Oracle sqlloader
		常用命令：gpload  -f  my_load.yml
		
		
		gpssh-exkeys/gpssh/gpscp
		作用：设置免密登录，批量执行命令，批量传输文件
		场景：维护现场，集群初始化
		常用命令：gpssh-exkeys  -f  hostfile_exkeys
		
		
		gpmovemirrors
		作用：用于将mirror移动到新的位置
		场景：优化数据分布和储存
		常用命令：gpmovemirrors -i move_config_file
		
		
		gpstart/gpstop/gpstate
		作用：启动集群/停止，重启，重载集群/查看集群状态
		场景：配置文件修改，访问入口文件修改后使生效
		常用命令：gpstop  -u / gpstart / gpstop / gpstate 
	

# 第三节Greenplum 管理工具
	1、常用的管理工具datagrip
		https://www.jetbrains.com/datagrip/
	
	2、常用的管理工具navicat
		http://www.navicat.com.cn/download/navicat-for-postgresql
	
	3、常用的管理工具dbeaver
		https://dbeaver.io/
	
	4、度版本比较

		1、有条件的公司或者个人，推荐有限使用DataGrip，如果已经使用JetBrains家的其他工具如：IDEA，那么可以直接安装一个数据插件即可。
		2、崇尚开源免费的用户，推荐选用DBeaver，用起来功能也挺全，除了可以连接Greenplum，也可以连接几乎你所知道的所有的数据库，如果不支持，还可以自行扩展所需要的内容。
		3、Nvicat,pgadmin等，只要支持Postgresql，都能连接上，但是存在各种不同情况的不兼容的问题，只适合临时使用。

# 第四节Greenplum BI/ETL 工具
	1、商业BI--Tableau
		1、Tableau 是一款数据分析与可视化工具，他支持连接到各种数据库，不管是电子表格，还是数据库数据，都能进行无缝连接。
		2、支持连接到Greenplum数据库，通过GPDB提高查询分析性能。
		3、优化建议一：尽可能关闭cursor
		4、优化建议二：初始化时设定参数
		
	2、商业BI--帆软
		1、FineBi 是国产商业BI报表软件最好的一家，从各个方面来讲，都推荐大家尝试一下，可以在官网申请使用。
		2、支持连接到Greenplum
		3、可以访问官方论坛获取更多链接信息：
		https://help.finebi.com/doc-view-289.html
		
	3、开源BI--Superset
		1、Superset 是一款可视化工具:使用Python代码编写。
		2、详细信息科源代码可以参考：https://superset.apache.org
		https://github.com/apache/incubator-superset
		3、进入Superset后，可以通过提供的postgresql连接到GPDB，然后将相对应的数据库引入到Superset，再与核实的图进行关联展示。
		
	4、提供Docker一站式方式体验，方便大家体验功能和选型对比。

	
	5、商业ETL-HVR
		1、HVR是一款集中式的数据同步工具，支持多种目标源。
		2、支持GPDB 5/6数据库作为目标端数据库。
		3、支持各种常用关系数据库，文件作为数据源，支持关系型数据库，文件，NoSQL,NewSQL,作为目标端。
		4、支持一对一，一对多，多对一，多对多的数据传输方式，支持自定义ETL逻辑。
		5、数据初始化及入库，均采用相关数据库最高效的方式。
	6、商业ETL-Informatica 
		1、informatica 是一款成熟的ETL工具，在国内商业市场上占用率比较高，易用性稳定都很高。
		2、Greenplum商业版本，提供infomatica  Connector，通过该连接器，可以充分结合informatinca的开发能力和Greenplum的并行处理能力。
		3、针对开原版本，可以尝试采用postgres的odbc进行连接。
	
	7、开源ETL-kettle
		1、Kettle是一款老牌的开源ETL工具，神兽大家的喜爱。
		2、开源版本，提供可视化脚本编写界面，调度可以通过开源软件kettle-scheduler进行
		3、kettle入库GPDB的方式有：insert/copy/gpload

	
# 第五节Greenplum 测试工具

	1、tpc.org  下的测试软件
		1、事务处理性能委员会(Transaction  Processing   Performance  Council) , 是有数10家会员公司创建的非盈利的组织，他的功能是制定商务应用基准程序(Benchmark) 的标准规则，性能和价格度量，并管理测试结果的发布。
		2、目前有10几种相关度量标准。
		3、与关系型数据库相关性比较大的有：
			TPC - H
			TPC - C
			TPC - DS
	
	2、TPC-H/TPC-DS与TPC-C比较
		1、TPC-H 通常用于PLAP测试，在一些客户要求的TPC-H测试长江下，客户通常会对我们提供的测试脚本进行理论验证，保证多个产品的TPC-H测试的一致性，该测试包含22个复杂的查询，目前针对Greenplum的测试，我们通常采用PG社区分享的脚本和逻辑进行测试
			https://github.com/digoal/gp_tpch
			https://developer.aliyun.com/article/93
	
		2、TPC-DS 也是用于OLAP测试的，但是测试逻辑更为复杂，一共99个查询，有很多新兴数据库目前为止还无法满足所有99个查询的语法，目前GPDB上的TPC-DS测试，建议参考：
			https://github.com/pivotalguru/TPC-DS提供的测试脚本
	
		3、TPC-C 通用用于PLTP测试，作为数据库事务处理性能的一个衡量标准，目前GPDB上的TPC-C测试，可以采用开源工具BenchmarkSQL进行：
			https://sourceforge.net/projects/benchmarksql
		
	3、HammerDB 测试
		1、获取地址：
			https://www.hammerdb.com/index.html
		
			https://github.com/TPC-Council/HammerDB
		
		2、执行步骤
			1）、安装hammerdb
			2）、进入控制台
			3）、进行配置
			4）、构建测试库
			5）、加载配置脚本
			6）、构建测试
			7）、运行测试
			
	4、JMeter 测试
		1、获取地址
			https://jmeter.apache.org
		
		
		2、执行步骤
			1）、安装jmeter
			2)、运行jmeter
			3）、新建测试计划
			4）、新建测试线程组
			5）、增加驱动
			6）、新建jdbc链接
			7）、天假jdbc请求
			8）、添加报告
			9）、运行测试