# greenplum-table-percentage 
	此项目主要检测greenplum集群中膨胀的表,经过检测会生成一个csv文件，以便技术人员分析原因及解决问题

# 项目结构介绍
	greenplum-table-percentage.sh
		主脚本,修改以下信息即可运行改脚本。
		1、修改该脚本中的数据库连接信息
		2、修改需要检测的schema_inspect,添加时请以英文逗号分割,例如:main,history
		3、运行完改脚本会在log/20190603/table-percentage/下生成一个csv文件,该文件是以膨胀率都排序
	

	log 
		日志目录,主要记录临时的生产的文件,以及检测结果文件

		20190603 
			当前检测的日期文件

			table-percentage
				最后生产csv的文件夹
			temp-percentage-results
				存放脚本生产的临时文件
	
	table-percentage-sql


# 运行项目输出详细日志如下
	time sh greenplum-table-percentage.sh
	*****************
	进度的百分比为: 18.18% 	 当前的行212 总行 1166 	 当前的表 data_quality.*********
	进度的百分比为: 99.97%   当前的行10647 总行 10650        当前的表 summary.*******
	进度的百分比为: 99.98%   当前的行10648 总行 10650        当前的表 summary.********
	进度的百分比为: 99.99%   当前的行10649 总行 10650        当前的表 summary.***********
	进度的百分比为: 100.00%          当前的行10650 总行 10650        当前的表 summary.********
	表的倾斜率检测完毕,请下载 greenplum-table-percentage/log/20190603/table-percentage/20190603-finish.csv  csv文件,以便分析结果......

# 遇到警告信息如下
	当出现以下错误时说明有的表没有收集相关的统计信息,可使用命更新表的统计信息 analyze tablename 

	psql:greenplum-table-percentage/table-percentage-sql/table-percentage.sql:1:NOTICE:One or more columns in the following table(s) do not have statistics: ******
	HINT:  For non-partitioned tables, run analyze <table_name>(<column_list>). For partitioned tables, run analyze rootpartition <table_name>(<column_list>). See log for columns missing statistics.

# 生成的CSV文件格式如下

	表名,最大segment的行,最小segment的行,倾斜率(%),表的大小,表的分布键
	datafix.enterp*******,10362661,84146,99,95GB, by (s_ext_nodenum)
	data_quality.dq_qg_*******,107,1,99,26kB, by (entid)
	data_quality.f_ent_*******,16495396,140377,99,5503MB, by (s_ext_nodenum)
	data_quality.f_ent_*******,12777242,107989,99,7824MB, by (s_ext_nodenum)
	data_quality.f_ent_*******,12759334,107950,99,7315MB, by (s_ext_nodenum)

![image](https://github.com/xfg0218/greenplum--summarize/blob/master/images/greenplum-images/table-percentage.png)



