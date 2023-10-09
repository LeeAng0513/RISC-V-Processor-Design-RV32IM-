/**********************************************************************
Project: Develop 32-bit RISC-V Processor
Module: data_path_tb.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: Core Test Bench
**********************************************************************/

`include "macro.v"
`default_nettype none

module core_tb
();

reg ip_clk_tb, ip_rst_tb;
reg [31:0] ip_wr_cache_data_tb, ip_wr_cache_addr_tb;
reg ip_wr_cache_en_tb, ip_wr_cache_done_ctrl_tb, ip_stall_ctrl_tb;
wire op_overflow_tb, op_valid_ctrl_tb;

core
dut_core(
	.ip_clk(ip_clk_tb),
	.ip_rst(ip_rst_tb),
	.ip_wr_cache_data(ip_wr_cache_data_tb),
	.ip_wr_cache_addr(ip_wr_cache_addr_tb),
	.ip_wr_cache_en(ip_wr_cache_en_tb),
	.ip_wr_cache_done_ctrl(ip_wr_cache_done_ctrl_tb),
	.ip_stall_ctrl(ip_stall_ctrl_tb),
	.op_overflow(op_overflow_tb),
	.op_valid_ctrl(op_valid_ctrl_tb)
);

initial ip_clk_tb <= 1'b1;
always #(`PERIOD_HALF) ip_clk_tb = ~ip_clk_tb;

//Signal initialization
initial begin	
	@(posedge ip_clk_tb) // initialize the value (at sim time 1)
		ip_rst_tb = 1'b1;
		ip_wr_cache_data_tb[31:0] = 32'h0;
		ip_wr_cache_addr_tb[31:0] = 32'h0;
		ip_wr_cache_en_tb = 1'b0;
		ip_wr_cache_done_ctrl_tb = 1'b0;
		ip_stall_ctrl_tb = 1'b0;
	
	// test case 1 (write data into instrcution and data cache and run the instructions)
	@(posedge ip_clk_tb) // insert value
		ip_rst_tb = 1'b0;
		ip_wr_cache_data_tb[31:0] = 32'h000042B7; // LUI x5, 0x00004 # load initial D-cache address in register
		ip_wr_cache_addr_tb[31:0] = 32'h00000004; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable

	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h0002A303; // LW x6, x5, 0x000 # i = 1
		ip_wr_cache_addr_tb[31:0] = 32'h00000008; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h0042A383; // LW x7, x5, 0x004 # a = 2
		ip_wr_cache_addr_tb[31:0] = 32'h0000000C; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h0082AE03; // LW x28, x5, 0x008 # b = 3
		ip_wr_cache_addr_tb[31:0] = 32'h00000010; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00C2AE83; // LW x29, x5, 0x00C # c = 4
		ip_wr_cache_addr_tb[31:0] = 32'h00000014; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h0102AF03; // LW x30, x5, 0x010 # d = 5
		ip_wr_cache_addr_tb[31:0] = 32'h00000018; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00000313; // ADDI x6, x0, 0x000 # i = 0
		ip_wr_cache_addr_tb[31:0] = 32'h0000001C; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00A00493; // ADDI x9, x0, 0x00A # 10
		ip_wr_cache_addr_tb[31:0] = 32'h00000020; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00500913; // ADDI x18, x0, 0x005 # 5
		ip_wr_cache_addr_tb[31:0] = 32'h00000024; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00935E63; // BGE x6, x9, loop_end
		ip_wr_cache_addr_tb[31:0] = 32'h00000028; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00694663; // BLT x18, x6, greater_5 # if i > 5
		ip_wr_cache_addr_tb[31:0] = 32'h0000002C; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h01EE8EB3; // ADD x29, x29, x30 # c += d
		ip_wr_cache_addr_tb[31:0] = 32'h00000030; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h008000EF; // JAL x1, if_end
		ip_wr_cache_addr_tb[31:0] = 32'h00000034; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h01C383B3; // ADD x7, x7, x28 # a += b
		ip_wr_cache_addr_tb[31:0] = 32'h00000038; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00130313; // ADDI x6, x6, 0x001 # i++
		ip_wr_cache_addr_tb[31:0] = 32'h0000003C; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'hFE9FF0EF; // JAL x1, loop
		ip_wr_cache_addr_tb[31:0] = 32'h00000040; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h008000EF; // JAL x1, multiplication
		ip_wr_cache_addr_tb[31:0] = 32'h00000044; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00C000EF; // JAL x1, exit
		ip_wr_cache_addr_tb[31:0] = 32'h00000048; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h03D38333; // MUL x6, x7, x29
		ip_wr_cache_addr_tb[31:0] = 32'h0000004C; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h000080E7; // JALR x1, x1, 0x000
		ip_wr_cache_addr_tb[31:0] = 32'h00000050; // instruction address
		ip_wr_cache_en_tb = 1'b1; // write enable

	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00000001; // 1
		ip_wr_cache_addr_tb[31:0] = 32'h00004000; // data address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00000002; // 2
		ip_wr_cache_addr_tb[31:0] = 32'h00004004; // data address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00000003; // 3
		ip_wr_cache_addr_tb[31:0] = 32'h00004008; // data address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00000004; // 4
		ip_wr_cache_addr_tb[31:0] = 32'h0000400C; // data address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00000005; // 5
		ip_wr_cache_addr_tb[31:0] = 32'h00004010; // data address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00000006; // 6
		ip_wr_cache_addr_tb[31:0] = 32'h00004014; // data address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00000007; // 7
		ip_wr_cache_addr_tb[31:0] = 32'h00004018; // data address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00000008; // 8
		ip_wr_cache_addr_tb[31:0] = 32'h0000401C; // data address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h00000009; // 9
		ip_wr_cache_addr_tb[31:0] = 32'h00004020; // data address
		ip_wr_cache_en_tb = 1'b1; // write enable
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_cache_data_tb[31:0] = 32'h0000000A; // 10
		ip_wr_cache_addr_tb[31:0] = 32'h00004024; // data address
		ip_wr_cache_en_tb = 1'b1; // write enable
		ip_wr_cache_done_ctrl_tb = 1'b1; // done flash data into cache

	repeat(4202) @(posedge ip_clk_tb) begin // 128 cycle to compute the result
		ip_wr_cache_data_tb[31:0] = 32'h0;
		ip_wr_cache_addr_tb[31:0] = 32'h0;
		ip_wr_cache_en_tb = 1'b0;
		ip_wr_cache_done_ctrl_tb = 1'b0;
		ip_stall_ctrl_tb = 1'b0;
	end

	$stop; //stop simulation
end
endmodule