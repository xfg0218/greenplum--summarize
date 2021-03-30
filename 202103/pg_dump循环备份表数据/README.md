	#!bin/bash
	
	# 表文件和该文件的行数
	tablefile="tablename.sql"
	lines=`cat $tablefile|wc -l`
	
	# 导入密码
	export PGPASSWORD=gpadmin
	
	# 循环开始备份表中的数据
	for tablename in `cat $tablefile`
	do
	
	# 获取该该表的位置
	currentlin=`cat $tablefile |grep -rn -w "$tablename"|awk -F ':' '{print $2}'`
	
	# 计算百分比
	proportion=`awk 'BEGIN{printf "%.1f%%\n",('$currentlin'/'$lines')*100}'`
	
	# 链接的服务器信息
	pg_dump -h 192.168.**.***  -p5432 -U gpadmin -t $tablename  database > $tablename".sql"
	
	
	# 打印日志信息
	echo  "正在备份表 < "$tablename  " > 总行数: " $lines " 当前的行数: "$currentlin " 进度百分比: " $proportion
	
	done
 
 
    日志输出信息: 
    正在备份表 < ods.*******  > 总行数:  20  当前的行数: 19  进度百分比:  95.0%
    正在备份表 < ods.*******  > 总行数:  20  当前的行数: 20  进度百分比:  100.0% 