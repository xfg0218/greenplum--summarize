
import org.bouncycastle.math.ec.ECPoint;

import java.math.BigInteger;

public class SM2Main {

  /** 元消息串 */
  private static final String sourceStr = "hello,Postgres";
  /** 测试私钥 */
  private static final String PRIVATE_KEY_STR =
      "85372687805075527629037692247722359815733002437633495568455913737414189947734";

  public static void main(String[] args) {

    SM2Util sm2 = new SM2Util();
    BigInteger privateKey = new BigInteger(PRIVATE_KEY_STR);
    ECPoint publicKey = sm2.getPublicKeyByPrivateKey(privateKey);
    String strEncrypt = sm2.encrypt(sourceStr, publicKey);
    System.out.println("加密消息:\n" + strEncrypt);
    String strDecrypt = sm2.decrypt(strEncrypt, privateKey);
    System.out.println("解密消息:\n" + strDecrypt);
  }

  /** 生成秘钥测试 */
  public static void generateKeyPair() {
    SM2Util sm2 = new SM2Util();
    SM2KeyPair keyPair = sm2.generateKeyPair();
    System.out.println("公钥：" + keyPair.getPublicKey());
    System.out.println("私钥：" + keyPair.getPrivateKey());
  }
}
