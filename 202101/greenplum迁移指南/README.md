# Greenplum迁移指南
	目录
	第一节 Greenplum数据迁移方法论
		1.1 为什么要进行数据迁移
		1.2 迁移整体的流程
	第二节Greenplum数据迁移工具
		2.1 迁移工具
		2.2 迁移工具--pra2pg
		2.3 迁移工具--sqluldr2
		2.4 迁移工具--sqldata
	第三节 如何实现自己的数据迁移程序
		3.1 数据迁移全周期功能
	第四节 Oracle到Greenplum的数据迁移
		4.1 为什么要从Oracle迁移到GPDB
		4.2 迁移场景
		4.3 元数据迁移
		4.4 元数据迁移
		4.5 数据迁移
		4.6 数据校验
	第五节 PostgreSQL到Greenplum的数据迁移
		5.1 一种平滑的解决方案
		5.2 元数据迁移
		5.3 数据迁移
		5.4 数据校验
	
	
# 第一节 Greenplum数据迁移方法论
	1.1 为什么要进行数据迁移
	数据迁移的目的是为了给数据找一个更合适的归宿，让其满足当前及未来某段时间内业务场景的使用需求，使数据更安全，更可靠，更有效的为客户服务。
	
	
	对于数据库而言，通常为了解决当前数据库遇到的瓶颈，考虑到成本，性能，可靠性，未来发展等多个方面因素，进行合理的数据迁移，以求通过新技术的引进，满足未来3-5年时间内业务持续性的需求。
	
	1.2 迁移整体的流程


# 第二节Greenplum数据迁移工具
	2.1 迁移工具
		根据第一部分的讲解，大家也可以理解数据迁移是一个复杂的工作，要求各方面配合，多种技术结合使用。
		
		目前市面上还没有任何一款工具可以灵活高性能的完成到Greenplum的异构数据迁移，并且在迁移过程中需要大量的人工干预，所以通常情况下我们都需要采用多种技术诶和来完成这一项工作。
		
		通常我们使用的工具有AWS Schema ConversionTool / ora2pg / sqluldr2 / sqldata / dbsync 等工具
	
	2.2 迁移工具--pra2pg 
		Ora2pg 是一款功能丰富的工具，用于将oracle/mysql数据迁移到PostgreSQL,由于Greenplum与postgreSQL的语法几乎一致性，所以同样也是用于Greenplum，通常情况下，我使用它来做简单的元数据转换及迁移分析。
		
		相关详细信息，源码及安装教程，参考开源中国: https://www.oschina.net/p/ora2pg?hmsr=aladdin1e1
	
	2.3 迁移工具--sqluldr2
		Sqluldr2 是一款Oracle数据快速导出工具，包含32位/64位程序，sqluldr2在大数据量导出方面速度特别快，能导出亿级数据为excel文件，另外他的导入速度也是非常快的，功能是将数据以TXT/CSV等格式导出。
		
		它支持windows和linux平台，通常用来配合gpfdist做大批量存量数据迁移，也可以用来构建自己的数据迁移工具。
		
		
		具体的使用方法可以参考博客：
		https://blog.csdn.net/cheng_feng_xiao_zhan/article/details/83620593
	
	2.4 迁移工具--sqldata
		SQLLines Data是一款开源(Apache License 2.0),可伸缩，并行高性能的data传输，schema转换工具，可以用作数据库和ETL处理。
		
		该工具特别适合数据量在TB以下级别的小型数据库迁移，速度快，省时省力。
		程序获取方式详细见:
		https://github.com/luzhihua407/SQLines-Data
		
		
	
	注意事项
	1、目标端td的数据库名字必须和用户名一致，如果不一致，会以用户为准，而不是数据库名称为准。
	2、单表迁移数据量超过21亿，结果报告展示会显示负数。
	
	
