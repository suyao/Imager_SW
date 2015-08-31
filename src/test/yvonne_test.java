/**
 * File: TestJtag.java
 * 
 * This document is a part of SAGE_SW project.
 *
 * Copyright (c) 2014 Jing Pu
 *
 */
package test;


import java.io.*;

public class yvonne_test {

	
	public static void main(String[] args) {
		
		try {
		  Runtime.getRuntime().exec("cmd /c yvonneutil < C:/Users/sony/Documents/sensor_scripts/Imager_SW/src/yvone/test_hv.txt");
		} catch (IOException e) {
            System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
        }
	}
		
}
