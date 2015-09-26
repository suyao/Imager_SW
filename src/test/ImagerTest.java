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
		ImagerCntr imager = new ImagerCntr(jdrv);
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
		InitJTAG(jdrv);
		
		// Analog Sampler Test
		/*
		 * analog test point:
		 * 0	cmp_b  ---------------------------
		 * 1	clk_sar
		 * 2	clk_smp_sync
		 * 3	conv_per_b------------------------
		 * 4	dac_rst
		 * 5	clk_pre_amp
		 * 6	clk_latch      ----------------------------------
		 * 7	pre_amp1_outp ---------------------------
		 * 8	pre_amp1_outn
		 * 9	pre_amp2_outp-------------------------------
		 * 10	pre_amp2_outn
		 * 11	mux[239] ----------------------------------
		 * 12	bl_rst
		 * 13	bitline[0]
		 * 14	bl_to_adc[0] ---------------------------------
		 * 15	bl_to_adc[1] --------------------------------
		 * 16    ana_sampler_trig_sig-----------
		 * 17    ana_sampler_trig_sig
		 * 18   dout_trigger_tp
		 * 19  AVDD18 ------------------
		 * 20  AVDD18 ------------------
		 * 21  VDD -------------------
		 * 22  AVSS
		 * 23  AVSS
		 * 24  VSS
		 * 25  ------------------
		 * 26
		 */
		int sampler_idx = 0;
		//CalibrateSampler(sampler_idx, yvonne, imager);

		/* Ana_sampler_cali_mode
		 * 0: both samplers at signal mode;
		   1: sampler 0 at calibration mode, sampler 1 at signal mode
  		   2: sampler 0 at signal mode, sampler 1 at calibration mode
		   3: both samplers at calibration mode
		 */
		//imager.SetSamplerMode(3);
		//AnalogSampler(0,1,imager);
		
		
		//ADC calibration
		//CalibrateDummyADC(100, yvonne, imager); //repeat every analog value for 100 conversions
		
		//Pixel Readout
		//ImagerDebugModeTest(imager);
		
		jdrv.CloseController();
	}
	
	static void InitJTAG(JtagDriver jdrv){
		ImagerCntr imager = new ImagerCntr(jdrv);
		double tsmp = 96*Math.pow(10, -9); //96ns
		imager.ScanMode(false);
		imager.SetSmpPeriod(tsmp);
		
	}
	static DACCntr InitDAC() {
		//Set DAC Values
		double pvdd = 3.3;
		double ana33 = 3.3;
		double v0 = 1;
		double ana18 = 1.5004;
		double vrefp = 1.4;
		double vrefn = 0.9;
		double Iin = 1.0;
		double vcm = 1.3;
		double vrst = 0.6; 
		double dac_values[] = {pvdd,ana33,v0, ana18, vrefp, vrefn, Iin, vcm, vrst};
		DACCntr yvonne = new DACCntr(dac_values);
		return yvonne;
	}
	
	static void CalibrateDummyADC(int itr_times, DACCntr yvonne, ImagerCntr imager){
		
		try {
			File file = new File("./outputs/CalibrateADC/dummy_ADC_output.txt");
			if (!file.exists()) {
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			
			imager.EnableADC(false); // disable adc
			imager.EnableDummyADC(true); // enable dummy adc
			int idx = yvonne.FindIdxofName("ana18");
			for (int reg_int = 0; reg_int < DACCntr.levels; reg_int ++){
				String reg_str = Integer.toHexString(reg_int);
				reg_str = "0000".substring(reg_str.length()) + reg_str; 
				yvonne.WriteDACReg(idx, reg_str); //Write to Yvonne
				String ADC_out_str = "";
				for (int itr = 0 ; itr < itr_times; itr++){ //average readings to eliminate noise
				    ADC_out_str = imager.ReadDummyADC(); //JTAG readout
					bw.write(Integer.toString(reg_int) + " " + ADC_out_str +"\n");
				}
				System.out.println("Input: " + reg_str + ", Output: " + ADC_out_str);
			}
			bw.close();
			
		} catch (IOException e) {
			e.printStackTrace();
		}		
	}
	
	static void CalibrateADC(int itr_times, DACCntr yvonne, ImagerCntr imager){
		try {
			File file = new File("./outputs/CalibrateADC/ADC_output.txt");
			if (!file.exists()) {
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			
			imager.EnableDummyADC(false); // disable dummy adc
			imager.EnableADCCali(true);
			imager.EnableADC(true); // enable adc
			int idx = yvonne.FindIdxofName("ana18");
			for (int reg_int = 0; reg_int < DACCntr.levels; reg_int ++){
				String reg_str = Integer.toHexString(reg_int);
				reg_str = "0000".substring(reg_str.length()) + reg_str; 
				yvonne.WriteDACReg(idx, reg_str); //Write to Yvonne
				String ADC_out_str = "";
				for (int itr = 0 ; itr < itr_times; itr++){ //average readings to eliminate noise
				    ADC_out_str = imager.ReadDummyADC(); //JTAG readout
					bw.write(Integer.toString(reg_int) + " " + ADC_out_str +"\n");
				}
				System.out.println("Input: " + reg_str + ", Output: " + ADC_out_str);
			}
			bw.close();
			
		} catch (IOException e) {
			e.printStackTrace();
		}		
	}
	/*
	 * analog test point:
	 * 0	cmp_b  ------------
	 * 1	clk_sar
	 * 2	clk_smp_sync
	 * 3	conv_per_b --------------
	 * 4	dac_rst
	 * 5	clk_pre_amp
	 * 6	clk_latch       ---------------------
	 * 7	pre_amp1_outp ---------------------------------
	 * 8	pre_amp1_outn
	 * 9	pre_amp2_outp -------------------------------
	 * 10	pre_amp2_outn
	 * 11	mux[239] ----------------------------
	 * 12	bl_rst
	 * 13	bitline[0]
	 * 14	bl_to_adc[0] ----------------------------------
	 * 15	bl_to_adc[1] --------------------------------
	 * 16    ana_sampler_trig_sig-----------
	 * 17    ana_sampler_trig_sig
	 * 18   dout_trigger_tp -------------
	 * 19  AVDD18 ------------------
	 * 20  AVDD18 ------------------
	 * 21  VDD -------------------
	 * 22  AVSS
	 * 23  AVSS
	 * 24  VSS
	 * 25  --------------------------
	 * 26
	 */

	static void AnalogSampler(int idx1, int idx2,  ImagerCntr imager){	
		System.out.println("Start Analog Sampler Test on " + idx1 + " and " + idx2);
		if (idx1 ==16 || idx2 ==16 || idx1 ==17 || idx2 ==17)
			imager.EnableSamplerTrig(true);
		else
			imager.EnableSamplerTrig(false);
		imager.EnableTestClk(true);
		imager.EnableSampler(idx1, idx2);
		System.out.println("Finished Analog Sampler Test");
	}
	
	static void CalibrateSampler(int idx, DACCntr yvonne, ImagerCntr imager){
		System.out.println("Start Analog Sampler Test on " + idx );
		imager.SetSamplerMode(3);
		if (idx ==16 || idx ==17 )
			imager.EnableSamplerTrig(true);
		else
			imager.EnableSamplerTrig(false);
		imager.EnableTestClk(true);
		imager.EnableSingleSampler(idx);
		double div = 0.01;	
		String reg[]=new String[yvonne.GetChannelNum()];	
		for (double i = 0; i <=1.8 ;i = i + div){
			yvonne.WriteDACValue("ana33", i, reg);
			// wait for 3 sec
			try {Thread.sleep(4000);} catch (InterruptedException e) {e.printStackTrace();}
			// TODO read from DMV
		}
		System.out.println("Finished Analog Sampler Test");
	}
	
	static void ImagerDebugModeTest(ImagerCntr imager){
		int row = 0;
		int col = 1;
		double tsmp = 96*Math.pow(10, -9); //sampling period 96ns
		double pw_smp = 40*Math.pow(10, -9); //sampling pulse width 40ns
		double trow = 50 * tsmp ; //row time ~5us
		double pw_rst = 4 * tsmp;
		double dly_rst = 20 * tsmp ;
		double pw_tx = 6 * tsmp;
		double dly_rst2tx = 20 * tsmp;
		double dly_tx = dly_rst + dly_rst2tx;
		double pw_isf = 17 * tsmp;
		double dly_isf = 19 * tsmp;
		
		System.out.println("Test Single Pixel at Row = " + row + ", Col = " + col);
		imager.ScanMode(false);
		imager.RowCounterForce(true);
		imager.SetRowCounter(row);
		imager.SetColCounter(col);
		imager.SetSmpPeriod(tsmp);
		imager.SetSmpPW(pw_smp);
		imager.SetRowPeriod(trow);
		imager.SetRstPW(pw_rst);
		imager.SetRstDelayTime(dly_rst);
		imager.SetTxPW(pw_tx);
		imager.SetTxDelayTime(dly_tx);
		imager.SetIsfPW(pw_isf);
		imager.SetIsfDelayTime(dly_isf);
		imager.SetMuxDelayTime(dly_isf + pw_isf -tsmp);
		imager.EnableDout(false); //disable output dout
		
		try {
			File file = new File("./outputs/SinglePixel/row0col1.txt");
			if (!file.exists()) {
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			String out;
			for (int i =1; i<100; i++){
				out = imager.ReadADCatRST();
				bw.write(out);
				out = imager.ReadADCatTX();
				bw.write(out);
			}
			bw.close();
			System.out.println("Test Single Pixel Finishes");
		} catch (IOException e) {
			e.printStackTrace();
		}
 
	}
	
	static void ImagerFrameTest(ImagerCntr imager){
		int row_num = 320;
		int col_num = 240;
		double tsmp = 96*Math.pow(10, -9); //sampling period 96ns
		double pw_smp = 40*Math.pow(10, -9); //sampling pulse width 40ns
		double pw_isf = 9 * tsmp;
		double dly_isf = 19 * tsmp;
		double trow = (col_num+pw_isf*2+6+16*2) * tsmp ; //row time ~28us
		double pw_rst = 4 * tsmp;
		double dly_rst = 20 * tsmp ;
		double pw_tx = 6 * tsmp;
		double dly_rst2tx = 20 * tsmp;
		double dly_tx = dly_rst + dly_rst2tx;

		int left = 0;
		int right = 1;
		System.out.println("Full Frame Test Starts:");
		imager.ScanMode(true);
		imager.RowCounterForce(false);
		imager.SetSmpPeriod(tsmp);
		imager.SetSmpPW(pw_smp);
		imager.SetRowPeriod(trow);
		imager.SetRstPW(pw_rst);
		imager.SetRstDelayTime(dly_rst);
		imager.SetTxPW(pw_tx);
		imager.SetTxDelayTime(dly_tx);
		imager.SetIsfPW(pw_isf);
		imager.SetIsfDelayTime(dly_isf);
		imager.SetMuxDelayTime(dly_isf + pw_isf -tsmp);
		imager.EnableDout(true);
		imager.OutputSel(left);
		
		try {
			File file = new File("./outputs/FullFrame/test.txt");
			if (!file.exists()) {
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			for (int i = 0; i<row_num; i++){
				int time = (int) (trow * Math.pow(10, 6));
				try {Thread.sleep(time);} catch (InterruptedException e) {e.printStackTrace();}
				if ( i%10 == 0 )
					System.out.println("Scanning Row : " + i);
			}
			bw.close();
			System.out.println("Test Full Frame Finishes");
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
}
