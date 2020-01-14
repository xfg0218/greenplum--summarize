# Greenplum 元数据信息
	Greenplum 元数据信息.pdf 是对Greenplum常用的查询语句,查看的GP版本是PostgreSQL 8.3.23 (Greenplum Database 5.11.1),
	如有不足的地方请大家指正下载请到:
	https://github.com/xfg0218/greenplum--summarize/tree/master/greenplum%E5%AD%A6%E4%B9%A0pdf%E6%96%87%E6%A1%A3
	
# Greenplum 元数据信息目录
	Greenplum 元数据信息
	1、 获取集群中数据库信息
		1.1 集群中的创建的数据库信息
		1.2 查看每个数据库的储存大小
	2、 查看数据库下schema信息
		2.1 查看数据库下创建的schema信息
		2.2 查看数据库下每个schema的大小
	3、 查看schema下表的信息
		3.1 查看schema下的表的清单
		3.2 查看表的字段的信息
		3.3 查看schema下的每个表的大小
		3.4 获取表的生命周期
		3.5 获取表的膨胀率
		3.6 查看表的倾斜率
		3.7 查看需要Analyze的表
		3.8 查看表的字段个类型信息
		3.9 查看表字段的注释信息
	4 查看集群中用户相关的信息
		4.1 集群中创建的用户信息
		4.2 用户创建的表信息
	5 集群中Function的信息
		5.1 查看创建的所有Function的信息
		5.2 查看制定schema下的Function信息
	6 集群中资源队列的信息
		6.1 查看创建的资源队列
		6.2 查看资源队列的参数配置
	7 集群中正在运行的SQL信息
		7.1 查看正在运行的SQL信息
	8 查询数据库与表的年龄
		8.1 查询数据库的年龄
		8.2 查询表的年龄
		
	
# Greenplum 元数据信息内容展示	
## 1、获取集群中数据库信息
### 1.1 集群中的创建的数据库信息
	select datname from pg_database where datname not in ('template1','template0','postgres');
### 1.2 查看每个数据库的储存大小
	select pg_size_pretty(pg_database_size('databases')) as databasesize, 'databases' as databasename
	databases : 数据库信息
	
## 2、查看数据库下schema信息
### 2.1 查看数据库下创建的schema信息
	select nspname as schemaname from pg_namespace where nspname!~'pg_*' ORDER BY nspname

### 2.2 查看数据库下每个schema的大小
	select pg_size_pretty(cast(sum(pg_relation_size( schemaname || '.' || tablename)) as bigint)), schemaname
	from pg_tables t inner join pg_namespace d on t.schemaname=d.nspname group by schemaname;
## 3、查看schema下表的信息
### 3.1 查看schema下的表的清单

	select 'schemaname '||'.'||c.relname as tablename
	from pg_catalog.pg_class c, pg_catalog.pg_namespace n
	where
	n.oid = c.relnamespace
	and n.nspname='schemaname '
	and pc.relstorage IN ('type')
	
	schemaname : schema的名字
	type：a和c是AO表,h是heap表,x是外表

### 3.2 查看表的字段的信息
	select table_schema||'.'||table_name as tablename,column_name,
	case character_maximum_length is null   
	when 't' then data_type
	else data_type||'('||character_maximum_length||')' end as character_maximum_length
	from information_schema.columns where table_schema='schema'
	and table_name='tablename';
	
	schema :  schema的信息
	Tablename : 表的名字

### 3.3 查看schema下的每个表的大小
	select schemaname||'.'||tablename,
	pg_relation_size(schemaname || '.' || tablename)/1024/1024/1024 as tablesize
	from pg_tables t inner join pg_namespace d on t.schemaname=d.nspname 
	and nspname='schema '
	ORDER BY tablesize desc 
	limit 100;
	
	
	schema :  schema的信息
### 3.4 获取表的生命周期
	select staactionname,stausename,stasubtype,to_char(statime,'yyyy-mm-dd hh24:mm:ss')||'' as statime
	from pg_stat_last_operation where objid = 'tablename'::regclass  order by statime desc
	
	tablename : 表的名字

### 3.5 获取表的膨胀率
	select percent_hidden
	from gp_toolkit.__gp_aovisimap_compaction_info('main.t_ent_baseinfo'::regclass)
	ORDER BY percent_hidden desc;
### 3.6 查看表的倾斜率
	SELECT max(c) AS MaxSegRows, min(c) AS MinSegRows,
	substr((max(c)-min(c))*100.0/max(c)||'',0,8) AS PercentageDifferenceBetween
	FROM (SELECT count(*) c, gp_segment_id FROM tablename 
	GROUP BY 2) AS a
	
	tablename : 表的名字

### 3.7 查看需要Analyze的表
	select smischema||'.'||smitable as tablename,smisize,smicols,smirecs from gp_toolkit.gp_stats_missing where smisize='f' limit 10;

### 3.8 查看表的字段个类型信息
	select table_schema||'.'||table_name as tablename,column_name,
	case character_maximum_length is null   
	when 't' then data_type
	else data_type||'('||character_maximum_length||')' end as character_maximum_length
	from information_schema.columns where table_schema='schema'
	and table_name='tablename';
	
	
	schema ： schem信息
	tablename : 表的名字
