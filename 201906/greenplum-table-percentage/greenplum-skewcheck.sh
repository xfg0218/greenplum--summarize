#!bin/bash

# 1、把改脚本放到任意目录下
# 2、table-percentage文件夹存放的是大于或等于制定倾斜率的表的详细信息
# 3、按照生成的文件修改表的分布键

#当前的日期
currentDate=`date +%Y%m%d`

#当前该脚本的路径与父路径
bashpath=$(cd `dirname $0`;pwd)
basepath_parent=$(dirname $(pwd))

# 执行查看AO表的SQL脚本
skewcheck_ao_table_ori=$bashpath"/skewcheck-sql/all-table.sql-ori"
skewcheck_ao_table=$bashpath"/skewcheck-sql/all-table.sql"

# 查看表倾斜率的SQL
skewcheck_table_ori=$bashpath"/skewcheck-sql/table-percentage.sql-ori"
skewcheck_table=$bashpath"/skewcheck-sql/table-percentage.sql"

# 所产生的日志路径
skewcheck_log=$bashpath"/log"

#创建生成结果的临时目录与倾斜的详细目录
temp_all_table_results=$skewcheck_log"/"$currentDate"/temp-percentage-results"
skewcheck_table_log=$skewcheck_log"/"$currentDate"/table-percentage"

# 以下为数据库的链接信息
gpdatabase='********'
scheamname='public'
gpip='192.168.***.**'
gpport='5432'
gpuser='******'

# 需要检查的schema,请以英文逗号分割
schema_inspect='data_quality,datafix,dim,history,issues,main,ods,ods_spider,produce_check,riskbell,summary,vatel'
#schema_inspect='data_quality'

# 允许膨胀的百分比,大于等于此膨胀的则需要清理
percent_hidden='1'

# 删除日志文件并创建新文件
if [ -d $skewcheck_log ];then
     rm -rf $skewcheck_log
fi


mkdir -p  $temp_all_table_results
mkdir -p  $skewcheck_table_log

# 根据schema获取schema下的表,汇总成一个文件
array=(${schema_inspect//,/ })
for schema_var in ${array[@]}
do
   cp $skewcheck_ao_table_ori $skewcheck_ao_table
   sed -i 's/schemaName/'$schema_var'/g' $skewcheck_ao_table
   psql -d $gpdatabase  -h $gpip -p $gpport -U $gpuser -f  $skewcheck_ao_table >> $temp_all_table_results/$currentDate-$schema_var".txt"   
    
   # 删除文件的头两行与最后两行,把文件中的空格删除掉,拼接成schema.tablename的样式
   sed -i '1,2d' $temp_all_table_results/$currentDate-$schema_var".txt"
   sed -i '$d' $temp_all_table_results/$currentDate-$schema_var".txt"
   sed -i '$d' $temp_all_table_results/$currentDate-$schema_var".txt"
   sed -i 's/[[:space:]]//g' $temp_all_table_results/$currentDate-$schema_var".txt"
   cat $temp_all_table_results/$currentDate-$schema_var".txt" |awk -F '|' '{print $1"."$2}' >> $temp_all_table_results"/"$currentDate"-finish.txt"
  
done


# 1、遍历合并的AO与堆表的文件
# 2、根据表的名字查看表的倾斜率,倾斜率是向下取整
# 3、生成当前处理的进度
# 4、获取表的倾斜率与制定的数值进行比较
# 5、获取表的大小与表的最大和最小的segment的行数以及分布键进行保存
# 6、拼接需要的信息,最终生成csv格式以便分析 
finish_tablename=$temp_all_table_results"/"$currentDate"-finish.txt"
filesumline=`cat $finish_tablename|wc -l`
for tablename in `cat $finish_tablename`
do

   # 获取表的倾斜率,使用的是int方式,向下取整
   cp $skewcheck_table_ori $skewcheck_table
   sed -i 's/tableName/'$tablename'/g' $skewcheck_table
   percent_result=`psql -d $gpdatabase  -h $gpip -p $gpport -U $gpuser -f  $skewcheck_table`
   percent_number=`echo $percent_result|awk '{gsub(/[[:blank:]]*/,"",$0);print $0}'|awk 'gsub(/-/,"",$0)'|awk -F 'percentage' '{print $2}'|awk -F '(' '{print int($1)}'`
   
   # 计算当前的进度
   currentline=`cat $finish_tablename|grep -w -n $tablename|awk -F ':' '{print $1}'`
   percentage=`awk 'BEGIN{printf "%.2f%\n",'$currentline'/'$filesumline'*100}'`
   echo -e "进度的百分比为: $percentage \t 当前的行$currentline 总行 $filesumline \t 当前的表 $tablename"

   # 获取表的倾斜率与制定的数值进行比较
   if [[ $percent_number -ge $percent_hidden ]] ;then
       # 获取表的大小
       originalTableSize=`psql -d $gpdatabase  -h $gpip -p $gpport -U $gpuser -c "select pg_size_pretty(pg_relation_size('$tablename'))"`
       orTableSize=`echo $originalTableSize|awk '{gsub(/[[:blank:]]*/,"",$0);print $0}'|awk 'gsub(/-/,"",$0)'|awk -F '('  '{print $1}'|awk -F 'pg_size_pretty' '{print $2}'`
       # 获取表的segment的最大与最小行
       rows=`psql -d $gpdatabase  -h $gpip -p $gpport -U $gpuser -c "SELECT max(c) AS "maxrows",min(c) AS "minrows" FROM (SELECT count(*) c,gp_segment_id FROM $tablename  GROUP BY 2) AS a"`
       maxnumber=`echo $rows|awk '{gsub(/[[:blank:]]*/,"",$0);print $0}'|awk 'gsub(/-/,"",$0)'|awk -F '+' '{print $2}'|awk -F '|' '{print $1}'`
       minnumber=`echo $rows|awk '{gsub(/[[:blank:]]*/,"",$0);print $0}'|awk 'gsub(/-/,"",$0)'|awk -F '+' '{print $2}'|awk -F '|' '{print $2}'|awk -F '(' '{print $1}'`
       # 获取表的分布键
       tableschemaori=`psql -d $gpdatabase  -h $gpip -p $gpport -U $gpuser -c "select get_table_structure('$tablename')"`       
       tableDistributed=`echo $tableschemaori|awk -F 'Distributed' '{print $2}'|awk -F ';' '{print $1}'`

       echo $tablename","$maxnumber","$minnumber","$percent_number","$orTableSize","$tableDistributed >> $skewcheck_table_log/$currentDate"-temp.csv"
   fi

   # 删除倾斜率的文件,以便下次使用
  if [ -f $skewcheck_table ];then
   rm  -rf $skewcheck_table
  fi

done


#  判断是否有满足表的信息
finish_file_temp=$skewcheck_table_log/$currentDate"-temp.csv"
finish_file=$skewcheck_table_log/$currentDate"-finish.csv"
if [[ -f $finish_file ]];then
 sort -t ',' -k 4.1,4.2nr $finish_file_temp >> $finish_file
 sed -i '1i\表名,最大segment的行,最小segment的行,倾斜率(%),表的大小,表的分布键'  $finish_file
 echo -e "\n\n 表的倾斜率检测完毕,请下载 $finish_file  csv文件,以便分析结果......"
 if [[ -f $finish_file_temp ]];then
   rm -rf $finish_file_temp 
 fi

else
 echo -e "\n\n 没有倾斜率大于等于 $percent_hidden % "
fi 


# 正确退出脚本
exit

