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

import MacraigorJtagioPkg.MacraigorJtagio;
import YvonnePkg.DACCntr;

public class yvonne_test {

	
	public static void main(String[] args) {
		double pvdd = 3.3;
		double ana33 = 3.3;
		double v0 = 1;
		double ana18 = 1;
		double vrefp = 1.4;
		double vrefn = 0.9;
		double Iin = 1.8;
		double vcm = 1;
		double vrst = 0.6; 
		double dac_values[] = {pvdd,ana33,v0, ana18, vrefp, vrefn, Iin, vcm, vrst};
		DACCntr yvonne = new DACCntr(dac_values,1);
	/*	try {
		  Runtime.getRuntime().exec("cmd /c yvonneutil < ./src/YvonneCmds/test_hv.txt");
		} catch (IOException e) {
            System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
        } */
	} 
		
}
