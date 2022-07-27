## 中标麒麟V7 ×86_64 下载
链接: https://pan.baidu.com/s/19vZ-sQkgnnxdk4-dOl6bVQ?pwd=asps 提取码: asps

## Greenplum 下载
链接: https://pan.baidu.com/s/1nyJa_Cp8Z2e510KkTiMQvQ?pwd=1e9f 提取码: 1e9f

## 离线安装需要的RPM依赖
链接: https://pan.baidu.com/s/164Zqbxl22WXDIpdIbJbj2Q?pwd=icrn 提取码: icrn


## 常用命令
```
cat /etc/.productinfo
cat /etc/os-release
nkvers

```

## 麒麟系统信息
```
[root@localhost home]# cat /etc/.productinfo
NeoKylin Linux Advanced Server
release V7Update6/(Chromium)-x86_64
b4.lic/20190820

[root@localhost home]# nkvers
############## NeoKylin Linux Version#################
Release:
NeoKylin Linux Advanced Server release V7Update6 (Chromium)

Kernel:
3.10.0-957.el7.x86_64

Build:
NeoKylin Linux Advanced Server
release V7Update6/(Chromium)-x86_64
b4.lic/20190820

#################################################


[root@localhost home]# cat /etc/os-release
NAME="NeoKylin Linux Advanced Server"
VERSION="V7Update6 (Chromium)"
ID="neokylin"
ID_LIKE="fedora"
VARIANT="Server"
VARIANT_ID="server"
VERSION_ID="V7Update6"
PRETTY_NAME="NeoKylin Linux Advanced Server V7Update6 (Chromium)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:neokylin:enterprise_linux:V7Update6:GA:server"
HOME_URL="https://www.cs2c.com.cn/"
BUG_REPORT_URL="https://bugzilla.cs2c.com.cn/"

NEOKYLIN_BUGZILLA_PRODUCT="NeoKylin Linux Advanced Server 7"
NEOKYLIN_BUGZILLA_PRODUCT_VERSION=V7Update6
NEOKYLIN_SUPPORT_PRODUCT="NeoKylin Linux Advanced Server"
NEOKYLIN_SUPPORT_PRODUCT_VERSION="V7Update6"


```

## 安装环境准备

### 设置hostname
```
-- 设置hostname
hostnamectl set-hostname mdw


-- 修改配置文件
vi /etc/hosts
172.16.172.190 mdw

```

### 关闭防火墙
```
iptables -F
setenforce 0
sed -ri "/^SELINUX/cSELINUX=disabled" /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld
```

### 修改sysctl文件
```
-- 在文件中添加以下信息
/etc/sysctl.conf

kernel.shmmax = 34000000000
kernel.shmmni = 8192
kernel.shmall = 34000000000
kernel.sem = 1000 8192000 400 8192
kernel.sysrq = 1
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.msgmni = 2048
net.ipv4.tcp_syncookies = 1
net.ipv4.ip_forward = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.conf.all.arp_filter = 1
net.ipv4.ip_local_port_range = 1025 65535
net.core.netdev_max_backlog = 10000
net.core.rmem_max = 2097152
net.core.wmem_max = 2097152
vm.overcommit_memory = 2
vm.swappiness = 1
kernel.pid_max = 655350

```


### 修改limits.conf参数
```
-- 在文件中添加以下信息
vi /etc/security/limits.conf

* soft nofile 65536
* hard nofile 65536
* soft nproc 131072
* hard nproc 131072
```

### 创建gpadmin用户
```
groupadd -g 530 gpadmin
useradd -g 530 -u 530 -m -d /home/gpadmin -s /bin/bash gpadmin
chown -R gpadmin:gpadmin /home/gpadmin
echo "gpadmin" | passwd --stdin gpadmin
```

## 安装数据库

### 安装RPM包
```
yum install -y  greenplum-db-6.2.1-rhel7-x86_64.rpm

```

### 配置环境变量
```
在gpadmin用户下.bashrc和.bash_profile设置一下变量

source /usr/local/greenplum-db/greenplum_path.sh
export MASTER_DATA_DIRECTORY=/home/master/gpseg-1
export GPPORT=5432
export PGDATABASE=testdb

```

### 创建保存的数据文件路径并设置权限
```
mkdir /home/master
mkdir /home/primary
mkdir /home/mirror

chown -R gpadmin:gpadmin /home/master/
chown -R gpadmin:gpadmin /home/primary/
chown -R gpadmin:gpadmin /home/mirror/

```

### 修改初始化配置文件
```

cp /usr/local/greenplum-db/docs/cli_help/gpconfigs/gpinitsystem_config /home/gpadmin

-- 修改以下配置文件的以下内容
gpinitsystem_config

- DATA_DIRECTORY
- MASTER_HOSTNAME
- MASTER_DIRECTORY
- MIRROR_PORT_BASE
- MIRROR_DATA_DIRECTORY

```

### 进行安装
```
设置安装的host,在all_host添加需要安装的hostname

gpinitsystem -c /home/gpadmin/gpinitsystem_config -h all_host


```
###  安装完成后的版本信息
```
postgres=# select version();
                                                                                               version

--------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
 PostgreSQL 9.4.24 (Greenplum Database 6.2.1 build commit:d90ac1a1b983b913b3950430d4d9e47ee8827fd4) on x86_64-
unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Dec 12 2019 18:35:48
(1 row)
```
















