/**
 * File: ArrayDriver.java
 * 
 * This document is a part of SAGE project.
 *
 * Copyright (c) 2015 Jing Pu
 *
 */
package MacraigorJtagioPkg;

import MacraigorJtagioPkg.JtagDriver.ClockDomain;

/**
 * Array Driver class adopted from SAGEChip/verif/array_driver.vp
 * 
 * @author jingpu
 *
 */
public class ArrayDriver {

	private byte[][][] states; // shadow states of the pixel array
	final private JtagDriver jdrv;
	
	/* Parameters */
	final private int rows = 32;
	final private int cols = 50;
	final private int data_width = 4;
	final private int reg_width = 20;
	final private int base_addr = 0;
	final private int tc_data_width = 8;
	final private int tc_addr_width = 8;
	final private int sc_data_width = 16;
	final private int sc_addr_width = 16;
	
	// REGISTER SETUP AND ENCODING
	// REG 0 - duty 0 LSB
	// REG 1 - duty 1
	// REG 2 - duty 2
	// REG 3 - duty 3
	// REG 4 - duty 4
	// REG 5 - duty 5
	// REG 6 - duty 6 MSB
	// REG 7 - PIXEL_EN
	// REG 8 - SENSOR_SEL 0 LSB
	// REG 9 - SENSOR_SEL 1
	// REG 10 - SENSOR_SEL 2 MSB
	// REG 11 - IN_HV
	// REG 12 - EN_HV (default is HIGH)
	// REG 13 - EN_HIZ_HV
	// REG 14 - PD_GAINB 0 LSB
	// REG 15 - PD_GAINB 1 (default is HIGH)
	// REG 16 - IT_GAINB 0 LSB
	// REG 17 - IT_GAINB 1 (default is HIGH)
	// REG 18 - IC_GAINB 0 LSB
	// REG 19 - IC_GAINB 1 (default is HIGH)

	// Initial state of a pixel = 20'ha9000;
	// copied from rtl/digital/ctrl_reg.vp
	final private byte[] INIT_STATES = { 0, 0, 0, 0x9, 0xA };
	
	/* Some derived values */
	private int regsPerPix = reg_width / data_width;
	private int row_addr_width = (int) Math.ceil(Math.log(rows) / Math.log(2));
	private int col_addr_width = (int) Math.ceil(Math.log(cols) / Math.log(2));
	private int sel_addr_width = (int) Math.ceil(Math.log(regsPerPix)
			/ Math.log(2));

	public ArrayDriver(JtagDriver jd)
	{
		// check Jtag driver parameters
		if (jd.get_sc_addr_width() != sc_addr_width
				|| jd.get_sc_data_width() != sc_data_width
				|| jd.get_tc_addr_width() != tc_addr_width
				|| jd.get_tc_data_width() != tc_data_width)
			System.err.println("ArrayDriver(): Jtag driver is not compatible.");
		jdrv = jd;
		states = new byte[rows][cols][regsPerPix];
		reset();
	}
	
	/**
	 * Resets the shadow array to zeros. Note that no JTAG operations 
	 * are triggered for efficiency. User should pull system reset
	 * externally or call write_reg().
	 */
	public void reset()
	{
		for (int i = 0; i < rows; i++)
			for (int j = 0; j < cols; j++)
				System.arraycopy(INIT_STATES, 0, states[i][j], 0, regsPerPix);
	}
	

	/**
	 * Checks the consistency between the pixel array and the shadow array. JTAG
	 * operations are involved to read all the states in the pixel array.
	 * 
	 * @return true if the test pass.
	 */
	public boolean checkConsistency(){
		for (int i = 0; i < rows; i++)
			for (int j = 0; j < cols; j++) {
				if(!pos_validate(i, j)) continue;
				for (int k = 0; k < regsPerPix; k++){
					String addr = cal_address(i, j, k);
					String hexString = jdrv
							.readReg(ClockDomain.sc_domain, addr);
					byte value = hexStringToByte(hexString);
					//jdrv.jtag_read_reg(sc_domain, addr, value);
					if (states[i][j][k] != value){
						System.err.printf("Consistency check failed at (%d, %d, %d)\n", i, j, k);
						System.err.printf(
								"HW value: %x,  Shadow array value: %x\n",
								value, states[i][j][k]);
						return false;
					}
				}
			}
		return true;
	}
	

	/**
	 * Writes a single bit of pixel [ROW, COL]. BIT_IDX is the index of the bit
	 * in the pixel's register. The write value is VALUE. Shadow array is
	 * updated accordingly.
	 * 
	 * @param row
	 * @param col
	 * @param bit_idx
	 *            index of the bit ranging from 0 to 19
	 * @param value
	 *            true if the bit value is one.
	 */
	public void writeBit(int row, int col, int bit_idx, boolean value) {
		if (!pos_validate(row, col)) {
			System.err.printf("(%d, %d) is invalid position.\n", row, col);
			return;
		}
		int sel = idx_to_sel(bit_idx);
		byte reg_val = states[row][col][sel];
		
		// calculate the new reg value
		int bit_pos = bit_idx % data_width;
		if (value)
			reg_val |= 1 << bit_pos;
		else
			reg_val &= ~(1 << bit_pos);
		writeWord(row, col, sel, reg_val);
	}

