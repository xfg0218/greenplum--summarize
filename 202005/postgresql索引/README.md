# 索引介绍
## 索引的简单介绍
	1、在关系数据库中，索引是一种单独的，物理的对数据库表中一列或多列的值进行排序的一种储存结构，
	它是某个表中一列或若干列值的集合和相对应的指向表中物理标识这些值的数据页的逻辑指针清单。
	2、索引的作用相当于图书的目录，可以根据目录中的页码快速查找到所需要的内容。

## 索引常用参数
	unique : 创建唯一索引
	concurrently : 在线创建索引，不会阻塞读写操作
	using method : 默认为btree
	asc /desc 排序，默认升序

## 创建索引的方法
	CREATE [ UNIQUE ] INDEX [ CONCURRENTLY ] [ name ] ON table_name [ USING method ]
		( { column_name | ( expression ) } [ COLLATE collation ] [ opclass ] [ ASC | DESC ] [ NULLS { FIRST | LAST } ] [, ...] )
		[ WITH ( storage_parameter = value [, ... ] ) ]
		[ TABLESPACE tablespace_name ]
		[ WHERE predicate ]

## 查看已经使用的索引
	select * from pg_am;
	
## 常用索引类型及使用场景

	btree
	1、=,>,>=,<,<=,排序
	2、范围和等值查询
	3、等效这些操作的其他操作例如:BETWEEN,IN以及IS NULL和字符串开头的模糊查询,
	btree索引要想起作用where条件必须包含第一个索引列
	4、如果创建组合索引使用where时and性能会大于or,如果两列上单独创建索引or查询的性能会比and性能快
	5、基于模式匹配时如like或~时,仅当模式存在一个变量时并且常量位于模式字符串的开头,
	索引才会生效，例如where col like ‘foo%’或where ~ ‘^foo’时生效，否则会全表扫描 


	hash(KEY值为HASH值,可以适合很长的字符串)
	1、=
	
	
	gin
	1、多值类型(数组，全文检索,枚举，网络地址类型),包含，相交
	2、JSON类型
	3、普通类型(通过btree_gin插件支持)与btree类似
	4、字符串(通过pg_trgm插件支持):模糊查询，相似查询
	5、多列:任意列组合查询
	6、也叫倒排索引
	
	
	gist
	1、空间类型:方位(上，下，左，右)，空间关系(相交，包含)，空间距离排序(KNN)
	2、范围函数:=,&&,<@,@>,<<,>>,-|-,&<, and &>
	3、普通类型(通过btree_gist插件支持)与b-tree类似，增加空间类型类似操作符
	4、数组类型(通过intarray插件支持);与GIN类似
	5、多列:任意列组合查询
	
	spgist
	1、平面几何类型,与GIST类似
	2、范围类型:与GIST类似
	
	brin
	1、适合线性数据，时序数据(HEAP  PAGE 之间便捷清洗的数据)
	2、普通类型:与B-Tree类似
	3、空间类型:包含
	4、占用的空间储存比较小
	
	rum
	1、多值类型(数组，全文检索):包含，相交，相似排序
	2、普通类型:与B-Tree相似
	
	bloom
	多列:任意列自合，等值查询
	
	
	zombodb
	1、可以把索引创建到es数据库中，实现数据和索引分开
	2、返回的数据是毫秒级的，几乎是无延时
	
	partial index
	1、支持分区索引
	
	range
	时序数据范围检索索引
	
	
## 不同的索引类型及使用场景

###  btree索引使用场景
	btree索引的组织是有序的,表里面的字段ID数据是无序的,创建索引后就是有序的。可以做范围查询,等值查询,排序查询。特点索引比较大，是和表的大小几乎相同的,在插入时的速度会很慢，原因在与索引的数据需要排序，结构是双链表，所以做条件查询比较快。Is null 数值也可以储存在索引中。Postgresql默认的索引是btree索引。
	
	1、<
	2、<=
	3、=
	4、>=
	5、>
	6、between ... and ...
	7、In
	8、排序
	
	btree索引实例
	-- 创建表
	create  table t_btree(id  int , info  text);
	
	create index 	idx_ttl on t_btree using btree (id);
	
	set enable_bitmapscan = off;
	
	explain ANALYSE select count(*) from t_btree where id = 1;
	
	-- 使用了全表扫描,原因是表中没有数据
	explain ANALYSE select count(*) from t_btree where id is not null;
	explain ANALYSE select count(*) from t_btree where id is null;
	
	-- 排序使用了索引
	explain ANALYSE select * from t_btree  order by id;
	explain ANALYSE select * from t_btree  order by id desc ;
	
	-- 范围索引
	explain ANALYSE select * from t_btree  where id > 10 ;

