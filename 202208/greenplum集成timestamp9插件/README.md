# timestamp9 编译安装


## 编译环境
```
$ cat /etc/redhat-release
CentOS Linux release 7.9.2009 (Core)

$ uname  -a
Linux mdw 3.10.0-1160.el7.x86_64 #1 SMP Mon Oct 19 16:18:59 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```

## 编译条件
```
1、gcc 大于4.8.5, 大约4.8.5 才有需要的-Werror=implicit-fallthrough=3 选项。
2、g++ 大于, 与gcc 与相同的版本。
3、cmake 需要使用3.6.2 版本。
4、需要安装rpm-build，安装方式：sudo yum install rpm-build -y

```
> gcc 在线安装方式
```
https://blog.csdn.net/b_ingram/article/details/121569398
```

## 编译步骤

### 源码下载并编译
```
$ git clone https://github.com/fvannee/timestamp9.git
$ cd timestamp9
# sh build.sh
```

## 安装timestamp9插件
```
1、按照步骤编译完成后，在当前的目录下会有timestamp9-PG12-1.4.0-1.x86_64.rpm文件。
2、需要在集群的每台机器上安装。
```

### 安装方式
```
-- 安装timestamp9
$ sudo rpm -ivh timestamp9-PG12-1.4.0-1.x86_64.rpm
Preparing...                          ################################# [100%]
Updating / installing...
   1:timestamp9-pg12-1.4.0-1          ################################# [100%]


-- 查看安装的路径
$ rpm -ql timestamp9-pg12-1.4.0-1
/user/local/greenplum/lib/postgresql/timestamp9.so
/user/local/greenplum/share/postgresql/extension/timestamp9--0.1.0--0.2.0.sql
/user/local/greenplum/share/postgresql/extension/timestamp9--0.2.0--0.3.0.sql
/user/local/greenplum/share/postgresql/extension/timestamp9--0.3.0--1.0.0.sql
/user/local/greenplum/share/postgresql/extension/timestamp9--1.0.0--1.0.1.sql
/user/local/greenplum/share/postgresql/extension/timestamp9--1.0.1--1.1.0.sql
/user/local/greenplum/share/postgresql/extension/timestamp9--1.1.0--1.2.0.sql
/user/local/greenplum/share/postgresql/extension/timestamp9--1.2.0--1.3.0.sql
/user/local/greenplum/share/postgresql/extension/timestamp9--1.3.0--1.4.0.sql
/user/local/greenplum/share/postgresql/extension/timestamp9--1.4.0.sql
/user/local/greenplum/share/postgresql/extension/timestamp9.control


-- 每台机器进行校验
$ gpssh -f all_seg -e "rpm -ql timestamp9-pg12-1.4.0-1"

```

## 使用timestamp9
```
$ psql postgres
Timing is on.
psql (12)
Type "help" for help.

postgres=# create extension timestamp9;
CREATE EXTENSION
Time: 25117.889 ms (00:25.118)
postgres=#
postgres=# select 0::bigint::timestamp9;
             timestamp9
-------------------------------------
 1970-01-01 08:00:00.000000000 +0800
(1 row)

Time: 2481.235 ms (00:02.481)
```




