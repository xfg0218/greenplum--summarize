package com.chinadaas.connection;

import java.sql.Connection;
import java.sql.DriverManager;

import com.chinadaas.utils.ConfigureFileValue;

/**
 * oracle  链接工具
 * 
 * @author xiaoxu
 *
 */
public class OracleConnection {
	
	public static void main(String[] args) {
		OracleConnection.oracleDBConn();
	}
	
	/**
	 * oracle 链接
	 * 
	 * @return
	 */
	public static synchronized  Connection oracleDBConn() {
		Connection oracleconn = null;
		String oracledriver = ConfigureFileValue.getConfigureValue("oracledriver");
		String oracleusername = ConfigureFileValue.getConfigureValue("oracleusername");
		String oraclepassword = ConfigureFileValue.getConfigureValue("oraclepassword");
		String oracleURL = ConfigureFileValue.getConfigureValue("oracleURL");
		try {
			Class.forName(oracledriver);
			oracleconn = DriverManager.getConnection(oracleURL, oracleusername, oraclepassword);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return oracleconn;
	}
}
