# greenplum 对连接池pgbouncer的使用

pgbouncer详情请查看:https://www.linkedin.com/pulse/scaling-greenplum-pgbouncer-sandeep-katta-/?articleId=6128769027482402816

# 目录结构
	1 pgbouncer 介绍
		1.1 greenplum对pgbouncer的介绍
		1.2 pgbouncer 官网介绍
		1.3 中文介绍pgbouncer的使用
	2 配置pgbouncer连接池
		2.1 创建PgBouncer需要的配置文件
		2.2 创建users.txt用户名与密码映射文件
	3 启动pgBouncer连接池
		3.1 查看pgbouncer参数
		3.2 启动pgbouncer连接池
		3.3 链接测试
	4  unsupported startup parameter: extra_float_digits 问题解答

# 说明
	pool_mode支持三种连接池模型:
	1、Session pooling:当一个客户端连接时，只要它保持连接状态，就分配给它一个连接。当该客户端断开连接时，该连接才被放回到池中。
	2、Transaction pooling: 在一个事务运行期间，分配一个连接给客户端。当PgBouncer发现事务完成，该连接就被放回到池中。这种模式只能被用于不使用依赖于会话的特性的应用。
	3、Statement pooling:语句池化类似于事务池化，但是不允许多语句事务。这种模式的目标是为了在客户端强制自动提交模式，且它的定位是PostgreSQL上的PL/Proxy
# 1 pgbouncer 介绍
## 1.1 greenplum对pgbouncer的介绍
	https://gpdb.docs.pivotal.io/43240/utility_guide/admin_utilities/pgbouncer-ref.html

## 1.2 pgbouncer 官网介绍
	http://www.pgbouncer.org/

## 1.3 中文介绍pgbouncer的使用
	https://gp-docs-cn.github.io/docs/admin_guide/access_db/topics/pgbouncer.html
	
# 2 配置pgbouncer连接池
	pgbouncer可以配置在运行在Greenplum数据库的master上或另一台机器上，用户最好运行在Greenplum数据库的master上。

## 2.1 创建PgBouncer需要的配置文件
	创建pgbouncer.ini文件，格式如下:
	[databases]
	postgres = host=192.168.***.** port=54** dbname=postgres  pool_mode=statement
	mydb = host=192.168.***.** port=54** dbname=mydb pool_mode=transaction
	testdb = host=192.168.***.**  port=54** dbname=mydb pool_mode=transaction user=dbuser  password=yourpassword connect_query='SELECT 1'
	[pgbouncer]
	pool_mode = session
	listen_port = 6540
	listen_addr = 192.168.***.**
	auth_type = md5
	auth_file = users.txt
	logfile = pgbouncer.log
	pidfile = pgbouncer.pid
	admin_users = gpadmin
	default_pool_size = 100
	max_client_conn = 300
	
	
	说明
	1、postgres/mydb 分别是数据库的名字,可以配置多个
	2、auth_type 有md5和plain和trust方式
	3、default_pool_size：默认池大小，表示建立多少个pgbouncer到数据库的连接。
	4、max_client_conn：最大连接用户数，客户端到pgbouncer的链接数量。
	5、pool_mode支持三种连接池模型：
		session，会话级连接，连接生命周期里，连接池分配一个数据库连接，客户端断开连接时，连接放回连接池。
		transaction， 事务级连接，客户端的每个事务结束时，数据库连接就会重新释放回连接池，在执行一个事务时，就需要从连接池重新获得一个连接。
		statement，语句级别连接 ，执行完一个SQL语句时，连接就会释放回连接池，再次执行一个SQL语句时，需要重新从连接池里获取连接，这种模式意味客户端需要强制“autocommit”模式。

	
