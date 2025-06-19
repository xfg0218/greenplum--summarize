
import org.bouncycastle.crypto.DerivationFunction;
import org.bouncycastle.crypto.digests.SHA256Digest;
import org.bouncycastle.crypto.digests.ShortenedDigest;
import org.bouncycastle.crypto.generators.KDF1BytesGenerator;
import org.bouncycastle.crypto.params.ISO18033KDFParameters;
import org.bouncycastle.math.ec.ECCurve;
import org.bouncycastle.math.ec.ECPoint;
import org.bouncycastle.util.encoders.Base64;

import java.math.BigInteger;
import java.security.SecureRandom;
import java.util.Arrays;

public class SM2Util {
  /** 素数p */
  private static final BigInteger p =
      new BigInteger(
          "FFFFFFFE"
              + "FFFFFFFF"
              + "FFFFFFFF"
              + "FFFFFFFF"
              + "FFFFFFFF"
              + "00000000"
              + "FFFFFFFF"
              + "FFFFFFFF",
          16);

  /** 系数a */
  private static final BigInteger a =
      new BigInteger(
          "FFFFFFFE"
              + "FFFFFFFF"
              + "FFFFFFFF"
              + "FFFFFFFF"
              + "FFFFFFFF"
              + "00000000"
              + "FFFFFFFF"
              + "FFFFFFFC",
          16);

  /** 系数b */
  private static final BigInteger b =
      new BigInteger(
          "28E9FA9E"
              + "9D9F5E34"
              + "4D5A9E4B"
              + "CF6509A7"
              + "F39789F5"
              + "15AB8F92"
              + "DDBCBD41"
              + "4D940E93",
          16);

  /** 坐标x */
  private static final BigInteger xg =
      new BigInteger(
          "32C4AE2C"
              + "1F198119"
              + "5F990446"
              + "6A39C994"
              + "8FE30BBF"
              + "F2660BE1"
              + "715A4589"
              + "334C74C7",
          16);

  /** 坐标y */
  private static final BigInteger yg =
      new BigInteger(
          "BC3736A2"
              + "F4F6779C"
              + "59BDCEE3"
              + "6B692153"
              + "D0A9877C"
              + "C62A4740"
              + "02DF32E5"
              + "2139F0A0",
          16);

  /** 基点G, G=(xg,yg),其介记为n */
  private static final BigInteger n =
      new BigInteger(
          "FFFFFFFE"
              + "FFFFFFFF"
              + "FFFFFFFF"
              + "FFFFFFFF"
              + "7203DF6B"
              + "21C6052B"
              + "53BBF409"
              + "39D54123",
          16);

  private static final SecureRandom random = new SecureRandom();
  private final ECCurve.Fp curve;
  private final ECPoint G;

  /**
   * 将字节数组转成base64字符串
   *
   * @param b
   * @return
   */
  private static String toBase64Str(byte[] b) {
    return new String(Base64.encode(b));
  }

  /**
   * base64字符串转成字节数组
   *
   * @param encryptMsg base64字符串
   * @return 转换后的字节数组
   */
  private static byte[] toByteArray(String encryptMsg) {
    return Base64.decode(encryptMsg.getBytes());
  }

  public BigInteger random(BigInteger max) {
    BigInteger r = new BigInteger(256, random);
    // int count = 1;
    while (r.compareTo(max) >= 0) {
      r = new BigInteger(128, random);
      // count++;
    }
    // System.out.println("count: " + count);
    return r;
  }

  private boolean allZero(byte[] buffer) {
    for (int i = 0; i < buffer.length; i++) {
      if (buffer[i] != 0) return false;
    }
    return true;
  }

  /**
   * 加密
   *
   * @param input 待加密消息M
   * @param publicKey 公钥
   * @return byte[] 加密后的字节数组
   */
  public String encrypt(String input, ECPoint publicKey) {

    byte[] inputBuffer = input.getBytes();
    toBase64Str(inputBuffer);

    /* 1 产生随机数k，k属于[1, n-1] */
    BigInteger k = random(n);

    /* 2 计算椭圆曲线点C1 = [k]G = (x1, y1) */
    ECPoint C1 = G.multiply(k);
    byte[] C1Buffer = C1.getEncoded(false);

    /* 4 计算 [k]PB = (x2, y2) */
    ECPoint kpb = publicKey.multiply(k).normalize();

    /* 5 计算 t = KDF(x2||y2, klen) */
    byte[] kpbBytes = kpb.getEncoded(false);
    DerivationFunction kdf = new KDF1BytesGenerator(new ShortenedDigest(new SHA256Digest(), 20));
    byte[] t = new byte[inputBuffer.length];
    kdf.init(new ISO18033KDFParameters(kpbBytes));
    kdf.generateBytes(t, 0, t.length);

    if (allZero(t)) {
      System.err.println("all zero");
    }

    /* 6 计算C2=M^t */
    byte[] C2 = new byte[inputBuffer.length];
    for (int i = 0; i < inputBuffer.length; i++) {
      C2[i] = (byte) (inputBuffer[i] ^ t[i]);
    }

    /* 7 计算C3 = Hash(x2 || M || y2) */
    byte[] C3 =
        calculateHash(kpb.getXCoord().toBigInteger(), inputBuffer, kpb.getYCoord().toBigInteger());

    /* 8 输出密文 C=C1 || C2 || C3 */
    byte[] encryptResult = new byte[C1Buffer.length + C2.length + C3.length];
    System.arraycopy(C1Buffer, 0, encryptResult, 0, C1Buffer.length);
    System.arraycopy(C2, 0, encryptResult, C1Buffer.length, C2.length);
    System.arraycopy(C3, 0, encryptResult, C1Buffer.length + C2.length, C3.length);
    return toBase64Str(encryptResult);
  }

