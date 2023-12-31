# Greenplum7的介绍
https://tanzu.vmware.com/content/blog/vmware-greenplum-7-release


# Greenplum7 的 Docker下载
```
-- 下载镜像
docker run -itd --name gpdb7 -h gpdb7 -p 5437:5433 -p 28087:28081 lhrbest/greenplum:7.0.0_v2  /usr/sbin/init

-- 查看运行的容器
#  docker ps -a|grep gpdb
87e8cb4a4ed4        lhrbest/greenplum:7.0.0_v2          "/usr/sbin/init"         3 minutes ago       Up 3 minutes        22/tcp, 3389/tcp, 5432/tcp, 28080/tcp, 0.0.0.0:5437->5433/tcp, 0.0.0.0:28087->28081/tcp   gpdb7

-- 进入容器
[root@mdw ~]# docker exec -it gpdb7  /bin/bash
[root@gpdb7 /]# su - gpadmin
[gpadmin@gpdb7 ~]$ gpstart -a
[gpadmin@gpdb7 ~]$ psql
psql (12.12)
Type "help" for help.

postgres=# select version();
                                                                                                                version

------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------
 PostgreSQL 12.12 (Greenplum Database 7.0.0 build commit:0a7a3566873325aca1789ae6f818c80f17a9402d) on x86_64-pc-linux-gnu, compiled by gcc (GCC) 8.5.0 20210514 (R
ed Hat 8.5.0-18), 64-bit compiled on Sep 20 2023 23:21:05 Bhuvnesh C.
(1 row)

```




