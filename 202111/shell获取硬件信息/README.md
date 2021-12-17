``` shell

#!bin/bash

echo -e "------ os release ------"
cat /etc/redhat-release
cat /etc/issue | grep Linux

echo -e "\n ------ cpu physical ------"
cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l

echo -e "------ cpu info ------"
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c

echo -e "------ cpu processor ------"
cat /proc/cpuinfo | grep "processor" | uniq | wc -l

echo -e "\n ------ os BIT ------"
getconf LONG_BIT
uname -m

echo -e "------ os type ------"
dmidecode |grep "Product"

echo -e "\n ------ os network ------"
ls /sys/class/net/

echo -e "------ virtual network ------"
ls /sys/devices/virtual/net/

echo -e "------ devices  network ------"
ls /sys/class/net/ | grep -v "`ls /sys/devices/virtual/net/`"

echo -e "------ Ethernet  network ------"
lspci | grep "Ethernet controller"



echo -e "\n ------ os free ------"
free -h

echo -e "------ os disk ------"
df -h

echo -e "------ fdisk  ------"
df -h|grep "/dev/"
fdisk -l|grep "/dev/"

echo -e "\n ------ L1d cache ------ "
lscpu | grep -i 'L1d 缓存\|L1d cache' | awk -F '：|:' '{print $2}'

echo -e "------ L1i cache ------"
lscpu | grep -i 'L1i 缓存\|L1i cache' | awk -F '：|:' '{print $2}'

echo -e "------ L2 cache ------"
lscpu | grep -i 'L2 缓存\|L2 cache' | awk -F '：|:' '{print $2}'

echo -e "------ L3 cahce ------"
lscpu | grep -i 'L3 缓存\|L3 cache' | awk -F '：|:' '{print $2}'

```

