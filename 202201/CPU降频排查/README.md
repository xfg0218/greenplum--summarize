# CPU 降频处理
```
1、centos 7.9 系统，x86_64
2、CPU 32 C ,每个显示2.1GHz , 查看最高用到800MHz
3、把CPU的运行频率设置为performance
4、参考资料 https://billtian.github.io/digoal.blog/2018/06/02/01.html

```

# 分析降频命令
```

cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
performance powersave


查看当前cpu运行频率
watch -n 1 "cat /proc/cpuinfo | grep MHz"


cpupower frequency-info --driver
analyzing CPU 0:
  driver: intel_pstate


该命令可以看到limits: 800 MHz - 3.20 GHz
# cpupower frequency-info
analyzing CPU 0:
  driver: intel_pstate
  CPUs which run at the same hardware frequency: 0
  CPUs which need to have their frequency coordinated by software: 0
  maximum transition latency:  Cannot determine or is not supported.
  hardware limits: 800 MHz - 3.20 GHz
  available cpufreq governors: performance powersave
  current policy: frequency should be within 800 MHz and 3.20 GHz.
                  The governor "performance" may decide which speed to use
                  within this range.
  current CPU frequency: 2.70 GHz (asserted by call to hardware)
  boost state support:
    Supported: yes
    Active: yes


```

# 设置CPU的运行频率为performance
```

cpupower -c all frequency-set -g performance 
或者：
cpupower  frequency-set -g performance

```

#  再次查看cpu运行频率
```

watch -n 1 "cat /proc/cpuinfo | grep MHz"

Every 1.0s: cat /proc/cpuinfo | grep MHz                                                                                               
cpu MHz         : 2699.981
cpu MHz         : 2699.981
cpu MHz         : 2699.981
cpu MHz         : 2699.981
cpu MHz         : 2699.981
********

```





