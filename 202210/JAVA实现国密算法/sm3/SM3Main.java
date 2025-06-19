
import org.bouncycastle.util.encoders.Hex;

public class SM3Main {
  public static void main(String[] args) {
    byte[] strFinal = new byte[32];
    byte[] sourceMsg = "hello,Postgres".getBytes();
    SM3Digest sm3 = new SM3Digest();
    sm3.update(sourceMsg, 0, sourceMsg.length);
    sm3.doFinal(strFinal, 0);
    String strReturn = new String(Hex.encode(strFinal));
    System.out.println("SM3 Return: \n" + strReturn);
  }
}
