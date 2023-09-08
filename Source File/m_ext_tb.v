/**********************************************************************
Project: 32-bit RISC-V Processor
Module: m_ext_tb.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: M Extension Test Bench
**********************************************************************/

`include "macro.v"
`default_nettype none

module m_ext_tb
();
reg [31:0] ip_rs1_tb, ip_rs2_tb;
reg [2:0] ip_funct_3_tb;
reg ip_clk_tb;
wire [31:0] op_result_tb;
wire op_overflow_tb;

m_ext
dut_m_ext(
	.ip_rs1(ip_rs1_tb),
	.ip_rs2(ip_rs2_tb),
	.ip_funct_3(ip_funct_3_tb),
	.ip_clk(ip_clk_tb),
	.op_result(op_result_tb),
	.op_overflow(op_overflow_tb)
);

initial ip_clk_tb <= 1'b1;
always #(`PERIOD_HALF) ip_clk_tb = ~ip_clk_tb;

initial begin
	@(posedge ip_clk_tb) // initialize the value (at sim time 1)
		ip_rs1_tb[31:0] = 32'b0;
		ip_rs2_tb[31:0] = 32'b0;
		ip_funct_3_tb[2:0] = 3'b0;

	// test case 1 (MUL with two positive signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h00015C7B; // 89211
		ip_rs2_tb[31:0] = 32'h0000058A; // 1418
		ip_funct_3_tb[2:0] = 3'b000;
	
	// test case 2 (MUL with one positive and one negative signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFEEC39; // -70599
		ip_rs2_tb[31:0] = 32'h0000157F; // 5503
		ip_funct_3_tb[2:0] = 3'b000;
	
	// test case 3 (MUL with two negative signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFF799A; // -34406
		ip_rs2_tb[31:0] = 32'hFFFFEC4E; // -5042
		ip_funct_3_tb[2:0] = 3'b000;
	
	// test case 4 (MULH with two positive signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h005E2EA0; // 6172320
		ip_rs2_tb[31:0] = 32'h000426C4; // 272068
		ip_funct_3_tb[2:0] = 3'b001;
	
	// test case 5 (MULH with one positive and one negative signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h007DA5DF; // 8234463
		ip_rs2_tb[31:0] = 32'hFFFE2B1D; // -120035
		ip_funct_3_tb[2:0] = 3'b001;
	
	// test case 6 (MULHSU with one positive signed and one unigned value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h000258D3; // 153811
		ip_rs2_tb[31:0] = 32'h9EC4BA46; // 2663692870
		ip_funct_3_tb[2:0] = 3'b010;
	
	// test case 7 (MULHSU with one negetive signed and one unigned value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFF9A235; // -417227
		ip_rs2_tb[31:0] = 32'hE44C0824; // 3830188068
		ip_funct_3_tb[2:0] = 3'b010;
	
	// test case 8 (MULHU with two unigned value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hCAF1B84E; // 3404838990
		ip_rs2_tb[31:0] = 32'h8841A4E9; // 2286003433
		ip_funct_3_tb[2:0] = 3'b011;
	
	// test case 9 (DIV with two positive signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h00774EED; // 7818989
		ip_rs2_tb[31:0] = 32'h00000017; // 23
		ip_funct_3_tb[2:0] = 3'b100;

	// test case 10 (DIV with one positive and one negative signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h00041E0F; // 269839
		ip_rs2_tb[31:0] = 32'hFFFFFC59; // -935
		ip_funct_3_tb[2:0] = 3'b100;

	// test case 11 (DIV with two negative signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFEEF06A; // -1118102
		ip_rs2_tb[31:0] = 32'hFFFFDC43; // -9149
		ip_funct_3_tb[2:0] = 3'b100;
	
	// test case 12 (DIVU with two unsigned value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hC7485D8D; // 3343408525
		ip_rs2_tb[31:0] = 32'h15A51D1A; // 363142426
		ip_funct_3_tb[2:0] = 3'b101;
	
	// test case 13 (REM with two positive signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h00001C72; // 7282
		ip_rs2_tb[31:0] = 32'h00000272; // 626
		ip_funct_3_tb[2:0] = 3'b110;

	// test case 14 (REM with one positive and one negative signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFC854E8D; // -58372467
		ip_rs2_tb[31:0] = 32'h000097CD; // 38861
		ip_funct_3_tb[2:0] = 3'b110;

	// test case 15 (REM with two negative signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFF681C3; // -622141
		ip_rs2_tb[31:0] = 32'hFFFEA8F6; // -87818
		ip_funct_3_tb[2:0] = 3'b110;
	
	// test case 16 (REMU with two unsigned value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hE3CA4D08; // 3821686024
		ip_rs2_tb[31:0] = 32'h02E40755; // 48498517
		ip_funct_3_tb[2:0] = 3'b111;

	// test case 17 (Special Case - divide by zero)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h003AE27C; // 3859068
		ip_rs2_tb[31:0] = 32'h00000000; // 0
		ip_funct_3_tb[2:0] = 3'b100;

	// test case 18 (Special Case - the largest negative number divide by -1)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h80000000; // -4294967296
		ip_rs2_tb[31:0] = 32'hFFFFFFFF; // -1
		ip_funct_3_tb[2:0] = 3'b100;
	
	repeat(2) @(posedge ip_clk_tb) begin // 4 cycle to compute the result
		ip_rs1_tb[31:0] = 32'b0;
		ip_rs2_tb[31:0] = 32'b0;
		ip_funct_3_tb[2:0] = 3'b000;
	end

// To stop simulation.
$stop;
end
endmodule