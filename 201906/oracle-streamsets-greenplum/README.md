# oracle-streamsets-greenplum

	oracle-streamsets-greenplum 主要使用streamsets把oracle数据同步到greenplum,相关资料请查看:

	1、streamsets 官网:https://streamsets.com/
	2、streamsets 相关介绍:https://blog.csdn.net/xfg0218/article/details/80731557
	3、streamsets 配置实例请查看xiaoxu_test.json文件 
[下载地址](https://github.com/xfg0218/greenplum--summarize/blob/master/images/streamsets-images/xiaoxu_test.json)
	4、把xiaoxu_test.json导入到streamsets中修改配置参数即可使用


# oracle 数据导入到greenplum 案例
## 1、查看oracle数据的大小
	select count(*) from F_ENT_XW_ZS_20181208;
	-- 2630,9816

## 2、查看streamsets数据源的配置
![images](https://github.com/xfg0218/greenplum--summarize/blob/master/images/streamsets-images/data-source.png)

## 3、查看streamsets目标源的配置
![images](https://github.com/xfg0218/greenplum--summarize/blob/master/images/streamsets-images/target--source.png)

## 4、查看streamsets 整体的运行情况
![images](https://github.com/xfg0218/greenplum--summarize/blob/master/images/streamsets-images/streamsets.png)

# 更多streamsets案例
更多streamsets 的资料请查看 [更多streamsets 的资料] (https://blog.csdn.net/xfg0218/article/details/79403054)

