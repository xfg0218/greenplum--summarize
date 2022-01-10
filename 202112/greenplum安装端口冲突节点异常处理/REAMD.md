# 问题描述
```
1、greenplum在安装集群时,有一台segment端口冲突，导致启动失败
2、找到segment节点上冲突的端口关闭，在master节点上执行gprecoverseg已回复启动失败的节点
3、在master节点上执行操作命令都报gpstop failed. (Reason='FATAL:  no pg_hba.conf entry for host "::1", user "gpadmin", database "template1", SSL off
') exiting...
```

# 解决方式

## 重新加载配置文件
``` shell
tkpoc=# select pg_reload_conf();

```
## 重新加载配置文件
``` shell
gpstop -u
```

