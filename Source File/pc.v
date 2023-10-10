/**********************************************************************
Project: Develop 32-bit RISC-V Processor
Module: pc.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: Program Counter
**********************************************************************/

`default_nettype none // to catch typing errors due to typo of signal names

module pc
#( // declare all the parameter needed
parameter initial_I_cache_addr = 32'h00000000 // initial user program instruction address
) 
( // declare all the input and output pin needed
	input wire ip_clk, ip_rst,
	input wire [31:0] ip_target_addr,
	input wire ip_stall_ctrl, ip_jump_branch_ctrl,
	output wire [31:0] op_pc,
	output wire op_done_execute_ctrl
);

// register
reg [31:0] pc; // program counter

// wire
wire [31:0] next_pc;  // next address (+4 byte)
wire [28:0] carry_bit_adder; // carry bit of pc + 4 adder
wire stall_ctrl; // stall control detection (if stall or pc reach to D-cache address)

// variable
genvar i; // for loop

// wire assignment
// PC + 4 adder
assign next_pc[1:0] = pc[1:0];
assign next_pc[2] = pc[2] ^ 1'b1;
assign carry_bit_adder[0] = pc[2] & 1'b1; // calculation of carry bit of adder
assign next_pc[3] = pc[3] ^ carry_bit_adder[0]; // calculation of result
generate
	for (i = 1; i < 29; i = i + 1) begin
		assign carry_bit_adder[i] = pc[i + 2] & carry_bit_adder[i - 1]; // calculation of carry bit of adder
		assign next_pc[i + 3] = pc[i + 3] ^ carry_bit_adder[i]; // calculation of result
	end
endgenerate

assign stall_ctrl = ip_stall_ctrl | (|pc[31:14]); // stall control detection (if stall or pc is out of range of I-cache address)

// program counter
always @(posedge ip_clk or posedge ip_rst) begin
	if (ip_rst == 1'b1) begin // if reset
		pc[31:0] = initial_I_cache_addr; // reset to default value
	end

	else if (ip_rst == 1'b0) begin // if no reset
		if (ip_jump_branch_ctrl == 1'b1) begin // if jump or branch to target instruction address
			pc[31:0] <= ip_target_addr[31:0]; // update pc to target address
		end
		
		else if (ip_jump_branch_ctrl == 1'b0) begin // if branch to next instruction address
			if (stall_ctrl == 1'b1) begin // if stalling
				pc[31:0] <= pc[31:0]; // remain the pc
			end
		
			else if (stall_ctrl == 1'b0) begin // if not stalling
				pc[31:0] <= next_pc[31:0]; // instruction address + 4 in 32-bit Adder
			end
		end
	end
end

// output result
assign op_pc[31:0] = pc[31:0]; // output current pc
assign op_done_execute_ctrl = pc[14]; // stall the core if reach to last instruction detection

endmodule