	/**
	 * Reads a single bit of pixel [ROW, COL]. BIT_IDX is the index of the bit
	 * in the pixel's register. The read value stores in VALUE. Shadow array is
	 * updated accordingly.
	 * 
	 * @param row
	 * @param col
	 * @param bit_idx
	 *            index of the bit ranging from 0 to 19
	 * @return true if the bit value is one.
	 */
	public boolean readBit(int row, int col, int bit_idx) {
		if (!pos_validate(row, col)) {
			System.err.printf("(%d, %d) is invalid position.\n", row, col);
			return false;
		}
		int sel = idx_to_sel(bit_idx);
		byte reg_val = readWord(row, col, sel);

		// get the bit value
		int bit_pos = bit_idx % data_width;
		if (((reg_val >> bit_pos) & 1) != 0)
			return true;
		else
			return false;
	}

	public void turnOn(int row, int col) {
		writeBit(row, col, 11, true); // IN_HV
	}

	public void turnOff(int row, int col) {
		writeBit(row, col, 11, false); // IN_HV
	}

	public void enable(int row, int col) {
		writeBit(row, col, 12, true); // EN_HV
	}

	public void disable(int row, int col) {
		writeBit(row, col, 12, false); // EN_HV
	}

	/**
	 * Sends a singal jtag_write_reg() op, and writes `$data_width` bit(s) VALUE
	 * in the pixel at [ROW, COL]. SEL selects the field of register of that
	 * pixel to write. Shadow array is updated accordingly.
	 * 
	 * @param row
	 * @param col
	 * @param sel
	 * @param value
	 */
	public void writeWord(int row, int col, int sel, byte value) {
		if (!pos_validate(row, col)) {
			System.err.printf("(%d, %d) is invalid position.\n", row, col);
			return;
		}
		String addr = cal_address(row, col, sel);
		String hexString = String.format("%04x", value);
		jdrv.writeReg(ClockDomain.sc_domain, addr, hexString);
		states[row][col][sel] = value;
	}


	/**
	 * Sends a singal jtag_read_reg() op, and reads`$data_width` bit(s) of the
	 * pixel at [ROW, COL] into VALUE. SEL selects the field of register of that
	 * pixel to read. Shadow array is updated accordingly.
	 * 
	 * @param row
	 * @param col
	 * @param sel
	 * @return
	 */
	public byte readWord(int row, int col, int sel) {
		byte value = 0;
		if (!pos_validate(row, col)) {
			System.err.printf("(%d, %d) is invalid position.\n", row, col);
			return value;
		}
		String addr = cal_address(row, col, sel);
		// jdrv.jtag_read_reg(sc_domain, addr, value);
		String hexString = jdrv.readReg(ClockDomain.sc_domain, addr);
		value = hexStringToByte(hexString);
		states[row][col][sel] = value;
		return value;
	}

	/**
	 * Returns the SEL of the field of register that contains IDX bit.
	 * 
	 * @param idx
	 * @return
	 */
	private int idx_to_sel (int idx) {
		return idx / data_width;
	}

	/**
	 * Returns the address of the SEL field of register of the pixel at [ROW,
	 * COL].
	 * 
	 * @param row
	 * @param col
	 * @param sel
	 * @return address in hex string, whose length is sc_addr_width(4)
	 */
	private String cal_address(int row, int col, int sel) {
		int addr = base_addr + row * (1 << col_addr_width) * (1 << sel_addr_width)
				+ col * (1 << sel_addr_width) + sel;
		String s = String.format("%04x", addr);
		return s;
	}

	/**
	 * Extracts the last digit (least significant digit) of the hex string
	 * 
	 * @param s
	 *            hex string
	 * @return a byte value of the last digit of input
	 */
	private byte hexStringToByte(String s) {
		int len = s.length();
		return (byte) Character.digit(s.charAt(len - 1), 16);
	}


	/**
	 * Validates the position [ROW, COL] in the array.
	 * 
	 * @param row
	 * @param col
	 * @return false if it is out of range.
	 */
	private boolean pos_validate(int row, int col) {
		if (row < 0 || row >= rows || col < 0 || col >= cols)
			return false;

		return true;
	}

	
	public static void main(String[] args) {
		JtagDriver jtag = new JtagDriver(16, 16, 8, 8);
		ArrayDriver adrv = new ArrayDriver(jtag);

		// checking derived values
		if (adrv.base_addr != 0)
			System.err.println("wrong base_addr");
		if (adrv.regsPerPix != 5)
			System.err.println("wrong regsPerPix");
		if (adrv.row_addr_width != 5)
			System.err.println("wrong row_addr_width");
		if (adrv.col_addr_width != 6)
			System.err.println("wrong col_addr_width");
		if (adrv.sel_addr_width != 3)
			System.err.println("wrong sel_addr_width");

		// check functionalities of private methods
		System.out.println(adrv.cal_address(0, 0, 2)); // 0002
		System.out.println(adrv.cal_address(10, 15, 2)); // 147a
		System.out.println(adrv.hexStringToByte("abcd")); // 13
	}
}
