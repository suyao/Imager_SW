/**
 * File: JtagDriver.java
 * 
 * This document is a part of SAGE project.
 *
 * Copyright (c) 2014 Jing Pu
 *
 */
package MacraigorJtagioPkg;

import java.util.Arrays;

/**
 * Jtag Driver adopted from SAGEChip/verif/JTAGDriver.vp
 * 
 * @author jingpu
 *
 */

public class JtagDriver extends MacraigorJtagio {
	/**
	 * Enum type for specifying the clock domain of registers.
	 * 
	 * @author jingpu
	 *
	 */
	public static enum ClockDomain {
		tc_domain, sc_domain
	}

	public static enum JtagState {
		TestLogicReset, RunTestIdle, PauseDR, PauseIR, ShiftDR, ShiftIR
	}

	public static enum JtagReg {
		IR, DR
	}

	@SuppressWarnings("unused")
	private static class IRValue {
		static String extest = "00";
		static String idcode = "01";
		static String sample = "02";
		static String sc_cfg_data = "08";
		static String sc_cfg_inst = "09";
		static String sc_cfg_addr = "0A";
		static String tc_cfg_data = "0C";
		static String tc_cfg_inst = "0D";
		static String tc_cfg_addr = "0E";
		static String bypass = "FF";
	}

	@SuppressWarnings("unused")
	private static class OpCode {
		static String nop = "00";
		static String read = "01";
		static String write = "02";
		static String ack = "03";
	}

	/* IMPORTANT JTAG controller parameters must match real hardware. */
	private int jtag_inst_width = 5;
	private int sc_data_width = 16;
	private int sc_addr_width = 16;
	private int sc_op_width = 2;
	private int tc_data_width = 32;
	private int tc_addr_width = 12;
	private int tc_op_width = 2;

	private JtagState endStateIR, endStateDR;

	/**
	 * Default constructor
	 */
	public JtagDriver() {
		super();
		this.endStateIR = JtagState.RunTestIdle;
		this.endStateDR = JtagState.RunTestIdle;
	}

	/**
	 * @param sc_data_width
	 * @param sc_addr_width
	 * @param tc_data_width
	 * @param tc_addr_width
	 */
	public JtagDriver(int sc_data_width, int sc_addr_width, int tc_data_width,
			int tc_addr_width) {
		super();
		this.sc_data_width = sc_data_width;
		this.sc_addr_width = sc_addr_width;
		this.tc_data_width = tc_data_width;
		this.tc_addr_width = tc_addr_width;
		this.endStateIR = JtagState.RunTestIdle;
		this.endStateDR = JtagState.RunTestIdle;
	}

	/****************************************************************************
	 * Top level tasks
	 ***************************************************************************/


	public int get_sc_data_width() {
		return sc_data_width;
	}

	public int get_sc_addr_width() {
		return sc_addr_width;
	}

	public int get_tc_data_width() {
		return tc_data_width;
	}

	public int get_tc_addr_width() {
		return tc_addr_width;
	}

	/**
	 * Resets the jtag state machine and registers
	 */
	public void reset() {
		this.SetTRST(true);
		this.SetTRST(false);
	}

	/**
	 * Reads IDCODE of the test access port (TAP) device
	 * 
	 * @return the hex string dump of IDCODE
	 */
	public String readID() {
		shiftReg(JtagReg.IR, jtag_inst_width, IRValue.idcode);
		return shiftReg(JtagReg.DR, 32, "00000000");
	}

