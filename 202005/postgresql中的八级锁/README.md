# 转载说明
	以下内容全部转载于https://mp.weixin.qq.com/s/jDbZOB8RHo5XivSwPpajIA
	
# PostgreSQL数据库锁的说明

		锁是实现数据库并发控制必不可少的功能，PostgreSQL数据库通过其特有的多版本属性实现了MVCC，
	实现了读不阻塞写，写不阻塞读。PostgreSQL中表锁有八个级别，不同的锁对应了不同的排他级别。
	值得注意的是同一时刻两个事务不能再同一个表上获取相互冲突的锁，
	但是一个事务是永远不会与自己冲突的，一个事务里连续获取两个有冲突的锁类型是没有问题的。

# 表级锁
	先用一张图总结一下八种锁的冲突关系
![image]https://github.com/xfg0218/greenplum--summarize/blob/master/images/postgreSQL-images/postgreSQL%E5%85%AB%E7%A7%8D%E9%94%81%E7%9A%84%E5%86%B2%E7%AA%81%E5%85%B3%E7%B3%BB%E5%9B%BE.jpg

# 这八种锁的使用场景：

	1.AccessShare
	在某个表上发出SELECT命令只读取表而不去修改它的查询都会获取该锁类型。
	冲突级别：8
	
	2.RowShare
	SELECT FOR UPDATE/FOR SHARE命令会在目标表上取得一个这种模式的锁。
	冲突级别：7,8
	
	3.RowExclusive
	在表上发出UPDATE、DELETE和INSERT要修改表中数据时会取得这种锁模式。
	冲突级别：5,6,7,8
	
	4.ShareUpdateExclusive
	一些在线维护类操作所获得的锁，例如VACUUM（不带FULL）、ANALYZE、CREATE INDEX CONCURRENTLY、CREATE STATISTICS、ALTER TABLE VALIDATE等，该锁类型是自排他的。
	冲突级别：4,5,6,7,8
	
	5.Share
	发出CREATE INDEX命令（不带CONCURRENTLY）取得该锁，注意该锁不是自排他的。
	冲突级别：3,4,6,7,8
	
	6.ShareRowExclusive
	在以前老版本的官方文档中该锁不能通过发出某条数据库命令获得，而11以后的版本介绍该锁由CREATE COLLATION、CREATE TRIGGER和某些 ALTER TABLE命令获得。
	冲突级别：3,4,5,6,7,8
	
	7.Exclusive
	这种锁模式只允许并发的AccessShare锁，持有该锁只允许该表的只读操作。在以前老版本的官方文档中该锁不能通过发出某条数据库命令获得，而11以后的版本介绍该锁由REFRESH MATERIALIZED VIEW CONCURRENTLY获得。
	冲突级别：2,3,4,5,6,7,8
	
	8.AccessExclusive
	最高级别的锁，与所有模式的锁冲突，该锁保证持有者是访问该表的唯一事务。由DROP TABLE、TRUNCATE、REINDEX、CLUSTER、VACUUM FULL和REFRESH MATERIALIZED VIEW（不带CONCURRENTLY）命令获取。ALTER TABLE的某些命令也在会获得这种锁。同时，显式发出LOCK TABLE命令的默认锁模式也是该八级锁。
	冲突级别：所有
	
	值得注意的是savepoint之后获得的锁，在回退到保存点之前后该锁也会被事务释放。

