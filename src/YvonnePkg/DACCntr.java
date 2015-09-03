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
	/* Default DAC values
	private double pvdd_value = 3.3;
	private double ana33_value = 3.3;
	private double v0_value = 1;
	private double ana18_value = 1;
	private double vrefp_value = 1.4;
	private double vrefn_value = 0.9;
	private double Iin_value = 3.3;
	private double vcm_value = 1;
	private double vrst_value = 0.6; */
	private int ch_length = 9;
	private int bits = 16;
	private int levels = (int) Math.pow (2.0, bits);
	
	public DACCntr(double dac_values[]) { 
		/*0  PVDD;
		  1  ana33
		  2  v0_value
		  3  ana18
		  4  vrefp
		  5  vrefn
		  6  Iin
		  7  vcm
		  8  vrst */
		System.out.println("Start writing DAC registers.");
		String dac_reg[] = new String[ch_length];	
		Encoder(0, 1, 3.8, 0, dac_reg, dac_values);
		Encoder(2, 6, 1.8, 0, dac_reg, dac_values);
		Encoder(7, 8, 1.4, 0, dac_reg, dac_values);
		WriteToFile(dac_reg);
	} // CONSTRUCTOR
		
		public void Encoder(int start_idx, int end_idx, double max, double min, String reg[], double values[]) {
			double rsl = (max-min)/levels;	
			for (int i = start_idx ; i <= end_idx; i++) {
				double value = values[i];
				if (value >=max) value = max-rsl;
				if (value <=min) value = min;
				int reg_int = (int) Math.round(value/rsl);
				reg[i] = Integer.toHexString(reg_int);
				reg[i] = "0000".substring(reg[i].length()) + reg[i];	
				System.out.println( i + "  " + values[i] + " " + reg[i]);
			}
		}
		
		public void WriteToFile(String reg[]){
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
	
}