#!bin/bash

# 1、把改脚本放到任意目录下
# 2、bloatcheck-sql文件夹存放的是查询AO表的SQL与查询膨胀率的SQL
# 3、log文件夹则是存放临时生成的schema与table的文件,还有存放每个AO表的膨胀率详细的信息
# 4、释放空间使用的是vacuum schema.tablename

#当前的日期
currentDate=`date +%Y%m%d`

#当前该脚本的路径与父路径
bashpath=$(cd `dirname $0`;pwd)
basepath_parent=$(dirname $(pwd))

# 执行查看AO表的SQL脚本
bloatcheck_tablename_ori=$bashpath"/bloatcheck-sql/bloatcheck-tablename-ori.sql"
bloatcheck_tablename=$bashpath"/bloatcheck-sql/bloatcheck-tablenam.sql"

# 查看表膨胀率的SQL脚本
inspect_ao_expansivity_ori=$bashpath"/bloatcheck-sql/bloatcheck-percent-hidden-ori.sql.sql"
inspect_ao_expansivity=$bashpath"/bloatcheck-sql/bloatcheck-percent-hidden.sql"

# 所产生的日志路径
inspect_ao_log=$bashpath"/log"

#创建生成结果的临时目录与膨胀详细目录
temp_inspect_results=$inspect_ao_log"/"$currentDate"/temp-inspect-results"
table_percent_hidden=$inspect_ao_log"/"$currentDate"/table-percent-hidden"

# 以下为数据库的链接信息
gpdatabase='chinadaas'
scheamname='public'
gpip='192.168.209.11'
gpport='5432'
gpuser='gpadmin'

# 需要检查的schema,请以英文逗号分割
schema_inspect='data_quality,datafix,dim,history,issues,main,ods,ods_spider,produce_check,riskbell,summary,vatel'


# 允许膨胀的百分比,大于等于此膨胀的则需要清理
percent_hidden='15'

# 删除日志文件并创建新文件
if [ -d $inspect_ao_log ];then
     rm -rf $inspect_ao_log
fi
if [ -d $table_percent_hidden ];then
     rm -rf $table_percent_hidden
fi

mkdir -p  $temp_inspect_results
mkdir -p  $table_percent_hidden

# 根据schema获取schema下的表,汇总成一个文件
array=(${schema_inspect//,/ })
for schema_var in ${array[@]}
do
   cp $bloatcheck_tablename_ori $bloatcheck_tablename
   sed -i 's/schemaName/'$schema_var'/g' $bloatcheck_tablename

   psql -d $gpdatabase  -h $gpip -p $gpport -U $gpuser -f  $bloatcheck_tablename >> $temp_inspect_results/$currentDate-$schema_var".txt"   
   
   # 删除文件的头两行与最后两行,把文件中的空格删除掉,拼接成schema.tablename的样式
   sed -i '1,2d' $temp_inspect_results/$currentDate-$schema_var".txt"
   sed -i '$d' $temp_inspect_results/$currentDate-$schema_var".txt"
   sed -i '$d' $temp_inspect_results/$currentDate-$schema_var".txt"
   sed -i 's/[[:space:]]//g' $temp_inspect_results/$currentDate-$schema_var".txt"
   cat $temp_inspect_results/$currentDate-$schema_var".txt" |awk -F '|' '{print $1"."$2}' >> $temp_inspect_results"/"$currentDate"-finish.txt"
  
done


# 查找膨胀率大于等于设置的值的表并做清理,并把处理的过程保存下来
# 1、读取储存表的文件,一行一行的读取
# 2、获取当前表的膨胀率
# 3、判断当前表的膨胀率与设置的值比较
# 4、如果大于等于设置的值,则进行释放空间
# 5、统计释放空间表的详细信息,包括表明,表的膨胀率,表的原始大小,表清楚后的大小
finish_tablename=$temp_inspect_results"/"$currentDate"-finish.txt"
filesumline=`cat $finish_tablename|wc -l`
for tablename in `cat $finish_tablename`
do

   cp $inspect_ao_expansivity_ori $inspect_ao_expansivity
   sed -i 's/tablename/'$tablename'/g' $inspect_ao_expansivity
   percent_result=`psql -d $gpdatabase  -h $gpip -p $gpport -U $gpuser -f  $inspect_ao_expansivity`
   percent_number=`echo $percent_result|awk -F '----------------' '{print $2}'|awk -F '('  '{print $1}'|awk '{print int($0)}'`
   
   currentline=`cat $finish_tablename|grep -w -n $tablename|awk -F ':' '{print $1}'`
   percentage=`awk 'BEGIN{printf "%.2f%\n",'$currentline'/'$filesumline'*100}'`
   echo -e "当前进度的百分比为: $percentage \t 当前的行$currentline 总行 $filesumline \t 当前的表 $tablename"

   # 1、获取原始表的大小
   # 2、vacuum释放表的空间
   # 3、获取释放后的表的空间
   if [ $percent_number -ge $percent_hidden ] ;then
       
       originalTableSize=`psql -d $gpdatabase  -h $gpip -p $gpport -U $gpuser -c "select pg_size_pretty(pg_relation_size('$tablename'))"`
       orTableSize=`echo $originalTableSize|awk '{gsub(/[[:blank:]]*/,"",$0);print $0}'|awk -F '----------------' '{print $2}'|awk -F '('  '{print $1}'`
       psql -d $gpdatabase  -h $gpip -p $gpport -U $gpuser -c "vacuum $tablename"
       
       resultTableSize=`psql -d $gpdatabase  -h $gpip -p $gpport -U $gpuser -c "select pg_size_pretty(pg_relation_size('$tablename'))"`
       reTableSize=`echo $resultTableSize|awk '{gsub(/[[:blank:]]*/,"",$0);print $0}'|awk -F '----------------' '{print $2}'|awk -F '('  '{print $1}'`

       echo $tablename","$percent_number","$orTableSize","$reTableSize >> $table_percent_hidden/$currentDate"-finish.csv"
   fi 
  
  # 删除查看表膨胀率的文件,以便下次使用
  if [ -f $inspect_ao_expansivity ];then
   rm  -rf $inspect_ao_expansivity
  fi

done


finsh_file=$table_percent_hidden/$currentDate"-finish.csv"
if [[ -f $finsh_file ]];then
# 添加文件的表头
sed -i '1i\表名,最高膨胀率%,清除之前的大小,清除之后的大小'  $finsh_file

echo -e "\n\n表空间回收完毕,请下载 $finsh_file csv文件,以便分析结果......"
else
 echo -e "\n\n 没有膨胀率大于等于 $percent_hidden %"
fi


# 正确退出脚本
exit
