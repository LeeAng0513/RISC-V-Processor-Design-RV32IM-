/**********************************************************************
Project: Develop 32-bit RISC-V Processor
Module: reg_file_tb.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: 32 of 32-bits General Regsiters Test Bench
**********************************************************************/

`include "macro.v"
`default_nettype none

module reg_file_tb
();

reg ip_clk_tb, ip_rst_tb;
reg [31:0] ip_wr_data_tb;
reg [4:0] ip_rs1_addr_tb, ip_rs2_addr_tb, ip_rd_addr_tb;
reg ip_wr_en_tb;
wire [31:0] op_rs1_tb, op_rs2_tb;

reg_file
dut_reg_file(
	.ip_clk(ip_clk_tb),
	.ip_rst(ip_rst_tb),
	.ip_wr_data(ip_wr_data_tb),
	.ip_rd_addr(ip_rd_addr_tb),
	.ip_rs1_addr(ip_rs1_addr_tb),
	.ip_rs2_addr(ip_rs2_addr_tb),
	.ip_wr_en(ip_wr_en_tb),
	.op_rs1(op_rs1_tb),
	.op_rs2(op_rs2_tb)
);

initial ip_clk_tb <= 1'b1;
always #(`PERIOD_HALF) ip_clk_tb = ~ip_clk_tb;

//Signal initialization
initial begin
	@(posedge ip_clk_tb) // initialize the value (at sim time 1)
		ip_rst_tb = 1'b1;
		ip_wr_data_tb[31:0] = 32'b0;
		ip_rd_addr_tb[4:0] = 5'b0;
		ip_rs1_addr_tb[4:0] = 5'b0;
		ip_rs2_addr_tb[4:0] = 5'b0;
		ip_wr_en_tb = 1'b0;
	
	// test case 1 (write instruction into instrcution memory)
	@(posedge ip_clk_tb) // insert value
		ip_rst_tb = 1'b0;
		ip_wr_data_tb[31:0] = 32'h00000001; // 1
		ip_rd_addr_tb[4:0] = 5'b00101; // x5 (t0)
		ip_wr_en_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_data_tb[31:0] = 32'h00000002; // 2
		ip_rd_addr_tb[4:0] = 5'b00110; // x6 (t1)
		ip_wr_en_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_data_tb[31:0] = 32'h00000003; // 3
		ip_rd_addr_tb[4:0] = 5'b00111; // x7 (t3)
		ip_wr_en_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_data_tb[31:0] = 32'h00000004; // 4
		ip_rd_addr_tb[4:0] = 5'b01000; // x8 (s0)
		ip_wr_en_tb = 1'b1;

	// test case 2 (output data)
	@(posedge ip_clk_tb) // output x5 and x6 (t0 & t1)
		ip_wr_data_tb[31:0] = 32'b0;
		ip_rd_addr_tb[4:0] = 5'b0;
		ip_rs1_addr_tb[4:0] = 5'b00101;
		ip_rs2_addr_tb[4:0] = 5'b00110;
		ip_wr_en_tb = 1'b0;
	
	@(posedge ip_clk_tb) // output x7 and x8 (t3 & s0)
		ip_rs1_addr_tb[4:0] = 5'b00111;
		ip_rs2_addr_tb[4:0] = 5'b01000;
	
	repeat(2) @(posedge ip_clk_tb) begin // 1 cycle to compute the result
		ip_rs1_addr_tb[4:0] = 5'b0;
		ip_rs2_addr_tb[4:0] = 5'b0;
	end
	
	$stop; //stop simulation
end
endmodule
