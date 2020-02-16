# postgreSQL窗口函数总结说明
	postgreSQL窗口函数总结是平常使用的窗口函数，pdf文档请下载(Greenplum窗口函数总结.pdf):https://github.com/xfg0218/greenplum--summarize/tree/master/greenplum%E5%AD%A6%E4%B9%A0pdf%E6%96%87%E6%A1%A3

# postgreSQL窗口函数总结目录如下

# 窗口函数说明
	1、我们都知道在SQL中有一类函数叫做聚合函数,例如sum()、avg()、max()等等,这类函数可以将多行数据按照规则聚集为一行,一般来讲聚集后的行数是要少于聚集前的行数的,但是有时我们想要既显示聚集前的数据,又要显示聚集后的数据,这时我们便引入了窗口函数。
	
	2、在所有的SQL处理中,窗口函数都是最后一步执行,而且仅位于Order by字句之前。
	
	3、Partition By子句可以称为查询分区子句,非常类似于Group By,都是将数据按照边界值分组,而Over之前的函数在每一个分组之内进行,如果超出了分组,则函数会重新计算。
	
	4、order by子句会让输入的数据强制排序。Order By子句对于诸如row_number()，lead()，LAG()等函数是必须的，因为如果数据无序，这些函数的结果就没有任何意义。因此如果有了Order By子句，则count()，min()等计算出来的结果就没有任何意义。
	
	5、如果只使用partition by子句,未指定order by的话,我们的聚合是分组内的聚合。
	
	6、当同一个select查询中存在多个窗口函数时,他们相互之间是没有影响的。
	
# row_number/rank/dense_rank的区别
	这三个窗口函数的使用场景非常多,区别分别为:
	1、row_number()从1开始，按照顺序，生成分组内记录的序列,row_number()的值不会存在重复,当排序的值相同时,按照表中记录的顺序进行排列 
	2、rank() 生成数据项在分组中的排名，排名相等会在名次中留下空位 
	3、dense_rank() 生成数据项在分组中的排名，排名相等会在名次中不会留下空位
	
	注意： 
	rank和dense_rank的区别在于排名相等时会不会留下空位。

# 窗口函数语句语法
	<窗口函数> 
	OVER ([PARTITION BY <列清单>]                      
	ORDER BY <排序用列清单>)
	
	over:窗口函数关键字
	partition by:对结果集进行分组
	order by:设定结果集的分组数据排序
	
	聚合函数:聚合函数（SUM、AVG、COUNT、MAX、MIN）
	内置函数:rank、dense_rank、row_number、percent_rank、grouping sets、first_value、last_value、nth_value等专用窗口函

# 1 准备数据
	1.1 创建测试的表test1
	1.2 插入数据到test1表中
	
# 2 rank over 窗口函数使用
	2.1 按照分区查看每行的个数
	2.2 按照分区和排序查看每行的数据
	2.3 查看每个部门最高的数据
	
# 3 row_number over 窗口函数的使用
	3.1 显示数据的行号
		3.1.1 顺序显示行号
		3.1.2 获取一段内的数据
	3.2 显示分区的个数
	3.3 按照department分组wages排序显示数据
	3.4 查看每个部门的最高的数据
	
# 4 dense_rank窗口函数使用
	4.1 rank与dense_rank的区别
	4.2 dense_rank 窗口函数的显示
	4.3 rank 窗口函数的显示
	
# 5 rank/row_number/dense_rank比较

# 6 percent_rank 窗口函数的使用
	6.1 计算分组中的比例
	
# 7 grouping sets 函数的使用
	7.1 先按照wages分组再按照department进行分组
	
# 8 聚合函数+窗口函数使用
	8.1 查看一个部门的个数
	8.2 统计每个部门的wages之和
	8.3 按照排序统计每个部门的wages之和
	8.4 按照分组和排序统计数据
	8.5 window子句使用
		8.5.1 windom子句的说明
		8.5.2 执行的SQL语句
	8.6 窗口函数中的序列函数
		8.6.1 序列函数的说明
		8.6.2 执行的语句
		
# 9 first_value\last_value使用
	9.1 first_value和last_value说明
	9.2 执行的SQL

