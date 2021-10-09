# Paillier同态加密

## 什么是同态加密
1、[阿里巴巴解读为什么要用同态加密](https://mp.weixin.qq.com/s/zF-0KAAtaiNDB6TAa6t89Q)

2、[同态加密与共享协同过滤](https://blog.angelmsger.com/%E5%90%8C%E6%80%81%E5%8A%A0%E5%AF%86%E4%B8%8E%E5%85%B1%E4%BA%AB%E5%8D%8F%E5%90%8C%E8%BF%87%E6%BB%A4/)

3、[腾讯云同态加密支持说明](https://cloud.tencent.com/document/product/663/37648)


## 安装同态加密算法需要的包
``` shell
yum install gcc libffi-devel python-devel openssl-devel -y
yum install python-devel
yum install gmp-devel

/usr/bin/python3 -m pip install  gmpy
/usr/bin/python3 -m pip install gmpy2
/usr/bin/python3 -m pip install libnum
/usr/bin/python3 -m pip install phe

curl https://gcc.gnu.org/pub/gcc/infrastructure/mpc-1.0.3.tar.gz | tar xz
cd mpc-1.0.3
./configure
make && make install

```

## 案例1介绍

### 代码

``` python
#  vim   test.py
import gmpy2 as gy
import random
import time
import libnum

class Paillier(object):
    def __init__(self, pubKey=None, priKey=None):
        self.pubKey = pubKey
        self.priKey = priKey

    def __gen_prime__(self, rs):
        p = gy.mpz_urandomb(rs, 1024)
        while not gy.is_prime(p):
            p += 1
        return p

    def __L__(self, x, n):
        res = gy.div((x - 1), n)
        # this step is essential, directly using "/" causes bugs
        # due to the floating representation in python
        return res

    def __key_gen__(self):
        # generate random state
        while True:
            rs = gy.random_state(int(time.time()))
            p = self.__gen_prime__(rs)
            q = self.__gen_prime__(rs)
            n = p * q
            lmd =(p - 1) * (q - 1)
            # originally, lmd(lambda) is the least common multiple.
            # However, if using p,q of equivalent length, then lmd = (p-1)*(q-1)
            if gy.gcd(n, lmd) == 1:
                # This property is assured if both primes are of equal length
                break
        g = n + 1
        mu = gy.invert(lmd, n)
        #Originally,
        # g would be a random number smaller than n^2,
        # and mu = (L(g^lambda mod n^2))^(-1) mod n
        # Since q, p are of equivalent length, step can be simplified.
        self.pubKey = [n, g]
        self.priKey = [lmd, mu]
        return

    def decipher(self, ciphertext):
        n, g = self.pubKey
        lmd, mu = self.priKey
        m =  self.__L__(gy.powmod(ciphertext, lmd, n ** 2), n) * mu % n
        print("raw message:", m)
        plaintext = libnum.n2s(int(m))
        return plaintext

    def encipher(self, plaintext):
        m = libnum.s2n(plaintext)
        n, g = self.pubKey
        r = gy.mpz_random(gy.random_state(int(time.time())), n)
        while gy.gcd(n, r)  != 1:
            r += 1
        ciphertext = gy.powmod(g, m, n ** 2) * gy.powmod(r, n, n ** 2) % (n ** 2)
        return ciphertext

if __name__ == "__main__":
    pai = Paillier()
    pai.__key_gen__()
    pubKey = pai.pubKey
    print("Public/Private key generated.")
    plaintext = input("Enter your text: ")
    # plaintext = 'Cat is the cutest.'
    print("Original text:", plaintext)
    ciphertext = pai.encipher(plaintext)
    print("Ciphertext:", ciphertext)
    deciphertext = pai.decipher(ciphertext)
    print("Deciphertext: ", deciphertext)

```

### 运行效果
``` shell
# /usr/bin/python3 test.py
Public/Private key generated.
Enter your text: matrixdb
Original text: matrixdb
Ciphertext: 452004181584398320009887244530753781056608180144588113485863496914206075611222066770229479069903337767410588365455560797596871930831486870079530363697116168960869784127421137098059303564523795028664068293951658405621406503426970443438345910325180005619733526922585962719525688748936718554278285707202894634592962887738533265635694173065702679388862157062755685875978548015895313148525518071926170831444856213958552791170475174298759822853088199514507342730190179430887448262659009580197480758019470086408948861641285270756247149149106074692863301030039699778647979578229978256387722091232245467864143415671316034964041558918360961691355507759773152672992334600749430603953690319497858867991338319120812515681892557416453659842138024915311411571081641133574944177495685270551571672946492682388451777997933530565071844973510986644808255637873836476334419241966161185584580369436650873124905308638314185488536742481426575872326377806861014737357575123222969707789440164762147230390004940694882483986654184049289271024834533723819209623997082008728867403151126223844620173083239991686663123133774132209685082501402145168057822902567190092820975506829092616348992761244209651376896465984575700251206122475394424179008891314330533511437641
raw message: 7881708857619670114
Deciphertext:  b'matrixdb'

```


## 案例2介绍

``` python
from phe import paillier # 开源库
import time # 做性能测试

# 测试paillier参数
print("默认私钥大小：",paillier.DEFAULT_KEYSIZE) #2048
# 生成公私钥
public_key,private_key = paillier.generate_paillier_keypair()
# 测试需要加密的数据
message_list = [3.1415926,100,-4.6e-12]
print("需要加密的数据",message_list)
# 加密操作
time_start_enc = time.time()
encrypted_message_list = [public_key.encrypt(m) for m in message_list]
time_end_enc = time.time()
print("encrypted_message ：",encrypted_message_list)
print("加密耗时ms：",time_end_enc-time_start_enc)
# 解密操作
time_start_dec = time.time()
decrypted_message_list = [private_key.decrypt(c) for c in encrypted_message_list]
time_end_dec = time.time()
print(" decrypted_message_list ：", decrypted_message_list)
print("解密耗时ms：",time_end_dec-time_start_dec)
# print(encrypted_message_list[0])
print("原始数据:",decrypted_message_list)

# 测试加法和乘法同态
a,b,c = encrypted_message_list # a,b,c分别为对应密文

a_sum = a + 5 # 密文加明文
a_sub = a - 3 # 密文加明文的相反数
b_mul = b * 1 # 密文乘明文,数乘
c_div = c / -10.0 # 密文乘明文的倒数

# print("a:",a.ciphertext()) # 密文a的纯文本形式
# print("a_sum：",a_sum.ciphertext()) # 密文a_sum的纯文本形式

print("a+5=",private_key.decrypt(a_sum))
print("a-3",private_key.decrypt(a_sub))
print("b*1=",private_key.decrypt(b_mul))
print("c/-10.0=",private_key.decrypt(c_div))

##密文加密文
print((private_key.decrypt(a)+private_key.decrypt(b))==private_key.decrypt(a+b))

```

### 运行效果
``` shell
# /usr/bin/python3 sdf.py
默认私钥大小： 2048
需要加密的数据 [3.1415926, 100, -4.6e-12]
encrypted_message ： [<phe.paillier.EncryptedNumber object at 0x7ff85470bb70>, <phe.paillier.EncryptedNumber object at 0x7ff85470bb38>, <phe.paillier.EncryptedNumber object at 0x7ff8570eb898>]
加密耗时ms： 0.02731919288635254
 decrypted_message_list ： [3.1415926, 100, -4.6e-12]
解密耗时ms： 0.007689952850341797
原始数据: [3.1415926, 100, -4.6e-12]
a+5= 8.1415926
a-3 0.14159260000000007
b*1= 100
c/-10.0= 4.6e-13
True
```


