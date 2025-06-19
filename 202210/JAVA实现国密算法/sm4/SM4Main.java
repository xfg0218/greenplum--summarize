
public class SM4Main {
  public static void main(String[] args) {

    String plainText = "Hello,Postgres";

    SM4Utils sm4 = new SM4Utils();
    sm4.setSecretKey("00B9AB0B828FF688");
    sm4.setHexString(false);

    System.out.println("ECB模式:");
    String cipherText = sm4.encryptData_ECB(plainText);
    System.out.println("ECD加密消息: " + cipherText);
    plainText = sm4.decryptData_ECB(cipherText);
    System.out.println("ECB解密消息: " + plainText);

    System.out.println("\n\nCBC模式:");
    sm4.setIv("00B9AB0B828FF688");
    cipherText = sm4.encryptData_CBC(plainText);
    System.out.println("CBC加密消息: " + cipherText);

    plainText = sm4.decryptData_CBC(cipherText);
    System.out.println("CBC加密消息: " + plainText);
  }
}
