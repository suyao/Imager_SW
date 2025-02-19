/**
 * File: ImagerTest.java
 * 
 * This document is a part of SAGE_SW project.
 *
 * Copyright (c) 2015 Suyao Ji
 *
 */
package test;

import MacraigorJtagioPkg.JtagDriver;
import MacraigorJtagioPkg.ImagerCntr;
import MacraigorJtagioPkg.MacraigorJtagio;
import MacraigorJtagioPkg.JtagDriver.ClockDomain;
import YvonnePkg.DACCntr;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.util.Date;

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
	private static double v0 = 1;
	private static double vrefp = 1.25;
	private static double vrefn = 0.75;	
	private static double vcm = 1;
	private static double vrst = 0.4; 
	private static String idx_bd = "b";
	private static String idx_chip = "c";
	
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

	
	static DACCntr InitDAC(String bd_idx) {
		//Set DAC Values
		double pvdd = 3.1; 
		//double pvdd = 1.5; //1.46 at DVDD33 = 2.3
		double ana33 = 2.45;
		v0 = 1.15;
		double ana18 = 1;
		vrefp = 1.25;
		vrefn = 0.74998;
		double Iin = 1;
		vcm = 1;
		//vrst = 1.34; 
		vrst = 0.64;
		//vrst = 0.98;
		double dac_values[] = {pvdd,ana33,v0, ana18, vrefp, vrefn, Iin, vcm, vrst};
		int idx_bd = 1;
		switch (bd_idx){
		case "b1": idx_bd = 1; break;
		case "b2": idx_bd = 2; break;
		case "b3": idx_bd = 3; break;
		case "b4": idx_bd = 4; break;
		default : idx_bd = 1; break;
		}
		System.out.println( "Test Board " + idx_bd);
		DACCntr yvonne = new DACCntr(dac_values, idx_bd); // board #
		try {Thread.sleep(1000);} catch (InterruptedException e) {e.printStackTrace();}
		vrefn = 0.75;
		return yvonne;
	}
	
	public static void main(String[] args) {
		idx_bd="b3";
		idx_chip="p12"; //Steve change this to "p12" please
		JtagDriver jdrv = new JtagDriver(16, 8, 32, 12);
		ImagerCntr imager = new ImagerCntr(jdrv);
		// Initialize jtag, Reset JTAG, Read IDCODE
		MacraigorJtagio jtag = new MacraigorJtagio();
		jdrv.InitializeController("USB", "USB0", 1);
		jdrv.reset();
		System.out.println("IDCODE: " + jdrv.readID());
		imager.JtagReset();	// System reset
		DACCntr yvonne = InitDAC(idx_bd); //Set DAC Values
		InitJTAG(jdrv);
		imager.EnableDummyADCRst(false);
		imager.SetDummyADCcurrent(15, 15, 15, 15);
		
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
		//int sampler_idx = 0;
		//CalibrateSampler(sampler_idx, yvonne, imager);

		/* Ana_sampler_cali_mode
		 * 0: both samplers at signal mode;
		   1: sampler 0 at calibration mode, sampler 1 at signal mode
  		   2: sampler 0 at signal mode, sampler 1 at calibration mode
		   3: both samplers at calibration mode
		 */
		imager.SetSamplerMode(-1);
		//imager.EnableSamplerTrig(true);
		AnalogSampler(12,11,imager);
				
		//ADC calibration
		/*  -1 don't measure current
		 *  0 ADC amp1_n 
		 *  1 ADC amp1_p
		 *  2 ADC_amp2_n 
		 *  3 ADC_amp2_p
		 *  4 DUMMY_amp1_n
		 *  5 DUMMY_amp1_p
		 *  6 DUMMY_amp2_n
		 *  7 DUMMY_amp2_p
		 *  8 Isf
		 */
		imager.SetADCTiming(1,1,1);
		// SetADCcurrent( n1, p1, n2, p2) , the larger number, the smaller the current
		//imager.SetADCcurrent(0,13,4,3); imager.SetISFcurrent(4); // chip s3 on board 1
		//imager.SetADCcurrent(2,13,7,7); imager.SetISFcurrent(5);// chip s2 on board 3
		//imager.SetADCcurrent(3,10,5,8); imager.SetISFcurrent(5);// chip p11 on board 3
		//imager.SetADCcurrent(6,9,7,8); imager.SetISFcurrent(5); // chip p21 on board 1
		//imager.SetADCcurrent(3,10,5,8); imager.SetISFcurrent(5);// chip c1 on board 3
		imager.SetADCcurrent(5,11,8,6); imager.SetISFcurrent(5); // chip p12 on board 1
		imager.CurrentTestPt(8);
		double scale = 1.0;
		SetPVDD(3.2*scale,yvonne);
		yvonne.SetAllSupply(1.8*scale, 3.3*scale);
		try {Thread.sleep(1000);} catch (InterruptedException e) {e.printStackTrace();}

	
		imager.EnableDout(false);
		// ADC Testing
		//DummyADCTest(0.51, yvonne, imager);
		//ADCTest(0.66, yvonne, imager, 0); // left ADC if 0, right ADC if 1
		//CalibrateDummyADC(10, yvonne, imager); //repeat every analog value for 100 conversions
		//CalibrateADC(30, yvonne, imager, 0, 5, "slow"); //(itr, , ,left/right, extra_bit) //ADC calibrate, Steve, uncomment this line when testing under room temperature
		//CalibrateADC(30, yvonne, imager, 1, 5, "slow"); //(itr, , ,left/right, extra_bit)
		
		//SNR_ADC(30, yvonne, imager, 0, "slow");
		//SNR_ADC(30, yvonne, imager, 1, "slow");
		//ADC_ext_input(yvonne,imager,0, "fast");// adc_idx
		//Pixel Readout
		//ImagerDebugModeTest(imager,2,10,0, 4); //(rol, col, left load, right load)
		//System.out.println("Read from jtag x074: " + jdrv.readReg(ClockDomain.tc_domain, "0074"));
		//ImagerDebugModeTest(imager, 1,118);
		//ImagerDebugModeTest(imager, 300,3);
		//ReadImagerReg(jdrv);
		//ImagerFrameTest(imager, jdrv);
		//imager.EnableDout(false);
		//ReadNoiseTest(imager, jdrv);
		//System.out.println("Read from JTAG SC 000: " + jdrv.readReg(ClockDomain.tc_domain, "0000"));
		if (1==0){ //all voltage margin test, Steve
			scale = 0.95;
			SetPVDD(3.2*scale,yvonne);
			yvonne.SetAllSupply(1.8*scale, 3.3*scale);
			Partial_Settling_Calibration(50,  yvonne, imager, 0, 3, 0, 2, 250e6, 118, scale);
			
			for (scale = 0.9; scale <=1.1; scale = scale + 0.05){
				if (scale <1 || scale > 1) { //skip scale =1
					SetPVDD(3.2*scale,yvonne);
					yvonne.SetAllSupply(1.8*scale, 3.3*scale);		
					//Partial_Settling_Calibration(50,  yvonne, imager, 0, -2, 1, 4, 250e6, 118, scale);
					//Partial_Settling_Calibration(50,  yvonne, imager, 1, -2, 1, 4, 250e6, 122, scale);
					Partial_Settling_Calibration(50,  yvonne, imager, 0, 3, 0, 2, 250e6, 118, scale);
					//Partial_Settling_Calibration(50,  yvonne, imager, 1, -2, 0, 2, 250e6, 122, scale);
				}
			}	
		}
		
		if (1==1){ //specific voltage scale, Steve
			scale = 1.0;
			SetPVDD(3.2*scale,yvonne);
			yvonne.SetAllSupply(1.8*scale, 3.3*scale);
			Partial_Settling_Calibration(50,  yvonne, imager, 0, 3, 0, 2, 250e6, 118, scale);
		}
		jdrv.CloseController();
		DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd, HH:mm");
		Date date = new Date();
		System.out.println("Test finished at "+ dateFormat.format(date));
		
	}
	
	static void InitJTAG(JtagDriver jdrv){
		ImagerCntr imager = new ImagerCntr(jdrv);
		jdrv.SetSpeed(6);
		int a =jdrv.GetSpeed();
		System.out.println("TCK speed: " + a);
		String RO;
		//imager.ScanMode(true);
		imager.IsDigClk(false);
		imager.EnableDout(true);
		imager.EnableClkGate(false); //false is to let the clock gate pass
		
		jdrv.writeReg(ClockDomain.sc_domain, "00", "0234");
		for (int i= 0 ; i<=1; i++){
		RO = jdrv.readReg(ClockDomain.sc_domain, "00");
		System.out.println("Read from JTAG SC 00: " + RO);
		}
		
		jdrv.writeReg(ClockDomain.sc_domain, "02", "0234");
		for (int i = 0; i<=1 ;i++){
		RO = jdrv.readReg(ClockDomain.sc_domain, "02");
		System.out.println("Read from JTAG SC 02: " + RO); 
		}		
	}
	
	
	static void DummyADCTest(double value, DACCntr yvonne, ImagerCntr imager){		

		imager.EnableADC(false); // disable adc
		imager.EnableDummyADC(true); // enable dummy adc		
		imager.JtagReset();
		yvonne.WriteDACValue("ana18", value, yvonne.dac_reg  )	;
		String ADC_out_str = "";
		try {Thread.sleep(1000);} catch (InterruptedException e) {e.printStackTrace();}
		for (int i = 0; i<10; i ++){
			try {Thread.sleep(100);} catch (InterruptedException e) {e.printStackTrace();}
			ADC_out_str = imager.ReadDummyADC();
			System.out.println("Dummy ADC Output: " + ADC_out_str);
		}	
	}
	
	static void ADCTest(double value, DACCntr yvonne, ImagerCntr imager, int adc_idx){
		if (adc_idx == 0)
			imager.SetColCounter(1); // if col<120, output left adc, otherwise, right adc
		else
			imager.SetColCounter(136);
		imager.ScanMode(true);
		imager.EnableDummyADC(false); // disable dummy adc
		imager.EnableADCCali(true);
		imager.EnableADC(true); // enable adc	
		imager.DACRstCntr(0); //don't reset dac
		imager.OutputSel(adc_idx);
		imager.JtagReset();
		yvonne.WriteDACValue("ana18", value, yvonne.dac_reg  )	;
		String ADC_out_str = "";
		try {Thread.sleep(1000);} catch (InterruptedException e) {e.printStackTrace();}
		for (int i = 0; i<10; i ++){
			try {Thread.sleep(100);} catch (InterruptedException e) {e.printStackTrace();}
			ADC_out_str = imager.ReadADCatRST();
			System.out.println("ADC Output: " + ADC_out_str);
		}	
	}
	
	static void CalibrateDummyADC(int itr_times, DACCntr yvonne, ImagerCntr imager){
		System.out.println("Dummy ADC Calibration starts...");
		try {
			File file = new File("outputs/CalibrateADC/dummy_ADC_output.txt");
			if (!file.exists()) {
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);		
			imager.EnableADC(false); // disable adc
			imager.EnableDummyADC(true); // enable dummy adc		
			imager.JtagReset();
			int idx = yvonne.FindIdxofName("ana18");
			double rsl_ana18 = (DACCntr.ana18_max-DACCntr.ana18_min)/DACCntr.levels*2;
			int reg_min = (int) Math.round((v0-(vrefp-vrefn)-DACCntr.ana18_min)/rsl_ana18) + DACCntr.levels/4 - 32*20;
			int reg_max = (int) Math.round((v0+(vrefp-vrefn)-DACCntr.ana18_min)/rsl_ana18) + DACCntr.levels/4 + 32*20;
			for (int reg_int = reg_min; reg_int < reg_max; reg_int= reg_int + 32){
				String reg_str = Integer.toHexString(reg_int);
				reg_str = "0000".substring(reg_str.length()) + reg_str; 
				yvonne.WriteDACReg(idx, reg_str); //Write to Yvonne
				String ADC_out_str = "";
				System.out.println("Input: " + reg_str);
				if (reg_int == reg_min)
					try {Thread.sleep(2000);} catch (InterruptedException e) {e.printStackTrace();}
				try {Thread.sleep(300);} catch (InterruptedException e) {e.printStackTrace();}
				for (int itr = 0 ; itr < itr_times; itr++){ //average readings to eliminate noise
				    ADC_out_str = imager.ReadDummyADC(); //JTAG readout
					bw.write(Integer.toString(reg_int) + " " + ADC_out_str +"\n");
					System.out.println("               Output: " + ADC_out_str);
				}			
			}
			bw.close();
		} catch (IOException e) {
			e.printStackTrace();
		}	
		System.out.println("Finish Calibrating Dummy ADC");
	}
	
	static void CalibrateADC(int itr_times, DACCntr yvonne, ImagerCntr imager, int adc_idx, int extra_bit, String speed){
		System.out.println("ADC Calibration Starts...");
		DateFormat dateFormat = new SimpleDateFormat("_yyyyMMdd_HHmm");
		Date date = new Date();
		String which_adc = "_left";
		if (adc_idx == 1)
			which_adc = "_right";	
		String bit_info = Integer.toString(extra_bit) + "b";
		String filename = "outputs/CalibrateADC/ADC_ramp_"  + idx_bd + idx_chip + speed + which_adc + bit_info + dateFormat.format(date)+".txt";
		
		try {
			File file = new File(filename);
			if (!file.exists()) {
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			if (adc_idx == 0)
				imager.SetColCounter(1); // if col<120, output left adc, otherwise, right adc
			else
				imager.SetColCounter(136);
			imager.ScanMode(true);
			imager.EnableDummyADC(false); // disable dummy adc
			imager.EnableADCCali(true);
			imager.EnableADC(true); // enable adc
			imager.DACRstCntr(0); //don't reset dac
			imager.OutputSel(adc_idx);
			int idx = yvonne.FindIdxofName("ana18");
			double rsl_ana18 = (DACCntr.ana18_max-DACCntr.ana18_min)/DACCntr.levels*2;
			System.out.println("ana18_max = , " + DACCntr.ana18_max);
			//int reg_min = (int) Math.round((v0-(vrefp-vrefn)-DACCntr.ana18_min)/rsl_ana18) + DACCntr.levels/4 - 32*10;
			int reg_min = (int) Math.round((v0-DACCntr.ana18_min)/rsl_ana18) + DACCntr.levels/4 - 32*10;
			int reg_max = (int) Math.round((v0+(vrefp-vrefn)-DACCntr.ana18_min)/rsl_ana18) + DACCntr.levels/4 + 32*10;
			int inc = (int) Math.round(32/Math.pow(2, extra_bit));
			System.out.println(inc);
			for (int reg_int = reg_min; reg_int < reg_max; reg_int= reg_int + inc){
				String reg_str = Integer.toHexString(reg_int);
				reg_str = "0000".substring(reg_str.length()) + reg_str; 
				yvonne.WriteDACReg(idx, reg_str); //Write to Yvonne
				String ADC_out_str = "";
				System.out.println("Input: "+ reg_str);
				if (reg_int == reg_min)
					try {Thread.sleep(20000);} catch (InterruptedException e) {e.printStackTrace();}
				try {Thread.sleep(300);} catch (InterruptedException e) {e.printStackTrace();}
				for (int itr = 0 ; itr < itr_times; itr++){ //average readings to eliminate noise
					ADC_out_str = imager.ReadADCatRST(); //JTAG readout
					bw.write(Integer.toString(reg_int) + " " + ADC_out_str +"\n");
					System.out.println("               Output: " + ADC_out_str);
				}				
			}
			bw.close();
		} catch (IOException e) {
			e.printStackTrace();
		}		
		System.out.println("Finish Calibrating ADC");
	}

	static void SNR_ADC(int itr_times, DACCntr yvonne, ImagerCntr imager, int adc_idx, String speed){
		System.out.println("ADC SNR Measurement Starts...");
		DateFormat dateFormat = new SimpleDateFormat("_yyyyMMdd_HHmm");
		Date date = new Date();
		String which_adc = "_left";
		if (adc_idx == 1)
			which_adc = "_right";	
		String filename = "./outputs/CalibrateADC/ADC_SNR_"  + idx_bd + idx_chip + speed + which_adc + dateFormat.format(date)+".txt";
		try {
			File file = new File(filename);
			if (!file.exists()) {
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			if (adc_idx == 0)
				imager.SetColCounter(1); // if col<120, output left adc, otherwise, right adc
			else
				imager.SetColCounter(136);
			imager.ScanMode(true);
			imager.EnableDummyADC(false); // disable dummy adc
			imager.EnableADCCali(true);
			imager.EnableADC(true); // enable adc
			imager.DACRstCntr(0); //don't reset dac
			imager.OutputSel(adc_idx);
			double value;
			int N = 1024;
			double offset = 0.004;
			if (adc_idx == 0)
				if (speed == "slow") offset = -0.002;
				else offset = -0.011;
			else
				if (speed == "slow") offset = 0.004;
				else offset = -0.006;
			
			bw.write("vcm = " + vcm + ", vrefp = " + vrefp + ", vrefn = "+ vrefn + ". Board/adc idx: " + idx_bd + idx_chip + which_adc + ".\n");
			for (int i = 1; i <= N*2; i ++){	
				value = 0.4985 * Math.sin(2* Math.PI *1*i/N) + v0 +offset;
				yvonne.WriteDACValue("ana18", value, yvonne.dac_reg  )	;
				if (i == 1)
					try {Thread.sleep(20000);} catch (InterruptedException e) {e.printStackTrace();}
				String ADC_out_str = "";
				System.out.println("Input: "+ value);
				try {Thread.sleep(700);} catch (InterruptedException e) {e.printStackTrace();}
				for (int itr = 0 ; itr < itr_times; itr++){ //average readings to eliminate noise
					ADC_out_str = imager.ReadADCatRST(); //JTAG readout
					bw.write(value + " " + ADC_out_str +"\n");
					System.out.println("               Output: " + ADC_out_str);
				}
			}
			bw.close();
		} catch (IOException e) {
			e.printStackTrace();
		}		
		System.out.println("Finish ADC SNR Measurement");
	}

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
	
	static void ImagerDebugModeTest(ImagerCntr imager, int row, int col, int leftload, int rightload){
		int col_num = 240;
		double tsmp = 25*4*Math.pow(10, -9); //sampling period 96ns
		double pw_smp = 11*4*Math.pow(10, -9); //sampling pulse width 40ns
		double pw_tx = 10 * tsmp;
		double pw_isf = 9 * tsmp;
		double dly_isf = 16 * tsmp + pw_tx -10*tsmp; // this value has to be larger than dly_rst + pw_rst
		// in debug mode light integration time is single row time
		double trow =(col_num+6+16*1) * tsmp +pw_isf*2 + pw_tx - 10*tsmp ; //row time ~28us
		//double trow =(col_num+6+16*2) * tsmp +pw_isf*2 +50 * tsmp;
		double pw_rst = (10) * tsmp;
		double dly_rst = 3 * tsmp ;	
		double dly_tx = dly_rst + pw_isf + (col_num / 2 + 16) *tsmp + pw_tx - 10*tsmp;
		//double dly_tx = dly_rst + pw_isf + (80 / 2 + 16) *tsmp + pw_tx - 10*tsmp;
		double integ_time = 5*trow;
		//pw_tx = 10*tsmp;
		
		System.out.println("Test Single Pixel at Row = " + row + ", Col = " + col);
		imager.ScanMode(false);
		imager.RowCounterForce(true);
		imager.SetRowCounter(row);
		imager.SetColCounter(col);
		imager.SetSmpPeriod(tsmp);
		imager.SetSmpPW(pw_smp);
		imager.SetRowPeriod(integ_time);
		imager.SetRstPW(pw_rst);
		imager.SetRstDelayTime(dly_rst);
		imager.SetTxPW(pw_tx);
		imager.SetTxDelayTime(dly_tx);
		imager.SetIsfPW(pw_isf);
		imager.SetIsfDelayTime(dly_isf);
		imager.SetMuxDelayTime(dly_isf + pw_isf -tsmp);
		imager.SetClkMuxDelayTime(0);
		imager.EnableDout(true); //disable output dout
		imager.EnableDummyADC(false); // disable dummy adc
		imager.EnableADCCali(false);
		imager.EnableADC(true); // enable adc	
		imager.DACRstCntr(1); //dac rst mode
		imager.SetBitlineLoad(leftload,rightload);
		imager.SetBlRstDelayTime(0);
		//imager.SetPxIntegrationTime(160*trow);
		if (col < 120)
			imager.OutputSel(0);
		else
			imager.OutputSel(1);
		imager.JtagReset();
		
		String out;
		for (int i =0; i<10; i++){
			out = imager.ReadADCatRST();
			System.out.println("RST Read out : " + out);
			
			out = imager.ReadADCatTX();
			System.out.println("TX Read out: " + out);
	
		}

		System.out.println("Test Single Pixel Finishes");
 
	}
	
	static void ImagerFrameTest(ImagerCntr imager, JtagDriver jdrv){
		
		int row_num = 320;
		int col_num = 240;
		double tsmp = 4*(25)*Math.pow(10, -9); //sampling period 96ns
		double pw_smp = 4*(11)*Math.pow(10, -9); //sampling pulse width 40ns
		double pw_tx = (10   ) * tsmp;
		double pw_isf = 9* tsmp;
		double dly_isf = 16 * tsmp + pw_tx - 10*tsmp; // this value has to be larger than dly_rst + pw_rst
		double trow = (col_num+6+16*2 ) * tsmp +pw_isf*2 + pw_tx - 10*tsmp ; //row time ~28us
		//double trow = (col_num+6+16*2 ) * tsmp +pw_isf*2 +50*tsmp ; //row time ~28us
		double pw_rst = (10  ) * tsmp;
		double dly_rst = 3 * tsmp ;
		
		double dly_tx = dly_rst + pw_isf + (col_num / 2 + 16) *tsmp + pw_tx - 10*tsmp;
		double integ_time = 160*trow;
		//pw_tx = (10 ) * tsmp;

		int left = 0;
		int right = 1;
		System.out.println("Full Frame Test Starts:");
		imager.VideoRecord(true);
		imager.ScanMode(true);

		imager.RowCounterForce(false);
		//imager.SetMaxRowCounter(2);
		imager.SetRowCounter(2);
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
		imager.SetInitShiftClk(9);
		imager.EnableDummyADC(false); // disable dummy adc
		imager.EnableADCCali(false);
		imager.EnableADC(true); // enable adc	
		imager.DACRstCntr(1);
		imager.SetBitlineLoad(1,4);
		imager.SetPxIntegrationTime(320*trow- integ_time);
		imager.SetClkMuxDelayTime(0);
		imager.SetBlRstDelayTime(0);
		imager.JtagReset();
		jdrv.readReg(ClockDomain.tc_domain, "0000");
		System.out.println("Left half Frame Test Starts:");
		if (1==1) {
		try {Thread.sleep(100);} catch (InterruptedException e) {e.printStackTrace();}
		imager.OutputSel(right);	
		System.out.println("Right half Frame Test Starts:");
		imager.JtagReset();
		jdrv.readReg(ClockDomain.tc_domain, "0000");
		}
	}
	
static void ReadNoiseTest(ImagerCntr imager, JtagDriver jdrv){
		
		int row_num = 320;
		int col_num = 240;
		double tsmp = 4*(25)*Math.pow(10, -9); //sampling period 96ns
		double pw_smp = 4*(11)*Math.pow(10, -9); //sampling pulse width 40ns
		double pw_tx = (10   ) * tsmp;
		double pw_isf = 9* tsmp;
		double dly_isf = 16 * tsmp + pw_tx - 10*tsmp; // this value has to be larger than dly_rst + pw_rst
		double trow = (col_num+6+16*2 ) * tsmp +pw_isf*2 + pw_tx - 10*tsmp ; //row time ~28us
		//double trow = (col_num+6+16*2 ) * tsmp +pw_isf*2 +50*tsmp ; //row time ~28us
		double pw_rst = (10 ) * tsmp;
		double dly_rst = 3 * tsmp ;
		
		double dly_tx = dly_rst + pw_isf + (col_num / 2 + 16) *tsmp + pw_tx - 10*tsmp;
		double integ_time = 160*trow;
		double pw_blrst = 2*4*Math.pow(10, -9); //bitline reset time 12ns
		double pw_mux = tsmp - pw_blrst - 4*Math.pow(10, -9);
		//pw_tx = (10 ) * tsmp;

		int left = 0;
		int right = 1;
		System.out.println("Full Frame Test Starts:");
		imager.VideoRecord(true);
		imager.ScanMode(true);

		imager.RowCounterForce(false);
		imager.SetMaxRowCounter(3);
		imager.SetRowCounter(2);
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
		imager.SetInitShiftClk(9);
		imager.EnableDummyADC(false); // disable dummy adc
		imager.EnableADCCali(false);
		imager.EnableADC(true); // enable adc	
		imager.DACRstCntr(1);
		imager.SetBitlineLoad(1,2);
		imager.SetBlRstPW(pw_blrst);
		imager.SetClkMuxPW(tsmp - pw_mux);
		imager.SetPxIntegrationTime(320*trow- integ_time);
		imager.SetClkMuxDelayTime(0);
		imager.SetBlRstDelayTime(0);
		imager.JtagReset();
		jdrv.readReg(ClockDomain.tc_domain, "0000");
		System.out.println("Left half Frame Test Starts:");
		
	}
	static void ADC_ext_input( DACCntr yvonne, ImagerCntr imager, int adc_idx, String speed){
		
		System.out.println("ADC output to logic analyzer begins...");
		double tsmp = 4*(25)*Math.pow(10, -9); //sampling period 96ns
		double pw_smp = 4*(10)*Math.pow(10, -9); //sampling pulse width 40ns
		imager.SetSmpPeriod(tsmp);
		imager.SetSmpPW(pw_smp);
		if (adc_idx == 0)
			imager.SetColCounter(1); // if col<120, output left adc, otherwise, right adc
		else
			imager.SetColCounter(136);
		imager.ScanMode(false);
		imager.EnableDummyADC(false); // disable dummy adc
		imager.EnableADCCali(true);
		imager.EnableADC(true); // enable adc
		imager.DACRstCntr(1); //don't reset dac
		imager.EnableDout(true);
		imager.OutputSel(adc_idx);
		imager.JtagReset();
			
		System.out.println("Finish Calibrating ADC");
	}
	
	static void ReadImagerReg(JtagDriver jdrv){
		
 			System.out.println("Read from JTAG SC 000: " + jdrv.readReg(ClockDomain.tc_domain, "0000"));
 			System.out.println("Read from JTAG SC 004: " + jdrv.readReg(ClockDomain.tc_domain, "0004"));
 			System.out.println("Read from JTAG SC 018: " + jdrv.readReg(ClockDomain.tc_domain, "0018"));
 			System.out.println("Read from JTAG SC 020: " + jdrv.readReg(ClockDomain.tc_domain, "0020"));
 			System.out.println("Read from JTAG SC 028: " + jdrv.readReg(ClockDomain.tc_domain, "0028"));
 			System.out.println("Read from JTAG SC 02C: " + jdrv.readReg(ClockDomain.tc_domain, "002C"));
 			System.out.println("Read from JTAG SC 008: " + jdrv.readReg(ClockDomain.tc_domain, "0008"));
 			System.out.println("Read from JTAG SC 00C: " + jdrv.readReg(ClockDomain.tc_domain, "000C"));
 			System.out.println("Read from JTAG SC 010: " + jdrv.readReg(ClockDomain.tc_domain, "0010"));
 			System.out.println("Read from JTAG SC 030: " + jdrv.readReg(ClockDomain.tc_domain, "0030"));
 			System.out.println("Read from JTAG SC 034: " + jdrv.readReg(ClockDomain.tc_domain, "0034"));
 			System.out.println("Read from JTAG SC 038: " + jdrv.readReg(ClockDomain.tc_domain, "0038"));
 			System.out.println("Read from JTAG SC 03C: " + jdrv.readReg(ClockDomain.tc_domain, "003C"));
 			System.out.println("Read from JTAG SC 040: " + jdrv.readReg(ClockDomain.tc_domain, "0040"));
 			System.out.println("Read from JTAG SC 044: " + jdrv.readReg(ClockDomain.tc_domain, "0044"));
 			System.out.println("Read from JTAG SC 048: " + jdrv.readReg(ClockDomain.tc_domain, "0048"));
 			System.out.println("Read from JTAG SC 074: " + jdrv.readReg(ClockDomain.tc_domain, "0074"));
 			System.out.println("Read from JTAG SC 078: " + jdrv.readReg(ClockDomain.tc_domain, "0078"));
 			System.out.println("Read from JTAG SC 07c: " + jdrv.readReg(ClockDomain.tc_domain, "007c"));
 			System.out.println("Read from JTAG SC 014: " + jdrv.readReg(ClockDomain.tc_domain, "0014"));
 		
	}
	static void Partial_Settling_Calibration(int itr_times, DACCntr yvonne, ImagerCntr imager, int adc_idx, int extra_bit, int load_left, int load_right, double clk_freq, int col, double scale){
		
		int row = 0;
		//int col = 118;
		double min = 0.95; //slow clk
		double max = 2.47; //fast clk
		if (adc_idx == 1 ){
			//col = 122;
			if (clk_freq == 250e6){			
				min = 1.13; max = 2.45;
			}else{ min = 1.13; max = 2.45; }
		} 
		if (adc_idx == 0) {
			//col = 118;
			if (clk_freq == 250e6){
				min = 1.13; max = 2.45;
			}else {min = 1.13; max = 2.45;}		
		}

		//int load_left = 1; // in fF
		//int load_right = 4;
		int rstMode = 1;
		double tsmp = 4*25*Math.pow(10, -9); //sampling period 96ns
		double pw_smp = 4*11*Math.pow(10, -9); //sampling pulse width 40ns
		double pw_tx = (10*1) * tsmp;
		double pw_isf = 10 * tsmp;
		double dly_isf = 16 * tsmp + pw_tx -10*tsmp; // this value has to be larger than dly_rst + pw_rst
		// in debug mode light integration time is single row time
		double trow =(ImagerCntr.colNum+6+16*2) * tsmp +pw_isf*2 + pw_tx - 10*tsmp ; //row time ~28us
		//double trow =(ImagerCntr.colNum+6+16*2) * tsmp +pw_isf*2 +50 * tsmp;
		double pw_rst = (10) * tsmp;
		double dly_rst = 3 * tsmp ;	
		double dly_tx = dly_rst + pw_isf + (ImagerCntr.colNum / 2 + 16) *tsmp + pw_tx - 10*tsmp;
		double integ_time = 160*trow;
		//pw_tx = 10*tsmp;
		
		System.out.println("Test Partial Settling at Row = " + row + ", Col = " + col);
		imager.ScanMode(false);
		imager.RowCounterForce(true);
		imager.SetRowCounter(row);
		imager.SetColCounter(col);
		imager.SetSmpPeriod(tsmp);
		imager.SetSmpPW(pw_smp);
		imager.SetRowPeriod(integ_time);
		imager.SetRstPW(pw_rst);
		imager.SetRstDelayTime(dly_rst);
		imager.SetTxPW(pw_tx);
		imager.SetTxDelayTime(dly_tx);
		imager.SetIsfPW(pw_isf);
		imager.SetIsfDelayTime(dly_isf);
		imager.SetMuxDelayTime(dly_isf + pw_isf -tsmp);
		imager.EnableDout(false); //disable output dout
		imager.EnableDummyADC(false); // disable dummy adc
		imager.EnableADCCali(false);
		imager.EnableADC(true); // enable adc	
		imager.DACRstCntr(rstMode); //dac rst mode
		imager.SetBitlineLoad(load_left,load_right);
		imager.OutputSel(adc_idx);
		imager.SetClkMuxDelayTime(0);
		imager.SetBlRstDelayTime(0);
		imager.JtagReset();
		
		String load = "?pF";
		if (col < 120) {
			if (load_left ==0) load = "0pF";
			else load = "1pF";
		} else {
			if (load_right == 2) load = "2pF";
			else load = "4pF";
		}
		String smp_pw = "_pwsmp"+Integer.toString((int) Math.round(pw_smp/Math.pow(10,  -9)))+"ns";
		DateFormat dateFormat = new SimpleDateFormat("_yyyyMMdd_HHmm");
		Date date = new Date();
		String which_adc = "left";
		if (adc_idx == 1)
			which_adc = "right";
		String speed = "_slow";
		if (clk_freq == 250e6)  speed = "_fast";
		String sc = "_scale?";
		if (scale == 0.9){ sc = "_scale0-9"; }
		if (scale == 0.95){ sc = "_scale0-95"; }
		if (scale == 1){ sc = "_scale1"; }
		if (scale == 1.05){ sc = "_scale1-05"; }
		if (scale == 1.1){ sc = "_scale1-1"; }
		String filename = "./outputs/PVT/PartialSettling/" +idx_chip+"/" + idx_bd + idx_chip + which_adc + load + speed + col + smp_pw + dateFormat.format(date)+sc+".txt";

			
		try {
			File file = new File(filename);
			if (!file.exists()) {
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			bw.write("@isf_pulse = " + pw_isf*250e6/clk_freq*1e6 + "us, sampling pulse width = " 
					+ pw_smp*250e6/clk_freq*1e6 + "us, input clk freq is " + clk_freq/1e6 + "MHz"
					+ "cap load is " + load + ", vcm = " + vcm + ", v0 = " + v0 + ", vrefp = " + vrefp
					+ ", vrefn = " + vrefn + ".\n");
			double value;
			int idx = yvonne.FindIdxofName("ana33");
			double rsl_ana33 = (DACCntr.ana33_max-DACCntr.ana33_min)/DACCntr.levels*2;
			int reg_min = (int) Math.round((min-DACCntr.ana33_min)/rsl_ana33) + DACCntr.levels/4 ;
			int reg_max = (int) Math.round((max-DACCntr.ana33_min)/rsl_ana33) + DACCntr.levels/4 ;
			int inc = (int) Math.round(32/Math.pow(2, extra_bit));
			System.out.println(inc);
			for (int reg_int = reg_min; reg_int < reg_max; reg_int= reg_int + inc){
				String reg_str = Integer.toHexString(reg_int);
				reg_str = "0000".substring(reg_str.length()) + reg_str; 
				yvonne.WriteDACReg(idx, reg_str); //Write to Yvonne
				if (reg_int == reg_min)
					try {Thread.sleep(20000);} catch (InterruptedException e) {e.printStackTrace();}
				String ADC_out_str = "";
				value = min+(reg_int-reg_min)*rsl_ana33;
				System.out.println("ANA33 Input: "+ value);
				try {Thread.sleep(700);} catch (InterruptedException e) {e.printStackTrace();}
				for (int itr = 0 ; itr < itr_times; itr++){ //average readings to eliminate noise
					ADC_out_str = imager.ReadADCatRST(); //JTAG readout
					bw.write(value + " " + ADC_out_str +"\n");
					System.out.println("               Output: " + ADC_out_str);
				}
				
			}
			bw.close();
			System.out.println("Test Partial settling Finishes");
		} catch (IOException e) {
			e.printStackTrace();
		} 
	}
	
	static void SetPVDD(double val,DACCntr yvonne ){
		int idx = yvonne.FindIdxofName("PVDD");
		double rsl = (DACCntr.pvdd_max-DACCntr.pvdd_min)/DACCntr.levels*2;
		int reg_int = (int) Math.round((val-DACCntr.pvdd_min)/rsl) + DACCntr.levels/4;
		String reg_str = Integer.toHexString(reg_int);
		reg_str = "0000".substring(reg_str.length()) + reg_str; 
		try {Thread.sleep(3000);} catch (InterruptedException e) {e.printStackTrace();}
		yvonne.WriteDACReg(idx, reg_str); //Write to Yvonne
		try {Thread.sleep(3000);} catch (InterruptedException e) {e.printStackTrace();}
		
	}
}
