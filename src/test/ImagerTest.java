/**
 * File: ImagerTest.java
 * 
 * This document is a part of SAGE_SW project.
 *
 * Copyright (c) 2015 Jing Pu
 *
 */
package test;

import MacraigorJtagioPkg.JtagDriver;
import MacraigorJtagioPkg.ImagerCntr;
import MacraigorJtagioPkg.MacraigorJtagio;
import MacraigorJtagioPkg.JtagDriver.ClockDomain;
import YvonnePkg.DACCntr;

import java.io.*;
/**
 * Test the ArrayDriver and JtagDriver class on image sensor board
 * 
 * @author suyao
 *
 */
public class ImagerTest {

	/* ImagerChip configuration. */
	static int tc_data_width = 32;
	static int tc_addr_width = 12;
	static int sc_data_width = 16;
	static int sc_addr_width = 8;

	
	static void flashLed(MacraigorJtagio jtag, int times, int interval) {
		assert (jtag.Initialized());
		try {
			for (int i = 0; i < times; i++) {
				jtag.UsbLed(false);
				Thread.sleep(500);
				jtag.UsbLed(true);
				Thread.sleep(500);
			}
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

	
	/**
	 * This task writes a random SENSOR_SEL value into each pixel in the array,
	 * and then checks the array consistency by reading out all the regs inside
	 * the array.
	 * 
	 * @param jdrv
	 *            JTAG driver

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		JtagDriver jdrv = new JtagDriver(16, 8, 32, 12);
		// Initialize jtag
		MacraigorJtagio jtag = new MacraigorJtagio();
		jdrv.InitializeController("USB", "USB0", 1);
		flashLed(jtag, 3, 500);
		// Reset JTAG
		jdrv.reset();
		// Read IDCODE
		System.out.println("IDCODE: " + jdrv.readID());

		// System reset
		jdrv.writeReg(ClockDomain.tc_domain, "000", "00000001"); // eight hex digits b/c_data_width=32
		jdrv.writeReg(ClockDomain.tc_domain, "000", "00000000");
		
		
		//Set DAC Values
		DACCntr yvonne = InitDAC();
		//Analog Sampler test
		
		//ADC calibration
		int dummyFlag = 1; // 1 if dummy ADC, 0 if ADC
		CalibrateADC(dummyFlag, 100, yvonne, jdrv); //repeat every analog value for 100 conversions
		
		//
		
		jdrv.CloseController();
	}
	
	static void InitJTAG(JtagDriver jdrv){
		ImagerCntr imager = new ImagerCntr(jdrv);
		double tsmp = 96*Math.pow(10, -9); //96ns
		imager.ScanMode(true);
		imager.SetSmpPeriod(tsmp);
		
	}
	static DACCntr InitDAC() {
		//Set DAC Values
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
		DACCntr yvonne = new DACCntr(dac_values);
		return yvonne;
	}
	
	static void CalibrateADC(int dummyFlag, int itr_times, DACCntr yvonne, JtagDriver jdrv){
		try {
			File file = new File("./outputs/CalibrateADC/ADC_output.txt");
			if (!file.exists()) {
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			String jtag_adc_out_addr ="";
			if (dummyFlag ==1) {
				jdrv.writeReg(ClockDomain.tc_domain, "420", "00000000"); //disable adc		
				jdrv.writeReg(ClockDomain.tc_domain, "424", "00000001"); //enable dummy adc
				jtag_adc_out_addr = "004";
				
			}
			else{
				jdrv.writeReg(ClockDomain.tc_domain, "420", "00000001"); //enable adc		
				jdrv.writeReg(ClockDomain.tc_domain, "424", "00000000"); //disable dummy adc
				jdrv.writeReg(ClockDomain.tc_domain, "404", "00000001"); //adc input is from ana18
			}
			int idx = yvonne.FindIdxofName("ana18");
			for (int reg_int = 0; reg_int < DACCntr.levels; reg_int ++){
				String reg_str = Integer.toHexString(reg_int);
				reg_str = "0000".substring(reg_str.length()) + reg_str; 
				yvonne.WriteDACReg(idx, reg_str); //Write to Yvonne
				String ADC_out_str = "";
				for (int itr = 0 ; itr < itr_times; itr++){ //average readings to eliminate noise
				    ADC_out_str = jdrv.readReg(ClockDomain.sc_domain, jtag_adc_out_addr); //JTAG readout
					bw.write(Integer.toString(reg_int) + " " + ADC_out_str +"\n");
				}
				System.out.println("Input: " + reg_str + ", Output: " + ADC_out_str);
			}
			bw.close();
			
		} catch (IOException e) {
			e.printStackTrace();
		}		
	}

}