# 第三节 如何实现自己的数据迁移程序
## 3.1 数据迁移全周期功能
	Step1：Getthein for mation about source schema. 
	Step2：Generate DDL for Greenplum schema from Oracle schema 
	Step3：Generate CSV data dump for oracle tables. 
	Step4：Load the data baseusing GPFDist 
	step5：Validate the data 
	
	
	1-Test Oracle Database Connectivity 
	2-Oracle Database Information Report 
	3-Oracle Table Rows Count Report 
	4-Oracle Table Checksum Report 
	5-Generate Green plum Schema Table DDL corresponding to Oracle Schema 
	6-Generate Green plum External Table DDL corresponding to Oracle Schema 
	7-Generate Load data insert table scripts to insert data into Green plum table 
	8-Generate Select count DML scripts to count no of rows in green plum internal and external tables 
	9-Export Oracle Table Data in CSV Format consumed by Green plum External Table 
	10-**Export very large partitioned tables data in parallel and store in different location 
	11-**Generate External table DDL of large partitioned tables 
	21-Test Green plum Database Connectivity 22-Create table in Green plum using DDL generated from option 5 
	23-Create external table in Green plum using DDL generated from option 6or option 10 
	24-Load Data in Green plum 25-Generate table counts DML script 
	26-Create Checksum Report of Migrated data in Green plum 
	27-Compare Oracle and Green plum Checksum Report

# 第四节 Oracle到Greenplum的数据迁移
	4.1 为什么要从Oracle迁移到GPDB
		客户通常从别的平台迁移到Greenplum的原因有：
			1、成本：Greenplum相对于Teradata,Oracle Exadata等一体机设备，不需要购买专有的硬件设备，有明显的成本优势。
			2、性能：Greenplum相对传统关系型数据库有明显的性能提升，多个用户从Oracle迁移到Greenplum后，性能有几十倍的提升。
			3、易用性：Greenplum相对于Hadoop平台，SQL表达能力更为突出，应用改造成本要小很多。
			
			
			针对Oracle而言，Oracle并不是专门为分析性场景设计，其体系架构主要是对应数据变更的OLTP高并发，低延时场景。
			针对分析性，一般在Oracle上运行数小时候的分析应用，在Greenplum上只有数分钟或者秒级返回结果。
		
	4.2 迁移场景
		大部分场景都可以直接迁移到Greenplum，但也有部分场景(如高并发事务性场景)不太适合迁移到目前的Greenplum版本，具体的迁移建议如下：
| Oracle中的应用场景 | Oracle中的相应时间 | 迁移到Greenplum建议 |
|:----|:----:|:----|
| 分析性场景 | 1秒以上 | 此类应用完全可以迁移至Greenplum，迁移后性能会有较明显的提升 |
| 并发小查询场景 | 1秒以内 | 并发小查询场景包括小表全表扫描和大表索引扫描场景，迁移至Greenplum性能在同一量级，但因为数据节点交互延迟会略有增加 |
| 并发数据加载场景 | 1秒以内 | 可以迁移至Greenplum，需要将逐笔插入操作改为微批量插入，由于Greenplum MPP架构的优势，加载性能会有较明显的提升 |
| 低并发事务型场景 | 1秒以内 | 可以迁移至Greenplum，需要适当业务改造，将逐笔操作改为微批量操作高并发事务型场景	1秒以内	不建议迁移到Greenplum，由于数据夸节点的网络交换和锁的问题，会导致性能有较大的损失，甚至无法满足业务的需求，请关注Greenplum的研发进展和新版本性能，Greenplum社区正在不断增强高并发事务性特性。 |

		
	4.3 元数据迁移
		1、Oracle到Greenplum没有现成的工具，可以借助部分自动化转换工具先将Oracle语法转换为Postgresql语法，再通过脚本替换，最终转换为Greenplum语法。
		2、Oracle到PostgreSQL常用的迁移工具有Ora2pg以及AWS Schema ConversionTool。Ora2pg为命令行工具，只能从Oracle转换到PostgreSQL，而AWA Schema Conversion Tool(减仓AWSSCT)是为了发辫用户数据上云，由AWS提供的图形化自动转换工具，可以在本地部署安装，安装过程简单，能生成详细的分析报告，并且支持多种数据平台的语法转换。
		3、根据我们再用户环境的验证，大概可以完成将近70%的语法自动转化工作。
		4、储存过程的属于难点。
		
	4.4 元数据迁移
		SCT会自动进行类型转换，如果你想了解更多Oracle转Greenpm中不同数据类型的映射关系如下表
	
