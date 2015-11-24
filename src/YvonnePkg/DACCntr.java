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
	private static int idx_board;
	public static double ana18_min;
	public static double ana18_max;
	public static double ana33_min;
	public static double ana33_max;
	public static int levels = (int) Math.pow (2.0, bits);
	public String dac_reg[] = new String[ch_length];
	
	public DACCntr(double dac_values[], int idx_board) { 
		/*0  PVDD;
		  1  ana33
		  2  v0
		  3  ana18
		  4  vrefp
		  5  vrefn
		  6  Iin
		  7  vcm
		  8  vrst */
		this.idx_board = idx_board;
		System.out.println("Start writing DAC registers.");
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
		switch (this.idx_board) {
			case 1:
		        switch (idx) { // board #3
		        	case 0:  max = 2.7964; min = 0.93603; break;   //PVDD		 
		            case 1:  max = 2.8097; min = 0.93923; ana33_max = max; ana33_min = min; break;  //ana33           
		            case 2:  max = 1.5261; min = 0.50989; break;  //v0		 
		            case 3:  max = 1.53015;  min = 0.511715; ana18_max = max; ana18_min = min;  break; //ana18		 
		            case 4:  max = 1.5221; min = 0.503785;  break;  //vrefp			 
		            case 5:  max = 1.5274; min = 0.508115;  break; //vrefn	   		 			 		
		            case 6:  max = 1.5300;  min = 0.51029; break; //Iin				
		            case 7:  max = 1.0295; min = 0.342625; break; //vcm
		            case 8:  max = 1.027395;  min = 0.34183; break; //vrst   		
		            default: max = 1.527; min = 0.50782; break;
		        } break;
			case 2:
		        switch (idx) { // board #3
		        	case 0:  max = 2.8061; min = 0.9336; break;   //PVDD		 
		            case 1:  max = 2.8088; min = 0.93610; ana33_max = max; ana33_min = min; break;  //ana33           
		            case 2:  max = 1.5244; min = 0.50560; break;  //v0		 
		            case 3:  max = 1.5233;  min = 0.504575; ana18_max = max; ana18_min = min;  break; //ana18		 
		            case 4:  max = 1.5290; min = 0.51005;  break;  //vrefp			 
		            case 5:  max = 1.5302; min = 0.50886;  break; //vrefn	   		 			 		
		            case 6:  max = 1.5300;  min = 0.51029; break; //Iin				
		            case 7:  max = 1.02520; min = 0.33894; break; //vcm
		            case 8:  max = 1.02968;  min = 0.34331; break; //vrst   		
		            default: max = 1.527; min = 0.50782; break;
		        } break;
			case 3:
		        switch (idx) { // board #3
		        	case 0:  max = 2.7893; min = 0.93013; break; //PVDD		 
		            case 1:  max = 2.8118; min = 0.93892; ana33_max = max; ana33_min = min; break;//ana33          
		            case 2:  max = 1.5231; min = 0.50546; break;   //v0		
		            case 3:  max = 1.5269;  min = 0.507665; ana18_max = max; ana18_min = min;  break;//ana18	 
		            case 4:  max = 1.5238; min = 0.51115;  break;	//vrefp 				 
		            case 5:  max = 1.5232; min = 0.51329;  break;	//vrefn		
		            case 6:  max = 1.5311;  min = 0.51323;  break;	 //Iin	
		            case 7:  max = 1.02660; min = 0.34154;  break;//vcm       
		            case 8:  max = 1.02636;  min = 0.33923;  break;//vrst
		            default: max = 1.527; min = 0.50782; break;
		        } break;
			case 4:
		        switch (idx) { // board #3
	        	case 0:  max = 2.7896; min = 0.9295; break;   //PVDD		 
	            case 1:  max = 2.8064; min = 0.93541; ana33_max = max; ana33_min = min; break; //ana33           
	            case 2:  max = 1.5306; min = 0.50754; break;  //v0		 
	            case 3:  max = 1.5325;  min = 0.51218; ana18_max = max; ana18_min = min;  break; //ana18		 
	            case 4:  max = 1.5258; min = 0.504675;  break;  //vrefp			 
	            case 5:  max = 1.5329; min = 0.51276;  break; //vrefn	   		 			 		
	            case 6:  max = 1.5300;  min = 0.51029; break; //Iin				
	            case 7:  max = 1.02968; min = 0.34323; break; //vcm
	            case 8:  max = 1.02576;  min = 0.34006; break; //vrst   		
	            default: max = 1.527; min = 0.50782; break;
	        } break;
	        default: max = 1.5; min = 0.5; break;
		}
		double rsl = (max-min)/levels*2;	
		double value1 = value;
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
			File file = new File("src/YvonneCmds/DAC_single_reg.txt");
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
	
	public void SetAllSupply(double vlow, double vhigh){
		try {
			File file = new File("./src/YvonneCmds/supply_regs.txt");
			if (!file.exists()) {
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			//set avdd18, dvdd18, iovdd18
			int vlow_reg =(int) Math.round((vlow-1.8)/0.003773);
			if (vlow_reg < 0 ) vlow_reg = -1*vlow_reg + 128;
			bw.append("w 20 f8 ").append(Integer.toHexString(vlow_reg)).append("\n");	
			bw.append("w 20 f9 ").append(Integer.toHexString(vlow_reg)).append("\n");	
			bw.append("w 20 fa ").append(Integer.toHexString(vlow_reg)).append("\n");
			//set dvdd33, iovdd33
			int vhigh_reg = (int) Math.round((vhigh-3.3)/0.005282);
			if (vhigh_reg < 0 ) vhigh_reg = -1*vhigh_reg + 128;
			bw.append("w 20 fb ").append(Integer.toHexString(vhigh_reg)).append("\n");	
			
			bw.write("q");
			bw.close();
			fw.close();
			System.out.println("Finish writing supply registers.");
		} catch (IOException e) {
			e.printStackTrace();
		}
		// Execute I2C
		try {
			System.out.println("Reach here, supply setting ");
		    Runtime.getRuntime().exec("cmd /c I2CTool < ./src/YvonneCmds/supply_regs.txt");
			  
		} catch (IOException e) {
        	System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
	    }	
	}
}