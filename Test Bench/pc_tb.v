/**********************************************************************
Project: Develop 32-bit RISC-V Processor
Module: pc_tb.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: Program Counter Test Bench
**********************************************************************/

`include "macro.v"
`default_nettype none

module pc_tb
();

reg ip_clk_tb, ip_rst_tb;
reg [31:0] ip_target_addr_tb;
reg ip_stall_ctrl_tb, ip_jump_branch_ctrl_tb;
wire [31:0] op_pc_tb;
wire op_done_execute_ctrl;

pc
dut_pc(
	.ip_clk(ip_clk_tb),
	.ip_rst(ip_rst_tb),
	.ip_target_addr(ip_target_addr_tb),
	.ip_stall_ctrl(ip_stall_ctrl_tb),
	.ip_jump_branch_ctrl(ip_jump_branch_ctrl_tb),
	.op_pc(op_pc_tb),
	.op_done_execute_ctrl(op_done_execute_ctrl)
);

initial ip_clk_tb <= 1'b1;
always #(`PERIOD_HALF) ip_clk_tb = ~ip_clk_tb;

//Signal initialization
initial begin
	@(posedge ip_clk_tb) // initialize the value (at sim time 1)
		ip_rst_tb = 1'b1;
		ip_target_addr_tb[31:0] = 32'b0;
		ip_stall_ctrl_tb = 1'b0;
		ip_jump_branch_ctrl_tb = 1'b0;

	// test case 1 (next instruction pc + 4)
	repeat(4) @(posedge ip_clk_tb)
		ip_rst_tb = 1'b0;
	
	// test case 2 (jump or branch address)
	@(posedge ip_clk_tb) // insert value
		ip_target_addr_tb[31:0] = 32'h00000008; // jump or branch target address
		ip_jump_branch_ctrl_tb = 1'b1;
		
	// test case 3 (stalling)
	repeat(3) @(posedge ip_clk_tb) begin // insert value
		ip_jump_branch_ctrl_tb = 1'b0;
		ip_stall_ctrl_tb = 1'b1;
	end
	
	// test case 4 (stop the pc when reach to last instruction address)
	@(posedge ip_clk_tb) // insert value
		ip_target_addr_tb[31:0] = 32'h00003FF8; // jump or branch target address
		ip_jump_branch_ctrl_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b0;
	
	repeat(6) @(posedge ip_clk_tb) begin // compute the result
		ip_target_addr_tb[31:0] = 32'h0;
		ip_stall_ctrl_tb = 1'b0;
		ip_jump_branch_ctrl_tb = 1'b0;
	end
	
	$stop; //stop simulation
end
endmodule