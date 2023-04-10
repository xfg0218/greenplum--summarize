# 服务器磁盘坏快检测
有时在计算SQL时可能出现could not read block 3684552 of temporary file: read only 0 of 8192 bytes的错误，第一种可能是跑SQL产生的临时文件过大，导致磁盘不足。另一种可能是磁盘有坏道在跑SQL时被磁盘控制器自动修复磁盘坏道时终止了跑数程序，导致找不到临时的文件。

# 问题排查

## 临时文件过大问题排查思路
1、找到对应seg报错对应的主机及数据保存的路径。

2、重新运行SQL，使用`du -sh`实时观察该磁盘的使用情况，特别关注base/pgsql_tmp文件的增长速度。

3、如果观察到磁盘不足则是该问题所导致。

## 磁盘坏道检测方法

```
-- 安装smartmontools
sudo yum install -y smartmontools

-- 显示磁盘的SMART信息

$ sudo smartctl -a /dev/sda

smartctl 7.0 2018-12-30 r4883 [x86_64-linux-3.10.0-1160.53.1.el7.x86_64] (local build)
Copyright (C) 2002-18, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Vendor:               SEAGATE
Product:              ST1800MM0159
Revision:             CI04
Compliance:           SPC-4
User Capacity:        1,800,360,124,416 bytes [1.80 TB]
Logical block size:   512 bytes
Physical block size:  4096 bytes
LU is fully provisioned
Rotation Rate:        10500 rpm
Form Factor:          2.5 inches
Logical Unit id:      0x5000c500cdd2edc3
Serial number:        WBN2QRLB0000K0170NS8
Device type:          disk
Transport protocol:   SAS (SPL-3)
Local Time is:        Thu Mar 30 12:58:45 2023 CST
SMART support is:     Available - device has SMART capability.
SMART support is:     Enabled
Temperature Warning:  Enabled

=== START OF READ SMART DATA SECTION ===
SMART Health Status: OK

Grown defects during certification <not available>
Total blocks reassigned during format <not available>
Total new blocks reassigned <not available>
Power on minutes since format <not available>
Current Drive Temperature:     27 C
Drive Trip Temperature:        60 C

Manufactured in week 44 of year 2019
Specified cycle count over device lifetime:  10000
Accumulated start-stop cycles:  14
Specified load-unload count over device lifetime:  300000
Accumulated load-unload cycles:  651
Elements in grown defect list: 0

Vendor (Seagate Cache) information
  Blocks sent to initiator = 1411483296
  Blocks received from initiator = 2455610592
  Blocks read from cache and sent to initiator = 3698463409
  Number of read and write commands whose size <= segment size = 487995278
  Number of read and write commands whose size > segment size = 3128338

Vendor (Seagate/Hitachi) factory information
  number of hours powered up = 10799.60
  number of minutes until next internal SMART test = 30

Error counter log:
           Errors Corrected by           Total   Correction     Gigabytes    Total
               ECC          rereads/    errors   algorithm      processed    uncorrected
           fast | delayed   rewrites  corrected  invocations   [10^9 bytes]  errors
read:   610432509        0         0  610432509          0      20113.126           0
write:         0        0         0         0          0      69651.053           0
verify: 97836501        0         0  97836501          0        400.763           0

Non-medium error count:        0


[GLTSD (Global Logging Target Save Disable) set. Enable Save with '-S on']
No Self-tests have been logged


```

## 显示 SMART Health Status: OK
状态显示正常并不代表磁盘没有坏道，可能被操作系统自动修复了。

## Total errors corrected 和 Total uncorrected  errors参数值：
1、"Total errors corrected" 是指磁盘驱动器已经成功地纠正了磁盘上发现的读取/写入错误的总数。这是磁盘驱动器在其内部进行自我维护时完成的操作，它会检查磁盘上的数据是否出现错误，并尝试纠正这些错误，以确保数据的完整性和可靠性。通常情况下，磁盘上的错误会被及时纠正，因此Total errors corrected的值通常是比较小的。如果这个值很大，说明磁盘可能存在较大的问题。

2、Total uncorrected errors 指的是磁盘上未纠正的错误总数。磁盘读写过程中可能会发生错误，磁盘会尝试通过纠错码等机制来纠正这些错误，但是有些错误是无法被纠正的，这些无法被纠正的错误就是uncorrected errors。uncorrected errors的数量越多，说明磁盘的可靠性越差，可能会导致数据丢失或者系统异常等问题。通常情况下，磁盘的uncorrected errors数量应该为0。如果uncorrected errors数量不为0，建议备份数据并尽快更换磁盘。


## journalctl 的日志进一步分析磁盘的情况
```
-- journal 日志的保存路径
/run/log/journal/

-- 查看journalctl日志保存总大小
journalctl --disk-usage

-- 查看2023年3月30日下午20:20 之后的日志
journalctl --since "2023-03-30 20:20:00"

-- 查看从2023年3月1日00:00:00 到2023年3月31日00:00:00 之间的所有日志
journalctl --since "2023-03-01 00:00:00" --until "2023-03-31 00:00:00"

-- 可以使用 "yesterday"、"today"、"tomorrow"或者 "now" 获取日志的时间段
journalctl --since yesterday

-- 获取2023-03-25 00之后的日志保存到本地磁盘上
journalctl --since "2023-03-25 00:00:00"  >> journalctl.log
```







