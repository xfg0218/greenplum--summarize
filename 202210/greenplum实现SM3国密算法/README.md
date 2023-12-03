# 国产密码算法介绍
1.国产密码算法（国密算法）是指国家密码局认定的国产商用密码算法，在金融领域目前主要使用公开的SM2、SM3、SM4三类算法，分别是非对称算法、哈希算法和对称算法，密钥长度和分组长度均为128位。

2.SM2为国家密码管理局公布的公钥算法，其加密强度为256位。SM2椭圆曲线公钥密码算法是我国自主设计的公钥密码算法，包括SM2-1椭圆曲线数字签名算法，SM2-2椭圆曲线密钥交换协议，SM2-3椭圆曲线公钥加密算法，分别用于实现数字签名密钥协商和数据加密等功能。SM2算法与RSA算法不同的是，SM2算法是基于椭圆曲线上点群离散对数难题，相对于RSA算法，256位的SM2密码强度已经比2048位的RSA密码强度要高。

|序号|算法种类|算法是否公开|算法的长度|算法特点|JAVA算法制作方法|国家密码管理局资料|
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
|1|SM1|不公开|分组128bit|需要通过加密芯片的接口进行调用|https://download.csdn.net/download/ererfei/9474502||
|2|SM2|公开|ECC 256位|故其签名速度与秘钥生成速度都快于RSA,安全强度比RSA 2048位高,但运算速度快于RSA|https://blog.csdn.net/kimwu/article/details/14452913|http://www.oscca.gov.cn/sca/xxgk/2012-11/22/content_1002397.shtml|
|3|SM3|公开|校验结果为256位|SM3算法的安全性要高于MD5算法和SHA-1算法|https://blog.csdn.net/ye_xiao_yu/article/details/80600159|http://www.oscca.gov.cn/sca/xxgk/2010-12/17/content_1002389.shtml|
|4|SM4|公开|分组128bit|SM4算法与AES算法具有相同的密钥长度分组长度128比特，因此在安全性上高于3DES算法|http://www.oscca.gov.cn/sca/xxgk/2010-12/17/content_1002389.shtml|http://www.sca.gov.cn/sca/xwdt/2012-03/21/content_1002392.shtml|


# 安装`gmssl`模块
```
-- 需要再每台节点上进行安装


$ pip3.6 install gmssl

Collecting gmssl
  Downloading gmssl-3.2.2-py3-none-any.whl (10 kB)
Collecting pycryptodomex
  Downloading pycryptodomex-3.19.0-cp35-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (2.1 MB)
     |████████████████████████████████| 2.1 MB 27 kB/s
Installing collected packages: pycryptodomex, gmssl
Successfully installed gmssl-3.2.2 pycryptodomex-3.19.0

```


# 代码案例
```
-- 创建plpython3u插件
create extension plpython3u;

-- 国密SM3加密算法
CREATE OR REPLACE FUNCTION sm3_hash(input_text bytea)
RETURNS TEXT AS $$
from gmssl import sm3

# 计算SM3哈希值
def sm3_hash(msg):
    msg=bytearray(msg)
    h = sm3.sm3_hash(msg)
    return h

hash_value = sm3_hash(input_text)
print(hash_value)

return hash_value
$$ LANGUAGE plpython3u;

-- SM3算法测试
test=# select sm3_hash('hello,Greenplum'::bytea);
                             sm3_hash
------------------------------------------------------------------
 0811ed35301bd0cf5fa907c014c954c4500f1a7c8477c61039de8f512bac0531
(1 row)

Time: 48.214 ms


```
