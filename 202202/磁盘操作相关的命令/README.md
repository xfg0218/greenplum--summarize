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

# 参考资料
```

性能测试中问题反思和心得
https://mp.weixin.qq.com/s/z2CFj827FMJE7qCK5k3KoA

```

















