/**********************************************************************
Project: Develop 32-bit RISC-V Processor
Module: ALU.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: ALU
**********************************************************************/

`default_nettype none//to catch typing errors due to typo of signal names

module ALU
#( // declare all the parameter needed
parameter size = 6'b100000 // 32
) 
( // declare all the input and output pin needed
	input wire ip_clk,
	input wire [31:0] ip_rs1, ip_rs2, ip_pc, ip_imm_ext,
	input wire [2:0] ip_ALU_operation_ctrl, ip_branch_ctrl,
	input wire [1:0] ip_operand_a_ctrl, ip_operand_b_ctrl, ip_result_ctrl,
	input wire ip_sign_ctrl, ip_shift_direction_ctrl, ip_addr_ctrl,
	output wire [31:0] op_result, op_target_addr,
	output wire op_overflow, op_branch_ctrl
);

// wire
wire [31:0] operand_a; // operand a of ALU
wire [31:0] operand_b; // operand b of ALU
wire [31:0] operand_b_adder; // operand b of adder
wire [32:0] carry_bit_ALU_adder; // ALU adder carry bit
wire [31:0] result_AND; // result of AND
wire [31:0] result_OR; // result of OR
wire [31:0] result_XOR; // result of XOR
wire ALU_overflow; // overflow signal of ALU
wire LT_op; // involved LS instrcution
wire result_LT; // signal of rs1 less than rs2
wire zero; // result is zero
wire [31:0] result_ALU_adder; // result of ALU adder
wire [31:0] result_ALU; // result of ALU
wire sign_shift; // signed bit of shifter
wire [31:0] shifter_result_layer [0:4]; // barrel shifter layer
wire shift_overflow; // overflow detection of barrel shifter
wire [31:0] addr; // address for adding offset
wire [31:0] target_addr; // target address for jump / branch
wire [30:0] carry_bit_addr_adder; // address adder carry bit

// variable
genvar i;

// ALU
// data selection
assign operand_a[31:0] = (ip_operand_a_ctrl[1:0] == 2'b01) ? ip_pc[31:0] : ((ip_operand_a_ctrl[1:0] == 2'b10) ? 32'b0 : ip_rs1[31:0]); // data select for a operand
assign operand_b[31:0] = (ip_operand_b_ctrl[1:0] == 2'b01) ? ip_imm_ext[31:0] : ((ip_operand_b_ctrl[1:0] == 2'b10) ? 32'h00000004 : ip_rs2[31:0]); // data select for b operand

// ALU operation
assign result_AND[31:0] = operand_a[31:0] & operand_b[31:0]; // AND
assign result_OR[31:0] = operand_a[31:0] | operand_b[31:0]; // OR
assign result_XOR[31:0] = operand_a[31:0] ^ operand_b[31:0]; // XOR

// adder
assign operand_b_adder[31:0] = (ip_ALU_operation_ctrl[2] == 1'b1) ? (~operand_b[31:0]) : operand_b[31:0]; // convert operand_b if SUB
assign carry_bit_ALU_adder[0] = ip_ALU_operation_ctrl[2]; // subtraction of first carry bit after convert
generate
	for (i = 0; i < 32; i = i + 1) begin
		assign result_ALU_adder[i] = operand_a[i] ^ operand_b_adder[i] ^ carry_bit_ALU_adder[i]; // calculation of add result
		assign carry_bit_ALU_adder[i + 1] = (operand_a[i] & operand_b_adder[i]) | (operand_a[i] & carry_bit_ALU_adder[i]) | (operand_b_adder[i] & carry_bit_ALU_adder[i]); // calculation of carry bit of adder
	end
endgenerate
assign result_ALU = (ip_ALU_operation_ctrl[1:0] == 2'b00) ? result_AND[31:0] : ((ip_ALU_operation_ctrl[1:0] == 2'b01) ? result_OR[31:0] : ((ip_ALU_operation_ctrl[1:0] == 2'b10) ? result_XOR[31:0] : result_ALU_adder[31:0])); // ALU result selection
assign ALU_overflow = carry_bit_ALU_adder[32] ^ carry_bit_ALU_adder[31]; // addition overflow
assign LT_op = ((~ip_result_ctrl[1]) & ip_result_ctrl[0]) | (&ip_branch_ctrl[2:1]); // SLT / BLT / BGE operation
assign result_LT = (LT_op & (~ip_sign_ctrl) & (result_ALU_adder[31] ^ ALU_overflow)) | (LT_op & ip_sign_ctrl & (~carry_bit_ALU_adder[32])); // rs1 is less than rs2
assign zero = ~|result_ALU_adder[31:0]; // result is zero

// barrel shifter
assign sign_shift = (~ip_sign_ctrl) & operand_a[31]; // signed bit of shifter
assign shifter_result_layer[0][31:0] = (ip_shift_direction_ctrl == 1'b0) ? ((operand_b[0] == 1'b1) ? {operand_a[30:0], 1'b0} : operand_a[31:0]) : ((sign_shift == 1'b1) ? ((operand_b[0] == 1'b1) ? {1'b1, operand_a[31:1]} : operand_a[31:0]) : ((operand_b[0] == 1'b1) ? {1'b0, operand_a[31:1]} : operand_a[31:0])); // barrel shift layer 1
assign shifter_result_layer[1][31:0] = (ip_shift_direction_ctrl == 1'b0) ? ((operand_b[1] == 1'b1) ? {shifter_result_layer[0][29:0], 2'b00} : shifter_result_layer[0][31:0]) : ((sign_shift == 1'b1) ? ((operand_b[1] == 1'b1) ? {2'b11, shifter_result_layer[0][31:2]} : shifter_result_layer[0][31:0]) : ((operand_b[1] == 1'b1) ? {2'b00, shifter_result_layer[0][31:2]} : shifter_result_layer[0][31:0])); // barrel shift layer 2
assign shifter_result_layer[2][31:0] = (ip_shift_direction_ctrl == 1'b0) ? ((operand_b[2] == 1'b1) ? {shifter_result_layer[1][27:0], 4'b0000} : shifter_result_layer[1][31:0]) : ((sign_shift == 1'b1) ? ((operand_b[2] == 1'b1) ? {4'b1111, shifter_result_layer[1][31:4]} : shifter_result_layer[1][31:0]) : ((operand_b[2] == 1'b1) ? {4'b0000, shifter_result_layer[1][31:4]} : shifter_result_layer[1][31:0])); // barrel shift layer 3
assign shifter_result_layer[3][31:0] = (ip_shift_direction_ctrl == 1'b0) ? ((operand_b[3] == 1'b1) ? {shifter_result_layer[2][23:0], 8'b00000000} : shifter_result_layer[2][31:0]) : ((sign_shift == 1'b1) ? ((operand_b[3] == 1'b1) ? {8'b11111111, shifter_result_layer[2][31:8]} : shifter_result_layer[2][31:0]) : ((operand_b[3] == 1'b1) ? {8'b00000000, shifter_result_layer[2][31:8]} : shifter_result_layer[2][31:0])); // barrel shift layer 4
assign shifter_result_layer[4][31:0] = (ip_shift_direction_ctrl == 1'b0) ? ((operand_b[4] == 1'b1) ? {shifter_result_layer[3][15:0], 16'b0000000000000000} : shifter_result_layer[3][31:0]) : ((sign_shift == 1'b1) ? ((operand_b[4] == 1'b1) ? {16'b1111111111111111, shifter_result_layer[3][31:16]} : shifter_result_layer[3][31:0]) : ((operand_b[4] == 1'b1) ? {16'b0000000000000000, shifter_result_layer[3][31:16]} : shifter_result_layer[3][31:0])); // barrel shift layer 5
assign shift_overflow = ip_result_ctrl[1] & (~ip_result_ctrl[0]) & (|operand_b[31:5]); // shifting overflow

// address adder
assign addr[31:0] = (ip_addr_ctrl == 1'b1) ? ip_rs1[31:0] : ip_pc[31:0]; // address selection

// adder
assign target_addr[0] = addr[0] ^ ip_imm_ext[0]; // calculation of add result
assign carry_bit_addr_adder[0] = (addr[0] & ip_imm_ext[0]); // calculation of carry bit of adder
assign target_addr[1] = addr[1] ^ ip_imm_ext[1] ^ carry_bit_addr_adder[0]; // calculation of add result
generate
	for (i = 1; i < 31; i = i + 1) begin
		assign carry_bit_addr_adder[i] = (addr[i] & ip_imm_ext[i]) | (addr[i] & carry_bit_addr_adder[i - 1]) | (ip_imm_ext[i] & carry_bit_addr_adder[i - 1]); // calculation of carry bit of adder
		assign target_addr[i + 1] = addr[i + 1] ^ ip_imm_ext[i + 1] ^ carry_bit_addr_adder[i];
	end
endgenerate

// output result
assign op_result[31:0] = (ip_result_ctrl[1:0] == 2'b01) ? {31'b000000000000000000000000000000, result_LT} : ((ip_result_ctrl[1:0] == 2'b10) ? shifter_result_layer[4][31:0] : result_ALU[31:0]); // output the final result
assign op_branch_ctrl = ip_branch_ctrl[2] & (((~ip_branch_ctrl[1]) & (~ip_branch_ctrl[0]) & zero) | ((~ip_branch_ctrl[1]) & ip_branch_ctrl[0] & (~zero)) | (ip_branch_ctrl[1] & (~ip_branch_ctrl[0]) & result_LT) | (ip_branch_ctrl[1] & ip_branch_ctrl[0] & (~result_LT))); // output brnach condition
assign op_overflow = (ALU_overflow & (~ip_branch_ctrl[2])) | shift_overflow; // output overflow
assign op_target_addr[31:0] = target_addr[31:0]; // output target address
endmodule