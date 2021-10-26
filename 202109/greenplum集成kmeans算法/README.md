
# 参考资料
| 序列 | 标题 | 连接 |
|:----:|:----:|:----:|
| 1 | kmeans-postgresql | https://www.cybertec-postgresql.com/en/how-to-run-a-clustering-algorithm-within-postgresql/ |
| 2 | k-means 聚类 | https://blog.csdn.net/huangfei711/article/details/78480078 |
| 3 | PostgreSQL数据聚类——kmeans | https://blog.csdn.net/weixin_39540651/article/details/105576554 |


# 下载并编译
```shell
git clone git@github.com:cybertec-postgresql/kmeans-postgresql.git
cd  kmeans-postgresql
sudo  make  install

# 如果遇到错误，请查看常见错误
```

# 使用kmeans聚类算法函数
```shell
# 创建kmeans数据库
psql -U postgres -c "create database  kmeans";
psql -U user -d kmeans -f $KMEANS_HOME/kmeans--1.1.0.sql
```

```sql
# 加载数据到数据库中
psql -U user -d kmeans
kmeans=> CREATE TABLE testdata(val1 float, val2 float, val3 float);
kmeans=> \COPY testdata FROM '$KMEANS_HOME/data/testdata.txt' ( FORMAT CSV, DELIMITER(' ') );
kmeans=> SELECT kmeans(ARRAY[val1, val2], 5) OVER (), val1, val2 FROM testdata limit 10;
 kmeans |   val1    |   val2
--------+-----------+-----------
      3 |  0.504542 |  -0.28573
      2 |  1.056364 |  0.601873
      0 |  1.095326 | -1.447579
      1 | -0.210165 |  0.000284
      0 |  0.868013 | -1.063465
      0 |  0.598389 | -1.477808
      3 |  0.580927 | -0.783898
      0 |  0.331843 | -1.869486
      1 | -1.243951 |  1.005355
      4 |  1.181748 |  1.523744
(10 rows)


# kmeans的聚类算法
kmeans=> SELECT kmeans(ARRAY[val1, val2], 2) OVER (partition by val1 > 0), val1, val2 FROM testdata  limit 10;

 kmeans |   val1    |   val2
--------+-----------+-----------
      1 | -0.183497 |  1.416116
      1 | -1.016254 |  0.651607
      0 | -0.210165 |  0.000284
      1 | -0.116477 |  0.437483
      1 | -0.385261 |  0.278145
      0 | -0.119082 |  -0.00402
      0 | -1.251554 | -0.176027
      1 | -0.000228 |  0.347187
      0 |  -0.23825 | -1.277484
      0 | -0.367151 | -1.255189
(10 rows)
```

# 使用案例
```sql
create table t1(c1 int,c2 int,c3 int,c4 int);
insert into t1 select 100*random(),1000*random(),100*random(),10000*random() from generate_series(1,100000);
select kmeans(array[c1,c2,c3],2,array[1,2,3,4,5,6]) over() , * from t1 limit 10;
select kmeans(array[c1,c2,c3],3,array[[1,1,1],[2,2,2],[3,3,3]]) over() ,* from t1 limit 10;
```

# 常见问题
```shell
/usr/include/libxml2  -I/tmp/build/matrixdb/gpAux/ext/rhel7_x86_64/include  -c -o kmeans.o kmeans.c
cc1: error: -Werror=implicit-fallthrough=3: no option -Wimplicit-fallthrough=3
cc1: warning: unrecognized command line option "-Wno-format-truncation" [enabled by default]
make: *** [kmeans.o] Error 1

使用一下命令编译
make CFLAGS='-Wno-format-truncation'
```







