# Greenplum 架构和核心引擎
	与喜爱主要是《 Greenplum 架构和核心引擎》的目录，
	详细的文档请查看:https://github.com/xfg0218/greenplum--summarize/tree/master/greenplum%E5%AD%A6%E4%B9%A0pdf%E6%96%87%E6%A1%A3/Greenplum%E4%BB%8E%E5%85%A5%E9%97%A8%E5%88%B0%E7%B2%BE%E9%80%9A
# 1 Greenplum 架构概述
	1.1 概述简介
	1.2 MPP无共享静态拓扑
	1.3 集群内数据分两类
	1.4 对用户透明
	1.5 用户数据表
	1.6 系统表/数据字典
	1.7 数据分布:并行化处理的根基
	1.8 多态储存:根据数据温度选择最佳的储存方式
		1.8.1 行储存
		1.8.2 列储存
		1.8.3 外部表
# 2 Greenplum SQL的执行过程
	2.1 系统空闲状态
	2.2 客户端建立会话链接
	2.3 Master fork一个进程处理客户端请求
	2.4 QD建立和Segment的链接
	2.5 segment fork 一个子进程处理QD的链接请求
	2.6 客户端发送查询请求给QD
	2.7 QD发送任务给QE
	2.8 QD与QEs建立数据通信通道
	2.9 QE各司其职
	2.10 QE状态管理
	2.11 QD返回查询结果给客户端
# 3 Greenplum 主要设计思考
	3.1 继承自PostgreSQL的设计
	3.2 主从架构
	3.3 数据储存
	3.4 数据通信
	3.5 三级并行计算
	3.6 流水线执行
	3.7 网络
	3.8 磁盘