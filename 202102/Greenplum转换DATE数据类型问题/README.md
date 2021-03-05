# Greenplum转换DATE数据类型问题
	1 场景概述
	2 查看外表时的错误
	3 问题解答思路
		3.1 修改外表字段类型
		3.2 把外表映射成内表
		3.3 修改内表类型
		3.4 把内表修改成DATE类型
		3.5 更新字段效率查看

# 1 场景概述
	在工作中使用Greenplum外表时发现date类型中有null或空值,外表不识别类型，
	问题解答思路，先使用varchar类型把外表的数据加载到Greenplum,在使用数据类型转化转化为date即可。
# 2 查看外表时的错误
	[SQL]select * from test_external limit 100;
	
	NOTICE:  Found 8833 data formatting errors (8833 or more input rows). Rejected related input data.
	
	[Err] ERROR:  All 1000 first rows in this segment were rejected. Aborting operation regardless of REJECT LIMIT value. 
	Last error was: invalid input syntax for type date: "null", column candate  (seg17 slice1 192.168.209.14:40001 pid=417285)
	DETAIL:  External table xiaoxu_temp, line 1000 of gphdfs://nameservice1/tmp/*****/***_all/*, column candate
	
	以上问题是在查询外表时遇到了数据类型date为null的数值
	
# 3 问题解答思路
## 3.1 修改外表字段类型

	在创建外表语句时把candate字段的类型修改成varchar
	
## 3.2 把外表映射成内表
	把外表的数据复制到内表中，映射语句如下:
	
	create table temp_internal with (appendonly = true, compresstype = zlib, compresslevel = 5
	,orientation=column) as
	select * from test_external 
	Distributed by (id)
	
## 3.3 修改内表类型
	update  test_external  set candate=null where candate ='null' or length(candate)=0;
	
	以上语句是把内表中candate是null或空修改成null , 效果如下
	
	
## 3.4 把内表修改成DATE类型
	以下语句是先把candate转换为carchar再转换为date
	alter table test_external alter column "candate" type date using ("candate"::VARCHAR::date);
	
## 3.5 更新字段效率查看
	[SQL]update table test_external set candate=null where candate='null';
	
	时间: 145.664s
	
	受影响的行: 45804388
	
	
	[SQL]alter table table test_external alter column "candate" type date using ("candate"::VARCHAR::date);
	
	时间: 214.938s
	
	受影响的行: 0