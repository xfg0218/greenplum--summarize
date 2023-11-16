# 国产密码算法介绍
1.国产密码算法（国密算法）是指国家密码局认定的国产商用密码算法，在金融领域目前主要使用公开的SM2、SM3、SM4三类算法，分别是非对称算法、哈希算法和对称算法，密钥长度和分组长度均为128位。

2.SM2为国家密码管理局公布的公钥算法，其加密强度为256位。SM2椭圆曲线公钥密码算法是我国自主设计的公钥密码算法，包括SM2-1椭圆曲线数字签名算法，SM2-2椭圆曲线密钥交换协议，SM2-3椭圆曲线公钥加密算法，分别用于实现数字签名密钥协商和数据加密等功能。SM2算法与RSA算法不同的是，SM2算法是基于椭圆曲线上点群离散对数难题，相对于RSA算法，256位的SM2密码强度已经比2048位的RSA密码强度要高。

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

-- 国密sm2加密，返回的是b64加密后的值

CREATE or replace FUNCTION enc_str(str varchar) 
  RETURNS varchar
AS $$
import sys
from base64 import b64encode, b64decode
import binascii
from gmssl import sm2, func


# 16进制的公钥和私钥
private_key = '00B9AB0B828FF68872F21A837FC303668428DEA11DCD1B24429D0C99E24EED83D5'
public_key = 'B9C9A6E04E9C91F7BA880429273747D7EF5DDEB0BB2FF6317EB00BEF331A83081A6994B8993F3F5D6EADDDB81872266C87C018FB4162F5AF347B483E24620207'
sm2_crypt = sm2.CryptSM2(public_key=public_key, private_key=private_key)
# plpy.info(sm2_crypt)

# 数据和加密后数据为bytes类型再转换为b64encode
encode_info = sm2_crypt.encrypt(str.encode(encoding='utf-8'))
encode_info = b64encode(encode_info).decode()

# 控制台打印信息
# plpy.info("----encode_info----",encode_info)
return encode_info
$$ LANGUAGE plpython3u;


-- 测试enc_str加密算法
select enc_str('ddd');

-- 创建测试表
create table sm2_return(renturn varchar) DISTRIBUTED BY (renturn);

-- 插入加密后的数据
insert into sm2_return select enc_str('sm2test')::varchar;
select * from sm2_return;


-- 国密sm2解密，传入b64加密的值，然后再加密传到sm2解密
CREATE or replace FUNCTION dec_str(str varchar) 
  RETURNS varchar
AS $$
import sys
from base64 import b64encode, b64decode
import binascii
from gmssl import sm2, func
# 16进制的公钥和私钥
private_key = '00B9AB0B828FF68872F21A837FC303668428DEA11DCD1B24429D0C99E24EED83D5'
public_key = 'B9C9A6E04E9C91F7BA880429273747D7EF5DDEB0BB2FF6317EB00BEF331A83081A6994B8993F3F5D6EADDDB81872266C87C018FB4162F5AF347B483E24620207'
sm2_crypt = sm2.CryptSM2(public_key=public_key, private_key=private_key)
 
decode_info = sm2_crypt.decrypt(b64decode(str.encode())).decode(encoding="utf-8")

# 打印返回信息
# plpy.info("----decode_info----",decode_info)

return decode_info
$$ LANGUAGE plpython3u;


--  进行解密查看返回值
select dec_str(renturn) from sm2_return;

```

# 参考资料
```
-- 国密相关的资料
1、 https://www.zhihu.com/question/48777504
2、https://baijiahao.baidu.com/s?id=1629915330021466224&wfr=spider&for=pc
3、https://github.com/duanhongyi/gmssl
4、https://www.cnblogs.com/wonz/p/14181844.html

-- 更多语言实现方式
https://download.csdn.net/download/ererfei/9474502
https://github.com/NEWPLAN/SMx

```