	/**
	 * Use JTAG transactions to write a register value in the register file
	 * 
	 * @param cd
	 *            clock domain of the register, i.e. system clock (sc_domain),
	 *            or TCK (tc_domain)
	 * @param address
	 *            address of the register in hex string, and the length of the
	 *            string must match sc_addr_width/tc_addr_width
	 * @param data
	 *            data to write in hex string, and the length of the string must
	 *            match sc_data_width/tc_data_width
	 */
	public void writeReg(ClockDomain cd, String address, String data) {
		if (cd == ClockDomain.sc_domain) {
			// writes address and data
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.sc_cfg_addr);
			shiftReg(JtagReg.DR, sc_addr_width, address);
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.sc_cfg_data);
			shiftReg(JtagReg.DR, sc_data_width, data);
			// sends op
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.sc_cfg_inst);
			shiftReg(JtagReg.DR, sc_op_width, OpCode.write);
		} else if (cd == ClockDomain.tc_domain) {
			// writes address and data
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.tc_cfg_addr);
			shiftReg(JtagReg.DR, tc_addr_width, address);
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.tc_cfg_data);
			shiftReg(JtagReg.DR, tc_data_width, data);
			// sends op
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.tc_cfg_inst);
			shiftReg(JtagReg.DR, tc_op_width, OpCode.write);
		}
	}

	/**
	 * 
	 * Use JTAG transactions to read a register value in the register file
	 * 
	 * @param cd
	 *            clock domain of the register, i.e. system clock (sc_domain),
	 *            or TCK (tc_domain)
	 * @param address
	 *            address of the register in hex string, and the length of the
	 *            string must match sc_addr_width/tc_addr_width
	 * @return register value in hex string, and the length of the string is
	 *         sc_data_width/tc_data_width
	 */
	public String readReg(ClockDomain cd, String address) {
		byte[] data_out = null;
		if (cd == ClockDomain.sc_domain) {
			int arrayLen = (sc_data_width + 3) / 4; // bitlenth/4, rounded up
			data_out = new byte[arrayLen];
			byte[] dummy = new byte[arrayLen];
			// writes address
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.sc_cfg_addr);
			shiftReg(JtagReg.DR, sc_addr_width, address);
			// sends op
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.sc_cfg_inst);
			shiftReg(JtagReg.DR, sc_op_width, OpCode.read);
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.sc_cfg_data);
			shiftReg(JtagReg.DR, sc_data_width, dummy, data_out);
		} else if (cd == ClockDomain.tc_domain) {
			int arrayLen = (tc_data_width + 3) / 4; // bitlenth/4, rounded up
			data_out = new byte[arrayLen];
			byte[] dummy = new byte[arrayLen];
			// writes address and data
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.tc_cfg_addr);
			shiftReg(JtagReg.DR, tc_addr_width, address);
			// sends op
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.tc_cfg_inst);
			shiftReg(JtagReg.DR, tc_op_width, OpCode.read);
			// read data
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.tc_cfg_data);
			shiftReg(JtagReg.DR, tc_data_width, dummy, data_out);
		}
		return bytesToHexString(data_out);
	}

	/****************************************************************************
	 * Very low level tasks to manipulate the jtag state machine
	 ***************************************************************************/

	public boolean shiftReg(JtagReg reg, int length_in_bits, byte tdi_data[],
			byte tdo_data[]) {
		byte[] tdo_to_compare = tdo_data.clone();
		this.ScanIO(reg.name(), length_in_bits, tdi_data, tdo_data,
				getJtagEndState(reg).name());
		return Arrays.equals(tdo_data, tdo_to_compare);
	}
	
	public boolean shiftReg(JtagReg reg, int length_in_bits, String tdi_data,
			String tdo_data) {
		return shiftReg(reg, length_in_bits, hexStringToBytes(tdo_data),
				hexStringToBytes(tdi_data));
	}

	public String shiftReg(JtagReg reg, int length_in_bits, String tdi_data) {
		byte[] tdi_array = hexStringToBytes(tdi_data);
		byte[] tdo_array = new byte[tdi_array.length];
		shiftReg(reg, length_in_bits, tdi_array, tdo_array);
		return bytesToHexString(tdo_array);
	}

	public JtagState getJtagEndState(JtagReg reg) {
		JtagState state;
		switch (reg) {
		case DR:
			state = endStateDR;
		case IR:
			state = endStateIR;
		default:
			state = JtagState.RunTestIdle;
		}
		return state;
	}

	public void setJtagEndState(JtagReg reg, JtagState state) {
		switch(reg){
		case DR:
			endStateDR = state;
		case IR:
			endStateIR = state;
		}
	}

	/**
	 * Convert a string representation of a hex dump to a byte array
	 * http://stackoverflow.com/questions/140131
	 * 
	 * Modified the stackoverflow solution such that the HEX number of LSB is in
	 * the first element of the byte array. ("46504301" -> {1, 76, 80, 70})
	 * 
	 * @param s
	 * @return
	 */
	protected static byte[] hexStringToBytes(String s) {
		int len = s.length();
		int arrayLen = len / 2;
		byte[] data = new byte[arrayLen];
		for (int i = 0; i < len; i += 2)
			data[arrayLen - i / 2 - 1] = (byte) ((Character.digit(s.charAt(i),
					16) << 4) + Character.digit(s.charAt(i + 1), 16));
		return data;
	}

	final protected static char[] hexArray = "0123456789ABCDEF".toCharArray();

	/**
	 * Convert a string representation of a hex dump to a byte array
	 * http://stackoverflow.com/questions/9655181
	 * 
	 * Modified the stackoverflow solution such that the HEX number of LSB is in
	 * the first element of the byte array. ( {1, 76, 80, 70} -> "46504301")
	 * 
	 * @param bytes
	 * @return
	 */
	protected static String bytesToHexString(byte[] bytes) {
		char[] hexChars = new char[bytes.length * 2];
		for (int j = 0; j < bytes.length; j++) {
			int v = bytes[bytes.length - j - 1] & 0xFF;
			hexChars[j * 2] = hexArray[v >>> 4];
			hexChars[j * 2 + 1] = hexArray[v & 0x0F];
		}
		return new String(hexChars);
	}

	public static void main(String[] args) {
		// run test on hexString<->byteArray method
		String s = "46504301";
		byte[] bytes = { 0x01, 0x43, 0x50, 0x46 };
		if (!Arrays.equals(bytes, hexStringToBytes(s)))
			System.err.println("hexStringToBytes gave an wrong answer.");
		if (!s.equals(bytesToHexString(bytes)))
			System.err.println("bytesToHexString gave an wrong answer.");

		// runs an test on FPChip board
		System.out.println("runs an test on FPChip board");
		JtagDriver jtag = new JtagDriver();
		// read IDCODE
		jtag.InitializeController("USB", "USB0", 1);
		jtag.reset();
		System.out.println("IDCODE: " + jtag.readID());

		// ! JTAG Read -- ADDR: 0x6018
		System.out.println("Read at 0x6018: "
				+ jtag.readReg(ClockDomain.sc_domain, "6018"));
		// ! JTAG Write -- ADDR: 0x6018 Data: 0x000000000000cafe
		jtag.writeReg(ClockDomain.sc_domain, "6018", "000000000000cafe");
		System.out.println("Write at 0x6018 with 0x000000000000cafe");
		// ! JTAG Read -- ADDR: 0x6018
		System.out.println("Read at 0x6018: "
				+ jtag.readReg(ClockDomain.sc_domain, "6018"));

		jtag.CloseController();
	}
}