  /**
   * 解密
   *
   * @param encryptMsg 加密消息
   * @param privateKey 私钥
   * @return
   */
  public String decrypt(String encryptMsg, BigInteger privateKey) {
    return this.decrypt(toByteArray(encryptMsg), privateKey);
  }

  public String decrypt(byte[] encryptData, BigInteger privateKey) {
    byte[] C1Byte = new byte[65];
    System.arraycopy(encryptData, 0, C1Byte, 0, C1Byte.length);

    ECPoint C1 = curve.decodePoint(C1Byte).normalize();

    ECPoint dBC1 = C1.multiply(privateKey).normalize();

    byte[] dBC1Bytes = dBC1.getEncoded(false);
    DerivationFunction kdf = new KDF1BytesGenerator(new ShortenedDigest(new SHA256Digest(), 20));

    int klen = encryptData.length - 65 - 20;

    byte[] t = new byte[klen];
    kdf.init(new ISO18033KDFParameters(dBC1Bytes));
    kdf.generateBytes(t, 0, t.length);

    if (allZero(t)) {
      System.err.println("all zero");
    }

    /* 5 计算M'=C2^t */
    byte[] M = new byte[klen];
    for (int i = 0; i < M.length; i++) {
      M[i] = (byte) (encryptData[C1Byte.length + i] ^ t[i]);
    }

    /* 6 计算 u = Hash(x2 || M' || y2) 判断 u == C3是否成立 */
    byte[] C3 = new byte[20];
    System.arraycopy(encryptData, encryptData.length - 20, C3, 0, 20);
    byte[] u = calculateHash(dBC1.getXCoord().toBigInteger(), M, dBC1.getYCoord().toBigInteger());
    if (Arrays.equals(u, C3)) {
      String dMsg = new String(M);
      return dMsg;
    } else {
      toBase64Str(u);
      toBase64Str(C3);
      return "解密验证失败";
    }
  }

  private byte[] calculateHash(BigInteger x2, byte[] M, BigInteger y2) {
    ShortenedDigest digest = new ShortenedDigest(new SHA256Digest(), 20);
    byte[] buf = x2.toByteArray();
    digest.update(buf, 0, buf.length);
    digest.update(M, 0, M.length);
    buf = y2.toByteArray();
    digest.update(buf, 0, buf.length);

    buf = new byte[20];
    digest.doFinal(buf, 0);
    return buf;
  }

  private boolean between(BigInteger param, BigInteger min, BigInteger max) {
    return param.compareTo(min) >= 0 && param.compareTo(max) < 0;
  }

  /**
   * 公钥校验
   *
   * @param publicKey 公钥
   * @return boolean true或false
   */
  private boolean checkPublicKey(ECPoint publicKey) {
    if (!publicKey.isInfinity()) {
      BigInteger x = publicKey.getXCoord().toBigInteger();
      BigInteger y = publicKey.getYCoord().toBigInteger();
      if (between(x, new BigInteger("0"), p) && between(y, new BigInteger("0"), p)) {
        BigInteger xResult = x.pow(3).add(a.multiply(x)).add(b).mod(p);
        System.out.println("xResult: " + xResult);
        BigInteger yResult = y.pow(2).mod(p);
        System.out.println("yResult: " + yResult);
        return yResult.equals(xResult) && publicKey.multiply(n).isInfinity();
      }
      return false;
    } else {
      return false;
    }
  }

  /**
   * 获得公私钥对
   *
   * @return
   */
  public SM2KeyPair generateKeyPair() {
    BigInteger d = random(n.subtract(new BigInteger("1")));
    SM2KeyPair keyPair = new SM2KeyPair(G.multiply(d).normalize(), d);
    if (checkPublicKey(keyPair.getPublicKey())) {
      System.out.println("generate key successfully");
      return keyPair;
    } else {
      System.err.println("generate key failed");
      return null;
    }
  }

  public SM2Util() {
    curve =
        new ECCurve.Fp(
            p, // q
            a, // a
            b); // b
    G = curve.createPoint(xg, yg);
  }

  public ECPoint getPublicKeyByPrivateKey(BigInteger privateKey) {
    return G.multiply(privateKey).normalize();
  }
}
