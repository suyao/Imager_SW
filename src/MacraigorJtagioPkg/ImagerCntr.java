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
	private static int rowNum = 320;
	private static int colNum = 240;
	private double tsmp = 24 * Tclk_fast; //default smp period 96ns
	private double trow = tsmp * 296; //default row period
	private double minADCCurrent = 15 * Math.pow(10,-6);
	private double ADCcurrentRsl = 3 * Math.pow(10,-6);
	private double minIsfCurrent = 1 * Math.pow(10,-6);
	private double IsfcurrentRsl = 1 * Math.pow(10,-6);
	/**
	 * Default constructor
	 */
	public ImagerCntr(JtagDriver jdrv) {
		super();	
	}
	
	public void ScanMode (boolean scan){
		if (scan ==true){
			jdrv.writeReg(ClockDomain.tc_domain, "004", "00000001");
		}else
			jdrv.writeReg(ClockDomain.tc_domain, "004", "00000000");
	}
	
	public void SetSmpPeriod (double period){
		int p = (int) Math.round(period/Tclk_fast);
		int width = 5;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: smp_period EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "008", Int2HexStr(p));
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
		jdrv.writeReg(ClockDomain.tc_domain, "00c", Int2HexStr(p));
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
		jdrv.writeReg(ClockDomain.tc_domain, "010", Int2HexStr(p));
	}
	
	public void SetPxIntegrationTime (double time){
		int p = (int) Math.round(time/trow);
		int width = 9;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Pixel Integration Time EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "014", Int2HexStr(p));
	}
	
	public void SetInitShiftClk (String phase){
		int width = 4;
		if (phase.length()>width)
			System.out.println("ERROR: ShiftClk Init Value EXCEEDS max width! ");
		jdrv.writeReg(ClockDomain.tc_domain, "018", phase);
	}
	
	public void VideoRecord (boolean video){
		if (video ==true){
			jdrv.writeReg(ClockDomain.tc_domain, "01c", "00000001");
		}else
			jdrv.writeReg(ClockDomain.tc_domain, "01c", "00000000");
	}
	
	public void RowCounterForce (boolean stopcounter){
		if (stopcounter ==true){
			jdrv.writeReg(ClockDomain.tc_domain, "020", "00000001");
		}else
			jdrv.writeReg(ClockDomain.tc_domain, "020", "00000000");
	}
	
	public void SetMaxRowCounter (int p){
		int max = rowNum -1 ;
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Max Row Counter EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "024", Int2HexStr(p));
	}
	
	public void SetRowCounter (int p){
		int max = rowNum -1 ;
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Max Row Counter EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "028", Int2HexStr(p));
	}
	
	public void SetColCounter (int p){
		int max = colNum -1 ;
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Max Col Counter EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "02c", Int2HexStr(p));
	}
	
	public void SetRstPW (double pw){
		int p = (int) Math.round(pw/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Row rst pw EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "030", Int2HexStr(p));
	}
	
	public void SetRstDelayTime (double delay){
		int p = (int) Math.round(delay/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Row rst pw EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "034", Int2HexStr(p));
	}
	
	public void SetTxPW (double pw){
		int p = (int) Math.round(pw/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Row rst pw EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "038", Int2HexStr(p));
	}
	
	public void SetTxDelayTime (double delay){
		int p = (int) Math.round(delay/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Row rst delay EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "03c", Int2HexStr(p));
	}
	
	public void SetIsfPW (double pw){
		int p = (int) Math.round(pw/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Row Isf pw EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "040", Int2HexStr(p));
	}
	
	public void SetIsfDelayTime (double delay){
		int p = (int) Math.round(delay/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Row Isf delay EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "044", Int2HexStr(p));
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
		jdrv.writeReg(ClockDomain.tc_domain, "048", Int2HexStr(p));
	}
	
	public void SamplerEnable (int a, int b){	
		int width = 27;
		int max = (int) Math.pow(2, width);
		if (a >= max || b>=max ) {
			System.out.println("ERROR: Sampler enable register is wrong! ");
			return;
		}	
		int p = 1 << a + 1 << b;	
		jdrv.writeReg(ClockDomain.tc_domain, "050", Binary2HexStr(p));
	}
	
	public void SetSamplerMode (int p){		
		jdrv.writeReg(ClockDomain.tc_domain, "050", Binary2HexStr(p));
	}
	
	public void SetSmpADCDelayTime (double delay){
		int p = (int) Math.round(delay/Tclk_fast);
		int width = 4;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: ADC Sampling phase delay EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "054", Int2HexStr(p));
	}
	
	public void SetBlRstPW (double pw){
		int p = (int) Math.round(pw/Tclk_fast);
		int width = 5;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Bitline Rst pw EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "058", Int2HexStr(p));
	}
	
	public void SetBlRstDelayTime (double delay){
		int p = (int) Math.round(delay/Tclk_fast);
		int width = 5;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Bitline Rst delay EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "05c", Int2HexStr(p));
	}
	
	public void OutputSel (int p){
		int max = 2;
		if (p >= max ) {		
			System.out.println("ERROR: Output Sel must be 0 or 1! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "058", Int2HexStr(p));
	}
	
	public void IsDigClk (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "064", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "064", Int2HexStr(0));
	}
	
	public void EnableSamplerTrig (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "068", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "068", Int2HexStr(0));
	}
	
	public void EnableClkGate (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "06c", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "06c", Int2HexStr(0));
	}
	
	public void SetClkMuxPW (double pw){
		int p = (int) Math.round(pw/tsmp);
		int width = 5;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Mux pw EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "070", Int2HexStr(p));
	}
	
	public void SetClkMuxDelayTime (double delay){
		int p = (int) Math.round(delay/tsmp);
		int width = 5;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
			System.out.println("ERROR: Mux delay EXCEEDS max range! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "074", Int2HexStr(p));
	}
	
	public void DACRstCntr (int p){
		int max = 2;
		if (p >= max ) {		
			System.out.println("ERROR: Output Sel must be 0 or 1! ");
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "078", Int2HexStr(p));
	}
	
	public void SetBitlineLoad (int a, int b){
		int p = 0;
		if (a==1)
			p = p + 1;
		if (b == 4)
			p = p + 2;	
		jdrv.writeReg(ClockDomain.tc_domain, "07c", Int2HexStr(p));
	}
	
	public void EnableTestClk (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "080", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "080", Int2HexStr(0));
	}
	
	public void EnableDout (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "084", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "084", Int2HexStr(0));
	}
	
	public void SetADCcurrent (double n1, double p1, double n2, double p2){
		int width = 4;
		int max = (int) Math.pow(2, width);
		int p = max - (int) Math.round((n1-minADCCurrent)/ADCcurrentRsl);
		p = p + (max - (int) Math.round((p1-minADCCurrent)/ADCcurrentRsl)) << 4;
		p = p + (max - (int) Math.round((n2-minADCCurrent)/ADCcurrentRsl)) << 8;
		p = p + (max - (int) Math.round((p2-minADCCurrent)/ADCcurrentRsl)) << 12;
		jdrv.writeReg(ClockDomain.tc_domain, "400", Int2HexStr(p));
	}
	
	public void EnableADCCali (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "404", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "404", Int2HexStr(0));
	}
	
	public void CurrentTestPt (int p){
		int width = 9;
		if (p >= width)
			System.out.println("ERROR: Current Test Point setting could only be 0~8!");
		p = 1 << p;
		jdrv.writeReg(ClockDomain.tc_domain, "408", Int2HexStr(p));
	}
	
	public void SetADCTiming (int ovlp_amp_lch, int cmp_lch_pw, int sar_dly){
		int max = 4;
		if (ovlp_amp_lch >= max || cmp_lch_pw >= max || sar_dly >=max)
			System.out.println("ERROR: ADC Timing cntr out of range!");
		int p = ovlp_amp_lch + cmp_lch_pw *4 + sar_dly * 16;
		jdrv.writeReg(ClockDomain.tc_domain, "40c", Int2HexStr(p));
	}
	
	public void SetSelfBias (int adc, int dummy_adc, int sf){
		if (adc > 1 || dummy_adc > 1 || sf >1)
			System.out.println("ERROR: Set self bias incorrectly!");
		int p = adc + dummy_adc << 1 + sf <<2;
		jdrv.writeReg(ClockDomain.tc_domain, "410", Binary2HexStr(p));
	}
	
	public void EnableDummyADCRst (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "414", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "414", Int2HexStr(0));
	}
	
	public void SetADCcurrent (double current){
		int width = 3;
		int max = (int) Math.pow(2, width);
		int p = (int) Math.round((current-minIsfCurrent)/IsfcurrentRsl);
		p = max - p;
		jdrv.writeReg(ClockDomain.tc_domain, "41c", Int2HexStr(p));
	}
	
	public void EnableADC (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "420", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "420", Int2HexStr(0));
	}
	
	public void EnableDummyADC (boolean p){
		if (p == true ) {		
			jdrv.writeReg(ClockDomain.tc_domain, "424", Int2HexStr(1));
		} else	
			jdrv.writeReg(ClockDomain.tc_domain, "424", Int2HexStr(0));
	}
	
	public String Int2HexStr (int i){
		String s = Integer.toHexString(i);
		s = "00000000".substring(s.length()) + s;	
		return s;
	}
	
	public String Binary2HexStr (int i){
		String s = Integer.toString(i);
		int decimal = Integer.parseInt(s,2);
		String h = Integer.toHexString(decimal);
		s = "00000000".substring(h.length()) + h;	
		return s;
	}
}