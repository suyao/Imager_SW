/**
 * File: TestJtag.java
 * 
 * This document is a part of SAGE_SW project.
 *
 * Copyright (c) 2014 Jing Pu
 *
 */
package test;

import MacraigorJtagioPkg.MacraigorJtagio;
import java.io.*;
/**
 * Test the MacraigorJtagio class on FPChip board
 * 
 * @author jingpu
 *
 */
public class TestJtag {

	static void flashLed(MacraigorJtagio jtag, int times, int interval) {
		assert (jtag.Initialized());
		try {
			for (int i = 0; i < 3; i++) {
				jtag.UsbLed(false);
				Thread.sleep(500);
				jtag.UsbLed(true);
				Thread.sleep(500);
			}
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

	public static void main(String[] args) {
		byte[] in_data, out_data;
		in_data = new byte[4];
		out_data = new byte[4];

		MacraigorJtagio jtag = new MacraigorJtagio();
		// ENDIR IDLE;
		// ENDDR IDLE;
		String ENDIR = "RunTestIdle";
		String ENDDR = "RunTestIdle";

		jtag.InitializeController("USB", "USB0", 1);
		flashLed(jtag, 5, 500);
		// TRST ON;
		jtag.SetTRST(true);
		// TRST OFF;
		jtag.SetTRST(false);
		// STATE RESET IDLE;
		jtag.StateMove("RunTestIdle");
	   	
		try {
		  Runtime.getRuntime().exec("cmd /c yvonneutil < C:/Users/sony/Documents/sensor_scripts/Imager_SW/src/yvone/test_HV.txt");
		  
		} catch (IOException e) {
            System.out.println("exception happened - here's what I know: ");
            e.printStackTrace();
            System.exit(-1);
        }

		//!Shift 5bit ID request instr JTAG_IDCODE = 0x01 (== 1?) into tap 0.
		//SIR 5 TDI (01);
		out_data[0] = 1;
		out_data[1] = 0;
		out_data[2] = 0;
		out_data[3] = 0;
		jtag.ScanOut("IR", 5, out_data, ENDIR);

		// !Shift in zeroes (TDI) expect to see ID 0x46504301 come out (TDO)
		// (0x465043 stands for 'FPC').
		// SDR 32 TDI (00000000) SMASK (ffffffff) TDO (46504301) MASK(ffffffff);
		jtag.ScanIn("DR", 32, in_data, ENDDR);
		// in_data[0] = 1
		// in_data[1] = 67
		// in_data[2] = 80
		// in_data[3] = 70

		// ! JTAG Write -- ADDR: 0x6018 Data: 0x000000000000cafe
		// SIR 5 TDI (0a) SMASK (ff);
		out_data[0] = 10;
		out_data[1] = 0;
		out_data[2] = 0;
		out_data[3] = 0;
		jtag.ScanOut("IR", 5, out_data, ENDIR);

		// SDR 16 TDI (6018) SMASK (ffff);
		out_data[0] = 8;
		out_data[1] = 0;
		out_data[2] = 0;
		out_data[3] = 0;
		jtag.ScanOut("DR", 16, out_data, ENDDR);

		// SIR 5 TDI (08) SMASK (ff);
		out_data[0] = 10;
		out_data[1] = 0;
		out_data[2] = 0;
		out_data[3] = 0;
		jtag.ScanOut("IR", 5, out_data, ENDIR);
		// SDR 64 TDI (000000000000cafe); SMASK (ffffffffffffffff)
		// SIR 5 TDI (09) SMASK (ff);
		// SDR 2 TDI (2) SMASK (f);
		// RUNTEST IDLE 100 TCK IDLE;

		// ! JTAG Read and Check -- ADDR: 0x6018 Data: 0x000000000000cafe
		// SIR 5 TDI (0a) SMASK (ff);
		// SDR 16 TDI (6018) SMASK (ffff);
		// SIR 5 TDI (09) SMASK (ff);
		// SDR 2 TDI (1) SMASK (f);
		// SIR 5 TDI (08) SMASK (ff);
		// SDR 64 TDI (000000000000abcd) SMASK (ffffffffffffffff) TDO
		// (000000000000cafe) MASK (ffffffffffffffff);
		// RUNTEST IDLE 100 TCK IDLE;

		System.out.println("in_data[0] = " + in_data[0]);
		System.out.println("in_data[1] = " + in_data[1]);
		System.out.println("in_data[2] = " + in_data[2]);
		System.out.println("in_data[3] = " + in_data[3]);

		jtag.CloseController();
		System.out.println("Test End");
	}
}
