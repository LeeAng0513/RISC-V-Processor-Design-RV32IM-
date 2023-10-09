/**********************************************************************
Project: Develop 32-bit RISC-V Processor 
Module: cache_tb.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description:Cache Unit Test Bench
**********************************************************************/

`include "macro.v"
`default_nettype none

module cache_tb
();

reg ip_clk_tb, ip_rst_tb;
reg [31:0] ip_wr_addr_tb, ip_wr_data_tb;
reg ip_wr_en_tb, ip_wr_done_ctrl_tb;
reg [31:0] ip_pc_tb;
reg [31:0] ip_load_store_addr_tb, ip_store_data_tb;
reg [1:0] ip_load_store_bit_ctrl_tb;
reg ip_load_sign_ctrl_tb, ip_store_en_tb;
reg ip_done_execute_ctrl_tb;
wire [31:0] op_instr_tb, op_data_tb;
wire op_valid_ctrl_tb;

cache
dut_cache(
	.ip_clk(ip_clk_tb),
	.ip_rst(ip_rst_tb),
	.ip_wr_addr(ip_wr_addr_tb),
	.ip_wr_data(ip_wr_data_tb),
	.ip_wr_en(ip_wr_en_tb),
	.ip_wr_done_ctrl(ip_wr_done_ctrl_tb),
	.ip_pc(ip_pc_tb),
	.ip_load_store_addr(ip_load_store_addr_tb),
	.ip_store_data(ip_store_data_tb),
	.ip_load_store_bit_ctrl(ip_load_store_bit_ctrl_tb),
	.ip_load_sign_ctrl(ip_load_sign_ctrl_tb),
	.ip_store_en(ip_store_en_tb),
	.ip_done_execute_ctrl(ip_done_execute_ctrl_tb),
	.op_instr(op_instr_tb),
	.op_data(op_data_tb),
	.op_valid_ctrl(op_valid_ctrl_tb)
);

initial ip_clk_tb <= 1'b1;
always #(`PERIOD_HALF) ip_clk_tb = ~ip_clk_tb;

