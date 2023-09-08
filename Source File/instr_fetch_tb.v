/**********************************************************************
Project: Develop 32-bit RISC-V Processor
Module: instr_fetch_tb.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: Instruction Fetch Unit Test Bench
**********************************************************************/

`include "macro.v"
`default_nettype none

module instr_fetch_tb
();

reg [31:0] ip_wr_data_tb, ip_wr_addr_tb, ip_target_addr_tb;
reg ip_clk_tb, ip_rst_tb, ip_wr_en_tb, ip_jump_branch_ctrl_tb, ip_stall_ctrl_tb;
wire [31:0] op_pc_addr_tb, op_instr_tb;

instr_fetch
dut_instr_fetch(
	.ip_wr_data(ip_wr_data_tb),
	.ip_wr_addr(ip_wr_addr_tb),
	.ip_target_addr(ip_target_addr_tb),
	.ip_clk(ip_clk_tb),
	.ip_rst(ip_rst_tb),
	.ip_wr_en(ip_wr_en_tb),
	.ip_jump_branch_ctrl(ip_jump_branch_ctrl_tb),
	.ip_stall_ctrl(ip_stall_ctrl_tb),
	.op_pc_addr(op_pc_addr_tb),
	.op_instr(op_instr_tb)
);

initial ip_clk_tb <= 1'b1;
always #(`PERIOD_HALF) ip_clk_tb = ~ip_clk_tb;

//Signal initialization
initial begin
	@(posedge ip_clk_tb) // initialize the value (at sim time 1)
		ip_wr_data_tb[31:0] = 32'b0;
		ip_wr_addr_tb[31:0] = 32'b0;
		ip_target_addr_tb[31:0] = 32'b0;
		ip_wr_en_tb = 1'b0;
		ip_jump_branch_ctrl_tb = 1'b0;
		ip_stall_ctrl_tb = 1'b0;
		ip_rst_tb = 1'b1;
	
	// test case 1 (write instruction into instrcution memory)
	@(posedge ip_clk_tb) // insert value
		ip_wr_data_tb[31:0] = 32'h005303B3;
		ip_wr_addr_tb[31:0] = 32'h00008000;
		ip_wr_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
		ip_rst_tb = 1'b0;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_data_tb[31:0] = 32'h0063B2B3;
		ip_wr_addr_tb[31:0] = 32'h00008004;
		ip_wr_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_data_tb[31:0] = 32'h00190913;
		ip_wr_addr_tb[31:0] = 32'h00008008;
		ip_wr_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_data_tb[31:0] = 32'h00592023;
		ip_wr_addr_tb[31:0] = 32'h0000800C;
		ip_wr_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_data_tb[31:0] = 32'h00123456;
		ip_wr_addr_tb[31:0] = 32'h00008010;
		ip_wr_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;

	// test case 2 (next instruction pc + 4)
	repeat(2) @(posedge ip_clk_tb) begin// insert value
		ip_wr_data_tb[31:0] = 32'b0;
		ip_wr_addr_tb[31:0] = 32'b0;
		ip_wr_en_tb = 1'b0;
		ip_stall_ctrl_tb = 1'b0;
	end
	
	// test case 3 (jump or branch address)
	@(posedge ip_clk_tb) // insert value
		ip_target_addr_tb[31:0] = 32'h00008004; // jump or branch target address
		ip_jump_branch_ctrl_tb = 1'b1;
	
	repeat(3) @(posedge ip_clk_tb) begin // 1 cycle to compute the result
		ip_target_addr_tb[31:0] = 32'b0;
		ip_jump_branch_ctrl_tb = 1'b0;
		ip_stall_ctrl_tb = 1'b1;
	end
	
	$stop; //stop simulation
end
endmodule