| Oracle | Greenplum | 说明 |
|:----|:----:|:----|
| VARCHAR2(n) | VARCHAR(n) | 在Oracle中n代表字节数，在Greenplum中n代表字符数 |
| CHAR(n) | CHAR(n) | 同上 |
| NUMBER(n,m) | NUMERIC(n,m) | number可以转换为numeric，但真实业务中数值类型可以用smallint,int或bigint等替代，性能会有较大的提升 |
| NUMBER(4) | SMALLINT | |
| NUMBER(9) | INT | |
| NUMBER(18) | BIGINT | |
| NUMBER(n) | NUMERIC(n) | 如果n>19,则可以转换为numeric类型 |
| DATE | TIMESTAMP(0) | Oracle和Greenplum都有日期类型，但Oracle的日期类型会同时保存日期和时间，而Greenplum只保存日期 |
| TIMESTAMP WITH LOCAL | TIME ZONE	TIMESTAMPTZ | |
| CLOB | TEXT | PostgreSQL中TEXT类型不能超过1GB |
| BLOBRAW(n) | BYTEA | 在Oracle中BLOB用于存放非结构化的二进制数据类型，BLOB最大可以储存128TB，而PostgreSQL中BYTEA类型最大可以储存1GB,如果有更大的储存需求，可以使用Large Object类型 |
	
	4.5 数据迁移
		数据迁移包括全量和增量数据迁移，进行全量迁移时，可以用sqluldr2工具先把数据以CSV格式导出，然后再通过gpfdist加载到Greenplum。
		
		
		增量迁移一般借助golden  gate等cdc软件，尽量做到数据实时捕获，再通过gpfdist加载到Greenplum中，正经有用户以250ms的间隔通过gpfdist实时加载数据到Greenplum中，在8个计算节点的集群上速度可以达到200万/s
		
	4.6 数据校验
		数据校验通常有以下几种方式：
			1、count值校验
			2、部分字段汇总校验
			3、MD5校验
			
			
			通常情况下，对校验方式的选择还是根据客户的要求来做，前两种的效率较高，MD5校验的成本可能更高，但是准确率也高。
	
# 第五节 PostgreSQL到Greenplum的数据迁移
	5.1 一种平滑的解决方案
		Greenplum与PostgreSQL无论在语法还是使用方式上，都基本上相似，所以从PostgreSQL迁移到Greenplum，通常是TP,AP拆分的一种平滑解决方案，由于均属于开源软件，既节省成本，又能很好的相互结合。
	
	5.2 元数据迁移
		元数据迁移直接从过pg_dump导出后修改导入即可，通常只需要以下三步。
			-  pg_dump  -s schema.sql  sourcedb
			-  手工接入，修改脚本对应的分布键，分区等语法，优化储存过程
			-  psq -f schema.sql  -d  targetdb
		
	5.3 数据迁移 
		数据迁移可以选用前面提到的sqldata工具，也可以自己编写全量增量迁移工具，通常情况下，自己编写工具会采用copy + gpfdist 的组合，以最大限度的发挥两个数据库的优点。
	
	5.4 数据校验
	
		数据校验通常有以下几种方式：
			1、count值校验
			2、部分字段汇总校验
			3、MD5校验
			
			
			通常情况下，对校验方式的选择还是根据客户的要求来做，前两种的效率较高，MD5校验的成本可能更高，但是准确率也高。