//Signal initialization
initial begin
	@(posedge ip_clk_tb) // initialize the value (at sim time 1)
		ip_rst_tb = 1'b1;
		ip_wr_addr_tb[31:0] = 32'h0;
		ip_wr_data_tb[31:0] = 32'h0;
		ip_wr_en_tb = 1'b0;
		ip_wr_done_ctrl_tb = 1'b0;
		ip_pc_tb[31:0] = 32'h0;
		ip_load_store_addr_tb[31:0] = 32'h0;
		ip_store_data_tb[31:0] = 32'h0;
		ip_load_store_bit_ctrl_tb[1:0] = 2'b0;
		ip_load_sign_ctrl_tb = 1'b0;
		ip_store_en_tb = 1'b0;
		ip_done_execute_ctrl_tb = 1'b0;
	
	// test case 1 (write data into memory from I/O)
	@(posedge ip_clk_tb) // insert value
		ip_rst_tb = 1'b0;
		ip_wr_addr_tb[31:0] = 32'h00000000; // address of cache
		ip_wr_data_tb[31:0] = 32'h0002A303; // data
		ip_wr_en_tb = 1'b1; // write data
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_addr_tb[31:0] = 32'h00000004; // address of cache
		ip_wr_data_tb[31:0] = 32'h020002B7; // data
		ip_wr_en_tb = 1'b1; // write data
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_addr_tb[31:0] = 32'h00000008; // address of cache
		ip_wr_data_tb[31:0] = 32'h0002A303; // data
		ip_wr_en_tb = 1'b1; // write data
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_addr_tb[31:0] = 32'h0000000C; // address of cache
		ip_wr_data_tb[31:0] = 32'h0042A383; // data
		ip_wr_en_tb = 1'b1; // write data
		ip_wr_done_ctrl_tb = 1'b1; // complete write in data
	
	// test case 2 (output instruction)
	@(posedge ip_clk_tb) // insert value
		ip_wr_addr_tb[31:0] = 32'h0;
		ip_wr_data_tb[31:0] = 32'h0;
		ip_wr_en_tb = 1'b0;
		ip_wr_done_ctrl_tb = 1'b0;
		ip_pc_tb[31:0] = 32'h00000000; // address
	
	@(posedge ip_clk_tb) // insert value
		ip_pc_tb[31:0] = 32'h00000004; // address
	
	@(posedge ip_clk_tb) // insert value
		ip_pc_tb[31:0] = 32'h00000008; // address
	
	// test case 3 (SB)
	@(posedge ip_clk_tb) // insert value
		ip_pc_tb[31:0] = 32'h0;
		ip_load_store_addr_tb[31:0] = 32'h00004000; // address of cache
		ip_store_data_tb[31:0] = 32'h08EF965D; // data
		ip_load_store_bit_ctrl_tb = 2'b00; // byte
		ip_store_en_tb = 1'b1; // enable store
	
	@(posedge ip_clk_tb) // insert value
		ip_load_store_addr_tb[31:0] = 32'h00004004; // address of cache
		ip_store_data_tb[31:0] = 32'hD9A438B8; // data
		ip_load_store_bit_ctrl_tb = 2'b00; // byte
		ip_store_en_tb = 1'b1; // enable store

	// test case 4 (SH)
	@(posedge ip_clk_tb) // insert value
		ip_load_store_addr_tb[31:0] = 32'h00004008; // address of cache
		ip_store_data_tb[31:0] = 32'h5ED7C51F; // data
		ip_load_store_bit_ctrl_tb = 2'b01; // half
		ip_store_en_tb = 1'b1; // enable store

	@(posedge ip_clk_tb) // insert value
		ip_load_store_addr_tb[31:0] = 32'h0000400C; // address of cache
		ip_store_data_tb[31:0] = 32'h050B925A; // data
		ip_load_store_bit_ctrl_tb = 2'b01; // half
		ip_store_en_tb = 1'b1; // enable store
	
	// test case 5 (SW)
	@(posedge ip_clk_tb) // insert value
		ip_load_store_addr_tb[31:0] = 32'h00004010; // address of cache
		ip_store_data_tb[31:0] = 32'h12345678; // data
		ip_load_store_bit_ctrl_tb = 2'b10; // word
		ip_store_en_tb = 1'b1; // enable store
	
	@(posedge ip_clk_tb) // insert value
		ip_load_store_addr_tb[31:0] = 32'h00004014; // address of cache
		ip_store_data_tb[31:0] = 32'h87654321; // data
		ip_load_store_bit_ctrl_tb = 2'b10; // word
		ip_store_en_tb = 1'b1; // enable store
	
	// test case 6 (LB)
	@(posedge ip_clk_tb) // insert value
		ip_load_store_addr_tb[31:0] = 32'h00004000; // address of cache
		ip_store_data_tb[31:0] = 32'h0;
		ip_load_store_bit_ctrl_tb = 2'b00; // byte
		ip_store_en_tb = 1'b0; // load signed
	
	// test case 7 (LBU)
	@(posedge ip_clk_tb) // insert value
		ip_load_store_addr_tb[31:0] = 32'h00004004; // address of cache
		ip_load_store_bit_ctrl_tb = 2'b00; // byte
		ip_load_sign_ctrl_tb = 1'b1; // load unsigned
	
	// test case 8 (LH)
	@(posedge ip_clk_tb) // insert value
		ip_load_store_addr_tb[31:0] = 32'h00004008; // address of cache
		ip_load_store_bit_ctrl_tb = 2'b01; // half
		ip_load_sign_ctrl_tb = 1'b0; // load signed
	
	// test case 9 (LHU)
	@(posedge ip_clk_tb) // insert value
		ip_load_store_addr_tb[31:0] = 32'h0000400C; // address of cache
		ip_load_store_bit_ctrl_tb = 2'b01; // half
		ip_load_sign_ctrl_tb = 1'b1; // load unsigned
	
	// test case 10 (LW)
	@(posedge ip_clk_tb) // insert value
		ip_load_store_addr_tb[31:0] = 32'h00004010; // address of cache
		ip_load_store_bit_ctrl_tb = 2'b10; // word
		ip_load_sign_ctrl_tb = 1'b0;
	
	// test case 11 (set cache to invalid status when program done execution)
	@(posedge ip_clk_tb) // insert value
		ip_load_store_addr_tb[31:0] = 32'h0;
		ip_load_store_bit_ctrl_tb = 2'b0;
		ip_done_execute_ctrl_tb = 1'b1; // program done execution

	repeat(2) @(posedge ip_clk_tb) begin // 1 cycle to compute the result
		ip_wr_addr_tb[31:0] = 32'h0;
		ip_wr_data_tb[31:0] = 32'h0;
		ip_wr_en_tb = 1'b0;
		ip_wr_done_ctrl_tb = 1'b0;
		ip_pc_tb[31:0] = 32'h0;
		ip_load_store_addr_tb[31:0] = 32'h0;
		ip_store_data_tb[31:0] = 32'h0;
		ip_load_store_bit_ctrl_tb[1:0] = 2'b0;
		ip_load_sign_ctrl_tb = 1'b0;
		ip_store_en_tb = 1'b0;
		ip_done_execute_ctrl_tb = 1'b0;
	end
	
	$stop; //stop simulation
end
endmodule