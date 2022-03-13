[toc]

# 系统基本信息
```
查看系统的版本
# cat /etc/redhat-release
CentOS Linux release 7.8.2003 (Core)

查看内核
#  uname -a
Linux mdw 3.10.0-1127.el7.x86_64 #1 SMP Tue Mar 31 23:36:51 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux



```


# CPU 相关的命令
```
查看CPU详细信息
# lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                64
On-line CPU(s) list:   0-63
Thread(s) per core:    2
Core(s) per socket:    16
Socket(s):             2
NUMA node(s):          2
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 85
Model name:            Intel(R) Xeon(R) Gold 6226R CPU @ 2.90GHz
Stepping:              7
CPU MHz:               2900.000
BogoMIPS:              5800.00
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              1024K
L3 cache:              22528K
NUMA node0 CPU(s):     0-15,32-47
NUMA node1 CPU(s):     16-31,48-63


查看当前CPU的运行的频次
watch -n 1 "cat /proc/cpuinfo | grep MHz"


把CPU调整到正常频次，并在此查看使用的频次
cpupower -c all frequency-set -g performance
watch -n 1 "cat /proc/cpuinfo | grep MHz"


修改CPU的配置策略
1、tuned-adm list -- 列出所有的默认的调优策略
2、tuned-adm active -- 查看现在生效的调优策略
3、tunde-adm recommand  -- 查看tuned目前推荐使用的策略
4、tuned-adm profile + 策略名称  修改调优方案，使用新的调优策略
5、tuned-adm off - 关闭调优策略


profile + 策略名称 
balanced ：负载均衡
hpc-compute    
network-throughput ：网络吞吐量
throughput-performance：吞吐量-高性能
desktop ：桌面
latency-performance ：低延时-高性能
powersave：省电模式
virtual-guest 优化虚拟化客户机
functions
network-latency  网络低延时
virtual-host 优化虚拟化主机

例如
tuned-adm profile throughput-performance


```

# 查看网络信息命令
```
# ethtool bond0
Settings for bond0:
	Supported ports: [ ]
	Supported link modes:   Not reported
	Supported pause frame use: No
	Supports auto-negotiation: No
	Supported FEC modes: Not reported
	Advertised link modes:  Not reported
	Advertised pause frame use: No
	Advertised auto-negotiation: No
	Advertised FEC modes: Not reported
	Speed: 20000Mb/s
	Duplex: Full
	Port: Other
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: off
	Link detected: yes

```

# 查案硬件信息相关命令
## htop命令
```
在线安装
htop
yum install -y htop


离线安装
htop官网：http://hisham.hm/htop/
下载地址：https://sourceforge.net/projects/htop/
ncurses-devel下载地址：http://pkgs.org/download/ncurses-devel

http://ftp.gnu.org/gnu/ncurses/


安装ncurses-devel
rpm -ivh ncurses-devel-5.7-4.20090207.el6.x86_64.rpm

解压缩htop安装包
tar zxvf htop-2.0.1.tar.gz

安装htop
sudo ./configure
sudo make
sudo make install


CPU处理器:
蓝色=低优先级线程
绿色=普通优先级线程
红色=内核线程

内存:
绿色=已用内存
蓝色=缓冲区
黄色/橙色=缓存


```

## nload 命令
```
在线安装
yum install -y nload


离线安装
wget http://www.roland-riegel.de/nload/nload-0.7.4.tar.gz
tar zxvf nload-0.7.4.tar.gz
cd nload-0.7.4
./configure;make;make install


```

## iotop 命令
```
在线安装
yum install -y iotop


离线安装
wget http://mirror.centos.org/altarch/7/os/aarch64/Packages/iotop-0.6-4.el7.noarch.rpm
rpm -ivh iotop-0.6-4.el7.noarch.rpm


```


## nmon 命令
```
安装方式
wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/n/nmon-16g-3.el7.x86_64.rpm
rpm -ivh nmon-16g-3.el7.x86_64.rpm

q:停止并退出Nmon
h:查看帮助信息
c:查看 CPU 统计信息
m:查看内存统计信息
d:查看磁盘统计信息
k:查看内核统计信息
n:查看网络统计信息
N:查看 NFS 统计信息
j:查看文件系统统计信息
t:查看 Top 进程统计信息
V:查看虚拟内存统计信息
v:详细输出模式


```





















