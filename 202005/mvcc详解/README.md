# PostgreSQL中的多版本并发控制-MVCC目录
	1 PostgreSQL中的多版本并发控制-MVCC	1
	1.1 为什么需要MVCC	1
	1.2 不同的MVCC机制	1
	1.3 MVCC 设计的几个概念	1
	1.4 MVCC的工作机制	2
		1.1.1 插入数据实例	2
		1.1.2 修改数据实例	3
		1.1.3 删除数据实例	4
		1.1.4 数据操作总结来说	5
	1.5 MVCC 的优缺点	6
		1.5.1 优点	6
		1.5.2 缺点	6
		
# 1 PostgreSQL中的多版本并发控制-MVCC
	MVCC , Multi - Version Concurrency Control , 多版本控制并发

## 1.1 为什么需要MVCC
	数据库在并发操作下，如果数据正在写，而用户又在读，可能会出现数据不一致的问题，
	比如一行数据只写入了前半部分，后半部分还没有写入，而此时用户读取这行数据时就会出现前半部分是新数据，
	后半部分是旧数据的现象，造成前后数据不一致问题，解决这个问题最好的方法就是读写加锁，写的时候不允许读，
	读的时候不允许写，不过这样就降低了数据库的并发性能，因此便引入了MVCC的概念，
	它的目的便是实现读写事务相互不阻塞，从而提高数据库的并发性能。
	
## 1.2 不同的MVCC机制
	实现MVCC的机制有两种:
	1、写入数据时，把旧版本数据移到其他地方，如回滚等操作，在回滚中把数据读出来。
	2、写入数据库时，保留旧版本的数据，并插入新数据
	
	像oracle数据库使用的是第一种方式，postgresql使用的是第二种方式。

## 1.3 MVCC 设计的几个概念
	1、事务ID
	在postgresql中，每个事务都存在一个唯一的ID，也称为xid,可通过txid_current()函数获取当前的事务ID
	
	2、tupe
	每一行数据，称为一行元祖，一个tupe
	
	3、ctid
	tuple中的隐藏字段，代表tuple的物理位置
	
	4、xmin
	tuple 中的隐藏字段，在创建一个tuple时，记录此值为当前的事务ID
	
	5、xmax
	tuple 中的隐藏字段，默认为0，在删除时，记录此值为当前的事务的ID
	
	6、cmin/cmax
	tuple中的隐藏字段，表示同一个事务中多个语句的顺序，从0开始
	
## 1.4 MVCC的工作机制
	Postgresql中的MVCC就是通过以上几个隐藏字段协作同实现的，下面举几个例子来看下工作机制

### 1.4.1 插入数据实例
	1、首先我们开启事务插入一条数据，其中ctid代表数据的物理位置，xmin为当前事务ID，xmax为0
	
	postgres=# create table test(id int,name varchar(50));
	CREATE TABLE
	postgres=# begin transaction;
	BEGIN
	postgres=# select txid_current();
	txid_current 
	--------------
			535
	(1 row)
	
	postgres=# insert into test(id,name) values(1,'a');
	INSERT 0 1
	postgres=# insert into test(id,name) values(2,'b');
	INSERT 0 1
	postgres=# select ctid,xmin,xmax,cmin,cmax,* from test;
	ctid  | xmin | xmax | cmin | cmax | id | name 
	-------+------+------+------+------+----+------
	(0,1) |  535 |    0 |    0 |    0 |  1 | a
	(0,2) |  535 |    0 |    1 |    1 |  2 | b
	(2 rows)
	
	postgres=# commit;
	COMMIT
	postgres=# select ctid,xmin,xmax,cmin,cmax,* from test;
	ctid  | xmin | xmax | cmin | cmax | id | name 
	-------+------+------+------+------+----+------
	(0,1) |  535 |    0 |    0 |    0 |  1 | a
	(0,2) |  535 |    0 |    1 |    1 |  2 | b
	(2 rows)
	
	继续在上一个事务中再插入一条数据，因为在同一个事务中，可以看到cmin，cmax按顺序增长
	
