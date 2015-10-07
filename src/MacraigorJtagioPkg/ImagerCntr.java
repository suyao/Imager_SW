/**
 * File: ImagerCntr.java
 * 
 * This document is a part of SAGE project.
 *
 * Copyright (c) 2014 Jing Pu
 *
 */
package MacraigorJtagioPkg;

import MacraigorJtagioPkg.JtagDriver;
import MacraigorJtagioPkg.JtagDriver.ClockDomain;


/**
 * Control Imager Jtag registers 
 * 
 * @author suyao
 *
 */

public class ImagerCntr extends MacraigorJtagio {
	public JtagDriver jdrv;
	private static double fclk_fast = 250 * Math.pow (10, 6); //250Mhz
	private static double Tclk_fast = 1 / fclk_fast;
	public static int rowNum = 320;
	public static int colNum = 240;
	private double tsmp = 24 * Tclk_fast; //default smp period 96ns
	private double trow = tsmp * 296; //default row period

	/**
	 * Default constructor
	 */
	public ImagerCntr(JtagDriver jdrv) {
		super();	
		this.jdrv = jdrv;
	}
	
	public void setFCLK(int freq) {
		fclk_fast = freq ;
		System.out.println("Input clk frequency is " + freq / 1000000 + "MHz.");
		Tclk_fast = 1 / fclk_fast;
		
	}
	public void JtagReset(){
		jdrv.writeReg(ClockDomain.tc_domain, "0000", "00000001");
		//try {Thread.sleep(100);} catch (InterruptedException e) {e.printStackTrace();}
		jdrv.writeReg(ClockDomain.tc_domain, "0000", "00000000");
		//try {Thread.sleep(100);} catch (InterruptedException e) {e.printStackTrace();}
	}
	public void ScanMode (boolean scan){
		if (scan ==true){
			jdrv.writeReg(ClockDomain.tc_domain, "0004", "00000001");
		}else
			jdrv.writeReg(ClockDomain.tc_domain, "0004", "00000000");
	}
	
	public void SetSmpPeriod (double period){
		int p = (int) Math.round(period/Tclk_fast);
		int width = 5;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: smp_period EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0008", Int2HexStr(p));
		tsmp = p * Tclk_fast;
	}
	
