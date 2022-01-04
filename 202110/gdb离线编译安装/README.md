# Centos7.x 离线安装gdb

## 软件下载
	链接: https://pan.baidu.com/s/1XrYmTL5kFYsfrzjZbGFnbw 提取码: tfg8

## 解压软件
``` shell
tar xf  texinfo-2.15.tar.gz
tar -zxvf gdb-7.6.1.tar.gz
tar -zxvf perl-5.34.0.tar.gz
tar -zxvf termcap-1.3.1.tar.gz
```

## 先编译termcap
``` shell
cd termcap-1.3.1/
./configure
make && make install 

```

## 编译gdb
``` shell
cd  gdb-7.6.1
./configure
make && make install
```


### 查看gdb的版本
``` shell
gdb --version
GNU gdb (GDB) 7.6.1
Copyright (C) 2013 Free Software Foundation, Inc.

```

## 常见问题
```
问题一： WARING:'makeinfo' is missing on your system
解决方式: 编译安装 texinfo-2.15

问题二：configure ：error:perl  >= 5.7.3 with Encode and Data::Dumper required by Texinfo
解决方式： 编译安装 perl-5.34.0
```


## 使用gdb
``` shell
gdb  `which postgres` PID
(gdb) bt
(gdb) p debug_query_string
(gdb) p print
(gdb) help all 


```


## core 打包语法
``` shell
分析core原因
gdb  `which postgres` /data/mxdata/primary/mxseg11/core.50912
查看core语句：p debug_query_string
分析原因：bt
退出：q

### 对core进行打包，默认的会保存在当前目录下
/usr/local/matrixdb/sbin/packcore -b collect --binary /usr/local/matrixdb/bin/postgres /data/mxdata/primary/mxseg11/core.50890

```



## 参考资料
	1、https://ftp.gnu.org/gnu/termcap/
	2、https://blog.csdn.net/xian_dao_zhang/article/details/119425809?utm_medium=distribute.pc_aggpage_search_result.none-task-blog-2~aggregatepage~first_rank_ecpm_v1~rank_v31_ecpm-1-119425809.pc_agg_new_rank&utm_term=gdb%E7%A6%BB%E7%BA%BF%E5%AE%89%E8%A3%85&spm=1000.2123.3001.4430
	3、https://wiki.postgresql.org/wiki/Pgsrcstructure
	4、https://en.wikipedia.org/wiki/GNU_Debugger









