# 数据库中表储存的模式对性能的影响

| HEAP表 | 行存 | 不压缩 |
|:----:|:----:|:----:|
| | 行存 | |
| AO表 | (orientation=row) | 可压缩 |
| (appendonly=true) | 列存 | (compresstype=zlib,COMPRESSLEVEL=5) |
| | (orientation=column) | |

## 储存大小对比

| 类型 | 文件 | 堆储存 | AO表行存 | AO表列存 | AO表行存压缩 | AO表列存压缩 |
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
| 大小 | 35G | 32G | 34G | 30G | 13G | 6822MB |


## 建立压缩表的例子
	create  table   temp  with (appendonly = true,orientation = row,compresstype = zlib , COMPRESSLEVEL = 5 ) as select *  from pg_tables distributed  randomly;
	
## 说明
	压缩比例越高在数据库中的占用大小越小，在查询数据时减小I/O的开销。当在查询数据时解压的速度大于网络的传输速度，便能提高速度。
	
# GPFDIST 参数设置对性能的影响

| 参数名 | 说明 |
|:----:|:----:|
| writable_external_table_bufsize | 控制主实例向文件服务器发送数据包的大小，默认64kb |
| gp_external_max_segs | 控制访问文件服务器的实例数量，默认64 |

## 测试环境及测试方法
	以下测试的集群环境
	1、服务器数量20
	2、主备实例数：160
	3、网络速率：万兆

## gpfdist 导出控制参数writable_external_table_bufsize

| 文件大小（MB） | 导出耗时(s) | 速度(MB/s) | 参数值(kb) |
|:----:|:----:|:----:|:----:|
| 45441 | 201 | 226.07 | 512 |
| 45441 | 56 | 811.45 | 16384 |


## gpfdist 加载控制参数gp_external_max_segs

| 文件大小（MB） | 导出耗时(s) | 速度(MB/s) | 参数值(kb) |
|:----:|:----:|:----:|:----:|
| 45441 | 108 | 420.75 | 20 |
| 45441 | 59 | 770.19 | 40 |
 