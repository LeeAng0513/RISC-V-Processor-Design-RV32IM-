/**********************************************************************
Project: Develop 32-bit RISC-V Processor
Module: instr_fetch.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: Instruction Fetch Unit
**********************************************************************/

`default_nettype none // to catch typing errors due to typo of signal names

module instr_fetch
#( // declare all the parameter needed
parameter initial_addr = 32'h00008000, // initial pc address
parameter last_addr = 32'h00008FFF // last pc address
) 
( // declare all the input and output pin needed
	input wire [31:0] ip_wr_data, ip_wr_addr, ip_target_addr,
	input wire ip_clk, ip_rst, ip_wr_en, ip_jump_branch_ctrl, ip_stall_ctrl,
	output wire [31:0] op_pc_addr, op_instr
);

// register
reg [31:0] pc; // program counter
reg [7:0] instr_mem [initial_addr:last_addr]; // instruction memory

// wire
wire plus_4; // 4 to plus in to next pc adder
wire [31:0] next_pc;  // offset of next address (4 byte)
wire [28:0] carry_bit_adder; // carry bit of pc + 4 adder

// variable
reg [31:0] i; // for loop

// program counter
assign plus_4 = 1'b1; // 4

// PC + 4 adder
assign next_pc[1:0] = pc[1:0];
assign next_pc[2] = pc[2] ^ plus_4;
assign carry_bit_adder[0] = pc[2] & plus_4; // calculation of carry bit of adder
assign next_pc[3] = pc[3] ^ carry_bit_adder[0]; // calculation of result
assign carry_bit_adder[1] = pc[3] & carry_bit_adder[0]; // calculation of carry bit of adder
assign next_pc[4] = pc[4] ^ carry_bit_adder[1]; // calculation of result
assign carry_bit_adder[2] = pc[4] & carry_bit_adder[1]; // calculation of carry bit of adder
assign next_pc[5] = pc[5] ^ carry_bit_adder[2]; // calculation of result
assign carry_bit_adder[3] = pc[5] & carry_bit_adder[2]; // calculation of carry bit of adder
assign next_pc[6] = pc[6] ^ carry_bit_adder[3]; // calculation of result
assign carry_bit_adder[4] = pc[6] & carry_bit_adder[3]; // calculation of carry bit of adder
assign next_pc[7] = pc[7] ^ carry_bit_adder[4]; // calculation of result
assign carry_bit_adder[5] = pc[7] & carry_bit_adder[4]; // calculation of carry bit of adder
assign next_pc[8] = pc[8] ^ carry_bit_adder[5]; // calculation of result
assign carry_bit_adder[6] = pc[8] & carry_bit_adder[5]; // calculation of carry bit of adder
assign next_pc[9] = pc[9] ^ carry_bit_adder[6]; // calculation of result
assign carry_bit_adder[7] = pc[9] & carry_bit_adder[6]; // calculation of carry bit of adder
assign next_pc[10] = pc[10] ^ carry_bit_adder[7]; // calculation of result
assign carry_bit_adder[8] = pc[10] & carry_bit_adder[7]; // calculation of carry bit of adder
assign next_pc[11] = pc[11] ^ carry_bit_adder[8]; // calculation of result
assign carry_bit_adder[9] = pc[11] & carry_bit_adder[8]; // calculation of carry bit of adder
assign next_pc[12] = pc[12] ^ carry_bit_adder[9]; // calculation of result
assign carry_bit_adder[10] = pc[12] & carry_bit_adder[9]; // calculation of carry bit of adder
assign next_pc[13] = pc[13] ^ carry_bit_adder[10]; // calculation of result
assign carry_bit_adder[11] = pc[13] & carry_bit_adder[10]; // calculation of carry bit of adder
assign next_pc[14] = pc[14] ^ carry_bit_adder[11]; // calculation of result
assign carry_bit_adder[12] = pc[14] & carry_bit_adder[11]; // calculation of carry bit of adder
assign next_pc[15] = pc[15] ^ carry_bit_adder[12]; // calculation of result
assign carry_bit_adder[13] = pc[15] & carry_bit_adder[12]; // calculation of carry bit of adder
assign next_pc[16] = pc[16] ^ carry_bit_adder[13]; // calculation of result
assign carry_bit_adder[14] = pc[16] & carry_bit_adder[13]; // calculation of carry bit of adder
assign next_pc[17] = pc[17] ^ carry_bit_adder[14]; // calculation of result
assign carry_bit_adder[15] = pc[17] & carry_bit_adder[14]; // calculation of carry bit of adder
assign next_pc[18] = pc[18] ^ carry_bit_adder[15]; // calculation of result
assign carry_bit_adder[16] = pc[18] & carry_bit_adder[15]; // calculation of carry bit of adder
assign next_pc[19] = pc[19] ^ carry_bit_adder[16]; // calculation of result
assign carry_bit_adder[17] = pc[19] & carry_bit_adder[16]; // calculation of carry bit of adder
assign next_pc[20] = pc[20] ^ carry_bit_adder[17]; // calculation of result
assign carry_bit_adder[18] = pc[20] & carry_bit_adder[17]; // calculation of carry bit of adder
assign next_pc[21] = pc[21] ^ carry_bit_adder[18]; // calculation of result
assign carry_bit_adder[19] = pc[21] & carry_bit_adder[18]; // calculation of carry bit of adder
assign next_pc[22] = pc[22] ^ carry_bit_adder[19]; // calculation of result
assign carry_bit_adder[20] = pc[22] & carry_bit_adder[19]; // calculation of carry bit of adder
assign next_pc[23] = pc[23] ^ carry_bit_adder[20]; // calculation of result
assign carry_bit_adder[21] = pc[23] & carry_bit_adder[20]; // calculation of carry bit of adder
assign next_pc[24] = pc[24] ^ carry_bit_adder[21]; // calculation of result
assign carry_bit_adder[22] = pc[24] & carry_bit_adder[21]; // calculation of carry bit of adder
assign next_pc[25] = pc[25] ^ carry_bit_adder[22]; // calculation of result
assign carry_bit_adder[23] = pc[25] & carry_bit_adder[22]; // calculation of carry bit of adder
assign next_pc[26] = pc[26] ^ carry_bit_adder[23]; // calculation of result
assign carry_bit_adder[24] = pc[26] & carry_bit_adder[23]; // calculation of carry bit of adder
assign next_pc[27] = pc[27] ^ carry_bit_adder[24]; // calculation of result
assign carry_bit_adder[25] = pc[27] & carry_bit_adder[24]; // calculation of carry bit of adder
assign next_pc[28] = pc[28] ^ carry_bit_adder[25]; // calculation of result
assign carry_bit_adder[26] = pc[28] & carry_bit_adder[25]; // calculation of carry bit of adder
assign next_pc[29] = pc[29] ^ carry_bit_adder[26]; // calculation of result
assign carry_bit_adder[27] = pc[29] & carry_bit_adder[26]; // calculation of carry bit of adder
assign next_pc[30] = pc[30] ^ carry_bit_adder[27]; // calculation of result
assign carry_bit_adder[28] = pc[30] & carry_bit_adder[27]; // calculation of carry bit of adder
assign next_pc[31] = pc[31] ^ carry_bit_adder[28]; // calculation of result

always @(posedge ip_clk or posedge ip_rst) begin
	if (ip_rst == 1'b1) begin // if reset
		pc[31:0] = initial_addr; // reset to default value
	end

	else if (ip_rst == 1'b0) begin // if no reset
		if (ip_stall_ctrl == 1'b1) begin // if stalling
			pc[31:0] <= pc[31:0];
		end
		
		else if (ip_stall_ctrl == 1'b0) begin // if not stalling
			if (ip_jump_branch_ctrl == 1'b1) begin // if jump or branch to target instruction address
				pc[31:0] <= ip_target_addr[31:0]; // update pc to target address
			end
			
			else if (ip_jump_branch_ctrl == 1'b0) begin // if branch to next instruction address
				pc[31:0] <= next_pc[31:0]; // instruction address + 4 in 32-bit Adder
			end
		end
	end
end

// instruction memory
always @(posedge ip_clk or posedge ip_rst) begin
	if (ip_rst == 1'b1) begin // if reset
		// reset to default value
		for (i[31:0] = initial_addr; i[31:0] <= last_addr; i[31:0] = i[31:0] + 32'h1) begin
			instr_mem[i[31:0]] = 8'b0;
		end
	end
end

always @(*) begin
	if ((ip_rst == 1'b0) && (ip_wr_en == 1'b1)) begin // // if enable to flash data in instruction memory
		instr_mem[ip_wr_addr[31:0]] = ip_wr_data[7:0];
		instr_mem[ip_wr_addr[31:0] + 32'h1] = ip_wr_data[15:8];
		instr_mem[ip_wr_addr[31:0] + 32'h2] = ip_wr_data[23:16];
		instr_mem[ip_wr_addr[31:0] + 32'h3] = ip_wr_data[31:24];
	end
end

// output result
assign op_pc_addr[31:0] = pc[31:0]; // output current pc
// output the instruction
assign op_instr[7:0] = instr_mem[pc[31:0]];
assign op_instr[15:8] = instr_mem[pc[31:0] + 32'h1];
assign op_instr[23:16] = instr_mem[pc[31:0] + 32'h2];
assign op_instr[31:24] = instr_mem[pc[31:0] + 32'h3];

endmodule