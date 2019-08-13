package com.chinadaas.test;

import com.chinadaas.utils.ConfigureFileValue;

public class Test {

	public static void main(String[] args) {
		System.out.println("oracleURL:"+ConfigureFileValue.getConfigureValue("oraclepassword"));
	}
	
}
