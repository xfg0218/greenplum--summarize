package com.chinadaas.utils;

import java.io.Reader;
import java.sql.Clob;

/**
 * ascii 去除类
 * 
 * @author xiaoxu
 *
 */
public class AsciiTranUtils {
	
	/**
	 * 去除回车换行,以及常见的ascii符号,以及'符号,如果多次字符注重的请注意
	 * ascii详情请查看:https://blog.csdn.net/xfg0218/article/details/80901752
	 * 
	 * @param clob clob 字段
	 * @return
	 */
	public static StringBuffer toStringBuffer(Clob clob) {
	    try {
	        Reader reader = clob.getCharacterStream();
	        if (reader == null) {
	            return null;
	        }
	        StringBuffer sb = new StringBuffer();
	        char[] charbuf = new char[4096];
	        for (int i = reader.read(charbuf); i > 0; i = reader.read(charbuf)) {
	            sb.append(charbuf, 0, i);
	        }
	     return new StringBuffer(sb.toString().replaceAll("'","").replaceAll("[\\x01-\\x1f]", "").replace("\0", ""));
	    } catch (Exception e) {
		    e.printStackTrace();
	    }
		return null;
	}
}
