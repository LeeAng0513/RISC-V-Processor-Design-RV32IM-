/**********************************************************************
Project: 32-bit RISC-V Processor 
Module: data_mem_tb.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: Data Memory Test Bench
**********************************************************************/

`include "macro.v"
`default_nettype none

module data_mem_tb
();

reg [31:0] ip_addr_tb, ip_store_data_tb;
reg [1:0] ip_load_store_bit_ctrl_tb;
reg ip_clk_tb, ip_rst_tb, ip_load_sign_ctrl_tb, ip_store_en_tb;
wire [31:0] op_read_data_tb;

data_mem
dut_data_mem(
	.ip_addr(ip_addr_tb),
	.ip_store_data(ip_store_data_tb),
	.ip_load_store_bit_ctrl(ip_load_store_bit_ctrl_tb),
	.ip_clk(ip_clk_tb),
	.ip_rst(ip_rst_tb),
	.ip_load_sign_ctrl(ip_load_sign_ctrl_tb),
	.ip_store_en(ip_store_en_tb),
	.op_read_data(op_read_data_tb)
);

initial ip_clk_tb <= 1'b1;
always #(`PERIOD_HALF) ip_clk_tb = ~ip_clk_tb;

//Signal initialization
initial begin
	@(posedge ip_clk_tb) // initialize the value (at sim time 1)
		ip_addr_tb[31:0] = 32'b0;
		ip_store_data_tb[31:0] = 32'b0;
		ip_load_store_bit_ctrl_tb = 2'b0;
		ip_load_sign_ctrl_tb = 1'b0;
		ip_store_en_tb = 1'b0;
		ip_rst_tb = 1'b1;
	
	// test case 1 (SB)
	@(posedge ip_clk_tb) // insert value
		ip_addr_tb[31:0] = 32'h02000000; // address of memory
		ip_store_data_tb[31:0] = 32'h08EF965D; // data
		ip_load_store_bit_ctrl_tb = 2'b00; // byte
		ip_store_en_tb = 1'b1; // enable store
		ip_rst_tb = 1'b0;
	
	@(posedge ip_clk_tb) // insert value
		ip_addr_tb[31:0] = 32'h02000004; // address of memory
		ip_store_data_tb[31:0] = 32'hD9A438B8; // data
		ip_load_store_bit_ctrl_tb = 2'b00; // byte
		ip_store_en_tb = 1'b1; // enable store

	// test case 2 (SH)
	@(posedge ip_clk_tb) // insert value
		ip_addr_tb[31:0] = 32'h02000008; // address of memory
		ip_store_data_tb[31:0] = 32'h050B725A; // data
		ip_load_store_bit_ctrl_tb = 2'b01; // half
		ip_store_en_tb = 1'b1; // enable store

	@(posedge ip_clk_tb) // insert value
		ip_addr_tb[31:0] = 32'h0200000C; // address of memory
		ip_store_data_tb[31:0] = 32'h5ED7C51F; // data
		ip_load_store_bit_ctrl_tb = 2'b01; // half
		ip_store_en_tb = 1'b1; // enable store
	
	// test case 3 (SW)
	@(posedge ip_clk_tb) // insert value
		ip_addr_tb[31:0] = 32'h02000010; // address of memory
		ip_store_data_tb[31:0] = 32'h12345678; // data
		ip_load_store_bit_ctrl_tb = 2'b10; // word
		ip_store_en_tb = 1'b1; // enable store
	
	@(posedge ip_clk_tb) // insert value
		ip_addr_tb[31:0] = 32'h02000014; // address of memory
		ip_store_data_tb[31:0] = 32'h87654321; // data
		ip_load_store_bit_ctrl_tb = 2'b10; // word
		ip_store_en_tb = 1'b1; // enable store

	// test case 4 (LB)
	@(posedge ip_clk_tb) // insert value
		ip_addr_tb[31:0] = 32'h02000000; // address of memory
		ip_store_data_tb[31:0] = 32'h0;
		ip_load_store_bit_ctrl_tb = 2'b00; // byte
		ip_store_en_tb = 1'b0;
	
	// test case 5 (LBU)
	@(posedge ip_clk_tb) // insert value
		ip_addr_tb[31:0] = 32'h02000004; // address of memory
		ip_load_store_bit_ctrl_tb = 2'b00; // byte
		ip_load_sign_ctrl_tb = 1'b1; // load unsigned
	
	// test case 6 (LH)
	@(posedge ip_clk_tb) // insert value
		ip_addr_tb[31:0] = 32'h0200000C; // address of memory
		ip_load_store_bit_ctrl_tb = 2'b01; // half
		ip_load_sign_ctrl_tb = 1'b0;
	
	// test case 7 (LHU)
	@(posedge ip_clk_tb) // insert value // address of memory
		ip_addr_tb[31:0] = 32'h02000008;
		ip_load_store_bit_ctrl_tb = 2'b01; // half
		ip_load_sign_ctrl_tb = 1'b1; // load unsigned
	
	// test case 8 (LW)
	@(posedge ip_clk_tb) // insert value // address of memory
		ip_addr_tb[31:0] = 32'h02000014;
		ip_load_store_bit_ctrl_tb = 2'b10; // word
		ip_load_sign_ctrl_tb = 1'b0;

	repeat(2) @(posedge ip_clk_tb) begin // 1 cycle to compute the result
		ip_addr_tb[31:0] = 32'b0;
		ip_store_data_tb[31:0] = 32'b0;
		ip_load_sign_ctrl_tb = 1'b0;
	end
	
	$stop; //stop simulation
end
endmodule