### 1.4.2 修改数据实例

	修改ID为1的数据name为d,此时ID为1的ctid变为了(0,4),同时开启另外一个窗口，
	可以看到ID为1的xmax标识为修改数据时的事务ID，既代表词条tuple已删除。
	
	-- 第一个窗口
	postgres=# insert into test(id,name) values(3,'c');
	
	postgres=# begin transaction;
	BEGIN
	postgres=# select txid_current();
	txid_current 
	--------------
			537
	(1 row)
	
	postgres=# update test set name = 'd' where id ='1';
	UPDATE 1
	postgres=# select ctid,xmin,xmax,cmin,cmax,* from test;
	ctid  | xmin | xmax | cmin | cmax | id | name 
	-------+------+------+------+------+----+------
	(0,2) |  535 |    0 |    1 |    1 |  2 | b
	(0,3) |  536 |    0 |    0 |    0 |  3 | c
	(0,4) |  537 |    0 |    0 |    0 |  1 | d
	(3 rows)
	
	-- 第二个窗口
	postgres=# begin transaction;
	BEGIN
	postgres=# select txid_current();
	txid_current 
	--------------
			538
	(1 row)
	
	postgres=# select ctid,xmin,xmax,cmin,cmax,* from test;
	ctid  | xmin | xmax | cmin | cmax | id | name 
	-------+------+------+------+------+----+------
	(0,1) |  535 |  537 |    0 |    0 |  1 | a
	(0,2) |  535 |    0 |    1 |    1 |  2 | b
	(0,3) |  536 |    0 |    0 |    0 |  3 | c
	(3 rows)
	
	第一个窗口connit后在第二个窗口查询显示
	postgres=# select ctid,xmin,xmax,cmin,cmax,* from test;
	ctid  | xmin | xmax | cmin | cmax | id | name 
	-------+------+------+------+------+----+------
	(0,2) |  535 |    0 |    1 |    1 |  2 | b
	(0,3) |  536 |    0 |    0 |    0 |  3 | c
	(0,4) |  537 |    0 |    0 |    0 |  1 | d
	(3 rows)
	
### 1.4.3 删除数据实例

	删除ID为1的数据,另开启一个窗口，可以看到ID为1的xmax为删除操作的事务ID,
	代表此条tuple删除。
	
	
	-- 第一个窗口操作如下
	postgres=# begin transaction;
	BEGIN
	postgres=# select txid_current();
	txid_current 
	--------------
			539
	(1 row)
	
	postgres=# delete from test where id = 1;
	DELETE 1
	postgres=# select ctid,xmin,xmax,cmin,cmax,* from test;
	ctid  | xmin | xmax | cmin | cmax | id | name 
	-------+------+------+------+------+----+------
	(0,2) |  535 |    0 |    1 |    1 |  2 | b
	(0,3) |  536 |    0 |    0 |    0 |  3 | c
	(2 rows)
	
	
	-- 第二个窗口操作如下
	postgres=# begin transaction;
	BEGIN
	postgres=# select txid_current();
	txid_current 
	--------------
			541
	(1 row)
	
	postgres=# select ctid,xmin,xmax,cmin,cmax,* from test;
	ctid  | xmin | xmax | cmin | cmax | id | name 
	-------+------+------+------+------+----+------
	(0,2) |  535 |    0 |    1 |    1 |  2 | b
	(0,3) |  536 |    0 |    0 |    0 |  3 | c
	(0,4) |  537 |  539 |    0 |    0 |  1 | d
	(3 rows)
	
	
	-- 第一个窗口提交事务,第二个不提交事务,查看第二个窗口的数据信息
	
	-- 第一个窗口操作
	postgres=# commit;
	COMMIT
	
	-- 查看第二个窗口信息
	postgres=# select ctid,xmin,xmax,cmin,cmax,* from test;
	ctid  | xmin | xmax | cmin | cmax | id | name 
	-------+------+------+------+------+----+------
	(0,2) |  535 |    0 |    1 |    1 |  2 | b
	(0,3) |  536 |    0 |    0 |    0 |  3 | c
	(2 rows)
	
	
### 1.4.4 数据操作总结来说

	1、数据文件中同一逻辑行存在多个版本
	2、每个版本通过隐藏字段记录着它的创建事务的ID，删除事务ID等信息
	3、通过一定的逻辑保证每个事务能够看到一个特定的版本
	读写事务工作在不同的版本上，以保证读写不冲突。
	
	
## 1.5 MVCC 的优缺点

### 1.5.1 优点
	1、由于旧版本数据不在回滚段中，如果发生事务回滚，可以立即完成，无论事务的大小。
	2、数据可以进行大批量更新，不用担心回滚段被耗光
	
### 1.5.2 缺点
	1、旧版本的数据量大会影响查询效率
	2、旧版本的数据需要定时清理
	3、事务ID的储存是32bit,如果超出这个限制便会发生事务回滚，这样新事务就无法访问旧的记录了。
	为了解决MVCC带了的问题，postgresql引入了vacuum功能，它可以利用因更新或删除操作而被标记为删除
	的磁盘空间，同时也能保证事务ID不被用光而造成历史数据的丢失。
	
	