	public void SetSmpPW (double pw){
		int p = (int) Math.round(pw/Tclk_fast);
		int width = 4;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: smp_pw EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "000c", Int2HexStr(p));
	}
	
	public void SetRowPeriod (double period){
		int p = (int) Math.round(period/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: row_period EXCEEDS max range! ");
		}
		trow = p * tsmp;
		jdrv.writeReg(ClockDomain.tc_domain, "0010", Int2HexStr(p));
		System.out.println("Row time is " + period + "s");
	}
	
	public void SetPxIntegrationTime (double time){
		int p = (int) Math.round(time/trow);
		int width = 9;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Pixel Integration Time EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0014", Int2HexStr(p));
		System.out.println("Light integration time is " + time + "s, p = " + p);
	}
	
	public void SetInitShiftClk (int p){
		int width = 8;
		jdrv.writeReg(ClockDomain.tc_domain, "0018", Int2HexStr(p));
	}
	
	public void VideoRecord (boolean video){
		if (video ==true){
			jdrv.writeReg(ClockDomain.tc_domain, "001c", "00000001");
		}else
			jdrv.writeReg(ClockDomain.tc_domain, "001c", "00000000");
	}
	
	public void RowCounterForce (boolean stopcounter){
		if (stopcounter ==true){
			jdrv.writeReg(ClockDomain.tc_domain, "0020", "00000001");
		}else
			jdrv.writeReg(ClockDomain.tc_domain, "0020", "00000000");
	}
	
	public void SetMaxRowCounter (int p){
		int max = rowNum -1 ;
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Max Row Counter EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0024", Int2HexStr(p));
	}
	
	public void SetRowCounter (int p){
		int max = rowNum -1 ;
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Max Row Counter EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0028", Int2HexStr(p));
	}
	
	public void SetColCounter (int p){
		int max = colNum -1 ;
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Max Col Counter EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "002c", Int2HexStr(p));
	}
	
	public void SetRstPW (double pw){
		int p = (int) Math.round(pw/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Row rst pw EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0030", Int2HexStr(p));
	}
	
	public void SetRstDelayTime (double delay){
		int p = (int) Math.round(delay/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Row rst pw EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0034", Int2HexStr(p));
	}
	
	public void SetTxPW (double pw){
		int p = (int) Math.round(pw/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Row rst pw EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0038", Int2HexStr(p));
	}
	
	public void SetTxDelayTime (double delay){
		int p = (int) Math.round(delay/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Row rst delay EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "003c", Int2HexStr(p));
	}
	
	public void SetIsfPW (double pw){
		int p = (int) Math.round(pw/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Row Isf pw EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0040", Int2HexStr(p));
	}
	
	public void SetIsfDelayTime (double delay){
		int p = (int) Math.round(delay/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Row Isf delay EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0044", Int2HexStr(p));
	}
	
	// THIS NEEDS REVISION!
	public void SetMuxDelayTime (double delay){
		int p = (int) Math.round(delay/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Mux Delay EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0048", Int2HexStr(p));
	}
	
	public void EnableSampler (int a, int b){	
		int width = 27;
		int max = (int) Math.pow(2, width);
		if (a >= max || b>=max ) {
			System.out.println("ERROR: Sampler enable register is wrong! ");
			return;
		}	
		int p = (1 << a) +(1<<b) ;
		jdrv.writeReg(ClockDomain.tc_domain, "004c", Int2HexStr(p));
		//System.out.println("write to 004c: "+ Int2HexStr(p));
	}
	
	public void EnableSingleSampler (int a){	
		int width = 27;
		int max = (int) Math.pow(2, width);
		if (a >= max ) {
			System.out.println("ERROR: Sampler enable register is wrong! ");
			return;
		}	
		int p = 1 << a ;	
		jdrv.writeReg(ClockDomain.tc_domain, "004c", Int2HexStr(p));

	}
	
	public void SetSamplerMode (int p){		
		jdrv.writeReg(ClockDomain.tc_domain, "0050", Int2HexStr(p));
	}
	
	public void SetSmpADCDelayTime (double delay){
		int p = (int) Math.round(delay/Tclk_fast);
		int width = 4;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: ADC Sampling phase delay EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0054", Int2HexStr(p));
	}
	
	public void SetBlRstPW (double pw){
		int p = (int) Math.round(pw/Tclk_fast);
		int width = 5;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Bitline Rst pw EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0058", Int2HexStr(p));
	}
	
	public void SetBlRstDelayTime (double delay){
		int p = (int) Math.round(delay/Tclk_fast);
		int width = 5;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Bitline Rst delay EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "005c", Int2HexStr(p));
	}
	
	public void OutputSel (int p){
		int max = 2;
		if (p >= max ) {		
			System.out.println("ERROR: Output Sel must be 0 or 1! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0060", Int2HexStr(p));
	}
	
	public void IsDigClk (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "0064", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "0064", Int2HexStr(0));
	}
	
	public void EnableSamplerTrig (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "0068", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "0068", Int2HexStr(0));
	}
	
	public void EnableClkGate (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "006c", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "006c", Int2HexStr(0));
	}
	
	public void SetClkMuxPW (double pw){
		int p = (int) Math.round(pw/tsmp);
		int width = 5;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Mux pw EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0070", Int2HexStr(p));
	}
	
	public void SetClkMuxDelayTime (double delay){
		int p = (int) Math.round(delay/tsmp);
		int width = 5;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Mux delay EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0074", Int2HexStr(p));
	}
	/*
	 *  0: disable dac rst
	 *  1: enable dac rst
	 *  2: dynamic dac rst (rst before TX readout, not rst before RST readout)
	 */
	public void DACRstCntr (int p){
		int max = 3;
		if (p >= max ) {		
			System.out.println("ERROR: Output Sel must be 0 or 1! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "0078", Int2HexStr(p));
	}
	
	public void SetBitlineLoad (int a, int b){
		int p = 0;
		if (a==1)
			p = p + 1;
		if (b == 4)
			p = p + 2;	
		jdrv.writeReg(ClockDomain.tc_domain, "007c", Int2HexStr(p));
	}
	
	public void EnableTestClk (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "0080", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "0080", Int2HexStr(0));
	}
	
	public void EnableDout (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "0084", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "0084", Int2HexStr(0));
	}
	
	public void SetADCcurrent (int n1, int p1, int n2, int p2){
		if ( n1 > 15 || p1 >15 || n2 >15 || p2>15) {
			System.out.println("Current Control: cannot exceed 15!");
		} else{
		int p = n1 + (p1<<4) +(n2<<8)+(p2<<12);
		jdrv.writeReg(ClockDomain.tc_domain, "0400", Int2HexStr(p));
		}
	}
	
	public void EnableADCCali (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "0404", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "0404", Int2HexStr(0));
	}
	
	public void CurrentTestPt (int p){
		if (p==-1)
			jdrv.writeReg(ClockDomain.tc_domain, "0408", Int2HexStr(0));
		else {
			int width = 9;
			if (p >= width)
				System.out.println("ERROR: Current Test Point setting could only be 0~8!");
			p = 1 << p;
			jdrv.writeReg(ClockDomain.tc_domain, "0408", Int2HexStr(p));
		}
	}
	
	public void SetADCTiming (int ovlp_amp_lch, int cmp_lch_pw, int sar_dly){
		int max = 4;
		if (ovlp_amp_lch >= max || cmp_lch_pw >= max || sar_dly >=max)
			System.out.println("ERROR: ADC Timing cntr out of range!");
		int p = ovlp_amp_lch + cmp_lch_pw *4 + sar_dly * 16;
		jdrv.writeReg(ClockDomain.tc_domain, "040c", Int2HexStr(p));
	}
	
	public void SetSelfBias (int adc, int dummy_adc, int sf){
		if (adc > 1 || dummy_adc > 1 || sf >1)
			System.out.println("ERROR: Set self bias incorrectly!");
		int p = adc + (dummy_adc << 1) + (sf <<2);
		jdrv.writeReg(ClockDomain.tc_domain, "0410", Int2HexStr(p));
	}
	
	public void EnableDummyADCRst (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "0414", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "0414", Int2HexStr(0));
	}
	
	public void SetISFcurrent (int p){
		int width = 3;
		jdrv.writeReg(ClockDomain.tc_domain, "0418", Int2HexStr(p));
	}
	
	public void SetDummyADCcurrent (int n1, int p1, int n2, int p2){
		if ( n1 > 15 || p1 >15 || n2 >15 || p2>15) {
			System.out.println("Current Control: cannot exceed 15!");
		} else{
		int p = n1 + (p1<<4) +(n2<<8)+(p2<<12);
		jdrv.writeReg(ClockDomain.tc_domain, "041c", Int2HexStr(p));
		}
	}
	public void EnableADC (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "0420", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "0420", Int2HexStr(0));
	}
	
	public void EnableDummyADC (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "0424", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "0424", Int2HexStr(0));
	}
	
	public String Int2HexStr (int i){
		String s = Integer.toHexString(i);
		s = "00000000".substring(s.length()) + s;	
		return s;
	}


	public String ReadDummyADC(){
		return jdrv.readReg(ClockDomain.sc_domain, "04");
	}
	
	public String ReadADCatRST(){
		return jdrv.readReg(ClockDomain.sc_domain, "00");
	}
	
	public String ReadADCatTX(){
		return jdrv.readReg(ClockDomain.sc_domain, "02");
	}
}