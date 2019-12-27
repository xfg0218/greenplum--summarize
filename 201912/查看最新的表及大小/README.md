# Greenplum 查看最新创建的表及大小

# 说明
	最近发现GP中空间增长比较快，为了能更好的发现GP中一段时间内增长的表及大小

# 实现的SQL
	select pt.schemaname||'.'||ts.relname as tablename,
	pg_relation_size(pt.schemaname||'.'||ts.relname)/1024/1024/1024 as tablesizegb,
	ts.stausename,ts.stasubtype,ts.statime from (
	SELECT ps.stausename,ps.staactionname,ps.stasubtype,pc.relname,ps.statime
	FROM pg_stat_last_operation ps,pg_class pc WHERE ps.objid = pc.oid
	and ps.staactionname='CREATE'
	and ps.statime::date >= 'enddate '
	) ts,pg_tables pt
	where ts.relname = pt.tablename
	order by tablesizegb desc
	
	
	enddate :结束的时间,格式如:2019-12-27
	tablesizegb : 字段的单位是GB
	
# Greenplum 查看最新创建的表及大小图片案例
[](https://github.com/xfg0218/greenplum--summarize/blob/master/images/greenplum-images/%E6%9C%80%E6%96%B0%E7%9A%84%E8%A1%A8%E4%B8%8E%E5%A4%A7%E5%B0%8F.png)