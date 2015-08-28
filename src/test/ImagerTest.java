/**
 * File: ImagerTest.java
 * 
 * This document is a part of SAGE_SW project.
 *
 * Copyright (c) 2015 Jing Pu
 *
 */
package test;

import MacraigorJtagioPkg.ArrayDriver;
import MacraigorJtagioPkg.JtagDriver;
import MacraigorJtagioPkg.JtagDriver.ClockDomain;

/**
 * Test the ArrayDriver and JtagDriver class on SAGE board
 * 
 * @author jingpu
 *
 */
public class ImagerTest {

	/* SAGEChip configuration. */
	static int rows = 32;
	static int cols = 50;
	static int tc_data_width = 8;
	static int tc_addr_width = 8;
	static int sc_data_width = 16;
	static int sc_addr_width = 16;

//    REGISTER SETUP AND ENCODING
//    REG 0 - duty 0 LSB
//    REG 1 - duty 1 
//    REG 2 - duty 2
//    REG 3 - duty 3
//    REG 4 - duty 4
//    REG 5 - duty 5
//    REG 6 - duty 6 MSB
//    REG 7 - PIXEL_EN
//    REG 8 - SENSOR_SEL 0 LSB
//    REG 9 - SENSOR_SEL 1
//    REG 10 - SENSOR_SEL 2 MSB
//    REG 11 - IN_HV
//    REG 12 - EN_HV         (default is HIGH)
//    REG 13 - EN_HIZ_HV
//    REG 14 - PD_GAINB 0 LSB
//    REG 15 - PD_GAINB 1    (default is HIGH)
//    REG 16 - IT_GAINB 0 LSB
//    REG 17 - IT_GAINB 1    (default is HIGH)
//    REG 18 - IC_GAINB 0 LSB
//    REG 19 - IC_GAINB 1    (default is HIGH)
	
	/**
	 * This task writes a random SENSOR_SEL value into each pixel in the array,
	 * and then checks the array consistency by reading out all the regs inside
	 * the array.
	 * 
	 * @param jdrv
	 *            JTAG driver
	 * @param adrv
	 *            array driver
	 */
	static void checkArrayRegs(JtagDriver jdrv, ArrayDriver adrv) {
		// reset system
		jdrv.writeReg(ClockDomain.tc_domain, "00", "01");
		jdrv.writeReg(ClockDomain.tc_domain, "00", "00");
		adrv.reset();
		// write random SENSOR_SEL
		for (int i = 0; i < rows; i++)
			for (int j = 0; j < cols; j++) {
				adrv.writeBit(i, j, 7, false); // PIXEL_EN
				adrv.writeBit(i, j, 8, Math.random() > 0.5); // SENSOR_SEL 0
				adrv.writeBit(i, j, 9, Math.random() > 0.5); // SENSOR_SEL 1
				adrv.writeBit(i, j, 10, Math.random() > 0.5); // SENSOR_SEL 2
			}

		// Check array consistency
		if (adrv.checkConsistency())
			System.out.println("Passed array register check.");

		// reset system at the end
		jdrv.writeReg(ClockDomain.tc_domain, "00", "01");
		jdrv.writeReg(ClockDomain.tc_domain, "00", "00");
		adrv.reset();
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		JtagDriver jdrv = new JtagDriver(16, 16, 8, 8);
		ArrayDriver adrv = new ArrayDriver(jdrv);

		// Initialize jtag
		jdrv.InitializeController("USB", "USB0", 1);
		// Reset JTAG
		jdrv.reset();
		// Read IDCODE
		System.out.println("IDCODE: " + jdrv.readID());

		// System reset
		jdrv.writeReg(ClockDomain.tc_domain, "00", "01"); // two hex digits b/c_data_width=8
		jdrv.writeReg(ClockDomain.tc_domain, "00", "00");

		// Check array consistency after reset
		adrv.checkConsistency();

		// checkArrayRegs(jdrv, adrv);
		// adrv.turnOn(10, 10);
		// adrv.turnOff(10, 10);
		// adrv.disable(10, 10);
		// adrv.enable(10, 10);

		jdrv.CloseController();
	}

}
