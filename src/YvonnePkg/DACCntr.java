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
	public String dac_reg[] = new String[ch_length];
	
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
		//String dac_reg[] = new String[ch_length];	
		for (int i = 0; i < ch_length; i++) {
			Encoder(i, dac_reg, dac_values[i]);
		}
		WriteAllDAC(dac_reg);
	} // CONSTRUCTOR
	
	/*
	 * Given the register name, this function finds its 
	 * corresponding register address.
	 */
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

	/*
	 * This function encodes value of register idx and store 
	 * it at reg[idx].
	 */
	public void Encoder(int idx, String reg[], double value) {
		double min;
		double max; 
        switch (idx) { // board #3
        	case 0:  max = 2.8050;	//PVDD
        			 min = 0.93424;
        			 break;
            case 1:  max = 2.8118;	//ana33
            		 min = 0.93903;
                     break;
            case 2:  max = 1.5234;  //v0
   		 			 min = 0.50556; 
   		 			 break;  
            case 3:  max = 1.527;   //ana18
   		 			 min = 0.50782;
   		 			 break;
            case 4:  max = 1.5290;  //vrefp
   		 			 min = 0.5103;
   		 			 break;		 
            case 5:  max = 1.5285;  //vrefn
   		 			 min = 0.50886;
   		 			 break;	
            case 6:  max = 1.5311;  //Iin
   		 			 min = 0.51323;
   		 			 break;	
            case 7:  max = 1.02667; //vcm
            		 min = 0.34162;
                     break;
            case 8:  max = 1.02633; //vrst
            	 	 min = 0.3393;
            		 break;
            default: max = 1.527;
            		 min = 0.50782;
                     break;
        }
		double rsl = (max-min)/levels*2;	
		double value1 = value;
		//if (value1 >=max) value1 = max-rsl;
		//if (value1 <=min) value1 = min;
		int reg_int = (int) Math.round((value1-min)/rsl) + levels/4;
		reg[idx] = Integer.toHexString(reg_int);
		reg[idx] = "0000".substring(reg[idx].length()) + reg[idx];	
		System.out.println( idx + "  " + value + " " + reg[idx]);
	
	}
	
	/*
	 * This function writes all encoded register Hex values in 
	 * to a Yvonne cmd template file, and execute Yvonne process. 
	 */
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
				bw.append("v ").append("13").append(Integer.toString(i-7));		
				bw.append(reg[i]);
				bw.write("0\n");
			}
			bw.write("q");
			bw.close();
			fw.close();
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
	
	/*
	 * Given the register name and value of it to be encoded, this 
	 * function will write the encoded register to Yvonne cmd 
	 * template and executes it right away.
	 */
	public void WriteDACValue(String name, double value, String reg[]  ){
		int idx = FindIdxofName(name);
		Encoder(idx, reg, value);
		WriteDACReg(idx, reg[idx]);
		System.out.println("Write to " + name + " with value " + value + "(" + reg[idx] + ")");
	}
	
	/*
	 * Given the register address and its Hex value to be written,
	 * This function generates the corresponding Yvonne cmd template
	 * and executes it right away.
	 */
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
			fw.close();
			
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
	
	public int GetChannelNum(){
		return ch_length;
	}
	
}