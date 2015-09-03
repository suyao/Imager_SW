/**
 * File: DACCntr.java
 * 
 * This document is a part of Imager project.
 *
 * Copyright (c) 2015 Suyao Ji
 *
 */
package YvonnePkg;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class DACCntr
{
	private static int ch_length = 9;
	private static int bits = 16;
	public static int levels = (int) Math.pow (2.0, bits);
	
	public DACCntr(double dac_values[]) { 
		/*0  PVDD;
		  1  ana33
		  2  v0
		  3  ana18
		  4  vrefp
		  5  vrefn
		  6  Iin
		  7  vcm
		  8  vrst */
		System.out.println("Start writing DAC registers.");
		String dac_reg[] = new String[ch_length];	
		for (int i = 0; i < ch_length; i++) {
			Encoder(i, dac_reg, dac_values[i]);
		}
		/* Encoder(0, 1, 3.8, 0, dac_reg, dac_values);
		Encoder(2, 6, 1.8, 0, dac_reg, dac_values);
		Encoder(7, 8, 1.4, 0, dac_reg, dac_values); */
		WriteAllDAC(dac_reg);
	} // CONSTRUCTOR
		
	public void Encoder(int idx, String reg[], double value) {
		double min = 0;
		double max; 
        switch (idx) {
        	case 0:  max = 3.8;
        			 break;
            case 1:  max = 3.8;
                     break;
            case 7:  max = 1.4;
                     break;
            case 8:  max = 1.4;
            		 break;
            default: max = 1.8;
                     break;
        }
		double rsl = (max-min)/levels;	
		double value1 = value;
		if (value1 >=max) value1 = max-rsl;
		if (value1 <=min) value1 = min;
		int reg_int = (int) Math.round((value1-min)/rsl);
		reg[idx] = Integer.toHexString(reg_int);
		reg[idx] = "0000".substring(reg[idx].length()) + reg[idx];	
		System.out.println( idx + "  " + value + " " + reg[idx]);
	
	}
	
	public void WriteAllDAC(String reg[]){
		try {
			File file = new File("./src/YvonneCmds/DAC_regs.txt");
			if (!file.exists()) {
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			// channel 0;
			for (int i = 0; i <= 6; i++) {
				bw.append("v ").append("03").append(Integer.toString(i));				
				bw.append(reg[i]);
				bw.write("0\n");
			}
			// channel 1;
			for (int i = 7; i <= 8; i++) {
				bw.append("v ").append("13").append(Integer.toString(i-6));		
				bw.append(reg[i]);
				bw.write("0\n");
			}
			bw.write("q");
			bw.close();
			System.out.println("Finish writing DAC registers.");
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		// Execute YvonneUtil
		try {
		    Runtime.getRuntime().exec("cmd /c yvonneutil < ./src/YvonneCmds/DAC_regs.txt");
			  
		} catch (IOException e) {
        	System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
	    }		
	}
		
	public void WriteDACValue(String name, double value, String reg[]  ){
		int idx = FindIdxofName(name);
		Encoder(idx, reg, value);
		WriteDACReg(idx, reg[idx]);
		System.out.println("Write to " + name + "with value " + value + "(" + reg + ")");
	}
	
	public void WriteDACReg(int idx, String reg){
		try {
			File file = new File("./src/YvonneCmds/DAC_single_reg.txt");
			if (!file.exists()) {
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			// channel 0;
			if (idx <=6) {
				bw.append("v ").append("03").append(Integer.toString(idx));				
				bw.append(reg);
				bw.write("0\n");
			}
			// channel 1;
			else {
				bw.append("v ").append("13").append(Integer.toString(idx-6));		
				bw.append(reg);
				bw.write("0\n");
			}
			bw.write("q");
			bw.close();
			
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		// Execute YvonneUtil
		try {
		    Runtime.getRuntime().exec("cmd /c yvonneutil < ./src/YvonneCmds/DAC_single_reg.txt");
			  
		} catch (IOException e) {
        	System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
	    }	
	}
	
	public int FindIdxofName(String name){
		int idx;
		switch (name) {
    	case "PVDD":  idx = 0;
    			 break;
    	case "ana33":  idx = 1;
		 		 break;
    	case "v0":  idx = 2;
                 break;
    	case "ana18":  idx = 3;
        		 break;
    	case "vrefp":  idx = 4;
		 		 break;
    	case "vrefn":  idx = 5;
		 		 break;
    	case "Iin":  idx = 6;
		 		 break;
    	case "vcm":  idx = 7;
		 		 break;
    	case "vrst":  idx = 8;
		 		 break;
        default: idx = 0;
        	System.out.println( "ERROR: Unkown DAC register name " + name + " !!! ");
                 break;
		}
		return idx;
	}
}