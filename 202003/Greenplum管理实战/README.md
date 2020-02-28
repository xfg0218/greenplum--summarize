# Greenplum 管理实战
	目录
# 1 catalog 管理
## 1.1 catalog 基本原理
	1.1.1 仅在master保存的元数据
	1.1.2 表-元数据表(部分)
		1.1.2.1 查询实例
## 1.2 gpcheckcat 命令的使用
	1.2.1 catalog 检查不一致问题
	1.2.2 gpcheckcat 在线测试
	1.2.3 gpcheckcat 离线测试
	1.2.4 gpcheckcat 提示自动修复
	1.2.5 最佳实践和常见问题
# 2 master管理
## 2.1 master基本原理和操作
	2.1.1 master管理工具
	2.1.2 添加standby
	2.1.3 master-standby数据同步原理
	2.1.4 standby 同步状态
	2.1.5 standby 特定配置
	2.1.6 日志查看和收集
## 2.2 master 故障管理
	2.2.1 master 节点异常退出:尝试恢复master
	2.2.2 master节点异常退出:master无法恢复
	2.2.3 gpactivatestandby 内部逻辑
	2.2.4 提升standby操作过程
	2.2.5 重建standby操作过程
## 2.3 standby 故障管理
	2.3.1 standby异常
	2.3.2 standby 异常处理
## 2.4 集群启动过程
	2.4.1 gpstart 内部逻辑
	2.4.2 集群无法启动
# 3 segment 管理
## 3.1 基本原理和操作
	3.1.1 segment管理工具
	3.1.2 配置mirror
	3.1.3 primary-mirror数据同步
	3.1.4 mirror异常退出
	3.1.5 primary 异常退出
## 3.2 segment故障管理
	3.2.1 segment异常退出
	3.2.2 segment异常处理:主机错误
	3.2.3 segment异常处理:进程错误
	3.2.4 segment异常处理:数据错误
	3.2.5 primary segment异常处理:再平衡
	3.2.6 增量和全量恢复
	3.2.7 gprecoverseg 常见错误
## 3.3 集群扩容
	3.3.1 集群扩容准备
	### 3.3.2 扩容实例
		3.3.2.1 扩容之前的状态
		3.3.2.2 交互式生成输入文件
		3.3.2.3 添加节点
		3.3.2.4 数据重分布
		3.3.2.5 清除扩容的状态
		3.3.2.6 扩容后
## 4 资源管理
	4.1 资源管理resource group 概述
	4.2 资源组属性
	4.3 启用resource group
	4.4 创建resource group
	4.5 查看resource group信息
	4.6 常见问题和最佳实践