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
	private int tsmp = 24; //default smp period
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
		jdrv.writeReg(ClockDomain.tc_domain, "008", int2str(p));
		tsmp = p;
	}
	
	public void SetSmpPW (double pw){
		int p = (int) Math.round(pw/Tclk_fast);
		int width = 4;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "00c", int2str(p));
	}
	
	public void SetRowPeriod (double period){
		int p = (int) Math.round(period/tsmp);
		int width = 18;
		int max = (int) Math.pow(2, width);
		if (p >= max) {
			p = max - 1;
		}	
		jdrv.writeReg(ClockDomain.tc_domain, "010", int2str(p));
	}
	
	
	
	public String int2str (int i){
		String s = Integer.toHexString(i);
		s = "00000000".substring(s.length()) + s;	
		return s;
	}
	
	
}