
import org.bouncycastle.math.ec.ECPoint;

import java.math.BigInteger;

public class SM2KeyPair {
  /** 公钥 */
  private final ECPoint publicKey;

  /** 私钥 */
  private final BigInteger privateKey;

  public SM2KeyPair(ECPoint publicKey, BigInteger privateKey) {
    this.publicKey = publicKey;
    this.privateKey = privateKey;
  }

  public ECPoint getPublicKey() {
    return publicKey;
  }

  public BigInteger getPrivateKey() {
    return privateKey;
  }
}
