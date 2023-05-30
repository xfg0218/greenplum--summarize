# 恢复所有设置
```
-- reset all;

postgres=# show statement_mem ;
 statement_mem
---------------
 125MB
(1 row)

postgres=# set  statement_mem to '512MB';
postgres=# reset all;
postgres=# show statement_mem ;
 statement_mem
---------------
 125MB
(1 row)

postgres=#

```

# 只输出内容
```
$ psql -d postgres -AXtc "select 1 + 1"
2

```

# 导出CSV个数的数据
```
$ psql -d postgres --csv -c "select * from table_name limit 3"
id,name
64,edefe
64,edefe
23,edefe

```

# 使用-H选项，生成 html格式的结果
```
$ psql -d postgres -H -c "select * from table_name limit 3"

<table border="1">
  <tr>
    <th align="center">id</th>
    <th align="center">name</th>
  </tr>
  <tr valign="top">
    <td align="right">64</td>
    <td align="left">edefe</td>
  </tr>
  <tr valign="top">
    <td align="right">64</td>
    <td align="left">edefe</td>
  </tr>
  <tr valign="top">
    <td align="right">23</td>
    <td align="left">edefe</td>
  </tr>
</table>
<p>(3 rows)<br />
</p>

```

# 不显示字段名
```
$ psql -d postgres -t -c "select * from table_name limit 3"
 55 | edefe
  2 | edefe
 39 | edefe

```


# 显示元命令的查询语句
```
psql -d postgres -E -c '\l+'
********* QUERY **********
SELECT d.datname as "Name",
       pg_catalog.pg_get_userbyid(d.datdba) as "Owner",
       pg_catalog.pg_encoding_to_char(d.encoding) as "Encoding",
       d.datcollate as "Collate",
       d.datctype as "Ctype",
       pg_catalog.array_to_string(d.datacl, E'\n') AS "Access privileges",
       CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
            THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
            ELSE 'No Access'
       END as "Size",
       t.spcname as "Tablespace",
       pg_catalog.shobj_description(d.oid, 'pg_database') as "Description"
FROM pg_catalog.pg_database d
  JOIN pg_catalog.pg_tablespace t on d.dattablespace = t.oid
ORDER BY 1;
**************************

                                                                 List of databases
   Name    |  Owner  | Encoding |  Collate   |   Ctype    |  Access privileges  |  Size  | Tablespace |                Description
-----------+---------+----------+------------+------------+---------------------+--------+------------+--------------------------------------------
 postgres  | mxadmin | UTF8     | en_US.utf8 | en_US.utf8 |                     | 304 MB | pg_default | default administrative connection database
 template0 | mxadmin | UTF8     | en_US.utf8 | en_US.utf8 | =c/mxadmin         +| 131 MB | pg_default | unmodifiable empty database
           |         |          |            |            | mxadmin=CTc/mxadmin |        |            |
 template1 | mxadmin | UTF8     | en_US.utf8 | en_US.utf8 | =c/mxadmin         +| 131 MB | pg_default | default template for new databases
           |         |          |            |            | mxadmin=CTc/mxadmin |        |            |
(4 rows)
```


# 在执行计划中显示正在执行的SQL
```
$ psql -d postgres -e -c "select 1 + 1"
select 1 + 1
 ?column?
----------
        2
(1 row)
```

# 设置环境变量
```
-- 设置密码的环境变量
export PGDATABASE=mydb

```

# 简化版的psql 客户端
```
$ psql -d postgres -q
postgres=# select 1 + 1;
 ?column?
----------
        2
(1 row)
```


# 使用PSQL客户端按照指定行数返回
```
-- 处理可能较大的结果集按照指定的结果返回

\set FETCH_COUNT 200

```

# 设置PSQL时间
```
postgres=# \timing
Timing is on.

postgres=# select 1 + 1;
 ?column?
----------
        2
(1 row)

Time: 2.457 ms

-- 永久设置
vim ~/.psqlrc
\timing

```

# 加载shared_preload_libraries扩展
```
postgres=# load 'auto_explain';
LOAD
Time: 29.860 ms
postgres=# show auto_explain.log_min_duration ;
 auto_explain.log_min_duration
-------------------------------
 -1
(1 row)

Time: 0.545 ms
```

# 对数据库设置时区
```
postgres=# show  timezone;
     TimeZone
------------------
 America/New_York
(1 row)

Time: 0.488 ms
postgres=# ALTER DATABASE postgres SET timezone = 'Asia/Shanghai';
ALTER DATABASE
Time: 6.605 ms


postgres=# SET timezone = 'Asia/Shanghai';
SET
Time: 1.619 ms
postgres=# show  timezone;
   TimeZone
---------------
 Asia/Shanghai
(1 row)

Time: 0.403 ms



```








