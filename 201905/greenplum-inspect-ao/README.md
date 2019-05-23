# greenplum-inspect-ao
	greenplum-inspect-ao 主要对AO进行垃圾回收释放，具体的请查看:https://blog.csdn.net/xfg0218/article/details/83031550

# 项目结构介绍
	greenplum-inspect-ao.sh 运行的主脚本,只需要修改脚本里面的参数即可,脚本运行完毕后会在log/SYSDATE/table-percent-hidden下的csv文件,以便分析查看
	
	inspect-ao-sql
		inspect-ao-ori.sql:查询schema下的AO表
		inspect-ao-percent-hidden-ori.sql:查看表的膨胀率,按照膨胀率大小排序，获取最大的第一个
	log
		20190523 : 当前执行此脚本的日期
			table-percent-hidden : 执行完此脚本存放csv格式的文件夹
			temp-inspect-results : 存放临时的统计结果,包括每个schema的表并按照格式生成需要的新的文件，以便读取表
# 
