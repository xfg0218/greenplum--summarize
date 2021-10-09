# 国密算法的介绍

| 序号 | 算法种类 | 算法是否公开 | 算法的长度 | 算法特点 | JAVA算法制作方法 | 国家密码管理局资料 |
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
| 1 | SM1 | 不公开 | 分组128bit | 需要通过加密芯片的接口进行调用 | [java代码实现](https://download.csdn.net/download/ererfei/9474502) | |
| 2 | SM2 | 公开 | ECC 256位 | "故其签名速度与秘钥生成速度都快于RSA，安全强度比RSA 2048位高，但运算速度快于RSA"	 | [国密算法SM2证书制作](https://blog.csdn.net/kimwu/article/details/14452913) | [SM2密码算法使用规范](http://www.oscca.gov.cn/sca/xxgk/2012-11/22/content_1002397.shtml) |
| 3 | SM3 | 公开 | 校验结果为256位 | SM3算法的安全性要高于MD5算法和SHA-1算法 | [国密SM3的java实现](https://blog.csdn.net/ye_xiao_yu/article/details/80600159) | [SM3密码杂凑算法](http://www.oscca.gov.cn/sca/xxgk/2010-12/17/content_1002389.shtml) |
| 4 | SM4 | 公开 | 分组128bit | "SM4算法与AES算法具有相同的密钥长度分组长度128比特，因此在安全性上高于3DES算法" | [java代码实现](https://download.csdn.net/download/ererfei/9474502) | [祖冲之序列密码算法](http://www.sca.gov.cn/sca/xwdt/2012-03/21/content_1002392.shtml) |