### 3.9 查看表字段的注释信息
	SELECT 'tablename' as table_name
		,a.attname                            AS column_name
		,format_type(a.atttypid, a.atttypmod) AS data_type
		,d.description                        AS description
		,a.attnum
		,a.attnotnull                         AS notnull
		,coalesce(p.indisprimary, FALSE)      AS primary_key
		,f.adsrc                              AS default_val
	FROM   pg_attribute    a
	LEFT   JOIN pg_index   p ON p.indrelid = a.attrelid AND a.attnum = ANY(p.indkey)
	LEFT   JOIN pg_description d ON d.objoid  = a.attrelid AND d.objsubid = a.attnum
	LEFT   JOIN pg_attrdef f ON f.adrelid = a.attrelid  AND f.adnum = a.attnum
	WHERE  a.attnum > 0
	AND    NOT a.attisdropped
	AND    a.attrelid = 'tablename'::regclass
	ORDER  BY a.attnum;
	
	
	tablename : 表的名字

## 4 查看集群中用户相关的信息
### 4.1 集群中创建的用户信息
	select rolname,case rolsuper when 't' then '是管理员' when 'f' then '不是管理员' 
	end as rolsuper, case rolcreaterole when 't' then '可以创建角色' when 'f' then '不可以创建角色' end as rolcreaterole,
	case rolcreatedb  when 't' then '可以创建DB' when 'f' then '不可以创建DB' end as rolcreatedb,
	case rolcanlogin  when 't' then '可以登录' when 'f' then '不可以登录' end as rolcanlogin,
	case rolconnlimit when  '-1' then '没有限制' else '有限制' end as rolconnlimit,
	case  when rolvaliduntil is null  then '永不失效' else '有失效时间' end as rolvaliduntil,rsqname
	from pg_roles,gp_toolkit.gp_resqueue_status where rolname not like 'gpcc%' and pg_roles.rolresqueue=gp_toolkit.gp_resqueue_status.queueid
	order by rolname
### 4.2 用户创建的表信息
	select grantee,table_schema||'.'||table_name as tablename,privilege_type,is_grantable
	from information_schema.table_privileges where grantee= 'gpadmin'  limit 100
	
## 5 集群中Function的信息
### 5.1 查看创建的所有Function的信息
	SELECT pg_proc.proname AS proname,pg_type.typname AS typename,
	pg_proc.pronargs AS argscount FROM pg_proc JOIN pg_type ON
	(pg_proc.prorettype = pg_type.oid) WHERE pg_type.typname != 'void'
	and pg_proc.proname like 'sp_%' ORDER BY pg_proc.proname  ;
	
	void : 返回的类型
	sp_% : 函数的前缀
	
### 5.2 查看制定schema下的Function信息
	SELECT pg_proc.proname AS proname,pg_type.typname AS typename,
	pg_proc.pronargs AS argscount FROM pg_proc JOIN pg_type ON
	(pg_proc.prorettype = pg_type.oid) WHERE pg_type.typname != 'void'
	and pg_proc.proname like 'sp_%' and pronamespace = (SELECT pg_namespace.oid FROM pg_namespace WHERE nspname = 'schema' )
	ORDER BY pg_proc.proname ;
	
	void : 返回的类型
	sp_% : 函数的前缀
	schema : 制定的schema的信息

## 6 集群中资源队列的信息
### 6.1 查看创建的资源队列
	select  * from pg_resqueue

### 6.2 查看资源队列的参数配置
	select rsqname,resname,ressetting from pg_resqueue_attributes

## 7 集群中正在运行的SQL信息
### 7.1 查看正在运行的SQL信息
	select datname,procpid,usename,current_query,waiting,
	to_char(query_start,'yyyy-mm-dd hh24:mm:ss') as query_start,
	to_char(backend_start,'yyyy-mm-dd hh24:mm:ss') as backend_start,
	((substr(now()||'',0,20)::timestamp) - (substr(query_start||'',0,20)::timestamp))||'' as takingTime,
	client_addr,application_name,waiting_reason  from pg_stat_activity where current_query <> '<IDLE>'
	order by takingTime desc

## 8 查询数据库与表的年龄

### 8.1 查询数据库的年龄
	select datname,age(datfrozenxid) from pg_database where age(datfrozenxid) > 1500000000
	
	1500000000: 15亿的年龄
	
	如果超过15亿，建议用户在业务空闲时间段，执行：
	
	set vacuum_freeze_min_age = 0;  
	vacuum freeze; 
	
### 8.2 查询表的年龄
	select * from (
	select pt.schemaname||'.'||ts.relname as tablename,
	pg_relation_size(pt.schemaname||'.'||ts.relname)/1024/1024/1024 as tablesizegb,
	ts.relfrozenxid,ts.stausename,ts.stasubtype,ts.statime from (
	SELECT ps.stausename,ps.staactionname,ps.stasubtype,pc.relname,ps.statime,age(relfrozenxid) as relfrozenxid
	FROM pg_stat_last_operation ps,pg_class pc WHERE ps.objid = pc.oid
	and age(pc.relfrozenxid) > 1500000000
	) ts,pg_tables pt
	where ts.relname = pt.tablename
	order by tablesizegb desc
	) txd
	where txd.tablesizegb > 0
	
	1500000000 : 15亿的年龄
	tablename : 表的名字
	
	
	
	如果超过15亿，建议用户在业务空闲时间段，执行：
	
	set vacuum_freeze_min_age = 0;  
	vacuum freeze tablename;