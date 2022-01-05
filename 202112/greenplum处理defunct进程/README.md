#  集群现象
	1、使用psql连接数据库长时间无响应
	2、使用gpstate -e 查看长时间无响应
	3、查看系统硬件资源htop和free -h占用非常小
	4、查看日志$MASTER_DATA_DIRECTORY/log下的日志没有发现异常
	5、使用ps -axjf|grep postgres查看发现有比较多的postgres defunct,经过统计大概有203个

# 解决大量的postgres defunct进程


##  查看postgres defunct 进程是有哪个的子进程
``` SQL
# ps -axjf |grep  postgres
****
2951     37121 37111  0  2017 ?        00:01:27 [postgres] <defunct>  
2951     37128 37111  0  2017 ?        00:09:09 [postgres] <defunct>  
2951     37129 37111  0  2017 ?        00:01:28 postgres: stats collector process                                                   
2951     38325 37111  0 19:33 ?        00:00:00 [postgres] <defunct> 
****
```

## 查看该子进程的Call Stackd的信息
``` shell
查看该进程正在做哪些事情
pstack PID

```

## 尝试重启集群
``` shell
确定客户端无连接后，然后重启集群，如果长时间无响应需要暴力解决
gpstop -M fast -ar
```

## 关闭进程
``` shell
如果gpstop -M fast -ar 无法进行集群的重启，则需要进入暴力模式类解决
1、先使用ps -axjf |grep  postgres找到defunct进程的主进程，需要确定是QD还是QE进程
2、对主进程进行kill,如果kill也是停不掉则使用kill -9
3、对该进程进行启动
4、QD进程则使用 pg_ctl start -D /data2/master/gpseg-1/
5、QE进程则使用 nohup /usr/local/greenplum-4.3.4.enterprise/bin/postgres -D /data3/primary/gpseg4 -p 6004 -c gp_role=execute &
6、使用gpstate -e 查看集群的状态，如果有节点down并且是给节点使用gprecoverseg 进行恢复
```


# 参考资料
| 序号 | 说明 | 连接 |
|:----:|:----:|:----:|
| 1 | PostgreSQL Linux 下 僵尸状态的处理 | https://blog.csdn.net/weixin_33713350/article/details/89732225 |
| 2 | PostgreSQL Linux 下 僵尸状态的处理(德哥) | https://billtian.github.io/digoal.blog/2018/04/09/03.html |





