/**
 * File: ImagerTest.java
 * 
 * This document is a part of SAGE_SW project.
 *
 * Copyright (c) 2015 Jing Pu
 *
 */
package test;

//import MacraigorJtagioPkg.ArrayDriver;
import MacraigorJtagioPkg.JtagDriver;
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

	static void checkArrayRegs(JtagDriver jdrv) {
		// reset system
		jdrv.writeReg(ClockDomain.tc_domain, "00", "01");
		jdrv.writeReg(ClockDomain.tc_domain, "00", "00");
		

		// reset system at the end
		jdrv.writeReg(ClockDomain.tc_domain, "00", "01");
		jdrv.writeReg(ClockDomain.tc_domain, "00", "00");

	}

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
		jdrv.writeReg(ClockDomain.tc_domain, "00", "01"); // two hex digits b/c_data_width=8
		jdrv.writeReg(ClockDomain.tc_domain, "00", "00");
		
		
		//Set DAC Values
		InitDAC();
		//Analog Sampler test
		
		//ADC calibration
		
		
		jdrv.CloseController();
	}
	
	
	static void InitDAC() {
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
	}

}
