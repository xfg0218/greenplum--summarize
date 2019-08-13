package com.chinadaas.utils;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * 配置文件获取类
 * 
 * @author xiaoxu
 *
 */
public class ConfigureFileValue {

	/**
	 * @param key  配置文件的key
	 * @return
	 */
	public static String getConfigureValue(String key){
		String  value= "";
		try {
			Properties properties = new Properties();
			InputStream is = Thread.currentThread().getContextClassLoader()
					.getResourceAsStream("connectionUtils.properties");
			properties.load(is);
			value = (String) properties.getProperty(key);
		} catch (IOException e) {
			e.printStackTrace();
		}
		return value;
	}
	
	
}
