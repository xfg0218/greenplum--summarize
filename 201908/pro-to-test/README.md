# 说明
	最近测试环境进行了重新安装,需要把生产上的信息同步到测试环境下,整理此思路。同步需要在相同大版本下执行


# 目录

	1 安装需要准备的环境
	2 备份用户信息
	3 备份数据库信息
	4 备份schema和function与table的结构信息
	5 生产与测试环境同步数据
		5.1 打通生产与测试环境master节点的免密
		5.2 编写同步表的文件
		5.3 编写host文件
		5.4 同步数据


# 1 安装需要准备的环境

	1.1 安装oracle常用函数
	1.2 安装pljava扩展插件
	1.3 安装get_table_structure函数
	1.4 安装dblink常用函数
	1.5 安装madlib库
	************


# 2 备份用户信息
	pg_dumpall -h hostname -p port -U username  -g  -f  filename
	
	--
	-- Greenplum Database cluster dump
	--
	
	\connect postgres
	
	SET client_encoding = 'UTF8';
	SET standard_conforming_strings = on;
	
	--
	-- Roles
	--
	
	CREATE ROLE ******;
	ALTER ROLE ****** WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN PASSWORD 'md51dc3eb975e5228e9f479eff******';
	CREATE ROLE ******;
	ALTER ROLE ****** WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN PASSWORD 'md57d0bf5a0f957489647878be******';
	********


# 3 备份数据库信息
	pg_dumpall -h hostname -p port -U username  -s  -f  filename
	
	--
	-- Greenplum Database cluster dump
	--
	
	\connect postgres
	
	SET client_encoding = 'UTF8';
	SET standard_conforming_strings = on;
	
	--
	-- Roles
	--
	**
	--
	-- Database creation
	--
	*******


# 4 备份schema和function与table的结构信息
	time pg_dump -h hostname -p port -s -n schemaname -U username  dbname  -f  filename
	
	--
	-- Greenplum Database database dump
	--
	
	SET statement_timeout = 0;
	SET client_encoding = 'UTF8';
	SET standard_conforming_strings = on;
	SET check_function_bodies = false;
	SET client_min_messages = warning;
	
	SET default_with_oids = false;
	
	--
	-- Name: ods; Type: SCHEMA; Schema: -; Owner: gpadmin
	--
	
	CREATE SCHEMA ods;
	*********************


# 5 生产与测试环境同步数据
## 5.1 打通生产与测试环境master节点的免密

	gpssh-exkeys -h host1 -h host2
	
	host1 : 生产集群master节点
	host2 : 测试集群master节点

## 5.2 编写同步表的文件
	vim syn_table_list
	chin***.schema1.tablename
	*****

## 5.3 编写host文件
	$ cat  source_host_map_file 
	gpsdw1,192.168.***.**
	gpsdw2,192.168.***.**
	gpsdw3,192.168.***.**
	gpsdw4,192.168.***.**

## 5.4 同步数据
	time  gptransfer --source-host=192.168.***.** --source-port=5432 --source-user=gpadmin -f syn_table_list --source-map-file=source_host_map_file -a --dest-host=192.168.***.** --dest-port=5432 --dest-database=chin*** --truncate