/**********************************************************************
Project: 32-bit RISC-V Processor 
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
	input wire [31:0] ip_rs1, ip_rs2, ip_pc_addr,
	input wire [24:0] ip_imm,
	input wire [2:0] ip_imm_ext_ctrl, ip_ALU_operation_ctrl, ip_branch_ctrl,
	input wire [1:0] ip_operand_a_ctrl, ip_operand_b_ctrl, ip_result_ctrl,
	input wire ip_clk, ip_sign_ctrl, ip_shift_direction_ctrl, ip_addr_ctrl,
	output wire [31:0] op_result, op_target_addr,
	output wire op_overflow, op_branch_ctrl
);

// wire
wire sign_imm_ext; // signed bit extend for immediate
wire [31:0] imm_ext; // immediate data extand
wire [31:0] operand_a; // operand a of ALU
wire [31:0] operand_b; // operand b of ALU
wire [31:0] operand_b_adder; // operand b of adder
wire [32:0] carry_bit_ALU_adder; // ALU adder carry bit
wire [31:0] result_AND; // result of AND
wire [31:0] result_OR; // result of OR
wire [31:0] result_XOR; // result of XOR
wire ALU_overflow; // overflow signal of ALU
wire LT; // involved LS instrcution
wire result_LT; // signal of rs1 less than rs2
wire zero; // result is zero
wire [31:0] result_ALU_adder; // result of ALU adder
wire [31:0] result_ALU; // result of ALU
wire sign_shift; // signed bit of shifter
wire [31:0] shifter_layer_1; // barrel shifter layer 1
wire [31:0] shifter_layer_2; // barrel shifter layer 2
wire [31:0] shifter_layer_3; // barrel shifter layer 3
wire [31:0] shifter_layer_4; // barrel shifter layer 4
wire [31:0] shifter_layer_5; // barrel shifter layer 5
wire [31:0] result_shift; // result of barrel shifter
wire shift_overflow; // overflow detection of barrel shifter

wire [31:0] addr; // address for adding offset
wire [31:0] offset; // offset of the target address
wire [31:0] target_addr; // target address for jump / branch
wire [32:0] carry_bit_addr_adder; // address adder carry bit

// immediate extension
assign sign_imm_ext = (~ip_sign_ctrl) & ip_imm[24]; // signed bit extend for immediate
assign imm_ext[31:0] = (ip_imm_ext_ctrl[2:0] == 3'b001) ? {ip_imm[24:5], 12'b000000000000} : ((ip_imm_ext_ctrl[2:0] == 3'b010) ? ((ip_imm[24] == 1'b1) ? {12'b111111111111, ip_imm[24:5]} : {12'b000000000000, ip_imm[24:5]}) : ((ip_imm_ext_ctrl[2:0] == 3'b011) ? ((sign_imm_ext == 1'b1) ? {20'b11111111111111111111, ip_imm[24:13]} : {20'b00000000000000000000, ip_imm[24:13]}) : ((ip_imm_ext_ctrl[2:0] == 3'b100) ? ((ip_imm[24] == 1'b1) ? {20'b11111111111111111111, ip_imm[24:18], ip_imm[4:0]} : {20'b00000000000000000000, ip_imm[24:18], ip_imm[4:0]}) : ((ip_imm_ext_ctrl[2:0] == 3'b101) ? {27'b000000000000000000000000000, ip_imm[17:13]} : 32'b0)))); // 5 type of immediate extend

// ALU
// data selection
assign operand_a[31:0] = (ip_operand_a_ctrl[1:0] == 2'b01) ? ip_pc_addr[31:0] : ((ip_operand_a_ctrl[1:0] == 2'b10) ? 32'b0 : ip_rs1[31:0]); // data select for a operand
assign operand_b[31:0] = (ip_operand_b_ctrl[1:0] == 2'b01) ? imm_ext[31:0] : ((ip_operand_b_ctrl[1:0] == 2'b10) ? 32'h00000004 : ip_rs2[31:0]); // data select for b operand

// ALU operation
assign result_AND[31:0] = operand_a[31:0] & operand_b[31:0]; // AND
assign result_OR[31:0] = operand_a[31:0] | operand_b[31:0]; // OR
assign result_XOR[31:0] = operand_a[31:0] ^ operand_b[31:0]; // XOR

// adder
assign operand_b_adder[31:0] = (ip_ALU_operation_ctrl[2] == 1'b1) ? (~operand_b[31:0]) : operand_b[31:0]; // convert operand_b if SUB
assign carry_bit_ALU_adder[0] = ip_ALU_operation_ctrl[2]; // subtraction of first carry bit after convert
assign result_ALU_adder[0] = operand_a[0] ^ operand_b_adder[0] ^ carry_bit_ALU_adder[0]; // calculation of add result
assign carry_bit_ALU_adder[1] = (operand_a[0] & operand_b_adder[0]) | (operand_a[0] & carry_bit_ALU_adder[0]) | (operand_b_adder[0] & carry_bit_ALU_adder[0]); // calculation of carry bit of adder
assign result_ALU_adder[1] = operand_a[1] ^ operand_b_adder[1] ^ carry_bit_ALU_adder[1];
assign carry_bit_ALU_adder[2] = (operand_a[1] & operand_b_adder[1]) | (operand_a[1] & carry_bit_ALU_adder[1]) | (operand_b_adder[1] & carry_bit_ALU_adder[1]); // calculation of carry bit of adder
assign result_ALU_adder[2] = operand_a[2] ^ operand_b_adder[2] ^ carry_bit_ALU_adder[2];
assign carry_bit_ALU_adder[3] = (operand_a[2] & operand_b_adder[2]) | (operand_a[2] & carry_bit_ALU_adder[2]) | (operand_b_adder[2] & carry_bit_ALU_adder[2]); // calculation of carry bit of adder
assign result_ALU_adder[3] = operand_a[3] ^ operand_b_adder[3] ^ carry_bit_ALU_adder[3];
assign carry_bit_ALU_adder[4] = (operand_a[3] & operand_b_adder[3]) | (operand_a[3] & carry_bit_ALU_adder[3]) | (operand_b_adder[3] & carry_bit_ALU_adder[3]); // calculation of carry bit of adder
assign result_ALU_adder[4] = operand_a[4] ^ operand_b_adder[4] ^ carry_bit_ALU_adder[4];
assign carry_bit_ALU_adder[5] = (operand_a[4] & operand_b_adder[4]) | (operand_a[4] & carry_bit_ALU_adder[4]) | (operand_b_adder[4] & carry_bit_ALU_adder[4]); // calculation of carry bit of adder
assign result_ALU_adder[5] = operand_a[5] ^ operand_b_adder[5] ^ carry_bit_ALU_adder[5];
assign carry_bit_ALU_adder[6] = (operand_a[5] & operand_b_adder[5]) | (operand_a[5] & carry_bit_ALU_adder[5]) | (operand_b_adder[5] & carry_bit_ALU_adder[5]); // calculation of carry bit of adder
assign result_ALU_adder[6] = operand_a[6] ^ operand_b_adder[6] ^ carry_bit_ALU_adder[6];
assign carry_bit_ALU_adder[7] = (operand_a[6] & operand_b_adder[6]) | (operand_a[6] & carry_bit_ALU_adder[6]) | (operand_b_adder[6] & carry_bit_ALU_adder[6]); // calculation of carry bit of adder
assign result_ALU_adder[7] = operand_a[7] ^ operand_b_adder[7] ^ carry_bit_ALU_adder[7];
assign carry_bit_ALU_adder[8] = (operand_a[7] & operand_b_adder[7]) | (operand_a[7] & carry_bit_ALU_adder[7]) | (operand_b_adder[7] & carry_bit_ALU_adder[7]); // calculation of carry bit of adder
assign result_ALU_adder[8] = operand_a[8] ^ operand_b_adder[8] ^ carry_bit_ALU_adder[8];
assign carry_bit_ALU_adder[9] = (operand_a[8] & operand_b_adder[8]) | (operand_a[8] & carry_bit_ALU_adder[8]) | (operand_b_adder[8] & carry_bit_ALU_adder[8]); // calculation of carry bit of adder
assign result_ALU_adder[9] = operand_a[9] ^ operand_b_adder[9] ^ carry_bit_ALU_adder[9];
assign carry_bit_ALU_adder[10] = (operand_a[9] & operand_b_adder[9]) | (operand_a[9] & carry_bit_ALU_adder[9]) | (operand_b_adder[9] & carry_bit_ALU_adder[9]); // calculation of carry bit of adder
assign result_ALU_adder[10] = operand_a[10] ^ operand_b_adder[10] ^ carry_bit_ALU_adder[10];
assign carry_bit_ALU_adder[11] = (operand_a[10] & operand_b_adder[10]) | (operand_a[10] & carry_bit_ALU_adder[10]) | (operand_b_adder[10] & carry_bit_ALU_adder[10]); // calculation of carry bit of adder
assign result_ALU_adder[11] = operand_a[11] ^ operand_b_adder[11] ^ carry_bit_ALU_adder[11];
assign carry_bit_ALU_adder[12] = (operand_a[11] & operand_b_adder[11]) | (operand_a[11] & carry_bit_ALU_adder[11]) | (operand_b_adder[11] & carry_bit_ALU_adder[11]); // calculation of carry bit of adder
assign result_ALU_adder[12] = operand_a[12] ^ operand_b_adder[12] ^ carry_bit_ALU_adder[12];
assign carry_bit_ALU_adder[13] = (operand_a[12] & operand_b_adder[12]) | (operand_a[12] & carry_bit_ALU_adder[12]) | (operand_b_adder[12] & carry_bit_ALU_adder[12]); // calculation of carry bit of adder
assign result_ALU_adder[13] = operand_a[13] ^ operand_b_adder[13] ^ carry_bit_ALU_adder[13];
assign carry_bit_ALU_adder[14] = (operand_a[13] & operand_b_adder[13]) | (operand_a[13] & carry_bit_ALU_adder[13]) | (operand_b_adder[13] & carry_bit_ALU_adder[13]); // calculation of carry bit of adder
assign result_ALU_adder[14] = operand_a[14] ^ operand_b_adder[14] ^ carry_bit_ALU_adder[14];
assign carry_bit_ALU_adder[15] = (operand_a[14] & operand_b_adder[14]) | (operand_a[14] & carry_bit_ALU_adder[14]) | (operand_b_adder[14] & carry_bit_ALU_adder[14]); // calculation of carry bit of adder
assign result_ALU_adder[15] = operand_a[15] ^ operand_b_adder[15] ^ carry_bit_ALU_adder[15];
assign carry_bit_ALU_adder[16] = (operand_a[15] & operand_b_adder[15]) | (operand_a[15] & carry_bit_ALU_adder[15]) | (operand_b_adder[15] & carry_bit_ALU_adder[15]); // calculation of carry bit of adder
assign result_ALU_adder[16] = operand_a[16] ^ operand_b_adder[16] ^ carry_bit_ALU_adder[16];
assign carry_bit_ALU_adder[17] = (operand_a[16] & operand_b_adder[16]) | (operand_a[16] & carry_bit_ALU_adder[16]) | (operand_b_adder[16] & carry_bit_ALU_adder[16]); // calculation of carry bit of adder
assign result_ALU_adder[17] = operand_a[17] ^ operand_b_adder[17] ^ carry_bit_ALU_adder[17];
assign carry_bit_ALU_adder[18] = (operand_a[17] & operand_b_adder[17]) | (operand_a[17] & carry_bit_ALU_adder[17]) | (operand_b_adder[17] & carry_bit_ALU_adder[17]); // calculation of carry bit of adder
assign result_ALU_adder[18] = operand_a[18] ^ operand_b_adder[18] ^ carry_bit_ALU_adder[18];
assign carry_bit_ALU_adder[19] = (operand_a[18] & operand_b_adder[18]) | (operand_a[18] & carry_bit_ALU_adder[18]) | (operand_b_adder[18] & carry_bit_ALU_adder[18]); // calculation of carry bit of adder
assign result_ALU_adder[19] = operand_a[19] ^ operand_b_adder[19] ^ carry_bit_ALU_adder[19];
assign carry_bit_ALU_adder[20] = (operand_a[19] & operand_b_adder[19]) | (operand_a[19] & carry_bit_ALU_adder[19]) | (operand_b_adder[19] & carry_bit_ALU_adder[19]); // calculation of carry bit of adder
assign result_ALU_adder[20] = operand_a[20] ^ operand_b_adder[20] ^ carry_bit_ALU_adder[20];
assign carry_bit_ALU_adder[21] = (operand_a[20] & operand_b_adder[20]) | (operand_a[20] & carry_bit_ALU_adder[20]) | (operand_b_adder[20] & carry_bit_ALU_adder[20]); // calculation of carry bit of adder
assign result_ALU_adder[21] = operand_a[21] ^ operand_b_adder[21] ^ carry_bit_ALU_adder[21];
assign carry_bit_ALU_adder[22] = (operand_a[21] & operand_b_adder[21]) | (operand_a[21] & carry_bit_ALU_adder[21]) | (operand_b_adder[21] & carry_bit_ALU_adder[21]); // calculation of carry bit of adder
assign result_ALU_adder[22] = operand_a[22] ^ operand_b_adder[22] ^ carry_bit_ALU_adder[22];
assign carry_bit_ALU_adder[23] = (operand_a[22] & operand_b_adder[22]) | (operand_a[22] & carry_bit_ALU_adder[22]) | (operand_b_adder[22] & carry_bit_ALU_adder[22]); // calculation of carry bit of adder
assign result_ALU_adder[23] = operand_a[23] ^ operand_b_adder[23] ^ carry_bit_ALU_adder[23];
assign carry_bit_ALU_adder[24] = (operand_a[23] & operand_b_adder[23]) | (operand_a[23] & carry_bit_ALU_adder[23]) | (operand_b_adder[23] & carry_bit_ALU_adder[23]); // calculation of carry bit of adder
assign result_ALU_adder[24] = operand_a[24] ^ operand_b_adder[24] ^ carry_bit_ALU_adder[24];
assign carry_bit_ALU_adder[25] = (operand_a[24] & operand_b_adder[24]) | (operand_a[24] & carry_bit_ALU_adder[24]) | (operand_b_adder[24] & carry_bit_ALU_adder[24]); // calculation of carry bit of adder
assign result_ALU_adder[25] = operand_a[25] ^ operand_b_adder[25] ^ carry_bit_ALU_adder[25];
assign carry_bit_ALU_adder[26] = (operand_a[25] & operand_b_adder[25]) | (operand_a[25] & carry_bit_ALU_adder[25]) | (operand_b_adder[25] & carry_bit_ALU_adder[25]); // calculation of carry bit of adder
assign result_ALU_adder[26] = operand_a[26] ^ operand_b_adder[26] ^ carry_bit_ALU_adder[26];
assign carry_bit_ALU_adder[27] = (operand_a[26] & operand_b_adder[26]) | (operand_a[26] & carry_bit_ALU_adder[26]) | (operand_b_adder[26] & carry_bit_ALU_adder[26]); // calculation of carry bit of adder
assign result_ALU_adder[27] = operand_a[27] ^ operand_b_adder[27] ^ carry_bit_ALU_adder[27];
assign carry_bit_ALU_adder[28] = (operand_a[27] & operand_b_adder[27]) | (operand_a[27] & carry_bit_ALU_adder[27]) | (operand_b_adder[27] & carry_bit_ALU_adder[27]); // calculation of carry bit of adder
assign result_ALU_adder[28] = operand_a[28] ^ operand_b_adder[28] ^ carry_bit_ALU_adder[28];
assign carry_bit_ALU_adder[29] = (operand_a[28] & operand_b_adder[28]) | (operand_a[28] & carry_bit_ALU_adder[28]) | (operand_b_adder[28] & carry_bit_ALU_adder[28]); // calculation of carry bit of adder
assign result_ALU_adder[29] = operand_a[29] ^ operand_b_adder[29] ^ carry_bit_ALU_adder[29];
assign carry_bit_ALU_adder[30] = (operand_a[29] & operand_b_adder[29]) | (operand_a[29] & carry_bit_ALU_adder[29]) | (operand_b_adder[29] & carry_bit_ALU_adder[29]); // calculation of carry bit of adder
assign result_ALU_adder[30] = operand_a[30] ^ operand_b_adder[30] ^ carry_bit_ALU_adder[30];
assign carry_bit_ALU_adder[31] = (operand_a[30] & operand_b_adder[30]) | (operand_a[30] & carry_bit_ALU_adder[30]) | (operand_b_adder[30] & carry_bit_ALU_adder[30]); // calculation of carry bit of adder
assign result_ALU_adder[31] = operand_a[31] ^ operand_b_adder[31] ^ carry_bit_ALU_adder[31];
assign carry_bit_ALU_adder[32] = (operand_a[31] & operand_b_adder[31]) | (operand_a[31] & carry_bit_ALU_adder[31]) | (operand_b_adder[31] & carry_bit_ALU_adder[31]); // calculation of carry bit of adder
assign result_ALU = (ip_ALU_operation_ctrl[1:0] == 2'b00) ? result_AND[31:0] : ((ip_ALU_operation_ctrl[1:0] == 2'b01) ? result_OR[31:0] : ((ip_ALU_operation_ctrl[1:0] == 2'b10) ? result_XOR[31:0] : result_ALU_adder[31:0])); // ALU result selection
assign ALU_overflow = carry_bit_ALU_adder[32] ^ carry_bit_ALU_adder[31]; // addition overflow
assign LT = ((~ip_result_ctrl[1]) & ip_result_ctrl[0]) | (&ip_branch_ctrl[2:1]); // SLT / BLT / BGE operation
assign result_LT = (LT & (~ip_sign_ctrl) & (result_ALU_adder[31] ^ ALU_overflow)) | (LT & ip_sign_ctrl & (~carry_bit_ALU_adder[32])); // rs1 is less than rs2
assign zero = ~|result_ALU_adder[31:0]; // result is zero

// barrel shifter
assign sign_shift = (~ip_sign_ctrl) & operand_a[31]; // signed bit of shifter
assign shifter_layer_1[31:0] = (ip_shift_direction_ctrl == 1'b0) ? ((operand_b[0] == 1'b1) ? {operand_a[30:0], 1'b0} : operand_a[31:0]) : ((sign_shift == 1'b1) ? ((operand_b[0] == 1'b1) ? {1'b1, operand_a[31:1]} : operand_a[31:0]) : ((operand_b[0] == 1'b1) ? {1'b0, operand_a[31:1]} : operand_a[31:0])); // barrel shift layer 1
assign shifter_layer_2[31:0] = (ip_shift_direction_ctrl == 1'b0) ? ((operand_b[0] == 1'b1) ? {shifter_layer_1[29:0], 2'b00} : shifter_layer_1[31:0]) : ((sign_shift == 1'b1) ? ((operand_b[0] == 1'b1) ? {2'b11, shifter_layer_1[31:2]} : shifter_layer_1[31:0]) : ((operand_b[0] == 1'b1) ? {2'b00, shifter_layer_1[31:2]} : shifter_layer_1[31:0])); // barrel shift layer 2
assign shifter_layer_3[31:0] = (ip_shift_direction_ctrl == 1'b0) ? ((operand_b[0] == 1'b1) ? {shifter_layer_2[27:0], 4'b0000} : shifter_layer_2[31:0]) : ((sign_shift == 1'b1) ? ((operand_b[0] == 1'b1) ? {4'b1111, shifter_layer_2[31:4]} : shifter_layer_2[31:0]) : ((operand_b[0] == 1'b1) ? {4'b0000, shifter_layer_2[31:4]} : shifter_layer_2[31:0])); // barrel shift layer 3
assign shifter_layer_4[31:0] = (ip_shift_direction_ctrl == 1'b0) ? ((operand_b[0] == 1'b1) ? {shifter_layer_3[23:0], 8'b00000000} : shifter_layer_3[31:0]) : ((sign_shift == 1'b1) ? ((operand_b[0] == 1'b1) ? {8'b11111111, shifter_layer_3[31:8]} : shifter_layer_3[31:0]) : ((operand_b[0] == 1'b1) ? {8'b00000000, shifter_layer_3[31:8]} : shifter_layer_3[31:0])); // barrel shift layer 4
assign shifter_layer_5[31:0] = (ip_shift_direction_ctrl == 1'b0) ? ((operand_b[0] == 1'b1) ? {shifter_layer_4[15:0], 16'b0000000000000000} : shifter_layer_4[31:0]) : ((sign_shift == 1'b1) ? ((operand_b[0] == 1'b1) ? {16'b1111111111111111, shifter_layer_4[31:16]} : shifter_layer_4[31:0]) : ((operand_b[0] == 1'b1) ? {16'b0000000000000000, shifter_layer_4[31:16]} : shifter_layer_4[31:0])); // barrel shift layer 5
assign result_shift[31:0] = shifter_layer_5[31:0]; // shifting result
assign shift_overflow = ip_result_ctrl[1] & (~ip_result_ctrl[0]) & (|operand_b[31:5]); // shifting overflow

// address adder
assign addr[31:0] = (ip_addr_ctrl == 1'b1) ? ip_rs1[31:0] : ip_pc_addr[31:0]; // address selection
assign offset[31:0] = {imm_ext[30:0], 1'b0}; // offset multiply by 2 (shift left 1 bit)

// adder
assign carry_bit_addr_adder[0] = 1'b0;
assign target_addr[0] = addr[0] ^ offset[0] ^ carry_bit_addr_adder[0]; // calculation of add result
assign carry_bit_addr_adder[1] = (addr[0] & offset[0]) | (addr[0] & carry_bit_addr_adder[0]) | (offset[0] & carry_bit_addr_adder[0]); // calculation of carry bit of adder
assign target_addr[1] = addr[1] ^ offset[1] ^ carry_bit_addr_adder[1];
assign carry_bit_addr_adder[2] = (addr[1] & offset[1]) | (addr[1] & carry_bit_addr_adder[1]) | (offset[1] & carry_bit_addr_adder[1]); // calculation of carry bit of adder
assign target_addr[2] = addr[2] ^ offset[2] ^ carry_bit_addr_adder[2];
assign carry_bit_addr_adder[3] = (addr[2] & offset[2]) | (addr[2] & carry_bit_addr_adder[2]) | (offset[2] & carry_bit_addr_adder[2]); // calculation of carry bit of adder
assign target_addr[3] = addr[3] ^ offset[3] ^ carry_bit_addr_adder[3];
assign carry_bit_addr_adder[4] = (addr[3] & offset[3]) | (addr[3] & carry_bit_addr_adder[3]) | (offset[3] & carry_bit_addr_adder[3]); // calculation of carry bit of adder
assign target_addr[4] = addr[4] ^ offset[4] ^ carry_bit_addr_adder[4];
assign carry_bit_addr_adder[5] = (addr[4] & offset[4]) | (addr[4] & carry_bit_addr_adder[4]) | (offset[4] & carry_bit_addr_adder[4]); // calculation of carry bit of adder
assign target_addr[5] = addr[5] ^ offset[5] ^ carry_bit_addr_adder[5];
assign carry_bit_addr_adder[6] = (addr[5] & offset[5]) | (addr[5] & carry_bit_addr_adder[5]) | (offset[5] & carry_bit_addr_adder[5]); // calculation of carry bit of adder
assign target_addr[6] = addr[6] ^ offset[6] ^ carry_bit_addr_adder[6];
assign carry_bit_addr_adder[7] = (addr[6] & offset[6]) | (addr[6] & carry_bit_addr_adder[6]) | (offset[6] & carry_bit_addr_adder[6]); // calculation of carry bit of adder
assign target_addr[7] = addr[7] ^ offset[7] ^ carry_bit_addr_adder[7];
assign carry_bit_addr_adder[8] = (addr[7] & offset[7]) | (addr[7] & carry_bit_addr_adder[7]) | (offset[7] & carry_bit_addr_adder[7]); // calculation of carry bit of adder
assign target_addr[8] = addr[8] ^ offset[8] ^ carry_bit_addr_adder[8];
assign carry_bit_addr_adder[9] = (addr[8] & offset[8]) | (addr[8] & carry_bit_addr_adder[8]) | (offset[8] & carry_bit_addr_adder[8]); // calculation of carry bit of adder
assign target_addr[9] = addr[9] ^ offset[9] ^ carry_bit_addr_adder[9];
assign carry_bit_addr_adder[10] = (addr[9] & offset[9]) | (addr[9] & carry_bit_addr_adder[9]) | (offset[9] & carry_bit_addr_adder[9]); // calculation of carry bit of adder
assign target_addr[10] = addr[10] ^ offset[10] ^ carry_bit_addr_adder[10];
assign carry_bit_addr_adder[11] = (addr[10] & offset[10]) | (addr[10] & carry_bit_addr_adder[10]) | (offset[10] & carry_bit_addr_adder[10]); // calculation of carry bit of adder
assign target_addr[11] = addr[11] ^ offset[11] ^ carry_bit_addr_adder[11];
assign carry_bit_addr_adder[12] = (addr[11] & offset[11]) | (addr[11] & carry_bit_addr_adder[11]) | (offset[11] & carry_bit_addr_adder[11]); // calculation of carry bit of adder
assign target_addr[12] = addr[12] ^ offset[12] ^ carry_bit_addr_adder[12];
assign carry_bit_addr_adder[13] = (addr[12] & offset[12]) | (addr[12] & carry_bit_addr_adder[12]) | (offset[12] & carry_bit_addr_adder[12]); // calculation of carry bit of adder
assign target_addr[13] = addr[13] ^ offset[13] ^ carry_bit_addr_adder[13];
assign carry_bit_addr_adder[14] = (addr[13] & offset[13]) | (addr[13] & carry_bit_addr_adder[13]) | (offset[13] & carry_bit_addr_adder[13]); // calculation of carry bit of adder
assign target_addr[14] = addr[14] ^ offset[14] ^ carry_bit_addr_adder[14];
assign carry_bit_addr_adder[15] = (addr[14] & offset[14]) | (addr[14] & carry_bit_addr_adder[14]) | (offset[14] & carry_bit_addr_adder[14]); // calculation of carry bit of adder
assign target_addr[15] = addr[15] ^ offset[15] ^ carry_bit_addr_adder[15];
assign carry_bit_addr_adder[16] = (addr[15] & offset[15]) | (addr[15] & carry_bit_addr_adder[15]) | (offset[15] & carry_bit_addr_adder[15]); // calculation of carry bit of adder
assign target_addr[16] = addr[16] ^ offset[16] ^ carry_bit_addr_adder[16];
assign carry_bit_addr_adder[17] = (addr[16] & offset[16]) | (addr[16] & carry_bit_addr_adder[16]) | (offset[16] & carry_bit_addr_adder[16]); // calculation of carry bit of adder
assign target_addr[17] = addr[17] ^ offset[17] ^ carry_bit_addr_adder[17];
assign carry_bit_addr_adder[18] = (addr[17] & offset[17]) | (addr[17] & carry_bit_addr_adder[17]) | (offset[17] & carry_bit_addr_adder[17]); // calculation of carry bit of adder
assign target_addr[18] = addr[18] ^ offset[18] ^ carry_bit_addr_adder[18];
assign carry_bit_addr_adder[19] = (addr[18] & offset[18]) | (addr[18] & carry_bit_addr_adder[18]) | (offset[18] & carry_bit_addr_adder[18]); // calculation of carry bit of adder
assign target_addr[19] = addr[19] ^ offset[19] ^ carry_bit_addr_adder[19];
assign carry_bit_addr_adder[20] = (addr[19] & offset[19]) | (addr[19] & carry_bit_addr_adder[19]) | (offset[19] & carry_bit_addr_adder[19]); // calculation of carry bit of adder
assign target_addr[20] = addr[20] ^ offset[20] ^ carry_bit_addr_adder[20];
assign carry_bit_addr_adder[21] = (addr[20] & offset[20]) | (addr[20] & carry_bit_addr_adder[20]) | (offset[20] & carry_bit_addr_adder[20]); // calculation of carry bit of adder
assign target_addr[21] = addr[21] ^ offset[21] ^ carry_bit_addr_adder[21];
assign carry_bit_addr_adder[22] = (addr[21] & offset[21]) | (addr[21] & carry_bit_addr_adder[21]) | (offset[21] & carry_bit_addr_adder[21]); // calculation of carry bit of adder
assign target_addr[22] = addr[22] ^ offset[22] ^ carry_bit_addr_adder[22];
assign carry_bit_addr_adder[23] = (addr[22] & offset[22]) | (addr[22] & carry_bit_addr_adder[22]) | (offset[22] & carry_bit_addr_adder[22]); // calculation of carry bit of adder
assign target_addr[23] = addr[23] ^ offset[23] ^ carry_bit_addr_adder[23];
assign carry_bit_addr_adder[24] = (addr[23] & offset[23]) | (addr[23] & carry_bit_addr_adder[23]) | (offset[23] & carry_bit_addr_adder[23]); // calculation of carry bit of adder
assign target_addr[24] = addr[24] ^ offset[24] ^ carry_bit_addr_adder[24];
assign carry_bit_addr_adder[25] = (addr[24] & offset[24]) | (addr[24] & carry_bit_addr_adder[24]) | (offset[24] & carry_bit_addr_adder[24]); // calculation of carry bit of adder
assign target_addr[25] = addr[25] ^ offset[25] ^ carry_bit_addr_adder[25];
assign carry_bit_addr_adder[26] = (addr[25] & offset[25]) | (addr[25] & carry_bit_addr_adder[25]) | (offset[25] & carry_bit_addr_adder[25]); // calculation of carry bit of adder
assign target_addr[26] = addr[26] ^ offset[26] ^ carry_bit_addr_adder[26];
assign carry_bit_addr_adder[27] = (addr[26] & offset[26]) | (addr[26] & carry_bit_addr_adder[26]) | (offset[26] & carry_bit_addr_adder[26]); // calculation of carry bit of adder
assign target_addr[27] = addr[27] ^ offset[27] ^ carry_bit_addr_adder[27];
assign carry_bit_addr_adder[28] = (addr[27] & offset[27]) | (addr[27] & carry_bit_addr_adder[27]) | (offset[27] & carry_bit_addr_adder[27]); // calculation of carry bit of adder
assign target_addr[28] = addr[28] ^ offset[28] ^ carry_bit_addr_adder[28];
assign carry_bit_addr_adder[29] = (addr[28] & offset[28]) | (addr[28] & carry_bit_addr_adder[28]) | (offset[28] & carry_bit_addr_adder[28]); // calculation of carry bit of adder
assign target_addr[29] = addr[29] ^ offset[29] ^ carry_bit_addr_adder[29];
assign carry_bit_addr_adder[30] = (addr[29] & offset[29]) | (addr[29] & carry_bit_addr_adder[29]) | (offset[29] & carry_bit_addr_adder[29]); // calculation of carry bit of adder
assign target_addr[30] = addr[30] ^ offset[30] ^ carry_bit_addr_adder[30];
assign carry_bit_addr_adder[31] = (addr[30] & offset[30]) | (addr[30] & carry_bit_addr_adder[30]) | (offset[30] & carry_bit_addr_adder[30]); // calculation of carry bit of adder
assign target_addr[31] = addr[31] ^ offset[31] ^ carry_bit_addr_adder[31];

// output result
assign op_result[31:0] = (ip_result_ctrl[1:0] == 2'b01) ? {31'b000000000000000000000000000000, result_LT} : ((ip_result_ctrl[1:0] == 2'b10) ? result_shift[31:0] : result_ALU[31:0]); // output the final result
assign op_branch_ctrl = ip_branch_ctrl[2] & (((~ip_branch_ctrl[1]) & (~ip_branch_ctrl[0]) & zero) | ((~ip_branch_ctrl[1]) & ip_branch_ctrl[0] & (~zero)) | (ip_branch_ctrl[1] & (~ip_branch_ctrl[0]) & result_LT) | (ip_branch_ctrl[1] & ip_branch_ctrl[0] & (~result_LT))); // output brnach condition
assign op_overflow = ALU_overflow | shift_overflow; // output overflow
assign op_target_addr[31:0] = target_addr[31:0]; // output target address
endmodule