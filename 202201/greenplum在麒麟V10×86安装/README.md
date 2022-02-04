# greenplum在麒麟V10×86架构上安装
## 系统下载
```
麒麟V10×86 系统下载 https://pan.baidu.com/s/1VEP7X9eMcMtUBJX3LmXMeA 提取码: 5u41
需要的安装包下载: https://pan.baidu.com/s/11W_0u4Ssj_kiWyO9l5CIUQ 提取码: bmui
GP6.7.0 下载：https://www.aliyundrive.com/s/dCsDWku7mTN
```

## 查看安装后的系统信息
```
# arch
x86_64

# uname -a
Linux mdw 4.19.90-24.4.v2101.ky10.x86_64 #1 SMP Mon May 24 12:14:55 CST 2021 x86_64 x86_64 x86_64 GNU/Linux

```

## 创建gpadmin用户
```
groupadd -g 530 gpadmin
useradd -g 530 -u 530 -m -d /home/gpadmin -s /bin/bash gpadmin
chown -R gpadmin:gpadmin /home/gpadmin
echo "gpadmin" | passwd --stdin gpadmin
```

## 安装gp数据库
```
# yum install -y greenplum-db-6.7.0-rhel7-x86_64.rpm
上次元数据过期检查：0:00:18 前，执行于 2022年02月03日 星期四 00时27分13秒。
依赖关系解决。
==================================================================================================================================================================
 Package                               Architecture                    Version                                    Repository                                 Size
==================================================================================================================================================================
安装:
 greenplum-db                          x86_64                          6.7.0-1.el7                                @commandline                              175 M
安装依赖关系:
 apr-util                              x86_64                          1.6.1-12.p00.ky10                          ks10-adv-updates                          109 k

事务概要
==================================================================================================================================================================
安装  2 软件包

总计：176 M
总下载：109 k
安装大小：493 M
下载软件包：
apr-util-1.6.1-12.p00.ky10.x86_64.rpm                                                                                             844 kB/s | 109 kB     00:00
------------------------------------------------------------------------------------------------------------------------------------------------------------------
总计                                                                                                                              835 kB/s | 109 kB     00:00
运行事务检查
事务检查成功。
运行事务测试
事务测试成功。
运行事务
  准备中  :                                                                                                                                                   1/1
  运行脚本: apr-util-1.6.1-12.p00.ky10.x86_64                                                                                                                 1/2
  安装    : apr-util-1.6.1-12.p00.ky10.x86_64                                                                                                                 1/2
  运行脚本: apr-util-1.6.1-12.p00.ky10.x86_64                                                                                                                 1/2
  安装    : greenplum-db-6.7.0-1.el7.x86_64                                                                                                                   2/2
  运行脚本: greenplum-db-6.7.0-1.el7.x86_64                                                                                                                   2/2
/sbin/ldconfig: /usr/lib64/libLLVM-7.so 不是符号链接


  验证    : apr-util-1.6.1-12.p00.ky10.x86_64                                                                                                                 1/2
  验证    : greenplum-db-6.7.0-1.el7.x86_64                                                                                                                   2/2

已安装:
  apr-util-1.6.1-12.p00.ky10.x86_64                                                greenplum-db-6.7.0-1.el7.x86_64

完毕！

```


## 设置环境变量
```
source /usr/local/greenplum-db/greenplum_path.sh
export MASTER_DATA_DIRECTORY=/data/gpmaster/gpseg-1
export GPPORT=5432

```

## 创建数据目录
```
gpssh -f /home/gpadmin/all_host -e 'mkdir -p /data/primary'
gpssh -f /home/gpadmin/all_host -e 'mkdir -p /data/mirror’
gpssh -f /home/gpadmin/all_host -e 'mkdir -p /data/master


gpssh -f /home/gpadmin/all_host -e 'chown -R gpadmin:gpadmin /data/primary'
gpssh -f /home/gpadmin/all_host -e 'chown -R gpadmin:gpadmin /data/mirror’'
gpssh -f /home/gpadmin/all_host -e 'chown -R gpadmin:gpadmin /data/master'

```

## 初始化文件
```
/usr/local/greenplum-db/docs/cli_help/gpconfigs/gpinitsystem_config /home/gpadmin/config


# cat gpinitsystem_config
# FILE NAME: gpinitsystem_config

# Configuration file needed by the gpinitsystem

################################################
#### REQUIRED PARAMETERS
################################################

#### Name of this Greenplum system enclosed in quotes.
ARRAY_NAME="Greenplum Data Platform"

#### Naming convention for utility-generated data directories.
SEG_PREFIX=gpseg

#### Base number by which primary segment port numbers
#### are calculated.
PORT_BASE=6000

#### File system location(s) where primary segment data directories
#### will be created. The number of locations in the list dictate
#### the number of primary segments that will get created per
#### physical host (if multiple addresses for a host are listed in
#### the hostfile, the number of segments will be spread evenly across
#### the specified interface addresses).
declare -a DATA_DIRECTORY=(/data/primary/primary /data/primary/primary)

#### OS-configured hostname or IP address of the master host.
MASTER_HOSTNAME=mdw

#### File system location where the master data directory
#### will be created.
MASTER_DIRECTORY=/data/primary/master

#### Port number for the master instance.
MASTER_PORT=5432

#### Shell utility used to connect to remote hosts.
TRUSTED_SHELL=ssh

#### Default server-side character set encoding.
ENCODING=UNICODE

################################################
#### OPTIONAL MIRROR PARAMETERS
################################################

#### Base number by which mirror segment port numbers
#### are calculated.
MIRROR_PORT_BASE=7000

#### File system location(s) where mirror segment data directories
#### will be created. The number of mirror locations must equal the
#### number of primary locations as specified in the
#### DATA_DIRECTORY parameter.
declare -a MIRROR_DATA_DIRECTORY=(/data/mirror’/mirror /data/mirror’/mirror)


################################################
#### OTHER OPTIONAL PARAMETERS
################################################

#### Create a database of this name after initialization.
#DATABASE_NAME=name_of_database

#### Specify the location of the host address file here instead of
#### with the -h option of gpinitsystem.
#MACHINE_LIST_FILE=/home/gpadmin/gpconfigs/hostfile_gpinitsystem



gpinitsystem -c /home/gpadmin/config/gpinitsystem_config -h /home/gpadmin/config/all_host


```