## 2.2 创建users.txt用户名与密码映射文件
	1、创建一个认证文件。该文件的名称必须匹配pgbouncer.ini文件中的 auth_file参数，在这个例子中是 users.txt。每一行包含一个用户名和口令。口令串的格式匹配PgBouncer配置文件中的auth_type参数。如果auth_type参数是plain，口令串就是一个明文口令，例如：
	"gpadmin" "gpadmin1234"
	
	2、下面例子中的auth_type是md5，因此认证域必须被MD5编码。被MD5编码的口令格式是：
	"md5" + MD5(<password><username>)
	
	3、用户可以使用Linux的md5sum命令来计算MD5串。例如，如果gpadmin的口令是admin1234，下面的命令会打印用于口令域的字符串：
	$ user=gpadmin; passwd=admin1234; echo -n md5; echo $passwd$user | md5sum
	md53ce96652dedd8226c498e09ae2d26220
	
	4、这里是PgBouncer认证文件中用于gpadmin用户的MD5编码过的条目：
	"gpadmin" "md53ce96652dedd8226c498e09ae2d26220"
	
	5、查看pg_shadow表里面保存的密码
	select usename,passwd from pg_shadow order by 1;
	
	导出用户名和密码并修改成以上的格式
	copy (select usename, passwd from pg_shadow order by 1) to 'saveFilePath';
	
	
# 3 启动pgBouncer连接池

## 3.1 查看pgbouncer参数
	Usage: pgbouncer [OPTION]... config.ini
	-d, --daemon           在后台运行
	-R, --restart          重新启动
	-q, --quiet            不带提示的运行
	-v, --verbose          更详细的运行
	-u, --user=<username>  制定username运行
	-V, --version          显示版本
	-h, --help             显示帮助并退出
  
## 3.2 启动pgbouncer连接池
	pgbouncer -d  pgbouncer.ini
	2019-11-27 17:03:19.024 108629 LOG File descriptor limit: 524288 (H:524288), max_client_conn: 100, max fds possible: 150
	2019-11-27 17:03:19.025 108629 LOG Stale pidfile, removing
	2019-11-27 17:03:19.025 108629 LOG listening on 192.168.***.**:65**
	2019-11-27 17:03:19.025 108629 LOG listening on unix:/tmp/.s.PGSQL.65**
	2019-11-27 17:03:19.025 108629 LOG process up: pgbouncer 1.8.1, libevent 1.4.6-stable (epoll), adns: evdns1, tls: OpenSSL 1.0.2l-fips  25 May 2017

	1、在以上显示了最大的连接数,以及最大的fds
	2、显示了启动的基本信息
	3、显示了pgbouncer的版本信息
	4、-d 参数是后台启动


## 3.3 链接测试

	$psql -p 6540 -U gpadmin mydb
	
	在链接事日志中会显示以下信息
	2019-11-27 17:06:51.470 109039 LOG C-0x71c830: mydb/gpadmin@192.168.***.**:27115 login attempt: db=mydb user=gpadmin tls=no
	2019-11-27 17:06:51.470 109039 LOG C-0x71c830: mydb/gpadmin@192.168.***.**:27115 closing because: client unexpected eof (age=0)
	2019-11-27 17:06:53.870 109039 LOG C-0x71c830: mydb/gpadmin@192.168.***.**:27117 login attempt: db=mydb user=gpadmin tls=no
	2019-11-27 17:06:53.870 109039 LOG S-0x721670: mydb/gpadmin@192.168.***.**:5432 new connection to server (from 192.168.***.**:43271)
	2019-11-27 17:07:47.688 109039 LOG Stats: 0 xacts/s, 0 queries/s, in 0 B/s, out 0 B/s, xact 0 us, query 0 us wait time 181 us
	2019-11-27 17:15:02.545 109039 LOG S-0x721990: mydb/gpadmin@192.168.***.**:5432 new connection to server (from 192.168.***.**:43429)
	
	在以上日志中可以看出
	1、有一个login与closing的一个连接
	2、有一个新的链接是在43271端口与43429与greenplum的5432进行连接

# 4  unsupported startup parameter: extra_float_digits
[unsupported startup parameter: extra_float_digits 问题解答](https://blog.csdn.net/cdnight/article/details/90476382)