# 锁冲突实验
	下面做几个小实验验证一下锁冲突。

	1.加列和查询冲突
	会话1：
	postgres=# begin ;
	BEGIN
	postgres=# select * from test;
	id
	----
	1
	(1 rows)
	
	会话2：
	postgres=# begin;
	BEGIN
	postgres=# alter table test add column a int;
	
	
	查询锁状态：
	postgres=# select l.locktype,l.relation,l.pid,l.mode,l.granted,p.query_start,p.query,p.state from pg_locks l,pg_stat_activity p where l.locktype='relation' and l.pid=p.pid and query not like '%pg_stat_activity%';        
	locktype | relation |  pid   |        mode         | granted |          query_start          |               query                |        state        
	----------+----------+--------+---------------------+---------+-------------------------------+------------------------------------+---------------------
	relation |    16782 | 500821 | AccessShareLock     | t       | 2020-06-20 09:42:21.338529+08 | select * from test;                | idle in transaction
	relation |    16782 | 502255 | AccessExclusiveLock | f       | 2020-06-20 09:43:08.922259+08 | alter table test add column a int; | active
	(2 rows)
	
	2.读写互不阻塞
	会话1：
	postgres=# begin;
	BEGIN
	postgres=# update test set id=2;
	UPDATE 1
	
	会话2：
	postgres=# select * from test;
	id
	----
	1
	(1 row)
	
	查询锁状态：
	postgres=# select l.locktype,l.relation,l.pid,l.mode,l.granted,p.query_start,p.query,p.state from pg_locks l,pg_stat_activity p where l.locktype='relation' and l.pid=p.pid and query not like '%pg_stat_activity%';
	locktype | relation |  pid   |       mode       | granted |          query_start          |         query         |        state        
	----------+----------+--------+------------------+---------+-------------------------------+-----------------------+---------------------
	relation |    16782 | 429476 | RowExclusiveLock | t       | 2020-06-20 12:35:15.523242+08 | update test set id=2; | idle in transaction
	relation |    16782 | 429965 | AccessShareLock  | t       | 2020-06-20 12:35:26.266669+08 | select * from test;   | idle in transaction
	(2 rows)
	
	3.在线创建索引
	会话1：
	postgres=# begin;
	BEGIN
	postgres=# select * from test;
	id
	----
	1
	(1 row)
	
	会话2：
	postgres=# create index concurrently on test(id);
	CREATE INDEX
	发现直接创建成功了，锁等待视图里面也没有相关信息。
	
	会话1：
	postgres=# begin;
	BEGIN
	postgres=# update test set id=2;
	UPDATE 1
	
	会话2：
	postgres=# create index concurrently on test(id);
	
	
	发现hang了，查看锁视图：
	postgres=# select l.locktype,l.relation,l.pid,l.mode,l.granted,p.query_start,p.query,p.state from pg_locks l,pg_stat_activity p where l.locktype='relation' and l.pid=p.pid and query not like '%pg_stat_activity%';
	locktype | relation |  pid   |           mode           | granted |          query_start          |                 query                  |        state        
	----------+----------+--------+--------------------------+---------+-------------------------------+----------------------------------------+---------------------
	relation |    16782 | 156109 | ShareUpdateExclusiveLock | t       | 2020-06-20 13:33:36.050598+08 | create index concurrently on test(id); | active
	relation |    16782 | 158346 | RowExclusiveLock         | t       | 2020-06-20 13:33:31.494708+08 | update test set id=2;                  | idle in transaction
	(2 rows)
	
	这里其实原因我上一篇文章专门介绍过，是因为先开启的会话1，造成长事务，引起会话2的创建索引事务等待。如果在一个大表上先直接并发创建索引，再update该表，基本是不会阻塞的（可能阻塞的原因是在创建索引的第二阶段获取快照之前有长事务未结束）。
	
	
	4.两个字段同时创建索引
	会话1：
	postgres=# begin;
	BEGIN
	postgres=# create index on test(id);
	CREATE INDEX
	
	会话2：
	postgres=# begin;
	BEGIN
	postgres=# create index on test(a);
	CREATE INDEX
	
	查询锁状态：
	postgres=# select l.locktype,l.relation,l.pid,l.mode,l.granted,p.query_start,p.query,p.state from pg_locks l,pg_stat_activity p where l.locktype='relation' and l.pid=p.pid and query not like '%pg_stat_activity%' and l.relation=16782;
	locktype | relation |  pid   |   mode    | granted |          query_start          |           query           |        state        
	----------+----------+--------+-----------+---------+-------------------------------+---------------------------+---------------------
	relation |    16782 | 156109 | ShareLock | t       | 2020-06-20 13:43:10.719273+08 | create index on test(a);  | idle in transaction
	relation |    16782 | 158346 | ShareLock | t       | 2020-06-20 13:42:35.576189+08 | create index on test(id); | idle in transaction
	(2 rows)
	
	5.在线维护类操作自排他
	会话1：
	postgres=# begin;
	BEGIN
	postgres=# analyze test;
	ANALYZE
	
	会话2：
	postgres=# create index concurrently on test(id);
	
	
	查询锁状态：
	postgres=# select l.locktype,l.relation,l.pid,l.mode,l.granted,p.query_start,p.query,p.state from pg_locks l,pg_stat_activity p where l.locktype='relation' and l.pid=p.pid and query not like '%pg_stat_activity%' and l.relation=16782;
	locktype | relation |  pid   |           mode           | granted |          query_start          |                 query                  |        state        
	----------+----------+--------+--------------------------+---------+-------------------------------+----------------------------------------+---------------------
	relation |    16782 | 156109 | ShareUpdateExclusiveLock | f       | 2020-06-20 13:56:21.525695+08 | create index concurrently on test(id); | active
	relation |    16782 | 158346 | ShareUpdateExclusiveLock | t       | 2020-06-20 13:55:24.686202+08 | analyze test;                          | idle in transaction
	(2 rows)
	
