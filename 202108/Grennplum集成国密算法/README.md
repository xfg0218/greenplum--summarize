# 国家算法的解读
| 序号 | 文章定义 | 文章解读 |
|:----:|:----:|:----:|
| 1 | 国密加密算法有多安全呢？ | https://www.zhihu.com/question/48777504 |
| 2 | 浅谈国密算法 | https://baijiahao.baidu.com/s?id=1629915330021466224&wfr=spider&for=pc |


# 国密算法的介绍

| 序号 | 算法种类 | 算法是否公开 | 算法的长度 | 算法特点 | JAVA算法制作方法 | 国家密码管理局资料 |
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
| 1 | SM1 | 不公开 | 分组128bit | 需要通过加密芯片的接口进行调用 | [java代码实现](https://download.csdn.net/download/ererfei/9474502) | |
| 2 | SM2 | 公开 | ECC 256位 | "故其签名速度与秘钥生成速度都快于RSA，安全强度比RSA 2048位高，但运算速度快于RSA"	 | [国密算法SM2证书制作](https://blog.csdn.net/kimwu/article/details/14452913) | [SM2密码算法使用规范](http://www.oscca.gov.cn/sca/xxgk/2012-11/22/content_1002397.shtml) |
| 3 | SM3 | 公开 | 校验结果为256位 | SM3算法的安全性要高于MD5算法和SHA-1算法 | [国密SM3的java实现](https://blog.csdn.net/ye_xiao_yu/article/details/80600159) | [SM3密码杂凑算法](http://www.oscca.gov.cn/sca/xxgk/2010-12/17/content_1002389.shtml) |
| 4 | SM4 | 公开 | 分组128bit | "SM4算法与AES算法具有相同的密钥长度分组长度128比特，因此在安全性上高于3DES算法" | [java代码实现](https://download.csdn.net/download/ererfei/9474502) | [祖冲之序列密码算法](http://www.sca.gov.cn/sca/xwdt/2012-03/21/content_1002392.shtml) |



# python3 实现sm2 国密算法

## sm2加密算法

```python
/***
国密sm2加密，返回的是b64加密后的值
***/
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
```

## sm2 解密算法
```python
/****
国密sm2解密，传入b64加密的值，然后再加密传到sm2解密
***/
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

```