### hash索引的使用场景

	1、hash索引储存索引是key值为64位的哈希值，只支持等值(=)查询
	2、hash索引特别适用于字段value非常长(不适合b-tree左印,因为b-tree一个PAGE至少要储存3个ENYRY，
	所以不支持特别长的VALUE)的场景，例如很长的字符串，并且用户只需要等值搜索，建议使用hash index.
	
	-- hash索引使用案例
	create  table t_hash(id  int,info  text);
	-- 插入数据
	insert into t_hash  select generate_series(1,10000),repeat(md5(random()::text),10000);
	-- 创建hash索引
	create index i_hash_info on t_hash using hash(info);
	-- 使用的全表扫描
	explain analyze select * from t_hash t_hash where info = (select info from t_hash limit 1);
	6.3.3 gin索引的使用场景
	gin 是倒排索引，储存被索引字段的VALUE或VALUE的元素，以及行号的list或tree.
	1、当需要搜索多值类型内的VALUE时，适合多值类型，例如数组，全文检索，TOKEN(根据不同的类型，
	支持相交，包含，大于，在左边，在右边等搜索)
	2、当用户的数据比较稀疏时，如果要搜索某个VALUE的值，可以适应btree_gin
	支持普通btree支持的类型(支持btree的操作符)
	3、当用户需要按任意列进行搜索时，gin支持多列展开单独建立索引域,同时支持内部多域
	索引的bitmapAnd,bitmapOr合并，快速的返回任意列搜索请求的数据。


	gin索引实例
	-- gin索引使用案例
	-- sudo yum -y  install postgresql12-contrib
	
	create  table tt4(id int,c1 text);
	create extension pg_trgm;
	create index idx_ttd on tt4 using gin(c1 gin_trgm_ops);
	
	-- 开启位图索引扫描
	set enable_bitmapscan = on;
	
	-- 查看执行计划查看
	explain analyze select * from tt4 where c1 like '%abc%';
	explain analyze select * from tt4 where c1 ~ 'abc';

### gist索引的使用场景
	1、集合类型:方位(上,下,左,右),空间关系(包含，相交等),空间距离排序(KNN)
	2、范围数据: =, &&, <@, @>, <<, >>, -|-, &<, and & > 
	3、普通类型(通过btree_gist插件支持),与b-tree类似，增加空间类型操作符
	4、数组类型(通过intarray插件支持);与GIN类似
	5、多列:任意列组合查询
	
	gist索引实例
	create   table  t_gist(id  int,pos point);
	Insert into t_gist select generate_series(1,100000),point(round(random()*1000)::numeric,2),round(random()*1000::numeric,2));
	create  index i_gist_pos on t_gist using gist(pos);
	explain  analyze select * from t_gist where circle ‘((100,100)10)’@ > pos;
	
## 组合索引/条件索引/表达式索引

### 组合索引的使用

	btree
	B-tree多列索引支持任意列的组合查询，但是最有效的查询还是包含驱动列条件的查询
	
	gin
		gin多列索引支持任意列的组合查询，并且任意查询条件的查询效率都是一样的(不支持排序)
	
	gist
	驱动列的选择性决定了需要扫描多少索引条目，与非驱动列无关(而b-tree是非驱动列也有关的)。索引并不建议使用gist多列索引，如果一定要使用GIST多列索引，请一定把选择性好的列作为驱动列。
	
### 条件索引
	1、查询时，强制过滤掉某些条件
	2、create  index i1  on  t1  where c1!=1;
	
### 表达式索引
	1、查询条件为表达式时
	2、Select * from t2 where (a||’’||b) =’aaa bbb’
	3、Create index i2 on t2(a||’’||b)
	4、尽量不要把表达式，函数放到查询条件中
	
### Panner配置
	set  enable_bitmapscan = on
	set  enable_hasgagg = on
	set  enable_hashjoin = on
	set  enable_indexscan = on
	set  enable_material = on
	set  enable_mergejoin = on
	set  enable_nestloop = on
	set  enable_seqscan = on
	set  enable_sort = on
	set  enable_tidscan = on
	set  enable_tidscan = on
	
	使用实例
	set session enable_seqscan = off;
	
### 索引使用技巧
	1、在选择性较好的列上创建索引
	2、同一个表避免创建过多的索引
	3、建议在关联的外键字段上创建索引

	
### 索引使用技巧

	是否使用索引和什么有关系 ?
	1、能否走索引，是操作符是否支持对应的索引访问方法来决定的
	2、是否用索引是优化器决定的，如果走索引的成本低，可以走索引，如果使用了开关禁止全表扫描，也可以走索引
	
### 常见不走索引的情况
	1、数据类型不匹配，操作符不匹配
	2、where 子句进行表达式或函数操作
	3、like 的全模糊匹配(btree)
	4、数据占比
	5、表分析(vacuum  analyze)
	6、统计信息不准确
	7、random_page_cost设置过大
	8、索引字段上重复值过多选择性不好