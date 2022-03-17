# 查看当前未挂载的磁盘
```
# fdisk -l
```


# 查看当前系统挂载情况
```
# lsblk
sdb               8:16   0   2.2T  0 disk
└─sdb1            8:17   0   2.2T  0 part /datab
sdc               8:32   0   2.2T  0 disk
└─sdc1            8:33   0   2.2T  0 part /datac
```

# 查看挂载文件的文件类型
```
# parted -l

Model: LENOVO AL15SEB24EQ (scsi)
Disk /dev/sdb: 2400GB
Sector size (logical/physical): 512B/4096B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name   Flags
 1      17.4kB  2400GB  2400GB  xfs          logic

```

# 查看磁盘的详细信息
```
# cat /proc/scsi/scsi
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: LENOVO   Model: AL15SEB24EQ      Rev: TB55
  Type:   Direct-Access                    ANSI  SCSI revision: 06
Host: scsi0 Channel: 00 Id: 01 Lun: 00
  Vendor: LENOVO   Model: AL15SEB24EQ      Rev: TB55
  Type:   Direct-Access


# smartctl -i /dev/sdl1
smartctl 7.3 2022-02-28 r5338 [x86_64-linux-3.10.0-1127.el7.x86_64] (local build)
Copyright (C) 2002-22, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Vendor:               LENOVO
Product:              AL15SEB24EQ
Revision:             TB55
Compliance:           SPC-4
User Capacity:        2,400,476,553,216 bytes [2.40 TB]
Logical block size:   512 bytes
Physical block size:  4096 bytes
Rotation Rate:        10500 rpm
Form Factor:          2.5 inches
Logical Unit id:      0x5000039b4840b88d
Serial number:        Y1F0A0YFFHTF
Device type:          disk
Transport protocol:   SAS (SPL-4)
Local Time is:        Sat Mar 12 22:37:41 2022 CST
SMART support is:     Available - device has SMART capability.
SMART support is:     Enabled
Temperature Warning:  Enabled

```


# 挂载磁盘相关命令
```

查看未挂载的磁盘
# fdisk -l

对磁盘进行创建分区，根据提示，依次输入"n"，"p" "1"，两次回车，"wq"意思就是新建一个主分区（1），大小是整个sdb磁盘，然后写入。
# fdisk /dev/sdb


写入系统，以下命令会格式化磁盘并写入文件系统
# mkfs.ext4  /dev/sdb


挂载磁盘，创建挂载的路径，并把磁盘挂载到该路径下
# mkdir /data
# mount /dev/sdb /data

卸载挂载目录
umount /dev/sdb


设置开机自动挂载，先查看磁盘的UUID和系统格式
blkid /dev/sdb1


设置系统开启加载
vim /etc/fstab

在后面添加一行
/dev/sdb /data  defaults 0 0


```


# 更多查看磁盘的工具
```
sdparm 工具
http://sg.danny.cz/sg/sdparm.html#__RefHeading___Toc168_3041630551

smartctl 工具
www.smartmontools.org


下载软件
https://sourceforge.net/projects/smartmontools/files/smartmontools/7.2/

```


# 查看磁盘的读写速度

## dd 测试磁盘的读写
```
测试磁盘的读写速度
time有计时的作用
dd 用于复制
if 读取
of 写到

测试目录/data 的存写的速度

顺序写
time dd if=/dev/zero of=/data/test  bs=8k count=10000
随机写
time dd if=/dev/zero of=/data/test  bs=8k count=10000 oflag=dsync


测试目录/data 的存读的速度
顺序读
time dd if=/data/test of=/dev/zero bs=8k count=10000
随机读
time dd if=/data/test of=/dev/zero bs=8k count=10000 oflag=dsync


# 测试最接近真实的文件写速度
dd if=/dev/zero of=test bs=50M count=100  conv=fdatasync

# 测试cache写缓存速度
dd if=/dev/zero of=/sdcard/test bs=1M count=100

# 跳过了内存缓存
dd if=/dev/zero of=test bs=1M count=128  oflag=direct

```

## fio 测试磁盘的读写
```

或者下载打包的软件
链接: https://pan.baidu.com/s/1DPMJbbP8PNstwf9fFirUHA?pwd=5vja 提取码: 5vja


下载并编译软件
wget http://brick.kernel.dk/snaps/fio-2.2.5.tar.gz
yum install -y libaio-devel gcc  
tar -zxvf fio-2.2.5.tar.gz
cd fio-2.2.5
./configure
make
make install


随机写
# fio -filename=/data00/file.txt -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=8k -size=30G -numjobs=10 -runtime=600 -group_reporting -name=mytest

顺序写
# fio -filename=/data00/file.txt -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=16k -size=30G -numjobs=10 -runtime=600 -group_reporting -name=mytest

随机读
# fio -filename=/data00/file.txt -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=16k -size=30G -numjobs=10 -runtime=600 -group_reporting -name=mytest


顺序读
# fio -filename=/data00/file.txt -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=16k -size=30G -numjobs=10 -runtime=60 -group_reporting -name=mytest


混合随机读写
# fio -filename=/data00/file.txt -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=70 -ioengine=psync -bs=16k -size=30G -numjobs=10 -runtime=600 -group_reporting -name=mytest -ioscheduler=noop



说明：
filename=/dev/sdb1       测试文件名称，通常选择需要测试的盘的data目录。
direct=1                 测试过程绕过机器自带的buffer。设置为1，就表示跳过系统缓存。
iodepth                  表示使用异步 I/O（asynchronous I/O，简称 AIO）时，同时发出的 I/O 请求上限。
rw                       表示 I/O 模式。我的示例中， read/write 分别表示顺序读 / 写，而randread/randwrite 则分别表示随机读 / 写。
bs=16k                   单次io的块文件大小为16k
bsrange=512-2048         同上，提定数据块的大小范围
size=5g                  本次的测试文件大小为5g，以每次4k的io进行测试。
numjobs=30               本次的测试线程为30.
runtime=1000             测试时间为1000秒，如果不写则一直将5g文件分4k每次写完为止。
ioengine                 表示 I/O 引擎，它支持同步（sync）、异步（libaio）、内存映射（mmap）、网络（net）等各种 I/O 引擎。
rwmixwrite=30            在混合读写的模式下，写占30%
group_reporting          关于显示结果的，汇总每个进程的信息。


此外
lockmem=1g               只使用1g内存进行测试。
zero_buffers             用0初始化系统buffer。



```



# 磁盘的调优
```
linux 磁盘队列深度nr_requests 和 queue_depth
https://www.365seal.com/y/w7VjRgq4V3.html

原文连接
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/performance_tuning_guide/sect-red_hat_enterprise_linux-performance_tuning_guide-storage_and_file_systems-configuration_tools



```





# 参考资料
```

性能测试中问题反思和心得
https://mp.weixin.qq.com/s/z2CFj827FMJE7qCK5k3KoA

```

















