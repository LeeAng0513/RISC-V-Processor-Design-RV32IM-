/**********************************************************************
Project: 32-bit RISC-V Processor 
Module: m_ext.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: M Extension
**********************************************************************/

`default_nettype none // to catch typing errors due to typo of signal names

module m_ext
#( // declare all the parameter needed
) 
( // declare all the input and output pin needed
	input wire [31:0] ip_rs1, ip_rs2,
	input wire [2:0] ip_funct_3,
	input wire ip_clk,
	output wire [31:0] op_result,
	output wire op_overflow
);

wire multiplication_sign; // signed multiplication
wire multiplication_fully_sign; // fully signed multiplication
wire multiplication_rs1_sign_neg; // rs1 is negative in multiplication
wire multiplication_rs2_sign_neg; // rs2 is negative in multiplication
wire division_sign; // signed or unsigned division
wire division_rs1_sign_neg; // rs1 is negative in division
wire division_rs2_sign_neg; // rs2 is negative in division
wire rs1_sign_neg; // rs1 is negative
wire rs2_sign_neg; // rs2 is negative
wire [32:0] invert_rs1; // invert of rs1
wire [32:0] carry_bit_convert_rs1_adder; // carry bit of adder after invert rs1
wire [32:0] result_convert_rs1_adder; // result of convert rs1 from negative to positive
wire [32:0] invert_rs2; // invert of rs2
wire [32:0] carry_bit_convert_rs2_adder; // carry bit of adder after invert rs2
wire [32:0] result_convert_rs2_adder; // result of convert rs2 from negative to positive
wire rs1_convert_ctrl; // data select for operand a
wire rs2_convert_ctrl; // data select for operand b
wire [32:0] operand_a; // operand a for calcaultion
wire [32:0] operand_b; // operand b for calcaultion
wire [32:0] layer_data_a [0:32]; // data for layer adder
wire [32:0] layer_data_b [0:32]; // data for layer adder
wire [31:0] carry_bit_layer_adder [0:32]; // carry bit of the layer
wire [32:0] result_layer_adder [0:32]; // result of the layer
wire [31:0] result_MUL; // result of MUL
wire [31:0] result_MULH; // result of MULH
wire [31:0] result_DIV; // result of DIV
wire [31:0] result_REM; // result of REM
wire multiplication_result_ctrl; // output lower bit or higher bit of multiplication result
wire division_result_ctrl; // output quotient or remainder of division result
wire [1:0] result_ctrl; // data selection of the operation result
wire [63:0] result; // result of calculation
wire [63:0] invert_result; // invert of result
wire [63:0] carry_bit_convert_result_adder; // carry bit of adder after invert result
wire [63:0] result_convert_result_adder; // result of convert result from negative to positive
wire result_convert_ctrl; // data select for final result

// control wire assignment
assign multiplication_sign = ~ip_funct_3[2] & (~&ip_funct_3[1:0]); // signed multiplication
assign multiplication_fully_sign = ~|ip_funct_3[2:1]; // fully signed multiplication
assign multiplication_rs1_sign_neg = ip_rs1[31] & multiplication_sign; // if rs1 is negative in multiplication
assign multiplication_rs2_sign_neg = ip_rs2[31] & multiplication_fully_sign; // if rs2 is negative in multiplication
assign division_sign = ip_funct_3[2] & (~ip_funct_3[0]); // signed division
assign division_rs1_sign_neg = ip_rs1[31] & division_sign; // if rs1 is negative in division
assign division_rs2_sign_neg = ip_rs2[31] & division_sign; // if rs2 is negative in division
assign rs1_sign_neg = multiplication_rs1_sign_neg | division_rs1_sign_neg; // if rs1 is negative
assign rs2_sign_neg = multiplication_rs2_sign_neg | division_rs2_sign_neg; // if rs2 is negative

// convert rs1 from negative to positive
assign invert_rs1[32:0] = ~{rs1_sign_neg, ip_rs1[31:0]};
assign carry_bit_convert_rs1_adder[0] = 1'b1;
assign result_convert_rs1_adder[0] = invert_rs1[0] ^ carry_bit_convert_rs1_adder[0]; // calculation of add result
assign carry_bit_convert_rs1_adder[1] = invert_rs1[0] & carry_bit_convert_rs1_adder[0]; // calculation of carry bit of adder
assign result_convert_rs1_adder[1] = invert_rs1[1] ^ carry_bit_convert_rs1_adder[1]; // calculation of add result
assign carry_bit_convert_rs1_adder[2] = invert_rs1[1] & carry_bit_convert_rs1_adder[1]; // calculation of carry bit of adder
assign result_convert_rs1_adder[2] = invert_rs1[2] ^ carry_bit_convert_rs1_adder[2]; // calculation of add result
assign carry_bit_convert_rs1_adder[3] = invert_rs1[2] & carry_bit_convert_rs1_adder[2]; // calculation of carry bit of adder
assign result_convert_rs1_adder[3] = invert_rs1[3] ^ carry_bit_convert_rs1_adder[3]; // calculation of add result
assign carry_bit_convert_rs1_adder[4] = invert_rs1[3] & carry_bit_convert_rs1_adder[3]; // calculation of carry bit of adder
assign result_convert_rs1_adder[4] = invert_rs1[4] ^ carry_bit_convert_rs1_adder[4]; // calculation of add result
assign carry_bit_convert_rs1_adder[5] = invert_rs1[4] & carry_bit_convert_rs1_adder[4]; // calculation of carry bit of adder
assign result_convert_rs1_adder[5] = invert_rs1[5] ^ carry_bit_convert_rs1_adder[5]; // calculation of add result
assign carry_bit_convert_rs1_adder[6] = invert_rs1[5] & carry_bit_convert_rs1_adder[5]; // calculation of carry bit of adder
assign result_convert_rs1_adder[6] = invert_rs1[6] ^ carry_bit_convert_rs1_adder[6]; // calculation of add result
assign carry_bit_convert_rs1_adder[7] = invert_rs1[6] & carry_bit_convert_rs1_adder[6]; // calculation of carry bit of adder
assign result_convert_rs1_adder[7] = invert_rs1[7] ^ carry_bit_convert_rs1_adder[7]; // calculation of add result
assign carry_bit_convert_rs1_adder[8] = invert_rs1[7] & carry_bit_convert_rs1_adder[7]; // calculation of carry bit of adder
assign result_convert_rs1_adder[8] = invert_rs1[8] ^ carry_bit_convert_rs1_adder[8]; // calculation of add result
assign carry_bit_convert_rs1_adder[9] = invert_rs1[8] & carry_bit_convert_rs1_adder[8]; // calculation of carry bit of adder
assign result_convert_rs1_adder[9] = invert_rs1[9] ^ carry_bit_convert_rs1_adder[9]; // calculation of add result
assign carry_bit_convert_rs1_adder[10] = invert_rs1[9] & carry_bit_convert_rs1_adder[9]; // calculation of carry bit of adder
assign result_convert_rs1_adder[10] = invert_rs1[10] ^ carry_bit_convert_rs1_adder[10]; // calculation of add result
assign carry_bit_convert_rs1_adder[11] = invert_rs1[10] & carry_bit_convert_rs1_adder[10]; // calculation of carry bit of adder
assign result_convert_rs1_adder[11] = invert_rs1[11] ^ carry_bit_convert_rs1_adder[11]; // calculation of add result
assign carry_bit_convert_rs1_adder[12] = invert_rs1[11] & carry_bit_convert_rs1_adder[11]; // calculation of carry bit of adder
assign result_convert_rs1_adder[12] = invert_rs1[12] ^ carry_bit_convert_rs1_adder[12]; // calculation of add result
assign carry_bit_convert_rs1_adder[13] = invert_rs1[12] & carry_bit_convert_rs1_adder[12]; // calculation of carry bit of adder
assign result_convert_rs1_adder[13] = invert_rs1[13] ^ carry_bit_convert_rs1_adder[13]; // calculation of add result
assign carry_bit_convert_rs1_adder[14] = invert_rs1[13] & carry_bit_convert_rs1_adder[13]; // calculation of carry bit of adder
assign result_convert_rs1_adder[14] = invert_rs1[14] ^ carry_bit_convert_rs1_adder[14]; // calculation of add result
assign carry_bit_convert_rs1_adder[15] = invert_rs1[14] & carry_bit_convert_rs1_adder[14]; // calculation of carry bit of adder
assign result_convert_rs1_adder[15] = invert_rs1[15] ^ carry_bit_convert_rs1_adder[15]; // calculation of add result
assign carry_bit_convert_rs1_adder[16] = invert_rs1[15] & carry_bit_convert_rs1_adder[15]; // calculation of carry bit of adder
assign result_convert_rs1_adder[16] = invert_rs1[16] ^ carry_bit_convert_rs1_adder[16]; // calculation of add result
assign carry_bit_convert_rs1_adder[17] = invert_rs1[16] & carry_bit_convert_rs1_adder[16]; // calculation of carry bit of adder
assign result_convert_rs1_adder[17] = invert_rs1[17] ^ carry_bit_convert_rs1_adder[17]; // calculation of add result
assign carry_bit_convert_rs1_adder[18] = invert_rs1[17] & carry_bit_convert_rs1_adder[17]; // calculation of carry bit of adder
assign result_convert_rs1_adder[18] = invert_rs1[18] ^ carry_bit_convert_rs1_adder[18]; // calculation of add result
assign carry_bit_convert_rs1_adder[19] = invert_rs1[18] & carry_bit_convert_rs1_adder[18]; // calculation of carry bit of adder
assign result_convert_rs1_adder[19] = invert_rs1[19] ^ carry_bit_convert_rs1_adder[19]; // calculation of add result
assign carry_bit_convert_rs1_adder[20] = invert_rs1[19] & carry_bit_convert_rs1_adder[19]; // calculation of carry bit of adder
assign result_convert_rs1_adder[20] = invert_rs1[20] ^ carry_bit_convert_rs1_adder[20]; // calculation of add result
assign carry_bit_convert_rs1_adder[21] = invert_rs1[20] & carry_bit_convert_rs1_adder[20]; // calculation of carry bit of adder
assign result_convert_rs1_adder[21] = invert_rs1[21] ^ carry_bit_convert_rs1_adder[21]; // calculation of add result
assign carry_bit_convert_rs1_adder[22] = invert_rs1[21] & carry_bit_convert_rs1_adder[21]; // calculation of carry bit of adder
assign result_convert_rs1_adder[22] = invert_rs1[22] ^ carry_bit_convert_rs1_adder[22]; // calculation of add result
assign carry_bit_convert_rs1_adder[23] = invert_rs1[22] & carry_bit_convert_rs1_adder[22]; // calculation of carry bit of adder
assign result_convert_rs1_adder[23] = invert_rs1[23] ^ carry_bit_convert_rs1_adder[23]; // calculation of add result
assign carry_bit_convert_rs1_adder[24] = invert_rs1[23] & carry_bit_convert_rs1_adder[23]; // calculation of carry bit of adder
assign result_convert_rs1_adder[24] = invert_rs1[24] ^ carry_bit_convert_rs1_adder[24]; // calculation of add result
assign carry_bit_convert_rs1_adder[25] = invert_rs1[24] & carry_bit_convert_rs1_adder[24]; // calculation of carry bit of adder
assign result_convert_rs1_adder[25] = invert_rs1[25] ^ carry_bit_convert_rs1_adder[25]; // calculation of add result
assign carry_bit_convert_rs1_adder[26] = invert_rs1[25] & carry_bit_convert_rs1_adder[25]; // calculation of carry bit of adder
assign result_convert_rs1_adder[26] = invert_rs1[26] ^ carry_bit_convert_rs1_adder[26]; // calculation of add result
assign carry_bit_convert_rs1_adder[27] = invert_rs1[26] & carry_bit_convert_rs1_adder[26]; // calculation of carry bit of adder
assign result_convert_rs1_adder[27] = invert_rs1[27] ^ carry_bit_convert_rs1_adder[27]; // calculation of add result
assign carry_bit_convert_rs1_adder[28] = invert_rs1[27] & carry_bit_convert_rs1_adder[27]; // calculation of carry bit of adder
assign result_convert_rs1_adder[28] = invert_rs1[28] ^ carry_bit_convert_rs1_adder[28]; // calculation of add result
assign carry_bit_convert_rs1_adder[29] = invert_rs1[28] & carry_bit_convert_rs1_adder[28]; // calculation of carry bit of adder
assign result_convert_rs1_adder[29] = invert_rs1[29] ^ carry_bit_convert_rs1_adder[29]; // calculation of add result
assign carry_bit_convert_rs1_adder[30] = invert_rs1[29] & carry_bit_convert_rs1_adder[29]; // calculation of carry bit of adder
assign result_convert_rs1_adder[30] = invert_rs1[30] ^ carry_bit_convert_rs1_adder[30]; // calculation of add result
assign carry_bit_convert_rs1_adder[31] = invert_rs1[30] & carry_bit_convert_rs1_adder[30]; // calculation of carry bit of adder
assign result_convert_rs1_adder[31] = invert_rs1[31] ^ carry_bit_convert_rs1_adder[31]; // calculation of add result
assign carry_bit_convert_rs1_adder[32] = invert_rs1[31] & carry_bit_convert_rs1_adder[31]; // calculation of carry bit of adder
assign result_convert_rs1_adder[32] = invert_rs1[32] ^ carry_bit_convert_rs1_adder[32]; // calculation of add result

// convert rs2 from negative to positive
assign invert_rs2[32:0] = ~{rs2_sign_neg, ip_rs2[31:0]};
assign carry_bit_convert_rs2_adder[0] = 1'b1;
assign result_convert_rs2_adder[0] = invert_rs2[0] ^ carry_bit_convert_rs2_adder[0]; // calculation of add result
assign carry_bit_convert_rs2_adder[1] = invert_rs2[0] & carry_bit_convert_rs2_adder[0]; // calculation of carry bit of adder
assign result_convert_rs2_adder[1] = invert_rs2[1] ^ carry_bit_convert_rs2_adder[1]; // calculation of add result
assign carry_bit_convert_rs2_adder[2] = invert_rs2[1] & carry_bit_convert_rs2_adder[1]; // calculation of carry bit of adder
assign result_convert_rs2_adder[2] = invert_rs2[2] ^ carry_bit_convert_rs2_adder[2]; // calculation of add result
assign carry_bit_convert_rs2_adder[3] = invert_rs2[2] & carry_bit_convert_rs2_adder[2]; // calculation of carry bit of adder
assign result_convert_rs2_adder[3] = invert_rs2[3] ^ carry_bit_convert_rs2_adder[3]; // calculation of add result
assign carry_bit_convert_rs2_adder[4] = invert_rs2[3] & carry_bit_convert_rs2_adder[3]; // calculation of carry bit of adder
assign result_convert_rs2_adder[4] = invert_rs2[4] ^ carry_bit_convert_rs2_adder[4]; // calculation of add result
assign carry_bit_convert_rs2_adder[5] = invert_rs2[4] & carry_bit_convert_rs2_adder[4]; // calculation of carry bit of adder
assign result_convert_rs2_adder[5] = invert_rs2[5] ^ carry_bit_convert_rs2_adder[5]; // calculation of add result
assign carry_bit_convert_rs2_adder[6] = invert_rs2[5] & carry_bit_convert_rs2_adder[5]; // calculation of carry bit of adder
assign result_convert_rs2_adder[6] = invert_rs2[6] ^ carry_bit_convert_rs2_adder[6]; // calculation of add result
assign carry_bit_convert_rs2_adder[7] = invert_rs2[6] & carry_bit_convert_rs2_adder[6]; // calculation of carry bit of adder
assign result_convert_rs2_adder[7] = invert_rs2[7] ^ carry_bit_convert_rs2_adder[7]; // calculation of add result
assign carry_bit_convert_rs2_adder[8] = invert_rs2[7] & carry_bit_convert_rs2_adder[7]; // calculation of carry bit of adder
assign result_convert_rs2_adder[8] = invert_rs2[8] ^ carry_bit_convert_rs2_adder[8]; // calculation of add result
assign carry_bit_convert_rs2_adder[9] = invert_rs2[8] & carry_bit_convert_rs2_adder[8]; // calculation of carry bit of adder
assign result_convert_rs2_adder[9] = invert_rs2[9] ^ carry_bit_convert_rs2_adder[9]; // calculation of add result
assign carry_bit_convert_rs2_adder[10] = invert_rs2[9] & carry_bit_convert_rs2_adder[9]; // calculation of carry bit of adder
assign result_convert_rs2_adder[10] = invert_rs2[10] ^ carry_bit_convert_rs2_adder[10]; // calculation of add result
assign carry_bit_convert_rs2_adder[11] = invert_rs2[10] & carry_bit_convert_rs2_adder[10]; // calculation of carry bit of adder
assign result_convert_rs2_adder[11] = invert_rs2[11] ^ carry_bit_convert_rs2_adder[11]; // calculation of add result
assign carry_bit_convert_rs2_adder[12] = invert_rs2[11] & carry_bit_convert_rs2_adder[11]; // calculation of carry bit of adder
assign result_convert_rs2_adder[12] = invert_rs2[12] ^ carry_bit_convert_rs2_adder[12]; // calculation of add result
assign carry_bit_convert_rs2_adder[13] = invert_rs2[12] & carry_bit_convert_rs2_adder[12]; // calculation of carry bit of adder
assign result_convert_rs2_adder[13] = invert_rs2[13] ^ carry_bit_convert_rs2_adder[13]; // calculation of add result
assign carry_bit_convert_rs2_adder[14] = invert_rs2[13] & carry_bit_convert_rs2_adder[13]; // calculation of carry bit of adder
assign result_convert_rs2_adder[14] = invert_rs2[14] ^ carry_bit_convert_rs2_adder[14]; // calculation of add result
assign carry_bit_convert_rs2_adder[15] = invert_rs2[14] & carry_bit_convert_rs2_adder[14]; // calculation of carry bit of adder
assign result_convert_rs2_adder[15] = invert_rs2[15] ^ carry_bit_convert_rs2_adder[15]; // calculation of add result
assign carry_bit_convert_rs2_adder[16] = invert_rs2[15] & carry_bit_convert_rs2_adder[15]; // calculation of carry bit of adder
assign result_convert_rs2_adder[16] = invert_rs2[16] ^ carry_bit_convert_rs2_adder[16]; // calculation of add result
assign carry_bit_convert_rs2_adder[17] = invert_rs2[16] & carry_bit_convert_rs2_adder[16]; // calculation of carry bit of adder
assign result_convert_rs2_adder[17] = invert_rs2[17] ^ carry_bit_convert_rs2_adder[17]; // calculation of add result
assign carry_bit_convert_rs2_adder[18] = invert_rs2[17] & carry_bit_convert_rs2_adder[17]; // calculation of carry bit of adder
assign result_convert_rs2_adder[18] = invert_rs2[18] ^ carry_bit_convert_rs2_adder[18]; // calculation of add result
assign carry_bit_convert_rs2_adder[19] = invert_rs2[18] & carry_bit_convert_rs2_adder[18]; // calculation of carry bit of adder
assign result_convert_rs2_adder[19] = invert_rs2[19] ^ carry_bit_convert_rs2_adder[19]; // calculation of add result
assign carry_bit_convert_rs2_adder[20] = invert_rs2[19] & carry_bit_convert_rs2_adder[19]; // calculation of carry bit of adder
assign result_convert_rs2_adder[20] = invert_rs2[20] ^ carry_bit_convert_rs2_adder[20]; // calculation of add result
assign carry_bit_convert_rs2_adder[21] = invert_rs2[20] & carry_bit_convert_rs2_adder[20]; // calculation of carry bit of adder
assign result_convert_rs2_adder[21] = invert_rs2[21] ^ carry_bit_convert_rs2_adder[21]; // calculation of add result
assign carry_bit_convert_rs2_adder[22] = invert_rs2[21] & carry_bit_convert_rs2_adder[21]; // calculation of carry bit of adder
assign result_convert_rs2_adder[22] = invert_rs2[22] ^ carry_bit_convert_rs2_adder[22]; // calculation of add result
assign carry_bit_convert_rs2_adder[23] = invert_rs2[22] & carry_bit_convert_rs2_adder[22]; // calculation of carry bit of adder
assign result_convert_rs2_adder[23] = invert_rs2[23] ^ carry_bit_convert_rs2_adder[23]; // calculation of add result
assign carry_bit_convert_rs2_adder[24] = invert_rs2[23] & carry_bit_convert_rs2_adder[23]; // calculation of carry bit of adder
assign result_convert_rs2_adder[24] = invert_rs2[24] ^ carry_bit_convert_rs2_adder[24]; // calculation of add result
assign carry_bit_convert_rs2_adder[25] = invert_rs2[24] & carry_bit_convert_rs2_adder[24]; // calculation of carry bit of adder
assign result_convert_rs2_adder[25] = invert_rs2[25] ^ carry_bit_convert_rs2_adder[25]; // calculation of add result
assign carry_bit_convert_rs2_adder[26] = invert_rs2[25] & carry_bit_convert_rs2_adder[25]; // calculation of carry bit of adder
assign result_convert_rs2_adder[26] = invert_rs2[26] ^ carry_bit_convert_rs2_adder[26]; // calculation of add result
assign carry_bit_convert_rs2_adder[27] = invert_rs2[26] & carry_bit_convert_rs2_adder[26]; // calculation of carry bit of adder
assign result_convert_rs2_adder[27] = invert_rs2[27] ^ carry_bit_convert_rs2_adder[27]; // calculation of add result
assign carry_bit_convert_rs2_adder[28] = invert_rs2[27] & carry_bit_convert_rs2_adder[27]; // calculation of carry bit of adder
assign result_convert_rs2_adder[28] = invert_rs2[28] ^ carry_bit_convert_rs2_adder[28]; // calculation of add result
assign carry_bit_convert_rs2_adder[29] = invert_rs2[28] & carry_bit_convert_rs2_adder[28]; // calculation of carry bit of adder
assign result_convert_rs2_adder[29] = invert_rs2[29] ^ carry_bit_convert_rs2_adder[29]; // calculation of add result
assign carry_bit_convert_rs2_adder[30] = invert_rs2[29] & carry_bit_convert_rs2_adder[29]; // calculation of carry bit of adder
assign result_convert_rs2_adder[30] = invert_rs2[30] ^ carry_bit_convert_rs2_adder[30]; // calculation of add result
assign carry_bit_convert_rs2_adder[31] = invert_rs2[30] & carry_bit_convert_rs2_adder[30]; // calculation of carry bit of adder
assign result_convert_rs2_adder[31] = invert_rs2[31] ^ carry_bit_convert_rs2_adder[31]; // calculation of add result
assign carry_bit_convert_rs2_adder[32] = invert_rs2[31] & carry_bit_convert_rs2_adder[31]; // calculation of carry bit of adder
assign result_convert_rs2_adder[32] = invert_rs2[32] ^ carry_bit_convert_rs2_adder[32]; // calculation of add result

// input convert control
assign rs1_convert_ctrl = rs1_sign_neg; // convert rs1 signal
assign rs2_convert_ctrl = multiplication_rs2_sign_neg | ((~ip_rs2[31]) & division_sign) | (ip_funct_3[2] & ip_funct_3[0]); // convert rs2 signal

// data select for operand a and b
assign operand_a[32:0] = (rs1_convert_ctrl == 1'b1) ? result_convert_rs1_adder[32:0] : {rs1_sign_neg, ip_rs1[31:0]}; // data select for operand a
assign operand_b[32:0] = (rs2_convert_ctrl == 1'b1) ? result_convert_rs2_adder[32:0] : {rs2_sign_neg, ip_rs2[31:0]}; // data select for operand b

// Layer 1
assign layer_data_a[0][32:0] = (ip_funct_3[2] == 1'b1) ? {32'b0, operand_a[32]} : 33'b0; // data select for layer 1
assign layer_data_b[0][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[0] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 1

// Layer 1 adder
assign result_layer_adder[0][0] = layer_data_a[0][0] ^ layer_data_b[0][0]; // calculation of add result
assign carry_bit_layer_adder[0][0] = layer_data_a[0][0] & layer_data_b[0][0]; // calculation of carry bit of adder
assign result_layer_adder[0][1] = layer_data_a[0][1] ^ layer_data_b[0][1] ^ carry_bit_layer_adder[0][0]; // calculation of add result
assign carry_bit_layer_adder[0][1] = (layer_data_a[0][1] & layer_data_b[0][1]) | (layer_data_a[0][1] & carry_bit_layer_adder[0][0]) | (layer_data_b[0][1] & carry_bit_layer_adder[0][0]); // calculation of carry bit of adder
assign result_layer_adder[0][2] = layer_data_a[0][2] ^ layer_data_b[0][2] ^ carry_bit_layer_adder[0][1]; // calculation of add result
assign carry_bit_layer_adder[0][2] = (layer_data_a[0][2] & layer_data_b[0][2]) | (layer_data_a[0][2] & carry_bit_layer_adder[0][1]) | (layer_data_b[0][2] & carry_bit_layer_adder[0][1]); // calculation of carry bit of adder
assign result_layer_adder[0][3] = layer_data_a[0][3] ^ layer_data_b[0][3] ^ carry_bit_layer_adder[0][2]; // calculation of add result
assign carry_bit_layer_adder[0][3] = (layer_data_a[0][3] & layer_data_b[0][3]) | (layer_data_a[0][3] & carry_bit_layer_adder[0][2]) | (layer_data_b[0][3] & carry_bit_layer_adder[0][2]); // calculation of carry bit of adder
assign result_layer_adder[0][4] = layer_data_a[0][4] ^ layer_data_b[0][4] ^ carry_bit_layer_adder[0][3]; // calculation of add result
assign carry_bit_layer_adder[0][4] = (layer_data_a[0][4] & layer_data_b[0][4]) | (layer_data_a[0][4] & carry_bit_layer_adder[0][3]) | (layer_data_b[0][4] & carry_bit_layer_adder[0][3]); // calculation of carry bit of adder
assign result_layer_adder[0][5] = layer_data_a[0][5] ^ layer_data_b[0][5] ^ carry_bit_layer_adder[0][4]; // calculation of add result
assign carry_bit_layer_adder[0][5] = (layer_data_a[0][5] & layer_data_b[0][5]) | (layer_data_a[0][5] & carry_bit_layer_adder[0][4]) | (layer_data_b[0][5] & carry_bit_layer_adder[0][4]); // calculation of carry bit of adder
assign result_layer_adder[0][6] = layer_data_a[0][6] ^ layer_data_b[0][6] ^ carry_bit_layer_adder[0][5]; // calculation of add result
assign carry_bit_layer_adder[0][6] = (layer_data_a[0][6] & layer_data_b[0][6]) | (layer_data_a[0][6] & carry_bit_layer_adder[0][5]) | (layer_data_b[0][6] & carry_bit_layer_adder[0][5]); // calculation of carry bit of adder
assign result_layer_adder[0][7] = layer_data_a[0][7] ^ layer_data_b[0][7] ^ carry_bit_layer_adder[0][6]; // calculation of add result
assign carry_bit_layer_adder[0][7] = (layer_data_a[0][7] & layer_data_b[0][7]) | (layer_data_a[0][7] & carry_bit_layer_adder[0][6]) | (layer_data_b[0][7] & carry_bit_layer_adder[0][6]); // calculation of carry bit of adder
assign result_layer_adder[0][8] = layer_data_a[0][8] ^ layer_data_b[0][8] ^ carry_bit_layer_adder[0][7]; // calculation of add result
assign carry_bit_layer_adder[0][8] = (layer_data_a[0][8] & layer_data_b[0][8]) | (layer_data_a[0][8] & carry_bit_layer_adder[0][7]) | (layer_data_b[0][8] & carry_bit_layer_adder[0][7]); // calculation of carry bit of adder
assign result_layer_adder[0][9] = layer_data_a[0][9] ^ layer_data_b[0][9] ^ carry_bit_layer_adder[0][8]; // calculation of add result
assign carry_bit_layer_adder[0][9] = (layer_data_a[0][9] & layer_data_b[0][9]) | (layer_data_a[0][9] & carry_bit_layer_adder[0][8]) | (layer_data_b[0][9] & carry_bit_layer_adder[0][8]); // calculation of carry bit of adder
assign result_layer_adder[0][10] = layer_data_a[0][10] ^ layer_data_b[0][10] ^ carry_bit_layer_adder[0][9]; // calculation of add result
assign carry_bit_layer_adder[0][10] = (layer_data_a[0][10] & layer_data_b[0][10]) | (layer_data_a[0][10] & carry_bit_layer_adder[0][9]) | (layer_data_b[0][10] & carry_bit_layer_adder[0][9]); // calculation of carry bit of adder
assign result_layer_adder[0][11] = layer_data_a[0][11] ^ layer_data_b[0][11] ^ carry_bit_layer_adder[0][10]; // calculation of add result
assign carry_bit_layer_adder[0][11] = (layer_data_a[0][11] & layer_data_b[0][11]) | (layer_data_a[0][11] & carry_bit_layer_adder[0][10]) | (layer_data_b[0][11] & carry_bit_layer_adder[0][10]); // calculation of carry bit of adder
assign result_layer_adder[0][12] = layer_data_a[0][12] ^ layer_data_b[0][12] ^ carry_bit_layer_adder[0][11]; // calculation of add result
assign carry_bit_layer_adder[0][12] = (layer_data_a[0][12] & layer_data_b[0][12]) | (layer_data_a[0][12] & carry_bit_layer_adder[0][11]) | (layer_data_b[0][12] & carry_bit_layer_adder[0][11]); // calculation of carry bit of adder
assign result_layer_adder[0][13] = layer_data_a[0][13] ^ layer_data_b[0][13] ^ carry_bit_layer_adder[0][12]; // calculation of add result
assign carry_bit_layer_adder[0][13] = (layer_data_a[0][13] & layer_data_b[0][13]) | (layer_data_a[0][13] & carry_bit_layer_adder[0][12]) | (layer_data_b[0][13] & carry_bit_layer_adder[0][12]); // calculation of carry bit of adder
assign result_layer_adder[0][14] = layer_data_a[0][14] ^ layer_data_b[0][14] ^ carry_bit_layer_adder[0][13]; // calculation of add result
assign carry_bit_layer_adder[0][14] = (layer_data_a[0][14] & layer_data_b[0][14]) | (layer_data_a[0][14] & carry_bit_layer_adder[0][13]) | (layer_data_b[0][14] & carry_bit_layer_adder[0][13]); // calculation of carry bit of adder
assign result_layer_adder[0][15] = layer_data_a[0][15] ^ layer_data_b[0][15] ^ carry_bit_layer_adder[0][14]; // calculation of add result
assign carry_bit_layer_adder[0][15] = (layer_data_a[0][15] & layer_data_b[0][15]) | (layer_data_a[0][15] & carry_bit_layer_adder[0][14]) | (layer_data_b[0][15] & carry_bit_layer_adder[0][14]); // calculation of carry bit of adder
assign result_layer_adder[0][16] = layer_data_a[0][16] ^ layer_data_b[0][16] ^ carry_bit_layer_adder[0][15]; // calculation of add result
assign carry_bit_layer_adder[0][16] = (layer_data_a[0][16] & layer_data_b[0][16]) | (layer_data_a[0][16] & carry_bit_layer_adder[0][15]) | (layer_data_b[0][16] & carry_bit_layer_adder[0][15]); // calculation of carry bit of adder
assign result_layer_adder[0][17] = layer_data_a[0][17] ^ layer_data_b[0][17] ^ carry_bit_layer_adder[0][16]; // calculation of add result
assign carry_bit_layer_adder[0][17] = (layer_data_a[0][17] & layer_data_b[0][17]) | (layer_data_a[0][17] & carry_bit_layer_adder[0][16]) | (layer_data_b[0][17] & carry_bit_layer_adder[0][16]); // calculation of carry bit of adder
assign result_layer_adder[0][18] = layer_data_a[0][18] ^ layer_data_b[0][18] ^ carry_bit_layer_adder[0][17]; // calculation of add result
assign carry_bit_layer_adder[0][18] = (layer_data_a[0][18] & layer_data_b[0][18]) | (layer_data_a[0][18] & carry_bit_layer_adder[0][17]) | (layer_data_b[0][18] & carry_bit_layer_adder[0][17]); // calculation of carry bit of adder
assign result_layer_adder[0][19] = layer_data_a[0][19] ^ layer_data_b[0][19] ^ carry_bit_layer_adder[0][18]; // calculation of add result
assign carry_bit_layer_adder[0][19] = (layer_data_a[0][19] & layer_data_b[0][19]) | (layer_data_a[0][19] & carry_bit_layer_adder[0][18]) | (layer_data_b[0][19] & carry_bit_layer_adder[0][18]); // calculation of carry bit of adder
assign result_layer_adder[0][20] = layer_data_a[0][20] ^ layer_data_b[0][20] ^ carry_bit_layer_adder[0][19]; // calculation of add result
assign carry_bit_layer_adder[0][20] = (layer_data_a[0][20] & layer_data_b[0][20]) | (layer_data_a[0][20] & carry_bit_layer_adder[0][19]) | (layer_data_b[0][20] & carry_bit_layer_adder[0][19]); // calculation of carry bit of adder
assign result_layer_adder[0][21] = layer_data_a[0][21] ^ layer_data_b[0][21] ^ carry_bit_layer_adder[0][20]; // calculation of add result
assign carry_bit_layer_adder[0][21] = (layer_data_a[0][21] & layer_data_b[0][21]) | (layer_data_a[0][21] & carry_bit_layer_adder[0][20]) | (layer_data_b[0][21] & carry_bit_layer_adder[0][20]); // calculation of carry bit of adder
assign result_layer_adder[0][22] = layer_data_a[0][22] ^ layer_data_b[0][22] ^ carry_bit_layer_adder[0][21]; // calculation of add result
assign carry_bit_layer_adder[0][22] = (layer_data_a[0][22] & layer_data_b[0][22]) | (layer_data_a[0][22] & carry_bit_layer_adder[0][21]) | (layer_data_b[0][22] & carry_bit_layer_adder[0][21]); // calculation of carry bit of adder
assign result_layer_adder[0][23] = layer_data_a[0][23] ^ layer_data_b[0][23] ^ carry_bit_layer_adder[0][22]; // calculation of add result
assign carry_bit_layer_adder[0][23] = (layer_data_a[0][23] & layer_data_b[0][23]) | (layer_data_a[0][23] & carry_bit_layer_adder[0][22]) | (layer_data_b[0][23] & carry_bit_layer_adder[0][22]); // calculation of carry bit of adder
assign result_layer_adder[0][24] = layer_data_a[0][24] ^ layer_data_b[0][24] ^ carry_bit_layer_adder[0][23]; // calculation of add result
assign carry_bit_layer_adder[0][24] = (layer_data_a[0][24] & layer_data_b[0][24]) | (layer_data_a[0][24] & carry_bit_layer_adder[0][23]) | (layer_data_b[0][24] & carry_bit_layer_adder[0][23]); // calculation of carry bit of adder
assign result_layer_adder[0][25] = layer_data_a[0][25] ^ layer_data_b[0][25] ^ carry_bit_layer_adder[0][24]; // calculation of add result
assign carry_bit_layer_adder[0][25] = (layer_data_a[0][25] & layer_data_b[0][25]) | (layer_data_a[0][25] & carry_bit_layer_adder[0][24]) | (layer_data_b[0][25] & carry_bit_layer_adder[0][24]); // calculation of carry bit of adder
assign result_layer_adder[0][26] = layer_data_a[0][26] ^ layer_data_b[0][26] ^ carry_bit_layer_adder[0][25]; // calculation of add result
assign carry_bit_layer_adder[0][26] = (layer_data_a[0][26] & layer_data_b[0][26]) | (layer_data_a[0][26] & carry_bit_layer_adder[0][25]) | (layer_data_b[0][26] & carry_bit_layer_adder[0][25]); // calculation of carry bit of adder
assign result_layer_adder[0][27] = layer_data_a[0][27] ^ layer_data_b[0][27] ^ carry_bit_layer_adder[0][26]; // calculation of add result
assign carry_bit_layer_adder[0][27] = (layer_data_a[0][27] & layer_data_b[0][27]) | (layer_data_a[0][27] & carry_bit_layer_adder[0][26]) | (layer_data_b[0][27] & carry_bit_layer_adder[0][26]); // calculation of carry bit of adder
assign result_layer_adder[0][28] = layer_data_a[0][28] ^ layer_data_b[0][28] ^ carry_bit_layer_adder[0][27]; // calculation of add result
assign carry_bit_layer_adder[0][28] = (layer_data_a[0][28] & layer_data_b[0][28]) | (layer_data_a[0][28] & carry_bit_layer_adder[0][27]) | (layer_data_b[0][28] & carry_bit_layer_adder[0][27]); // calculation of carry bit of adder
assign result_layer_adder[0][29] = layer_data_a[0][29] ^ layer_data_b[0][29] ^ carry_bit_layer_adder[0][28]; // calculation of add result
assign carry_bit_layer_adder[0][29] = (layer_data_a[0][29] & layer_data_b[0][29]) | (layer_data_a[0][29] & carry_bit_layer_adder[0][28]) | (layer_data_b[0][29] & carry_bit_layer_adder[0][28]); // calculation of carry bit of adder
assign result_layer_adder[0][30] = layer_data_a[0][30] ^ layer_data_b[0][30] ^ carry_bit_layer_adder[0][29]; // calculation of add result
assign carry_bit_layer_adder[0][30] = (layer_data_a[0][30] & layer_data_b[0][30]) | (layer_data_a[0][30] & carry_bit_layer_adder[0][29]) | (layer_data_b[0][30] & carry_bit_layer_adder[0][29]); // calculation of carry bit of adder
assign result_layer_adder[0][31] = layer_data_a[0][31] ^ layer_data_b[0][31] ^ carry_bit_layer_adder[0][30]; // calculation of add result
assign carry_bit_layer_adder[0][31] = (layer_data_a[0][31] & layer_data_b[0][31]) | (layer_data_a[0][31] & carry_bit_layer_adder[0][30]) | (layer_data_b[0][31] & carry_bit_layer_adder[0][30]); // calculation of carry bit of adder
assign result_layer_adder[0][32] = layer_data_a[0][32] ^ layer_data_b[0][32] ^ carry_bit_layer_adder[0][31]; // calculation of add result

// Layer 2
assign layer_data_a[1][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[0][32] == 1'b1) ? {layer_data_a[0][31:0], operand_a[31]} : {result_layer_adder[0][31:0], operand_a[31]}) : {1'b0, result_layer_adder[0][32:1]}; // data select for layer 2
assign layer_data_b[1][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[1] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 2

// Layer 2 adder
assign result_layer_adder[1][0] = layer_data_a[1][0] ^ layer_data_b[1][0]; // calculation of add result
assign carry_bit_layer_adder[1][0] = layer_data_a[1][0] & layer_data_b[1][0]; // calculation of carry bit of adder
assign result_layer_adder[1][1] = layer_data_a[1][1] ^ layer_data_b[1][1] ^ carry_bit_layer_adder[1][0]; // calculation of add result
assign carry_bit_layer_adder[1][1] = (layer_data_a[1][1] & layer_data_b[1][1]) | (layer_data_a[1][1] & carry_bit_layer_adder[1][0]) | (layer_data_b[1][1] & carry_bit_layer_adder[1][0]); // calculation of carry bit of adder
assign result_layer_adder[1][2] = layer_data_a[1][2] ^ layer_data_b[1][2] ^ carry_bit_layer_adder[1][1]; // calculation of add result
assign carry_bit_layer_adder[1][2] = (layer_data_a[1][2] & layer_data_b[1][2]) | (layer_data_a[1][2] & carry_bit_layer_adder[1][1]) | (layer_data_b[1][2] & carry_bit_layer_adder[1][1]); // calculation of carry bit of adder
assign result_layer_adder[1][3] = layer_data_a[1][3] ^ layer_data_b[1][3] ^ carry_bit_layer_adder[1][2]; // calculation of add result
assign carry_bit_layer_adder[1][3] = (layer_data_a[1][3] & layer_data_b[1][3]) | (layer_data_a[1][3] & carry_bit_layer_adder[1][2]) | (layer_data_b[1][3] & carry_bit_layer_adder[1][2]); // calculation of carry bit of adder
assign result_layer_adder[1][4] = layer_data_a[1][4] ^ layer_data_b[1][4] ^ carry_bit_layer_adder[1][3]; // calculation of add result
assign carry_bit_layer_adder[1][4] = (layer_data_a[1][4] & layer_data_b[1][4]) | (layer_data_a[1][4] & carry_bit_layer_adder[1][3]) | (layer_data_b[1][4] & carry_bit_layer_adder[1][3]); // calculation of carry bit of adder
assign result_layer_adder[1][5] = layer_data_a[1][5] ^ layer_data_b[1][5] ^ carry_bit_layer_adder[1][4]; // calculation of add result
assign carry_bit_layer_adder[1][5] = (layer_data_a[1][5] & layer_data_b[1][5]) | (layer_data_a[1][5] & carry_bit_layer_adder[1][4]) | (layer_data_b[1][5] & carry_bit_layer_adder[1][4]); // calculation of carry bit of adder
assign result_layer_adder[1][6] = layer_data_a[1][6] ^ layer_data_b[1][6] ^ carry_bit_layer_adder[1][5]; // calculation of add result
assign carry_bit_layer_adder[1][6] = (layer_data_a[1][6] & layer_data_b[1][6]) | (layer_data_a[1][6] & carry_bit_layer_adder[1][5]) | (layer_data_b[1][6] & carry_bit_layer_adder[1][5]); // calculation of carry bit of adder
assign result_layer_adder[1][7] = layer_data_a[1][7] ^ layer_data_b[1][7] ^ carry_bit_layer_adder[1][6]; // calculation of add result
assign carry_bit_layer_adder[1][7] = (layer_data_a[1][7] & layer_data_b[1][7]) | (layer_data_a[1][7] & carry_bit_layer_adder[1][6]) | (layer_data_b[1][7] & carry_bit_layer_adder[1][6]); // calculation of carry bit of adder
assign result_layer_adder[1][8] = layer_data_a[1][8] ^ layer_data_b[1][8] ^ carry_bit_layer_adder[1][7]; // calculation of add result
assign carry_bit_layer_adder[1][8] = (layer_data_a[1][8] & layer_data_b[1][8]) | (layer_data_a[1][8] & carry_bit_layer_adder[1][7]) | (layer_data_b[1][8] & carry_bit_layer_adder[1][7]); // calculation of carry bit of adder
assign result_layer_adder[1][9] = layer_data_a[1][9] ^ layer_data_b[1][9] ^ carry_bit_layer_adder[1][8]; // calculation of add result
assign carry_bit_layer_adder[1][9] = (layer_data_a[1][9] & layer_data_b[1][9]) | (layer_data_a[1][9] & carry_bit_layer_adder[1][8]) | (layer_data_b[1][9] & carry_bit_layer_adder[1][8]); // calculation of carry bit of adder
assign result_layer_adder[1][10] = layer_data_a[1][10] ^ layer_data_b[1][10] ^ carry_bit_layer_adder[1][9]; // calculation of add result
assign carry_bit_layer_adder[1][10] = (layer_data_a[1][10] & layer_data_b[1][10]) | (layer_data_a[1][10] & carry_bit_layer_adder[1][9]) | (layer_data_b[1][10] & carry_bit_layer_adder[1][9]); // calculation of carry bit of adder
assign result_layer_adder[1][11] = layer_data_a[1][11] ^ layer_data_b[1][11] ^ carry_bit_layer_adder[1][10]; // calculation of add result
assign carry_bit_layer_adder[1][11] = (layer_data_a[1][11] & layer_data_b[1][11]) | (layer_data_a[1][11] & carry_bit_layer_adder[1][10]) | (layer_data_b[1][11] & carry_bit_layer_adder[1][10]); // calculation of carry bit of adder
assign result_layer_adder[1][12] = layer_data_a[1][12] ^ layer_data_b[1][12] ^ carry_bit_layer_adder[1][11]; // calculation of add result
assign carry_bit_layer_adder[1][12] = (layer_data_a[1][12] & layer_data_b[1][12]) | (layer_data_a[1][12] & carry_bit_layer_adder[1][11]) | (layer_data_b[1][12] & carry_bit_layer_adder[1][11]); // calculation of carry bit of adder
assign result_layer_adder[1][13] = layer_data_a[1][13] ^ layer_data_b[1][13] ^ carry_bit_layer_adder[1][12]; // calculation of add result
assign carry_bit_layer_adder[1][13] = (layer_data_a[1][13] & layer_data_b[1][13]) | (layer_data_a[1][13] & carry_bit_layer_adder[1][12]) | (layer_data_b[1][13] & carry_bit_layer_adder[1][12]); // calculation of carry bit of adder
assign result_layer_adder[1][14] = layer_data_a[1][14] ^ layer_data_b[1][14] ^ carry_bit_layer_adder[1][13]; // calculation of add result
assign carry_bit_layer_adder[1][14] = (layer_data_a[1][14] & layer_data_b[1][14]) | (layer_data_a[1][14] & carry_bit_layer_adder[1][13]) | (layer_data_b[1][14] & carry_bit_layer_adder[1][13]); // calculation of carry bit of adder
assign result_layer_adder[1][15] = layer_data_a[1][15] ^ layer_data_b[1][15] ^ carry_bit_layer_adder[1][14]; // calculation of add result
assign carry_bit_layer_adder[1][15] = (layer_data_a[1][15] & layer_data_b[1][15]) | (layer_data_a[1][15] & carry_bit_layer_adder[1][14]) | (layer_data_b[1][15] & carry_bit_layer_adder[1][14]); // calculation of carry bit of adder
assign result_layer_adder[1][16] = layer_data_a[1][16] ^ layer_data_b[1][16] ^ carry_bit_layer_adder[1][15]; // calculation of add result
assign carry_bit_layer_adder[1][16] = (layer_data_a[1][16] & layer_data_b[1][16]) | (layer_data_a[1][16] & carry_bit_layer_adder[1][15]) | (layer_data_b[1][16] & carry_bit_layer_adder[1][15]); // calculation of carry bit of adder
assign result_layer_adder[1][17] = layer_data_a[1][17] ^ layer_data_b[1][17] ^ carry_bit_layer_adder[1][16]; // calculation of add result
assign carry_bit_layer_adder[1][17] = (layer_data_a[1][17] & layer_data_b[1][17]) | (layer_data_a[1][17] & carry_bit_layer_adder[1][16]) | (layer_data_b[1][17] & carry_bit_layer_adder[1][16]); // calculation of carry bit of adder
assign result_layer_adder[1][18] = layer_data_a[1][18] ^ layer_data_b[1][18] ^ carry_bit_layer_adder[1][17]; // calculation of add result
assign carry_bit_layer_adder[1][18] = (layer_data_a[1][18] & layer_data_b[1][18]) | (layer_data_a[1][18] & carry_bit_layer_adder[1][17]) | (layer_data_b[1][18] & carry_bit_layer_adder[1][17]); // calculation of carry bit of adder
assign result_layer_adder[1][19] = layer_data_a[1][19] ^ layer_data_b[1][19] ^ carry_bit_layer_adder[1][18]; // calculation of add result
assign carry_bit_layer_adder[1][19] = (layer_data_a[1][19] & layer_data_b[1][19]) | (layer_data_a[1][19] & carry_bit_layer_adder[1][18]) | (layer_data_b[1][19] & carry_bit_layer_adder[1][18]); // calculation of carry bit of adder
assign result_layer_adder[1][20] = layer_data_a[1][20] ^ layer_data_b[1][20] ^ carry_bit_layer_adder[1][19]; // calculation of add result
assign carry_bit_layer_adder[1][20] = (layer_data_a[1][20] & layer_data_b[1][20]) | (layer_data_a[1][20] & carry_bit_layer_adder[1][19]) | (layer_data_b[1][20] & carry_bit_layer_adder[1][19]); // calculation of carry bit of adder
assign result_layer_adder[1][21] = layer_data_a[1][21] ^ layer_data_b[1][21] ^ carry_bit_layer_adder[1][20]; // calculation of add result
assign carry_bit_layer_adder[1][21] = (layer_data_a[1][21] & layer_data_b[1][21]) | (layer_data_a[1][21] & carry_bit_layer_adder[1][20]) | (layer_data_b[1][21] & carry_bit_layer_adder[1][20]); // calculation of carry bit of adder
assign result_layer_adder[1][22] = layer_data_a[1][22] ^ layer_data_b[1][22] ^ carry_bit_layer_adder[1][21]; // calculation of add result
assign carry_bit_layer_adder[1][22] = (layer_data_a[1][22] & layer_data_b[1][22]) | (layer_data_a[1][22] & carry_bit_layer_adder[1][21]) | (layer_data_b[1][22] & carry_bit_layer_adder[1][21]); // calculation of carry bit of adder
assign result_layer_adder[1][23] = layer_data_a[1][23] ^ layer_data_b[1][23] ^ carry_bit_layer_adder[1][22]; // calculation of add result
assign carry_bit_layer_adder[1][23] = (layer_data_a[1][23] & layer_data_b[1][23]) | (layer_data_a[1][23] & carry_bit_layer_adder[1][22]) | (layer_data_b[1][23] & carry_bit_layer_adder[1][22]); // calculation of carry bit of adder
assign result_layer_adder[1][24] = layer_data_a[1][24] ^ layer_data_b[1][24] ^ carry_bit_layer_adder[1][23]; // calculation of add result
assign carry_bit_layer_adder[1][24] = (layer_data_a[1][24] & layer_data_b[1][24]) | (layer_data_a[1][24] & carry_bit_layer_adder[1][23]) | (layer_data_b[1][24] & carry_bit_layer_adder[1][23]); // calculation of carry bit of adder
assign result_layer_adder[1][25] = layer_data_a[1][25] ^ layer_data_b[1][25] ^ carry_bit_layer_adder[1][24]; // calculation of add result
assign carry_bit_layer_adder[1][25] = (layer_data_a[1][25] & layer_data_b[1][25]) | (layer_data_a[1][25] & carry_bit_layer_adder[1][24]) | (layer_data_b[1][25] & carry_bit_layer_adder[1][24]); // calculation of carry bit of adder
assign result_layer_adder[1][26] = layer_data_a[1][26] ^ layer_data_b[1][26] ^ carry_bit_layer_adder[1][25]; // calculation of add result
assign carry_bit_layer_adder[1][26] = (layer_data_a[1][26] & layer_data_b[1][26]) | (layer_data_a[1][26] & carry_bit_layer_adder[1][25]) | (layer_data_b[1][26] & carry_bit_layer_adder[1][25]); // calculation of carry bit of adder
assign result_layer_adder[1][27] = layer_data_a[1][27] ^ layer_data_b[1][27] ^ carry_bit_layer_adder[1][26]; // calculation of add result
assign carry_bit_layer_adder[1][27] = (layer_data_a[1][27] & layer_data_b[1][27]) | (layer_data_a[1][27] & carry_bit_layer_adder[1][26]) | (layer_data_b[1][27] & carry_bit_layer_adder[1][26]); // calculation of carry bit of adder
assign result_layer_adder[1][28] = layer_data_a[1][28] ^ layer_data_b[1][28] ^ carry_bit_layer_adder[1][27]; // calculation of add result
assign carry_bit_layer_adder[1][28] = (layer_data_a[1][28] & layer_data_b[1][28]) | (layer_data_a[1][28] & carry_bit_layer_adder[1][27]) | (layer_data_b[1][28] & carry_bit_layer_adder[1][27]); // calculation of carry bit of adder
assign result_layer_adder[1][29] = layer_data_a[1][29] ^ layer_data_b[1][29] ^ carry_bit_layer_adder[1][28]; // calculation of add result
assign carry_bit_layer_adder[1][29] = (layer_data_a[1][29] & layer_data_b[1][29]) | (layer_data_a[1][29] & carry_bit_layer_adder[1][28]) | (layer_data_b[1][29] & carry_bit_layer_adder[1][28]); // calculation of carry bit of adder
assign result_layer_adder[1][30] = layer_data_a[1][30] ^ layer_data_b[1][30] ^ carry_bit_layer_adder[1][29]; // calculation of add result
assign carry_bit_layer_adder[1][30] = (layer_data_a[1][30] & layer_data_b[1][30]) | (layer_data_a[1][30] & carry_bit_layer_adder[1][29]) | (layer_data_b[1][30] & carry_bit_layer_adder[1][29]); // calculation of carry bit of adder
assign result_layer_adder[1][31] = layer_data_a[1][31] ^ layer_data_b[1][31] ^ carry_bit_layer_adder[1][30]; // calculation of add result
assign carry_bit_layer_adder[1][31] = (layer_data_a[1][31] & layer_data_b[1][31]) | (layer_data_a[1][31] & carry_bit_layer_adder[1][30]) | (layer_data_b[1][31] & carry_bit_layer_adder[1][30]); // calculation of carry bit of adder
assign result_layer_adder[1][32] = layer_data_a[1][32] ^ layer_data_b[1][32] ^ carry_bit_layer_adder[1][31]; // calculation of add result

// Layer 3
assign layer_data_a[2][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[1][32] == 1'b1) ? {layer_data_a[1][31:0], operand_a[30]} : {result_layer_adder[1][31:0], operand_a[30]}) : {1'b0, result_layer_adder[1][32:1]}; // data select for layer 3
assign layer_data_b[2][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[2] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 3

// Layer 3 adder
assign result_layer_adder[2][0] = layer_data_a[2][0] ^ layer_data_b[2][0]; // calculation of add result
assign carry_bit_layer_adder[2][0] = layer_data_a[2][0] & layer_data_b[2][0]; // calculation of carry bit of adder
assign result_layer_adder[2][1] = layer_data_a[2][1] ^ layer_data_b[2][1] ^ carry_bit_layer_adder[2][0]; // calculation of add result
assign carry_bit_layer_adder[2][1] = (layer_data_a[2][1] & layer_data_b[2][1]) | (layer_data_a[2][1] & carry_bit_layer_adder[2][0]) | (layer_data_b[2][1] & carry_bit_layer_adder[2][0]); // calculation of carry bit of adder
assign result_layer_adder[2][2] = layer_data_a[2][2] ^ layer_data_b[2][2] ^ carry_bit_layer_adder[2][1]; // calculation of add result
assign carry_bit_layer_adder[2][2] = (layer_data_a[2][2] & layer_data_b[2][2]) | (layer_data_a[2][2] & carry_bit_layer_adder[2][1]) | (layer_data_b[2][2] & carry_bit_layer_adder[2][1]); // calculation of carry bit of adder
assign result_layer_adder[2][3] = layer_data_a[2][3] ^ layer_data_b[2][3] ^ carry_bit_layer_adder[2][2]; // calculation of add result
assign carry_bit_layer_adder[2][3] = (layer_data_a[2][3] & layer_data_b[2][3]) | (layer_data_a[2][3] & carry_bit_layer_adder[2][2]) | (layer_data_b[2][3] & carry_bit_layer_adder[2][2]); // calculation of carry bit of adder
assign result_layer_adder[2][4] = layer_data_a[2][4] ^ layer_data_b[2][4] ^ carry_bit_layer_adder[2][3]; // calculation of add result
assign carry_bit_layer_adder[2][4] = (layer_data_a[2][4] & layer_data_b[2][4]) | (layer_data_a[2][4] & carry_bit_layer_adder[2][3]) | (layer_data_b[2][4] & carry_bit_layer_adder[2][3]); // calculation of carry bit of adder
assign result_layer_adder[2][5] = layer_data_a[2][5] ^ layer_data_b[2][5] ^ carry_bit_layer_adder[2][4]; // calculation of add result
assign carry_bit_layer_adder[2][5] = (layer_data_a[2][5] & layer_data_b[2][5]) | (layer_data_a[2][5] & carry_bit_layer_adder[2][4]) | (layer_data_b[2][5] & carry_bit_layer_adder[2][4]); // calculation of carry bit of adder
assign result_layer_adder[2][6] = layer_data_a[2][6] ^ layer_data_b[2][6] ^ carry_bit_layer_adder[2][5]; // calculation of add result
assign carry_bit_layer_adder[2][6] = (layer_data_a[2][6] & layer_data_b[2][6]) | (layer_data_a[2][6] & carry_bit_layer_adder[2][5]) | (layer_data_b[2][6] & carry_bit_layer_adder[2][5]); // calculation of carry bit of adder
assign result_layer_adder[2][7] = layer_data_a[2][7] ^ layer_data_b[2][7] ^ carry_bit_layer_adder[2][6]; // calculation of add result
assign carry_bit_layer_adder[2][7] = (layer_data_a[2][7] & layer_data_b[2][7]) | (layer_data_a[2][7] & carry_bit_layer_adder[2][6]) | (layer_data_b[2][7] & carry_bit_layer_adder[2][6]); // calculation of carry bit of adder
assign result_layer_adder[2][8] = layer_data_a[2][8] ^ layer_data_b[2][8] ^ carry_bit_layer_adder[2][7]; // calculation of add result
assign carry_bit_layer_adder[2][8] = (layer_data_a[2][8] & layer_data_b[2][8]) | (layer_data_a[2][8] & carry_bit_layer_adder[2][7]) | (layer_data_b[2][8] & carry_bit_layer_adder[2][7]); // calculation of carry bit of adder
assign result_layer_adder[2][9] = layer_data_a[2][9] ^ layer_data_b[2][9] ^ carry_bit_layer_adder[2][8]; // calculation of add result
assign carry_bit_layer_adder[2][9] = (layer_data_a[2][9] & layer_data_b[2][9]) | (layer_data_a[2][9] & carry_bit_layer_adder[2][8]) | (layer_data_b[2][9] & carry_bit_layer_adder[2][8]); // calculation of carry bit of adder
assign result_layer_adder[2][10] = layer_data_a[2][10] ^ layer_data_b[2][10] ^ carry_bit_layer_adder[2][9]; // calculation of add result
assign carry_bit_layer_adder[2][10] = (layer_data_a[2][10] & layer_data_b[2][10]) | (layer_data_a[2][10] & carry_bit_layer_adder[2][9]) | (layer_data_b[2][10] & carry_bit_layer_adder[2][9]); // calculation of carry bit of adder
assign result_layer_adder[2][11] = layer_data_a[2][11] ^ layer_data_b[2][11] ^ carry_bit_layer_adder[2][10]; // calculation of add result
assign carry_bit_layer_adder[2][11] = (layer_data_a[2][11] & layer_data_b[2][11]) | (layer_data_a[2][11] & carry_bit_layer_adder[2][10]) | (layer_data_b[2][11] & carry_bit_layer_adder[2][10]); // calculation of carry bit of adder
assign result_layer_adder[2][12] = layer_data_a[2][12] ^ layer_data_b[2][12] ^ carry_bit_layer_adder[2][11]; // calculation of add result
assign carry_bit_layer_adder[2][12] = (layer_data_a[2][12] & layer_data_b[2][12]) | (layer_data_a[2][12] & carry_bit_layer_adder[2][11]) | (layer_data_b[2][12] & carry_bit_layer_adder[2][11]); // calculation of carry bit of adder
assign result_layer_adder[2][13] = layer_data_a[2][13] ^ layer_data_b[2][13] ^ carry_bit_layer_adder[2][12]; // calculation of add result
assign carry_bit_layer_adder[2][13] = (layer_data_a[2][13] & layer_data_b[2][13]) | (layer_data_a[2][13] & carry_bit_layer_adder[2][12]) | (layer_data_b[2][13] & carry_bit_layer_adder[2][12]); // calculation of carry bit of adder
assign result_layer_adder[2][14] = layer_data_a[2][14] ^ layer_data_b[2][14] ^ carry_bit_layer_adder[2][13]; // calculation of add result
assign carry_bit_layer_adder[2][14] = (layer_data_a[2][14] & layer_data_b[2][14]) | (layer_data_a[2][14] & carry_bit_layer_adder[2][13]) | (layer_data_b[2][14] & carry_bit_layer_adder[2][13]); // calculation of carry bit of adder
assign result_layer_adder[2][15] = layer_data_a[2][15] ^ layer_data_b[2][15] ^ carry_bit_layer_adder[2][14]; // calculation of add result
assign carry_bit_layer_adder[2][15] = (layer_data_a[2][15] & layer_data_b[2][15]) | (layer_data_a[2][15] & carry_bit_layer_adder[2][14]) | (layer_data_b[2][15] & carry_bit_layer_adder[2][14]); // calculation of carry bit of adder
assign result_layer_adder[2][16] = layer_data_a[2][16] ^ layer_data_b[2][16] ^ carry_bit_layer_adder[2][15]; // calculation of add result
assign carry_bit_layer_adder[2][16] = (layer_data_a[2][16] & layer_data_b[2][16]) | (layer_data_a[2][16] & carry_bit_layer_adder[2][15]) | (layer_data_b[2][16] & carry_bit_layer_adder[2][15]); // calculation of carry bit of adder
assign result_layer_adder[2][17] = layer_data_a[2][17] ^ layer_data_b[2][17] ^ carry_bit_layer_adder[2][16]; // calculation of add result
assign carry_bit_layer_adder[2][17] = (layer_data_a[2][17] & layer_data_b[2][17]) | (layer_data_a[2][17] & carry_bit_layer_adder[2][16]) | (layer_data_b[2][17] & carry_bit_layer_adder[2][16]); // calculation of carry bit of adder
assign result_layer_adder[2][18] = layer_data_a[2][18] ^ layer_data_b[2][18] ^ carry_bit_layer_adder[2][17]; // calculation of add result
assign carry_bit_layer_adder[2][18] = (layer_data_a[2][18] & layer_data_b[2][18]) | (layer_data_a[2][18] & carry_bit_layer_adder[2][17]) | (layer_data_b[2][18] & carry_bit_layer_adder[2][17]); // calculation of carry bit of adder
assign result_layer_adder[2][19] = layer_data_a[2][19] ^ layer_data_b[2][19] ^ carry_bit_layer_adder[2][18]; // calculation of add result
assign carry_bit_layer_adder[2][19] = (layer_data_a[2][19] & layer_data_b[2][19]) | (layer_data_a[2][19] & carry_bit_layer_adder[2][18]) | (layer_data_b[2][19] & carry_bit_layer_adder[2][18]); // calculation of carry bit of adder
assign result_layer_adder[2][20] = layer_data_a[2][20] ^ layer_data_b[2][20] ^ carry_bit_layer_adder[2][19]; // calculation of add result
assign carry_bit_layer_adder[2][20] = (layer_data_a[2][20] & layer_data_b[2][20]) | (layer_data_a[2][20] & carry_bit_layer_adder[2][19]) | (layer_data_b[2][20] & carry_bit_layer_adder[2][19]); // calculation of carry bit of adder
assign result_layer_adder[2][21] = layer_data_a[2][21] ^ layer_data_b[2][21] ^ carry_bit_layer_adder[2][20]; // calculation of add result
assign carry_bit_layer_adder[2][21] = (layer_data_a[2][21] & layer_data_b[2][21]) | (layer_data_a[2][21] & carry_bit_layer_adder[2][20]) | (layer_data_b[2][21] & carry_bit_layer_adder[2][20]); // calculation of carry bit of adder
assign result_layer_adder[2][22] = layer_data_a[2][22] ^ layer_data_b[2][22] ^ carry_bit_layer_adder[2][21]; // calculation of add result
assign carry_bit_layer_adder[2][22] = (layer_data_a[2][22] & layer_data_b[2][22]) | (layer_data_a[2][22] & carry_bit_layer_adder[2][21]) | (layer_data_b[2][22] & carry_bit_layer_adder[2][21]); // calculation of carry bit of adder
assign result_layer_adder[2][23] = layer_data_a[2][23] ^ layer_data_b[2][23] ^ carry_bit_layer_adder[2][22]; // calculation of add result
assign carry_bit_layer_adder[2][23] = (layer_data_a[2][23] & layer_data_b[2][23]) | (layer_data_a[2][23] & carry_bit_layer_adder[2][22]) | (layer_data_b[2][23] & carry_bit_layer_adder[2][22]); // calculation of carry bit of adder
assign result_layer_adder[2][24] = layer_data_a[2][24] ^ layer_data_b[2][24] ^ carry_bit_layer_adder[2][23]; // calculation of add result
assign carry_bit_layer_adder[2][24] = (layer_data_a[2][24] & layer_data_b[2][24]) | (layer_data_a[2][24] & carry_bit_layer_adder[2][23]) | (layer_data_b[2][24] & carry_bit_layer_adder[2][23]); // calculation of carry bit of adder
assign result_layer_adder[2][25] = layer_data_a[2][25] ^ layer_data_b[2][25] ^ carry_bit_layer_adder[2][24]; // calculation of add result
assign carry_bit_layer_adder[2][25] = (layer_data_a[2][25] & layer_data_b[2][25]) | (layer_data_a[2][25] & carry_bit_layer_adder[2][24]) | (layer_data_b[2][25] & carry_bit_layer_adder[2][24]); // calculation of carry bit of adder
assign result_layer_adder[2][26] = layer_data_a[2][26] ^ layer_data_b[2][26] ^ carry_bit_layer_adder[2][25]; // calculation of add result
assign carry_bit_layer_adder[2][26] = (layer_data_a[2][26] & layer_data_b[2][26]) | (layer_data_a[2][26] & carry_bit_layer_adder[2][25]) | (layer_data_b[2][26] & carry_bit_layer_adder[2][25]); // calculation of carry bit of adder
assign result_layer_adder[2][27] = layer_data_a[2][27] ^ layer_data_b[2][27] ^ carry_bit_layer_adder[2][26]; // calculation of add result
assign carry_bit_layer_adder[2][27] = (layer_data_a[2][27] & layer_data_b[2][27]) | (layer_data_a[2][27] & carry_bit_layer_adder[2][26]) | (layer_data_b[2][27] & carry_bit_layer_adder[2][26]); // calculation of carry bit of adder
assign result_layer_adder[2][28] = layer_data_a[2][28] ^ layer_data_b[2][28] ^ carry_bit_layer_adder[2][27]; // calculation of add result
assign carry_bit_layer_adder[2][28] = (layer_data_a[2][28] & layer_data_b[2][28]) | (layer_data_a[2][28] & carry_bit_layer_adder[2][27]) | (layer_data_b[2][28] & carry_bit_layer_adder[2][27]); // calculation of carry bit of adder
assign result_layer_adder[2][29] = layer_data_a[2][29] ^ layer_data_b[2][29] ^ carry_bit_layer_adder[2][28]; // calculation of add result
assign carry_bit_layer_adder[2][29] = (layer_data_a[2][29] & layer_data_b[2][29]) | (layer_data_a[2][29] & carry_bit_layer_adder[2][28]) | (layer_data_b[2][29] & carry_bit_layer_adder[2][28]); // calculation of carry bit of adder
assign result_layer_adder[2][30] = layer_data_a[2][30] ^ layer_data_b[2][30] ^ carry_bit_layer_adder[2][29]; // calculation of add result
assign carry_bit_layer_adder[2][30] = (layer_data_a[2][30] & layer_data_b[2][30]) | (layer_data_a[2][30] & carry_bit_layer_adder[2][29]) | (layer_data_b[2][30] & carry_bit_layer_adder[2][29]); // calculation of carry bit of adder
assign result_layer_adder[2][31] = layer_data_a[2][31] ^ layer_data_b[2][31] ^ carry_bit_layer_adder[2][30]; // calculation of add result
assign carry_bit_layer_adder[2][31] = (layer_data_a[2][31] & layer_data_b[2][31]) | (layer_data_a[2][31] & carry_bit_layer_adder[2][30]) | (layer_data_b[2][31] & carry_bit_layer_adder[2][30]); // calculation of carry bit of adder
assign result_layer_adder[2][32] = layer_data_a[2][32] ^ layer_data_b[2][32] ^ carry_bit_layer_adder[2][31]; // calculation of add result

// Layer 4
assign layer_data_a[3][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[2][32] == 1'b1) ? {layer_data_a[2][31:0], operand_a[29]} : {result_layer_adder[2][31:0], operand_a[29]}) : {1'b0, result_layer_adder[2][32:1]}; // data select for layer 4
assign layer_data_b[3][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[3] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 4

// Layer 4 adder
assign result_layer_adder[3][0] = layer_data_a[3][0] ^ layer_data_b[3][0]; // calculation of add result
assign carry_bit_layer_adder[3][0] = layer_data_a[3][0] & layer_data_b[3][0]; // calculation of carry bit of adder
assign result_layer_adder[3][1] = layer_data_a[3][1] ^ layer_data_b[3][1] ^ carry_bit_layer_adder[3][0]; // calculation of add result
assign carry_bit_layer_adder[3][1] = (layer_data_a[3][1] & layer_data_b[3][1]) | (layer_data_a[3][1] & carry_bit_layer_adder[3][0]) | (layer_data_b[3][1] & carry_bit_layer_adder[3][0]); // calculation of carry bit of adder
assign result_layer_adder[3][2] = layer_data_a[3][2] ^ layer_data_b[3][2] ^ carry_bit_layer_adder[3][1]; // calculation of add result
assign carry_bit_layer_adder[3][2] = (layer_data_a[3][2] & layer_data_b[3][2]) | (layer_data_a[3][2] & carry_bit_layer_adder[3][1]) | (layer_data_b[3][2] & carry_bit_layer_adder[3][1]); // calculation of carry bit of adder
assign result_layer_adder[3][3] = layer_data_a[3][3] ^ layer_data_b[3][3] ^ carry_bit_layer_adder[3][2]; // calculation of add result
assign carry_bit_layer_adder[3][3] = (layer_data_a[3][3] & layer_data_b[3][3]) | (layer_data_a[3][3] & carry_bit_layer_adder[3][2]) | (layer_data_b[3][3] & carry_bit_layer_adder[3][2]); // calculation of carry bit of adder
assign result_layer_adder[3][4] = layer_data_a[3][4] ^ layer_data_b[3][4] ^ carry_bit_layer_adder[3][3]; // calculation of add result
assign carry_bit_layer_adder[3][4] = (layer_data_a[3][4] & layer_data_b[3][4]) | (layer_data_a[3][4] & carry_bit_layer_adder[3][3]) | (layer_data_b[3][4] & carry_bit_layer_adder[3][3]); // calculation of carry bit of adder
assign result_layer_adder[3][5] = layer_data_a[3][5] ^ layer_data_b[3][5] ^ carry_bit_layer_adder[3][4]; // calculation of add result
assign carry_bit_layer_adder[3][5] = (layer_data_a[3][5] & layer_data_b[3][5]) | (layer_data_a[3][5] & carry_bit_layer_adder[3][4]) | (layer_data_b[3][5] & carry_bit_layer_adder[3][4]); // calculation of carry bit of adder
assign result_layer_adder[3][6] = layer_data_a[3][6] ^ layer_data_b[3][6] ^ carry_bit_layer_adder[3][5]; // calculation of add result
assign carry_bit_layer_adder[3][6] = (layer_data_a[3][6] & layer_data_b[3][6]) | (layer_data_a[3][6] & carry_bit_layer_adder[3][5]) | (layer_data_b[3][6] & carry_bit_layer_adder[3][5]); // calculation of carry bit of adder
assign result_layer_adder[3][7] = layer_data_a[3][7] ^ layer_data_b[3][7] ^ carry_bit_layer_adder[3][6]; // calculation of add result
assign carry_bit_layer_adder[3][7] = (layer_data_a[3][7] & layer_data_b[3][7]) | (layer_data_a[3][7] & carry_bit_layer_adder[3][6]) | (layer_data_b[3][7] & carry_bit_layer_adder[3][6]); // calculation of carry bit of adder
assign result_layer_adder[3][8] = layer_data_a[3][8] ^ layer_data_b[3][8] ^ carry_bit_layer_adder[3][7]; // calculation of add result
assign carry_bit_layer_adder[3][8] = (layer_data_a[3][8] & layer_data_b[3][8]) | (layer_data_a[3][8] & carry_bit_layer_adder[3][7]) | (layer_data_b[3][8] & carry_bit_layer_adder[3][7]); // calculation of carry bit of adder
assign result_layer_adder[3][9] = layer_data_a[3][9] ^ layer_data_b[3][9] ^ carry_bit_layer_adder[3][8]; // calculation of add result
assign carry_bit_layer_adder[3][9] = (layer_data_a[3][9] & layer_data_b[3][9]) | (layer_data_a[3][9] & carry_bit_layer_adder[3][8]) | (layer_data_b[3][9] & carry_bit_layer_adder[3][8]); // calculation of carry bit of adder
assign result_layer_adder[3][10] = layer_data_a[3][10] ^ layer_data_b[3][10] ^ carry_bit_layer_adder[3][9]; // calculation of add result
assign carry_bit_layer_adder[3][10] = (layer_data_a[3][10] & layer_data_b[3][10]) | (layer_data_a[3][10] & carry_bit_layer_adder[3][9]) | (layer_data_b[3][10] & carry_bit_layer_adder[3][9]); // calculation of carry bit of adder
assign result_layer_adder[3][11] = layer_data_a[3][11] ^ layer_data_b[3][11] ^ carry_bit_layer_adder[3][10]; // calculation of add result
assign carry_bit_layer_adder[3][11] = (layer_data_a[3][11] & layer_data_b[3][11]) | (layer_data_a[3][11] & carry_bit_layer_adder[3][10]) | (layer_data_b[3][11] & carry_bit_layer_adder[3][10]); // calculation of carry bit of adder
assign result_layer_adder[3][12] = layer_data_a[3][12] ^ layer_data_b[3][12] ^ carry_bit_layer_adder[3][11]; // calculation of add result
assign carry_bit_layer_adder[3][12] = (layer_data_a[3][12] & layer_data_b[3][12]) | (layer_data_a[3][12] & carry_bit_layer_adder[3][11]) | (layer_data_b[3][12] & carry_bit_layer_adder[3][11]); // calculation of carry bit of adder
assign result_layer_adder[3][13] = layer_data_a[3][13] ^ layer_data_b[3][13] ^ carry_bit_layer_adder[3][12]; // calculation of add result
assign carry_bit_layer_adder[3][13] = (layer_data_a[3][13] & layer_data_b[3][13]) | (layer_data_a[3][13] & carry_bit_layer_adder[3][12]) | (layer_data_b[3][13] & carry_bit_layer_adder[3][12]); // calculation of carry bit of adder
assign result_layer_adder[3][14] = layer_data_a[3][14] ^ layer_data_b[3][14] ^ carry_bit_layer_adder[3][13]; // calculation of add result
assign carry_bit_layer_adder[3][14] = (layer_data_a[3][14] & layer_data_b[3][14]) | (layer_data_a[3][14] & carry_bit_layer_adder[3][13]) | (layer_data_b[3][14] & carry_bit_layer_adder[3][13]); // calculation of carry bit of adder
assign result_layer_adder[3][15] = layer_data_a[3][15] ^ layer_data_b[3][15] ^ carry_bit_layer_adder[3][14]; // calculation of add result
assign carry_bit_layer_adder[3][15] = (layer_data_a[3][15] & layer_data_b[3][15]) | (layer_data_a[3][15] & carry_bit_layer_adder[3][14]) | (layer_data_b[3][15] & carry_bit_layer_adder[3][14]); // calculation of carry bit of adder
assign result_layer_adder[3][16] = layer_data_a[3][16] ^ layer_data_b[3][16] ^ carry_bit_layer_adder[3][15]; // calculation of add result
assign carry_bit_layer_adder[3][16] = (layer_data_a[3][16] & layer_data_b[3][16]) | (layer_data_a[3][16] & carry_bit_layer_adder[3][15]) | (layer_data_b[3][16] & carry_bit_layer_adder[3][15]); // calculation of carry bit of adder
assign result_layer_adder[3][17] = layer_data_a[3][17] ^ layer_data_b[3][17] ^ carry_bit_layer_adder[3][16]; // calculation of add result
assign carry_bit_layer_adder[3][17] = (layer_data_a[3][17] & layer_data_b[3][17]) | (layer_data_a[3][17] & carry_bit_layer_adder[3][16]) | (layer_data_b[3][17] & carry_bit_layer_adder[3][16]); // calculation of carry bit of adder
assign result_layer_adder[3][18] = layer_data_a[3][18] ^ layer_data_b[3][18] ^ carry_bit_layer_adder[3][17]; // calculation of add result
assign carry_bit_layer_adder[3][18] = (layer_data_a[3][18] & layer_data_b[3][18]) | (layer_data_a[3][18] & carry_bit_layer_adder[3][17]) | (layer_data_b[3][18] & carry_bit_layer_adder[3][17]); // calculation of carry bit of adder
assign result_layer_adder[3][19] = layer_data_a[3][19] ^ layer_data_b[3][19] ^ carry_bit_layer_adder[3][18]; // calculation of add result
assign carry_bit_layer_adder[3][19] = (layer_data_a[3][19] & layer_data_b[3][19]) | (layer_data_a[3][19] & carry_bit_layer_adder[3][18]) | (layer_data_b[3][19] & carry_bit_layer_adder[3][18]); // calculation of carry bit of adder
assign result_layer_adder[3][20] = layer_data_a[3][20] ^ layer_data_b[3][20] ^ carry_bit_layer_adder[3][19]; // calculation of add result
assign carry_bit_layer_adder[3][20] = (layer_data_a[3][20] & layer_data_b[3][20]) | (layer_data_a[3][20] & carry_bit_layer_adder[3][19]) | (layer_data_b[3][20] & carry_bit_layer_adder[3][19]); // calculation of carry bit of adder
assign result_layer_adder[3][21] = layer_data_a[3][21] ^ layer_data_b[3][21] ^ carry_bit_layer_adder[3][20]; // calculation of add result
assign carry_bit_layer_adder[3][21] = (layer_data_a[3][21] & layer_data_b[3][21]) | (layer_data_a[3][21] & carry_bit_layer_adder[3][20]) | (layer_data_b[3][21] & carry_bit_layer_adder[3][20]); // calculation of carry bit of adder
assign result_layer_adder[3][22] = layer_data_a[3][22] ^ layer_data_b[3][22] ^ carry_bit_layer_adder[3][21]; // calculation of add result
assign carry_bit_layer_adder[3][22] = (layer_data_a[3][22] & layer_data_b[3][22]) | (layer_data_a[3][22] & carry_bit_layer_adder[3][21]) | (layer_data_b[3][22] & carry_bit_layer_adder[3][21]); // calculation of carry bit of adder
assign result_layer_adder[3][23] = layer_data_a[3][23] ^ layer_data_b[3][23] ^ carry_bit_layer_adder[3][22]; // calculation of add result
assign carry_bit_layer_adder[3][23] = (layer_data_a[3][23] & layer_data_b[3][23]) | (layer_data_a[3][23] & carry_bit_layer_adder[3][22]) | (layer_data_b[3][23] & carry_bit_layer_adder[3][22]); // calculation of carry bit of adder
assign result_layer_adder[3][24] = layer_data_a[3][24] ^ layer_data_b[3][24] ^ carry_bit_layer_adder[3][23]; // calculation of add result
assign carry_bit_layer_adder[3][24] = (layer_data_a[3][24] & layer_data_b[3][24]) | (layer_data_a[3][24] & carry_bit_layer_adder[3][23]) | (layer_data_b[3][24] & carry_bit_layer_adder[3][23]); // calculation of carry bit of adder
assign result_layer_adder[3][25] = layer_data_a[3][25] ^ layer_data_b[3][25] ^ carry_bit_layer_adder[3][24]; // calculation of add result
assign carry_bit_layer_adder[3][25] = (layer_data_a[3][25] & layer_data_b[3][25]) | (layer_data_a[3][25] & carry_bit_layer_adder[3][24]) | (layer_data_b[3][25] & carry_bit_layer_adder[3][24]); // calculation of carry bit of adder
assign result_layer_adder[3][26] = layer_data_a[3][26] ^ layer_data_b[3][26] ^ carry_bit_layer_adder[3][25]; // calculation of add result
assign carry_bit_layer_adder[3][26] = (layer_data_a[3][26] & layer_data_b[3][26]) | (layer_data_a[3][26] & carry_bit_layer_adder[3][25]) | (layer_data_b[3][26] & carry_bit_layer_adder[3][25]); // calculation of carry bit of adder
assign result_layer_adder[3][27] = layer_data_a[3][27] ^ layer_data_b[3][27] ^ carry_bit_layer_adder[3][26]; // calculation of add result
assign carry_bit_layer_adder[3][27] = (layer_data_a[3][27] & layer_data_b[3][27]) | (layer_data_a[3][27] & carry_bit_layer_adder[3][26]) | (layer_data_b[3][27] & carry_bit_layer_adder[3][26]); // calculation of carry bit of adder
assign result_layer_adder[3][28] = layer_data_a[3][28] ^ layer_data_b[3][28] ^ carry_bit_layer_adder[3][27]; // calculation of add result
assign carry_bit_layer_adder[3][28] = (layer_data_a[3][28] & layer_data_b[3][28]) | (layer_data_a[3][28] & carry_bit_layer_adder[3][27]) | (layer_data_b[3][28] & carry_bit_layer_adder[3][27]); // calculation of carry bit of adder
assign result_layer_adder[3][29] = layer_data_a[3][29] ^ layer_data_b[3][29] ^ carry_bit_layer_adder[3][28]; // calculation of add result
assign carry_bit_layer_adder[3][29] = (layer_data_a[3][29] & layer_data_b[3][29]) | (layer_data_a[3][29] & carry_bit_layer_adder[3][28]) | (layer_data_b[3][29] & carry_bit_layer_adder[3][28]); // calculation of carry bit of adder
assign result_layer_adder[3][30] = layer_data_a[3][30] ^ layer_data_b[3][30] ^ carry_bit_layer_adder[3][29]; // calculation of add result
assign carry_bit_layer_adder[3][30] = (layer_data_a[3][30] & layer_data_b[3][30]) | (layer_data_a[3][30] & carry_bit_layer_adder[3][29]) | (layer_data_b[3][30] & carry_bit_layer_adder[3][29]); // calculation of carry bit of adder
assign result_layer_adder[3][31] = layer_data_a[3][31] ^ layer_data_b[3][31] ^ carry_bit_layer_adder[3][30]; // calculation of add result
assign carry_bit_layer_adder[3][31] = (layer_data_a[3][31] & layer_data_b[3][31]) | (layer_data_a[3][31] & carry_bit_layer_adder[3][30]) | (layer_data_b[3][31] & carry_bit_layer_adder[3][30]); // calculation of carry bit of adder
assign result_layer_adder[3][32] = layer_data_a[3][32] ^ layer_data_b[3][32] ^ carry_bit_layer_adder[3][31]; // calculation of add result

// Layer 5
assign layer_data_a[4][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[3][32] == 1'b1) ? {layer_data_a[3][31:0], operand_a[28]} : {result_layer_adder[3][31:0], operand_a[28]}) : {1'b0, result_layer_adder[3][32:1]}; // data select for layer 5
assign layer_data_b[4][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[4] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 5

// Layer 5 adder
assign result_layer_adder[4][0] = layer_data_a[4][0] ^ layer_data_b[4][0]; // calculation of add result
assign carry_bit_layer_adder[4][0] = layer_data_a[4][0] & layer_data_b[4][0]; // calculation of carry bit of adder
assign result_layer_adder[4][1] = layer_data_a[4][1] ^ layer_data_b[4][1] ^ carry_bit_layer_adder[4][0]; // calculation of add result
assign carry_bit_layer_adder[4][1] = (layer_data_a[4][1] & layer_data_b[4][1]) | (layer_data_a[4][1] & carry_bit_layer_adder[4][0]) | (layer_data_b[4][1] & carry_bit_layer_adder[4][0]); // calculation of carry bit of adder
assign result_layer_adder[4][2] = layer_data_a[4][2] ^ layer_data_b[4][2] ^ carry_bit_layer_adder[4][1]; // calculation of add result
assign carry_bit_layer_adder[4][2] = (layer_data_a[4][2] & layer_data_b[4][2]) | (layer_data_a[4][2] & carry_bit_layer_adder[4][1]) | (layer_data_b[4][2] & carry_bit_layer_adder[4][1]); // calculation of carry bit of adder
assign result_layer_adder[4][3] = layer_data_a[4][3] ^ layer_data_b[4][3] ^ carry_bit_layer_adder[4][2]; // calculation of add result
assign carry_bit_layer_adder[4][3] = (layer_data_a[4][3] & layer_data_b[4][3]) | (layer_data_a[4][3] & carry_bit_layer_adder[4][2]) | (layer_data_b[4][3] & carry_bit_layer_adder[4][2]); // calculation of carry bit of adder
assign result_layer_adder[4][4] = layer_data_a[4][4] ^ layer_data_b[4][4] ^ carry_bit_layer_adder[4][3]; // calculation of add result
assign carry_bit_layer_adder[4][4] = (layer_data_a[4][4] & layer_data_b[4][4]) | (layer_data_a[4][4] & carry_bit_layer_adder[4][3]) | (layer_data_b[4][4] & carry_bit_layer_adder[4][3]); // calculation of carry bit of adder
assign result_layer_adder[4][5] = layer_data_a[4][5] ^ layer_data_b[4][5] ^ carry_bit_layer_adder[4][4]; // calculation of add result
assign carry_bit_layer_adder[4][5] = (layer_data_a[4][5] & layer_data_b[4][5]) | (layer_data_a[4][5] & carry_bit_layer_adder[4][4]) | (layer_data_b[4][5] & carry_bit_layer_adder[4][4]); // calculation of carry bit of adder
assign result_layer_adder[4][6] = layer_data_a[4][6] ^ layer_data_b[4][6] ^ carry_bit_layer_adder[4][5]; // calculation of add result
assign carry_bit_layer_adder[4][6] = (layer_data_a[4][6] & layer_data_b[4][6]) | (layer_data_a[4][6] & carry_bit_layer_adder[4][5]) | (layer_data_b[4][6] & carry_bit_layer_adder[4][5]); // calculation of carry bit of adder
assign result_layer_adder[4][7] = layer_data_a[4][7] ^ layer_data_b[4][7] ^ carry_bit_layer_adder[4][6]; // calculation of add result
assign carry_bit_layer_adder[4][7] = (layer_data_a[4][7] & layer_data_b[4][7]) | (layer_data_a[4][7] & carry_bit_layer_adder[4][6]) | (layer_data_b[4][7] & carry_bit_layer_adder[4][6]); // calculation of carry bit of adder
assign result_layer_adder[4][8] = layer_data_a[4][8] ^ layer_data_b[4][8] ^ carry_bit_layer_adder[4][7]; // calculation of add result
assign carry_bit_layer_adder[4][8] = (layer_data_a[4][8] & layer_data_b[4][8]) | (layer_data_a[4][8] & carry_bit_layer_adder[4][7]) | (layer_data_b[4][8] & carry_bit_layer_adder[4][7]); // calculation of carry bit of adder
assign result_layer_adder[4][9] = layer_data_a[4][9] ^ layer_data_b[4][9] ^ carry_bit_layer_adder[4][8]; // calculation of add result
assign carry_bit_layer_adder[4][9] = (layer_data_a[4][9] & layer_data_b[4][9]) | (layer_data_a[4][9] & carry_bit_layer_adder[4][8]) | (layer_data_b[4][9] & carry_bit_layer_adder[4][8]); // calculation of carry bit of adder
assign result_layer_adder[4][10] = layer_data_a[4][10] ^ layer_data_b[4][10] ^ carry_bit_layer_adder[4][9]; // calculation of add result
assign carry_bit_layer_adder[4][10] = (layer_data_a[4][10] & layer_data_b[4][10]) | (layer_data_a[4][10] & carry_bit_layer_adder[4][9]) | (layer_data_b[4][10] & carry_bit_layer_adder[4][9]); // calculation of carry bit of adder
assign result_layer_adder[4][11] = layer_data_a[4][11] ^ layer_data_b[4][11] ^ carry_bit_layer_adder[4][10]; // calculation of add result
assign carry_bit_layer_adder[4][11] = (layer_data_a[4][11] & layer_data_b[4][11]) | (layer_data_a[4][11] & carry_bit_layer_adder[4][10]) | (layer_data_b[4][11] & carry_bit_layer_adder[4][10]); // calculation of carry bit of adder
assign result_layer_adder[4][12] = layer_data_a[4][12] ^ layer_data_b[4][12] ^ carry_bit_layer_adder[4][11]; // calculation of add result
assign carry_bit_layer_adder[4][12] = (layer_data_a[4][12] & layer_data_b[4][12]) | (layer_data_a[4][12] & carry_bit_layer_adder[4][11]) | (layer_data_b[4][12] & carry_bit_layer_adder[4][11]); // calculation of carry bit of adder
assign result_layer_adder[4][13] = layer_data_a[4][13] ^ layer_data_b[4][13] ^ carry_bit_layer_adder[4][12]; // calculation of add result
assign carry_bit_layer_adder[4][13] = (layer_data_a[4][13] & layer_data_b[4][13]) | (layer_data_a[4][13] & carry_bit_layer_adder[4][12]) | (layer_data_b[4][13] & carry_bit_layer_adder[4][12]); // calculation of carry bit of adder
assign result_layer_adder[4][14] = layer_data_a[4][14] ^ layer_data_b[4][14] ^ carry_bit_layer_adder[4][13]; // calculation of add result
assign carry_bit_layer_adder[4][14] = (layer_data_a[4][14] & layer_data_b[4][14]) | (layer_data_a[4][14] & carry_bit_layer_adder[4][13]) | (layer_data_b[4][14] & carry_bit_layer_adder[4][13]); // calculation of carry bit of adder
assign result_layer_adder[4][15] = layer_data_a[4][15] ^ layer_data_b[4][15] ^ carry_bit_layer_adder[4][14]; // calculation of add result
assign carry_bit_layer_adder[4][15] = (layer_data_a[4][15] & layer_data_b[4][15]) | (layer_data_a[4][15] & carry_bit_layer_adder[4][14]) | (layer_data_b[4][15] & carry_bit_layer_adder[4][14]); // calculation of carry bit of adder
assign result_layer_adder[4][16] = layer_data_a[4][16] ^ layer_data_b[4][16] ^ carry_bit_layer_adder[4][15]; // calculation of add result
assign carry_bit_layer_adder[4][16] = (layer_data_a[4][16] & layer_data_b[4][16]) | (layer_data_a[4][16] & carry_bit_layer_adder[4][15]) | (layer_data_b[4][16] & carry_bit_layer_adder[4][15]); // calculation of carry bit of adder
assign result_layer_adder[4][17] = layer_data_a[4][17] ^ layer_data_b[4][17] ^ carry_bit_layer_adder[4][16]; // calculation of add result
assign carry_bit_layer_adder[4][17] = (layer_data_a[4][17] & layer_data_b[4][17]) | (layer_data_a[4][17] & carry_bit_layer_adder[4][16]) | (layer_data_b[4][17] & carry_bit_layer_adder[4][16]); // calculation of carry bit of adder
assign result_layer_adder[4][18] = layer_data_a[4][18] ^ layer_data_b[4][18] ^ carry_bit_layer_adder[4][17]; // calculation of add result
assign carry_bit_layer_adder[4][18] = (layer_data_a[4][18] & layer_data_b[4][18]) | (layer_data_a[4][18] & carry_bit_layer_adder[4][17]) | (layer_data_b[4][18] & carry_bit_layer_adder[4][17]); // calculation of carry bit of adder
assign result_layer_adder[4][19] = layer_data_a[4][19] ^ layer_data_b[4][19] ^ carry_bit_layer_adder[4][18]; // calculation of add result
assign carry_bit_layer_adder[4][19] = (layer_data_a[4][19] & layer_data_b[4][19]) | (layer_data_a[4][19] & carry_bit_layer_adder[4][18]) | (layer_data_b[4][19] & carry_bit_layer_adder[4][18]); // calculation of carry bit of adder
assign result_layer_adder[4][20] = layer_data_a[4][20] ^ layer_data_b[4][20] ^ carry_bit_layer_adder[4][19]; // calculation of add result
assign carry_bit_layer_adder[4][20] = (layer_data_a[4][20] & layer_data_b[4][20]) | (layer_data_a[4][20] & carry_bit_layer_adder[4][19]) | (layer_data_b[4][20] & carry_bit_layer_adder[4][19]); // calculation of carry bit of adder
assign result_layer_adder[4][21] = layer_data_a[4][21] ^ layer_data_b[4][21] ^ carry_bit_layer_adder[4][20]; // calculation of add result
assign carry_bit_layer_adder[4][21] = (layer_data_a[4][21] & layer_data_b[4][21]) | (layer_data_a[4][21] & carry_bit_layer_adder[4][20]) | (layer_data_b[4][21] & carry_bit_layer_adder[4][20]); // calculation of carry bit of adder
assign result_layer_adder[4][22] = layer_data_a[4][22] ^ layer_data_b[4][22] ^ carry_bit_layer_adder[4][21]; // calculation of add result
assign carry_bit_layer_adder[4][22] = (layer_data_a[4][22] & layer_data_b[4][22]) | (layer_data_a[4][22] & carry_bit_layer_adder[4][21]) | (layer_data_b[4][22] & carry_bit_layer_adder[4][21]); // calculation of carry bit of adder
assign result_layer_adder[4][23] = layer_data_a[4][23] ^ layer_data_b[4][23] ^ carry_bit_layer_adder[4][22]; // calculation of add result
assign carry_bit_layer_adder[4][23] = (layer_data_a[4][23] & layer_data_b[4][23]) | (layer_data_a[4][23] & carry_bit_layer_adder[4][22]) | (layer_data_b[4][23] & carry_bit_layer_adder[4][22]); // calculation of carry bit of adder
assign result_layer_adder[4][24] = layer_data_a[4][24] ^ layer_data_b[4][24] ^ carry_bit_layer_adder[4][23]; // calculation of add result
assign carry_bit_layer_adder[4][24] = (layer_data_a[4][24] & layer_data_b[4][24]) | (layer_data_a[4][24] & carry_bit_layer_adder[4][23]) | (layer_data_b[4][24] & carry_bit_layer_adder[4][23]); // calculation of carry bit of adder
assign result_layer_adder[4][25] = layer_data_a[4][25] ^ layer_data_b[4][25] ^ carry_bit_layer_adder[4][24]; // calculation of add result
assign carry_bit_layer_adder[4][25] = (layer_data_a[4][25] & layer_data_b[4][25]) | (layer_data_a[4][25] & carry_bit_layer_adder[4][24]) | (layer_data_b[4][25] & carry_bit_layer_adder[4][24]); // calculation of carry bit of adder
assign result_layer_adder[4][26] = layer_data_a[4][26] ^ layer_data_b[4][26] ^ carry_bit_layer_adder[4][25]; // calculation of add result
assign carry_bit_layer_adder[4][26] = (layer_data_a[4][26] & layer_data_b[4][26]) | (layer_data_a[4][26] & carry_bit_layer_adder[4][25]) | (layer_data_b[4][26] & carry_bit_layer_adder[4][25]); // calculation of carry bit of adder
assign result_layer_adder[4][27] = layer_data_a[4][27] ^ layer_data_b[4][27] ^ carry_bit_layer_adder[4][26]; // calculation of add result
assign carry_bit_layer_adder[4][27] = (layer_data_a[4][27] & layer_data_b[4][27]) | (layer_data_a[4][27] & carry_bit_layer_adder[4][26]) | (layer_data_b[4][27] & carry_bit_layer_adder[4][26]); // calculation of carry bit of adder
assign result_layer_adder[4][28] = layer_data_a[4][28] ^ layer_data_b[4][28] ^ carry_bit_layer_adder[4][27]; // calculation of add result
assign carry_bit_layer_adder[4][28] = (layer_data_a[4][28] & layer_data_b[4][28]) | (layer_data_a[4][28] & carry_bit_layer_adder[4][27]) | (layer_data_b[4][28] & carry_bit_layer_adder[4][27]); // calculation of carry bit of adder
assign result_layer_adder[4][29] = layer_data_a[4][29] ^ layer_data_b[4][29] ^ carry_bit_layer_adder[4][28]; // calculation of add result
assign carry_bit_layer_adder[4][29] = (layer_data_a[4][29] & layer_data_b[4][29]) | (layer_data_a[4][29] & carry_bit_layer_adder[4][28]) | (layer_data_b[4][29] & carry_bit_layer_adder[4][28]); // calculation of carry bit of adder
assign result_layer_adder[4][30] = layer_data_a[4][30] ^ layer_data_b[4][30] ^ carry_bit_layer_adder[4][29]; // calculation of add result
assign carry_bit_layer_adder[4][30] = (layer_data_a[4][30] & layer_data_b[4][30]) | (layer_data_a[4][30] & carry_bit_layer_adder[4][29]) | (layer_data_b[4][30] & carry_bit_layer_adder[4][29]); // calculation of carry bit of adder
assign result_layer_adder[4][31] = layer_data_a[4][31] ^ layer_data_b[4][31] ^ carry_bit_layer_adder[4][30]; // calculation of add result
assign carry_bit_layer_adder[4][31] = (layer_data_a[4][31] & layer_data_b[4][31]) | (layer_data_a[4][31] & carry_bit_layer_adder[4][30]) | (layer_data_b[4][31] & carry_bit_layer_adder[4][30]); // calculation of carry bit of adder
assign result_layer_adder[4][32] = layer_data_a[4][32] ^ layer_data_b[4][32] ^ carry_bit_layer_adder[4][31]; // calculation of add result

// Layer 6
assign layer_data_a[5][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[4][32] == 1'b1) ? {layer_data_a[4][31:0], operand_a[27]} : {result_layer_adder[4][31:0], operand_a[27]}) : {1'b0, result_layer_adder[4][32:1]}; // data select for layer 6
assign layer_data_b[5][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[5] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 6

// Layer 6 adder
assign result_layer_adder[5][0] = layer_data_a[5][0] ^ layer_data_b[5][0]; // calculation of add result
assign carry_bit_layer_adder[5][0] = layer_data_a[5][0] & layer_data_b[5][0]; // calculation of carry bit of adder
assign result_layer_adder[5][1] = layer_data_a[5][1] ^ layer_data_b[5][1] ^ carry_bit_layer_adder[5][0]; // calculation of add result
assign carry_bit_layer_adder[5][1] = (layer_data_a[5][1] & layer_data_b[5][1]) | (layer_data_a[5][1] & carry_bit_layer_adder[5][0]) | (layer_data_b[5][1] & carry_bit_layer_adder[5][0]); // calculation of carry bit of adder
assign result_layer_adder[5][2] = layer_data_a[5][2] ^ layer_data_b[5][2] ^ carry_bit_layer_adder[5][1]; // calculation of add result
assign carry_bit_layer_adder[5][2] = (layer_data_a[5][2] & layer_data_b[5][2]) | (layer_data_a[5][2] & carry_bit_layer_adder[5][1]) | (layer_data_b[5][2] & carry_bit_layer_adder[5][1]); // calculation of carry bit of adder
assign result_layer_adder[5][3] = layer_data_a[5][3] ^ layer_data_b[5][3] ^ carry_bit_layer_adder[5][2]; // calculation of add result
assign carry_bit_layer_adder[5][3] = (layer_data_a[5][3] & layer_data_b[5][3]) | (layer_data_a[5][3] & carry_bit_layer_adder[5][2]) | (layer_data_b[5][3] & carry_bit_layer_adder[5][2]); // calculation of carry bit of adder
assign result_layer_adder[5][4] = layer_data_a[5][4] ^ layer_data_b[5][4] ^ carry_bit_layer_adder[5][3]; // calculation of add result
assign carry_bit_layer_adder[5][4] = (layer_data_a[5][4] & layer_data_b[5][4]) | (layer_data_a[5][4] & carry_bit_layer_adder[5][3]) | (layer_data_b[5][4] & carry_bit_layer_adder[5][3]); // calculation of carry bit of adder
assign result_layer_adder[5][5] = layer_data_a[5][5] ^ layer_data_b[5][5] ^ carry_bit_layer_adder[5][4]; // calculation of add result
assign carry_bit_layer_adder[5][5] = (layer_data_a[5][5] & layer_data_b[5][5]) | (layer_data_a[5][5] & carry_bit_layer_adder[5][4]) | (layer_data_b[5][5] & carry_bit_layer_adder[5][4]); // calculation of carry bit of adder
assign result_layer_adder[5][6] = layer_data_a[5][6] ^ layer_data_b[5][6] ^ carry_bit_layer_adder[5][5]; // calculation of add result
assign carry_bit_layer_adder[5][6] = (layer_data_a[5][6] & layer_data_b[5][6]) | (layer_data_a[5][6] & carry_bit_layer_adder[5][5]) | (layer_data_b[5][6] & carry_bit_layer_adder[5][5]); // calculation of carry bit of adder
assign result_layer_adder[5][7] = layer_data_a[5][7] ^ layer_data_b[5][7] ^ carry_bit_layer_adder[5][6]; // calculation of add result
assign carry_bit_layer_adder[5][7] = (layer_data_a[5][7] & layer_data_b[5][7]) | (layer_data_a[5][7] & carry_bit_layer_adder[5][6]) | (layer_data_b[5][7] & carry_bit_layer_adder[5][6]); // calculation of carry bit of adder
assign result_layer_adder[5][8] = layer_data_a[5][8] ^ layer_data_b[5][8] ^ carry_bit_layer_adder[5][7]; // calculation of add result
assign carry_bit_layer_adder[5][8] = (layer_data_a[5][8] & layer_data_b[5][8]) | (layer_data_a[5][8] & carry_bit_layer_adder[5][7]) | (layer_data_b[5][8] & carry_bit_layer_adder[5][7]); // calculation of carry bit of adder
assign result_layer_adder[5][9] = layer_data_a[5][9] ^ layer_data_b[5][9] ^ carry_bit_layer_adder[5][8]; // calculation of add result
assign carry_bit_layer_adder[5][9] = (layer_data_a[5][9] & layer_data_b[5][9]) | (layer_data_a[5][9] & carry_bit_layer_adder[5][8]) | (layer_data_b[5][9] & carry_bit_layer_adder[5][8]); // calculation of carry bit of adder
assign result_layer_adder[5][10] = layer_data_a[5][10] ^ layer_data_b[5][10] ^ carry_bit_layer_adder[5][9]; // calculation of add result
assign carry_bit_layer_adder[5][10] = (layer_data_a[5][10] & layer_data_b[5][10]) | (layer_data_a[5][10] & carry_bit_layer_adder[5][9]) | (layer_data_b[5][10] & carry_bit_layer_adder[5][9]); // calculation of carry bit of adder
assign result_layer_adder[5][11] = layer_data_a[5][11] ^ layer_data_b[5][11] ^ carry_bit_layer_adder[5][10]; // calculation of add result
assign carry_bit_layer_adder[5][11] = (layer_data_a[5][11] & layer_data_b[5][11]) | (layer_data_a[5][11] & carry_bit_layer_adder[5][10]) | (layer_data_b[5][11] & carry_bit_layer_adder[5][10]); // calculation of carry bit of adder
assign result_layer_adder[5][12] = layer_data_a[5][12] ^ layer_data_b[5][12] ^ carry_bit_layer_adder[5][11]; // calculation of add result
assign carry_bit_layer_adder[5][12] = (layer_data_a[5][12] & layer_data_b[5][12]) | (layer_data_a[5][12] & carry_bit_layer_adder[5][11]) | (layer_data_b[5][12] & carry_bit_layer_adder[5][11]); // calculation of carry bit of adder
assign result_layer_adder[5][13] = layer_data_a[5][13] ^ layer_data_b[5][13] ^ carry_bit_layer_adder[5][12]; // calculation of add result
assign carry_bit_layer_adder[5][13] = (layer_data_a[5][13] & layer_data_b[5][13]) | (layer_data_a[5][13] & carry_bit_layer_adder[5][12]) | (layer_data_b[5][13] & carry_bit_layer_adder[5][12]); // calculation of carry bit of adder
assign result_layer_adder[5][14] = layer_data_a[5][14] ^ layer_data_b[5][14] ^ carry_bit_layer_adder[5][13]; // calculation of add result
assign carry_bit_layer_adder[5][14] = (layer_data_a[5][14] & layer_data_b[5][14]) | (layer_data_a[5][14] & carry_bit_layer_adder[5][13]) | (layer_data_b[5][14] & carry_bit_layer_adder[5][13]); // calculation of carry bit of adder
assign result_layer_adder[5][15] = layer_data_a[5][15] ^ layer_data_b[5][15] ^ carry_bit_layer_adder[5][14]; // calculation of add result
assign carry_bit_layer_adder[5][15] = (layer_data_a[5][15] & layer_data_b[5][15]) | (layer_data_a[5][15] & carry_bit_layer_adder[5][14]) | (layer_data_b[5][15] & carry_bit_layer_adder[5][14]); // calculation of carry bit of adder
assign result_layer_adder[5][16] = layer_data_a[5][16] ^ layer_data_b[5][16] ^ carry_bit_layer_adder[5][15]; // calculation of add result
assign carry_bit_layer_adder[5][16] = (layer_data_a[5][16] & layer_data_b[5][16]) | (layer_data_a[5][16] & carry_bit_layer_adder[5][15]) | (layer_data_b[5][16] & carry_bit_layer_adder[5][15]); // calculation of carry bit of adder
assign result_layer_adder[5][17] = layer_data_a[5][17] ^ layer_data_b[5][17] ^ carry_bit_layer_adder[5][16]; // calculation of add result
assign carry_bit_layer_adder[5][17] = (layer_data_a[5][17] & layer_data_b[5][17]) | (layer_data_a[5][17] & carry_bit_layer_adder[5][16]) | (layer_data_b[5][17] & carry_bit_layer_adder[5][16]); // calculation of carry bit of adder
assign result_layer_adder[5][18] = layer_data_a[5][18] ^ layer_data_b[5][18] ^ carry_bit_layer_adder[5][17]; // calculation of add result
assign carry_bit_layer_adder[5][18] = (layer_data_a[5][18] & layer_data_b[5][18]) | (layer_data_a[5][18] & carry_bit_layer_adder[5][17]) | (layer_data_b[5][18] & carry_bit_layer_adder[5][17]); // calculation of carry bit of adder
assign result_layer_adder[5][19] = layer_data_a[5][19] ^ layer_data_b[5][19] ^ carry_bit_layer_adder[5][18]; // calculation of add result
assign carry_bit_layer_adder[5][19] = (layer_data_a[5][19] & layer_data_b[5][19]) | (layer_data_a[5][19] & carry_bit_layer_adder[5][18]) | (layer_data_b[5][19] & carry_bit_layer_adder[5][18]); // calculation of carry bit of adder
assign result_layer_adder[5][20] = layer_data_a[5][20] ^ layer_data_b[5][20] ^ carry_bit_layer_adder[5][19]; // calculation of add result
assign carry_bit_layer_adder[5][20] = (layer_data_a[5][20] & layer_data_b[5][20]) | (layer_data_a[5][20] & carry_bit_layer_adder[5][19]) | (layer_data_b[5][20] & carry_bit_layer_adder[5][19]); // calculation of carry bit of adder
assign result_layer_adder[5][21] = layer_data_a[5][21] ^ layer_data_b[5][21] ^ carry_bit_layer_adder[5][20]; // calculation of add result
assign carry_bit_layer_adder[5][21] = (layer_data_a[5][21] & layer_data_b[5][21]) | (layer_data_a[5][21] & carry_bit_layer_adder[5][20]) | (layer_data_b[5][21] & carry_bit_layer_adder[5][20]); // calculation of carry bit of adder
assign result_layer_adder[5][22] = layer_data_a[5][22] ^ layer_data_b[5][22] ^ carry_bit_layer_adder[5][21]; // calculation of add result
assign carry_bit_layer_adder[5][22] = (layer_data_a[5][22] & layer_data_b[5][22]) | (layer_data_a[5][22] & carry_bit_layer_adder[5][21]) | (layer_data_b[5][22] & carry_bit_layer_adder[5][21]); // calculation of carry bit of adder
assign result_layer_adder[5][23] = layer_data_a[5][23] ^ layer_data_b[5][23] ^ carry_bit_layer_adder[5][22]; // calculation of add result
assign carry_bit_layer_adder[5][23] = (layer_data_a[5][23] & layer_data_b[5][23]) | (layer_data_a[5][23] & carry_bit_layer_adder[5][22]) | (layer_data_b[5][23] & carry_bit_layer_adder[5][22]); // calculation of carry bit of adder
assign result_layer_adder[5][24] = layer_data_a[5][24] ^ layer_data_b[5][24] ^ carry_bit_layer_adder[5][23]; // calculation of add result
assign carry_bit_layer_adder[5][24] = (layer_data_a[5][24] & layer_data_b[5][24]) | (layer_data_a[5][24] & carry_bit_layer_adder[5][23]) | (layer_data_b[5][24] & carry_bit_layer_adder[5][23]); // calculation of carry bit of adder
assign result_layer_adder[5][25] = layer_data_a[5][25] ^ layer_data_b[5][25] ^ carry_bit_layer_adder[5][24]; // calculation of add result
assign carry_bit_layer_adder[5][25] = (layer_data_a[5][25] & layer_data_b[5][25]) | (layer_data_a[5][25] & carry_bit_layer_adder[5][24]) | (layer_data_b[5][25] & carry_bit_layer_adder[5][24]); // calculation of carry bit of adder
assign result_layer_adder[5][26] = layer_data_a[5][26] ^ layer_data_b[5][26] ^ carry_bit_layer_adder[5][25]; // calculation of add result
assign carry_bit_layer_adder[5][26] = (layer_data_a[5][26] & layer_data_b[5][26]) | (layer_data_a[5][26] & carry_bit_layer_adder[5][25]) | (layer_data_b[5][26] & carry_bit_layer_adder[5][25]); // calculation of carry bit of adder
assign result_layer_adder[5][27] = layer_data_a[5][27] ^ layer_data_b[5][27] ^ carry_bit_layer_adder[5][26]; // calculation of add result
assign carry_bit_layer_adder[5][27] = (layer_data_a[5][27] & layer_data_b[5][27]) | (layer_data_a[5][27] & carry_bit_layer_adder[5][26]) | (layer_data_b[5][27] & carry_bit_layer_adder[5][26]); // calculation of carry bit of adder
assign result_layer_adder[5][28] = layer_data_a[5][28] ^ layer_data_b[5][28] ^ carry_bit_layer_adder[5][27]; // calculation of add result
assign carry_bit_layer_adder[5][28] = (layer_data_a[5][28] & layer_data_b[5][28]) | (layer_data_a[5][28] & carry_bit_layer_adder[5][27]) | (layer_data_b[5][28] & carry_bit_layer_adder[5][27]); // calculation of carry bit of adder
assign result_layer_adder[5][29] = layer_data_a[5][29] ^ layer_data_b[5][29] ^ carry_bit_layer_adder[5][28]; // calculation of add result
assign carry_bit_layer_adder[5][29] = (layer_data_a[5][29] & layer_data_b[5][29]) | (layer_data_a[5][29] & carry_bit_layer_adder[5][28]) | (layer_data_b[5][29] & carry_bit_layer_adder[5][28]); // calculation of carry bit of adder
assign result_layer_adder[5][30] = layer_data_a[5][30] ^ layer_data_b[5][30] ^ carry_bit_layer_adder[5][29]; // calculation of add result
assign carry_bit_layer_adder[5][30] = (layer_data_a[5][30] & layer_data_b[5][30]) | (layer_data_a[5][30] & carry_bit_layer_adder[5][29]) | (layer_data_b[5][30] & carry_bit_layer_adder[5][29]); // calculation of carry bit of adder
assign result_layer_adder[5][31] = layer_data_a[5][31] ^ layer_data_b[5][31] ^ carry_bit_layer_adder[5][30]; // calculation of add result
assign carry_bit_layer_adder[5][31] = (layer_data_a[5][31] & layer_data_b[5][31]) | (layer_data_a[5][31] & carry_bit_layer_adder[5][30]) | (layer_data_b[5][31] & carry_bit_layer_adder[5][30]); // calculation of carry bit of adder
assign result_layer_adder[5][32] = layer_data_a[5][32] ^ layer_data_b[5][32] ^ carry_bit_layer_adder[5][31]; // calculation of add result

// Layer 7
assign layer_data_a[6][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[5][32] == 1'b1) ? {layer_data_a[5][31:0], operand_a[26]} : {result_layer_adder[5][31:0], operand_a[26]}) : {1'b0, result_layer_adder[5][32:1]}; // data select for layer 7
assign layer_data_b[6][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[6] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 7

// Layer 7 adder
assign result_layer_adder[6][0] = layer_data_a[6][0] ^ layer_data_b[6][0]; // calculation of add result
assign carry_bit_layer_adder[6][0] = layer_data_a[6][0] & layer_data_b[6][0]; // calculation of carry bit of adder
assign result_layer_adder[6][1] = layer_data_a[6][1] ^ layer_data_b[6][1] ^ carry_bit_layer_adder[6][0]; // calculation of add result
assign carry_bit_layer_adder[6][1] = (layer_data_a[6][1] & layer_data_b[6][1]) | (layer_data_a[6][1] & carry_bit_layer_adder[6][0]) | (layer_data_b[6][1] & carry_bit_layer_adder[6][0]); // calculation of carry bit of adder
assign result_layer_adder[6][2] = layer_data_a[6][2] ^ layer_data_b[6][2] ^ carry_bit_layer_adder[6][1]; // calculation of add result
assign carry_bit_layer_adder[6][2] = (layer_data_a[6][2] & layer_data_b[6][2]) | (layer_data_a[6][2] & carry_bit_layer_adder[6][1]) | (layer_data_b[6][2] & carry_bit_layer_adder[6][1]); // calculation of carry bit of adder
assign result_layer_adder[6][3] = layer_data_a[6][3] ^ layer_data_b[6][3] ^ carry_bit_layer_adder[6][2]; // calculation of add result
assign carry_bit_layer_adder[6][3] = (layer_data_a[6][3] & layer_data_b[6][3]) | (layer_data_a[6][3] & carry_bit_layer_adder[6][2]) | (layer_data_b[6][3] & carry_bit_layer_adder[6][2]); // calculation of carry bit of adder
assign result_layer_adder[6][4] = layer_data_a[6][4] ^ layer_data_b[6][4] ^ carry_bit_layer_adder[6][3]; // calculation of add result
assign carry_bit_layer_adder[6][4] = (layer_data_a[6][4] & layer_data_b[6][4]) | (layer_data_a[6][4] & carry_bit_layer_adder[6][3]) | (layer_data_b[6][4] & carry_bit_layer_adder[6][3]); // calculation of carry bit of adder
assign result_layer_adder[6][5] = layer_data_a[6][5] ^ layer_data_b[6][5] ^ carry_bit_layer_adder[6][4]; // calculation of add result
assign carry_bit_layer_adder[6][5] = (layer_data_a[6][5] & layer_data_b[6][5]) | (layer_data_a[6][5] & carry_bit_layer_adder[6][4]) | (layer_data_b[6][5] & carry_bit_layer_adder[6][4]); // calculation of carry bit of adder
assign result_layer_adder[6][6] = layer_data_a[6][6] ^ layer_data_b[6][6] ^ carry_bit_layer_adder[6][5]; // calculation of add result
assign carry_bit_layer_adder[6][6] = (layer_data_a[6][6] & layer_data_b[6][6]) | (layer_data_a[6][6] & carry_bit_layer_adder[6][5]) | (layer_data_b[6][6] & carry_bit_layer_adder[6][5]); // calculation of carry bit of adder
assign result_layer_adder[6][7] = layer_data_a[6][7] ^ layer_data_b[6][7] ^ carry_bit_layer_adder[6][6]; // calculation of add result
assign carry_bit_layer_adder[6][7] = (layer_data_a[6][7] & layer_data_b[6][7]) | (layer_data_a[6][7] & carry_bit_layer_adder[6][6]) | (layer_data_b[6][7] & carry_bit_layer_adder[6][6]); // calculation of carry bit of adder
assign result_layer_adder[6][8] = layer_data_a[6][8] ^ layer_data_b[6][8] ^ carry_bit_layer_adder[6][7]; // calculation of add result
assign carry_bit_layer_adder[6][8] = (layer_data_a[6][8] & layer_data_b[6][8]) | (layer_data_a[6][8] & carry_bit_layer_adder[6][7]) | (layer_data_b[6][8] & carry_bit_layer_adder[6][7]); // calculation of carry bit of adder
assign result_layer_adder[6][9] = layer_data_a[6][9] ^ layer_data_b[6][9] ^ carry_bit_layer_adder[6][8]; // calculation of add result
assign carry_bit_layer_adder[6][9] = (layer_data_a[6][9] & layer_data_b[6][9]) | (layer_data_a[6][9] & carry_bit_layer_adder[6][8]) | (layer_data_b[6][9] & carry_bit_layer_adder[6][8]); // calculation of carry bit of adder
assign result_layer_adder[6][10] = layer_data_a[6][10] ^ layer_data_b[6][10] ^ carry_bit_layer_adder[6][9]; // calculation of add result
assign carry_bit_layer_adder[6][10] = (layer_data_a[6][10] & layer_data_b[6][10]) | (layer_data_a[6][10] & carry_bit_layer_adder[6][9]) | (layer_data_b[6][10] & carry_bit_layer_adder[6][9]); // calculation of carry bit of adder
assign result_layer_adder[6][11] = layer_data_a[6][11] ^ layer_data_b[6][11] ^ carry_bit_layer_adder[6][10]; // calculation of add result
assign carry_bit_layer_adder[6][11] = (layer_data_a[6][11] & layer_data_b[6][11]) | (layer_data_a[6][11] & carry_bit_layer_adder[6][10]) | (layer_data_b[6][11] & carry_bit_layer_adder[6][10]); // calculation of carry bit of adder
assign result_layer_adder[6][12] = layer_data_a[6][12] ^ layer_data_b[6][12] ^ carry_bit_layer_adder[6][11]; // calculation of add result
assign carry_bit_layer_adder[6][12] = (layer_data_a[6][12] & layer_data_b[6][12]) | (layer_data_a[6][12] & carry_bit_layer_adder[6][11]) | (layer_data_b[6][12] & carry_bit_layer_adder[6][11]); // calculation of carry bit of adder
assign result_layer_adder[6][13] = layer_data_a[6][13] ^ layer_data_b[6][13] ^ carry_bit_layer_adder[6][12]; // calculation of add result
assign carry_bit_layer_adder[6][13] = (layer_data_a[6][13] & layer_data_b[6][13]) | (layer_data_a[6][13] & carry_bit_layer_adder[6][12]) | (layer_data_b[6][13] & carry_bit_layer_adder[6][12]); // calculation of carry bit of adder
assign result_layer_adder[6][14] = layer_data_a[6][14] ^ layer_data_b[6][14] ^ carry_bit_layer_adder[6][13]; // calculation of add result
assign carry_bit_layer_adder[6][14] = (layer_data_a[6][14] & layer_data_b[6][14]) | (layer_data_a[6][14] & carry_bit_layer_adder[6][13]) | (layer_data_b[6][14] & carry_bit_layer_adder[6][13]); // calculation of carry bit of adder
assign result_layer_adder[6][15] = layer_data_a[6][15] ^ layer_data_b[6][15] ^ carry_bit_layer_adder[6][14]; // calculation of add result
assign carry_bit_layer_adder[6][15] = (layer_data_a[6][15] & layer_data_b[6][15]) | (layer_data_a[6][15] & carry_bit_layer_adder[6][14]) | (layer_data_b[6][15] & carry_bit_layer_adder[6][14]); // calculation of carry bit of adder
assign result_layer_adder[6][16] = layer_data_a[6][16] ^ layer_data_b[6][16] ^ carry_bit_layer_adder[6][15]; // calculation of add result
assign carry_bit_layer_adder[6][16] = (layer_data_a[6][16] & layer_data_b[6][16]) | (layer_data_a[6][16] & carry_bit_layer_adder[6][15]) | (layer_data_b[6][16] & carry_bit_layer_adder[6][15]); // calculation of carry bit of adder
assign result_layer_adder[6][17] = layer_data_a[6][17] ^ layer_data_b[6][17] ^ carry_bit_layer_adder[6][16]; // calculation of add result
assign carry_bit_layer_adder[6][17] = (layer_data_a[6][17] & layer_data_b[6][17]) | (layer_data_a[6][17] & carry_bit_layer_adder[6][16]) | (layer_data_b[6][17] & carry_bit_layer_adder[6][16]); // calculation of carry bit of adder
assign result_layer_adder[6][18] = layer_data_a[6][18] ^ layer_data_b[6][18] ^ carry_bit_layer_adder[6][17]; // calculation of add result
assign carry_bit_layer_adder[6][18] = (layer_data_a[6][18] & layer_data_b[6][18]) | (layer_data_a[6][18] & carry_bit_layer_adder[6][17]) | (layer_data_b[6][18] & carry_bit_layer_adder[6][17]); // calculation of carry bit of adder
assign result_layer_adder[6][19] = layer_data_a[6][19] ^ layer_data_b[6][19] ^ carry_bit_layer_adder[6][18]; // calculation of add result
assign carry_bit_layer_adder[6][19] = (layer_data_a[6][19] & layer_data_b[6][19]) | (layer_data_a[6][19] & carry_bit_layer_adder[6][18]) | (layer_data_b[6][19] & carry_bit_layer_adder[6][18]); // calculation of carry bit of adder
assign result_layer_adder[6][20] = layer_data_a[6][20] ^ layer_data_b[6][20] ^ carry_bit_layer_adder[6][19]; // calculation of add result
assign carry_bit_layer_adder[6][20] = (layer_data_a[6][20] & layer_data_b[6][20]) | (layer_data_a[6][20] & carry_bit_layer_adder[6][19]) | (layer_data_b[6][20] & carry_bit_layer_adder[6][19]); // calculation of carry bit of adder
assign result_layer_adder[6][21] = layer_data_a[6][21] ^ layer_data_b[6][21] ^ carry_bit_layer_adder[6][20]; // calculation of add result
assign carry_bit_layer_adder[6][21] = (layer_data_a[6][21] & layer_data_b[6][21]) | (layer_data_a[6][21] & carry_bit_layer_adder[6][20]) | (layer_data_b[6][21] & carry_bit_layer_adder[6][20]); // calculation of carry bit of adder
assign result_layer_adder[6][22] = layer_data_a[6][22] ^ layer_data_b[6][22] ^ carry_bit_layer_adder[6][21]; // calculation of add result
assign carry_bit_layer_adder[6][22] = (layer_data_a[6][22] & layer_data_b[6][22]) | (layer_data_a[6][22] & carry_bit_layer_adder[6][21]) | (layer_data_b[6][22] & carry_bit_layer_adder[6][21]); // calculation of carry bit of adder
assign result_layer_adder[6][23] = layer_data_a[6][23] ^ layer_data_b[6][23] ^ carry_bit_layer_adder[6][22]; // calculation of add result
assign carry_bit_layer_adder[6][23] = (layer_data_a[6][23] & layer_data_b[6][23]) | (layer_data_a[6][23] & carry_bit_layer_adder[6][22]) | (layer_data_b[6][23] & carry_bit_layer_adder[6][22]); // calculation of carry bit of adder
assign result_layer_adder[6][24] = layer_data_a[6][24] ^ layer_data_b[6][24] ^ carry_bit_layer_adder[6][23]; // calculation of add result
assign carry_bit_layer_adder[6][24] = (layer_data_a[6][24] & layer_data_b[6][24]) | (layer_data_a[6][24] & carry_bit_layer_adder[6][23]) | (layer_data_b[6][24] & carry_bit_layer_adder[6][23]); // calculation of carry bit of adder
assign result_layer_adder[6][25] = layer_data_a[6][25] ^ layer_data_b[6][25] ^ carry_bit_layer_adder[6][24]; // calculation of add result
assign carry_bit_layer_adder[6][25] = (layer_data_a[6][25] & layer_data_b[6][25]) | (layer_data_a[6][25] & carry_bit_layer_adder[6][24]) | (layer_data_b[6][25] & carry_bit_layer_adder[6][24]); // calculation of carry bit of adder
assign result_layer_adder[6][26] = layer_data_a[6][26] ^ layer_data_b[6][26] ^ carry_bit_layer_adder[6][25]; // calculation of add result
assign carry_bit_layer_adder[6][26] = (layer_data_a[6][26] & layer_data_b[6][26]) | (layer_data_a[6][26] & carry_bit_layer_adder[6][25]) | (layer_data_b[6][26] & carry_bit_layer_adder[6][25]); // calculation of carry bit of adder
assign result_layer_adder[6][27] = layer_data_a[6][27] ^ layer_data_b[6][27] ^ carry_bit_layer_adder[6][26]; // calculation of add result
assign carry_bit_layer_adder[6][27] = (layer_data_a[6][27] & layer_data_b[6][27]) | (layer_data_a[6][27] & carry_bit_layer_adder[6][26]) | (layer_data_b[6][27] & carry_bit_layer_adder[6][26]); // calculation of carry bit of adder
assign result_layer_adder[6][28] = layer_data_a[6][28] ^ layer_data_b[6][28] ^ carry_bit_layer_adder[6][27]; // calculation of add result
assign carry_bit_layer_adder[6][28] = (layer_data_a[6][28] & layer_data_b[6][28]) | (layer_data_a[6][28] & carry_bit_layer_adder[6][27]) | (layer_data_b[6][28] & carry_bit_layer_adder[6][27]); // calculation of carry bit of adder
assign result_layer_adder[6][29] = layer_data_a[6][29] ^ layer_data_b[6][29] ^ carry_bit_layer_adder[6][28]; // calculation of add result
assign carry_bit_layer_adder[6][29] = (layer_data_a[6][29] & layer_data_b[6][29]) | (layer_data_a[6][29] & carry_bit_layer_adder[6][28]) | (layer_data_b[6][29] & carry_bit_layer_adder[6][28]); // calculation of carry bit of adder
assign result_layer_adder[6][30] = layer_data_a[6][30] ^ layer_data_b[6][30] ^ carry_bit_layer_adder[6][29]; // calculation of add result
assign carry_bit_layer_adder[6][30] = (layer_data_a[6][30] & layer_data_b[6][30]) | (layer_data_a[6][30] & carry_bit_layer_adder[6][29]) | (layer_data_b[6][30] & carry_bit_layer_adder[6][29]); // calculation of carry bit of adder
assign result_layer_adder[6][31] = layer_data_a[6][31] ^ layer_data_b[6][31] ^ carry_bit_layer_adder[6][30]; // calculation of add result
assign carry_bit_layer_adder[6][31] = (layer_data_a[6][31] & layer_data_b[6][31]) | (layer_data_a[6][31] & carry_bit_layer_adder[6][30]) | (layer_data_b[6][31] & carry_bit_layer_adder[6][30]); // calculation of carry bit of adder
assign result_layer_adder[6][32] = layer_data_a[6][32] ^ layer_data_b[6][32] ^ carry_bit_layer_adder[6][31]; // calculation of add result

// Layer 8
assign layer_data_a[7][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[6][32] == 1'b1) ? {layer_data_a[6][31:0], operand_a[25]} : {result_layer_adder[6][31:0], operand_a[25]}) : {1'b0, result_layer_adder[6][32:1]}; // data select for layer 8
assign layer_data_b[7][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[7] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 8

// Layer 8 adder
assign result_layer_adder[7][0] = layer_data_a[7][0] ^ layer_data_b[7][0]; // calculation of add result
assign carry_bit_layer_adder[7][0] = layer_data_a[7][0] & layer_data_b[7][0]; // calculation of carry bit of adder
assign result_layer_adder[7][1] = layer_data_a[7][1] ^ layer_data_b[7][1] ^ carry_bit_layer_adder[7][0]; // calculation of add result
assign carry_bit_layer_adder[7][1] = (layer_data_a[7][1] & layer_data_b[7][1]) | (layer_data_a[7][1] & carry_bit_layer_adder[7][0]) | (layer_data_b[7][1] & carry_bit_layer_adder[7][0]); // calculation of carry bit of adder
assign result_layer_adder[7][2] = layer_data_a[7][2] ^ layer_data_b[7][2] ^ carry_bit_layer_adder[7][1]; // calculation of add result
assign carry_bit_layer_adder[7][2] = (layer_data_a[7][2] & layer_data_b[7][2]) | (layer_data_a[7][2] & carry_bit_layer_adder[7][1]) | (layer_data_b[7][2] & carry_bit_layer_adder[7][1]); // calculation of carry bit of adder
assign result_layer_adder[7][3] = layer_data_a[7][3] ^ layer_data_b[7][3] ^ carry_bit_layer_adder[7][2]; // calculation of add result
assign carry_bit_layer_adder[7][3] = (layer_data_a[7][3] & layer_data_b[7][3]) | (layer_data_a[7][3] & carry_bit_layer_adder[7][2]) | (layer_data_b[7][3] & carry_bit_layer_adder[7][2]); // calculation of carry bit of adder
assign result_layer_adder[7][4] = layer_data_a[7][4] ^ layer_data_b[7][4] ^ carry_bit_layer_adder[7][3]; // calculation of add result
assign carry_bit_layer_adder[7][4] = (layer_data_a[7][4] & layer_data_b[7][4]) | (layer_data_a[7][4] & carry_bit_layer_adder[7][3]) | (layer_data_b[7][4] & carry_bit_layer_adder[7][3]); // calculation of carry bit of adder
assign result_layer_adder[7][5] = layer_data_a[7][5] ^ layer_data_b[7][5] ^ carry_bit_layer_adder[7][4]; // calculation of add result
assign carry_bit_layer_adder[7][5] = (layer_data_a[7][5] & layer_data_b[7][5]) | (layer_data_a[7][5] & carry_bit_layer_adder[7][4]) | (layer_data_b[7][5] & carry_bit_layer_adder[7][4]); // calculation of carry bit of adder
assign result_layer_adder[7][6] = layer_data_a[7][6] ^ layer_data_b[7][6] ^ carry_bit_layer_adder[7][5]; // calculation of add result
assign carry_bit_layer_adder[7][6] = (layer_data_a[7][6] & layer_data_b[7][6]) | (layer_data_a[7][6] & carry_bit_layer_adder[7][5]) | (layer_data_b[7][6] & carry_bit_layer_adder[7][5]); // calculation of carry bit of adder
assign result_layer_adder[7][7] = layer_data_a[7][7] ^ layer_data_b[7][7] ^ carry_bit_layer_adder[7][6]; // calculation of add result
assign carry_bit_layer_adder[7][7] = (layer_data_a[7][7] & layer_data_b[7][7]) | (layer_data_a[7][7] & carry_bit_layer_adder[7][6]) | (layer_data_b[7][7] & carry_bit_layer_adder[7][6]); // calculation of carry bit of adder
assign result_layer_adder[7][8] = layer_data_a[7][8] ^ layer_data_b[7][8] ^ carry_bit_layer_adder[7][7]; // calculation of add result
assign carry_bit_layer_adder[7][8] = (layer_data_a[7][8] & layer_data_b[7][8]) | (layer_data_a[7][8] & carry_bit_layer_adder[7][7]) | (layer_data_b[7][8] & carry_bit_layer_adder[7][7]); // calculation of carry bit of adder
assign result_layer_adder[7][9] = layer_data_a[7][9] ^ layer_data_b[7][9] ^ carry_bit_layer_adder[7][8]; // calculation of add result
assign carry_bit_layer_adder[7][9] = (layer_data_a[7][9] & layer_data_b[7][9]) | (layer_data_a[7][9] & carry_bit_layer_adder[7][8]) | (layer_data_b[7][9] & carry_bit_layer_adder[7][8]); // calculation of carry bit of adder
assign result_layer_adder[7][10] = layer_data_a[7][10] ^ layer_data_b[7][10] ^ carry_bit_layer_adder[7][9]; // calculation of add result
assign carry_bit_layer_adder[7][10] = (layer_data_a[7][10] & layer_data_b[7][10]) | (layer_data_a[7][10] & carry_bit_layer_adder[7][9]) | (layer_data_b[7][10] & carry_bit_layer_adder[7][9]); // calculation of carry bit of adder
assign result_layer_adder[7][11] = layer_data_a[7][11] ^ layer_data_b[7][11] ^ carry_bit_layer_adder[7][10]; // calculation of add result
assign carry_bit_layer_adder[7][11] = (layer_data_a[7][11] & layer_data_b[7][11]) | (layer_data_a[7][11] & carry_bit_layer_adder[7][10]) | (layer_data_b[7][11] & carry_bit_layer_adder[7][10]); // calculation of carry bit of adder
assign result_layer_adder[7][12] = layer_data_a[7][12] ^ layer_data_b[7][12] ^ carry_bit_layer_adder[7][11]; // calculation of add result
assign carry_bit_layer_adder[7][12] = (layer_data_a[7][12] & layer_data_b[7][12]) | (layer_data_a[7][12] & carry_bit_layer_adder[7][11]) | (layer_data_b[7][12] & carry_bit_layer_adder[7][11]); // calculation of carry bit of adder
assign result_layer_adder[7][13] = layer_data_a[7][13] ^ layer_data_b[7][13] ^ carry_bit_layer_adder[7][12]; // calculation of add result
assign carry_bit_layer_adder[7][13] = (layer_data_a[7][13] & layer_data_b[7][13]) | (layer_data_a[7][13] & carry_bit_layer_adder[7][12]) | (layer_data_b[7][13] & carry_bit_layer_adder[7][12]); // calculation of carry bit of adder
assign result_layer_adder[7][14] = layer_data_a[7][14] ^ layer_data_b[7][14] ^ carry_bit_layer_adder[7][13]; // calculation of add result
assign carry_bit_layer_adder[7][14] = (layer_data_a[7][14] & layer_data_b[7][14]) | (layer_data_a[7][14] & carry_bit_layer_adder[7][13]) | (layer_data_b[7][14] & carry_bit_layer_adder[7][13]); // calculation of carry bit of adder
assign result_layer_adder[7][15] = layer_data_a[7][15] ^ layer_data_b[7][15] ^ carry_bit_layer_adder[7][14]; // calculation of add result
assign carry_bit_layer_adder[7][15] = (layer_data_a[7][15] & layer_data_b[7][15]) | (layer_data_a[7][15] & carry_bit_layer_adder[7][14]) | (layer_data_b[7][15] & carry_bit_layer_adder[7][14]); // calculation of carry bit of adder
assign result_layer_adder[7][16] = layer_data_a[7][16] ^ layer_data_b[7][16] ^ carry_bit_layer_adder[7][15]; // calculation of add result
assign carry_bit_layer_adder[7][16] = (layer_data_a[7][16] & layer_data_b[7][16]) | (layer_data_a[7][16] & carry_bit_layer_adder[7][15]) | (layer_data_b[7][16] & carry_bit_layer_adder[7][15]); // calculation of carry bit of adder
assign result_layer_adder[7][17] = layer_data_a[7][17] ^ layer_data_b[7][17] ^ carry_bit_layer_adder[7][16]; // calculation of add result
assign carry_bit_layer_adder[7][17] = (layer_data_a[7][17] & layer_data_b[7][17]) | (layer_data_a[7][17] & carry_bit_layer_adder[7][16]) | (layer_data_b[7][17] & carry_bit_layer_adder[7][16]); // calculation of carry bit of adder
assign result_layer_adder[7][18] = layer_data_a[7][18] ^ layer_data_b[7][18] ^ carry_bit_layer_adder[7][17]; // calculation of add result
assign carry_bit_layer_adder[7][18] = (layer_data_a[7][18] & layer_data_b[7][18]) | (layer_data_a[7][18] & carry_bit_layer_adder[7][17]) | (layer_data_b[7][18] & carry_bit_layer_adder[7][17]); // calculation of carry bit of adder
assign result_layer_adder[7][19] = layer_data_a[7][19] ^ layer_data_b[7][19] ^ carry_bit_layer_adder[7][18]; // calculation of add result
assign carry_bit_layer_adder[7][19] = (layer_data_a[7][19] & layer_data_b[7][19]) | (layer_data_a[7][19] & carry_bit_layer_adder[7][18]) | (layer_data_b[7][19] & carry_bit_layer_adder[7][18]); // calculation of carry bit of adder
assign result_layer_adder[7][20] = layer_data_a[7][20] ^ layer_data_b[7][20] ^ carry_bit_layer_adder[7][19]; // calculation of add result
assign carry_bit_layer_adder[7][20] = (layer_data_a[7][20] & layer_data_b[7][20]) | (layer_data_a[7][20] & carry_bit_layer_adder[7][19]) | (layer_data_b[7][20] & carry_bit_layer_adder[7][19]); // calculation of carry bit of adder
assign result_layer_adder[7][21] = layer_data_a[7][21] ^ layer_data_b[7][21] ^ carry_bit_layer_adder[7][20]; // calculation of add result
assign carry_bit_layer_adder[7][21] = (layer_data_a[7][21] & layer_data_b[7][21]) | (layer_data_a[7][21] & carry_bit_layer_adder[7][20]) | (layer_data_b[7][21] & carry_bit_layer_adder[7][20]); // calculation of carry bit of adder
assign result_layer_adder[7][22] = layer_data_a[7][22] ^ layer_data_b[7][22] ^ carry_bit_layer_adder[7][21]; // calculation of add result
assign carry_bit_layer_adder[7][22] = (layer_data_a[7][22] & layer_data_b[7][22]) | (layer_data_a[7][22] & carry_bit_layer_adder[7][21]) | (layer_data_b[7][22] & carry_bit_layer_adder[7][21]); // calculation of carry bit of adder
assign result_layer_adder[7][23] = layer_data_a[7][23] ^ layer_data_b[7][23] ^ carry_bit_layer_adder[7][22]; // calculation of add result
assign carry_bit_layer_adder[7][23] = (layer_data_a[7][23] & layer_data_b[7][23]) | (layer_data_a[7][23] & carry_bit_layer_adder[7][22]) | (layer_data_b[7][23] & carry_bit_layer_adder[7][22]); // calculation of carry bit of adder
assign result_layer_adder[7][24] = layer_data_a[7][24] ^ layer_data_b[7][24] ^ carry_bit_layer_adder[7][23]; // calculation of add result
assign carry_bit_layer_adder[7][24] = (layer_data_a[7][24] & layer_data_b[7][24]) | (layer_data_a[7][24] & carry_bit_layer_adder[7][23]) | (layer_data_b[7][24] & carry_bit_layer_adder[7][23]); // calculation of carry bit of adder
assign result_layer_adder[7][25] = layer_data_a[7][25] ^ layer_data_b[7][25] ^ carry_bit_layer_adder[7][24]; // calculation of add result
assign carry_bit_layer_adder[7][25] = (layer_data_a[7][25] & layer_data_b[7][25]) | (layer_data_a[7][25] & carry_bit_layer_adder[7][24]) | (layer_data_b[7][25] & carry_bit_layer_adder[7][24]); // calculation of carry bit of adder
assign result_layer_adder[7][26] = layer_data_a[7][26] ^ layer_data_b[7][26] ^ carry_bit_layer_adder[7][25]; // calculation of add result
assign carry_bit_layer_adder[7][26] = (layer_data_a[7][26] & layer_data_b[7][26]) | (layer_data_a[7][26] & carry_bit_layer_adder[7][25]) | (layer_data_b[7][26] & carry_bit_layer_adder[7][25]); // calculation of carry bit of adder
assign result_layer_adder[7][27] = layer_data_a[7][27] ^ layer_data_b[7][27] ^ carry_bit_layer_adder[7][26]; // calculation of add result
assign carry_bit_layer_adder[7][27] = (layer_data_a[7][27] & layer_data_b[7][27]) | (layer_data_a[7][27] & carry_bit_layer_adder[7][26]) | (layer_data_b[7][27] & carry_bit_layer_adder[7][26]); // calculation of carry bit of adder
assign result_layer_adder[7][28] = layer_data_a[7][28] ^ layer_data_b[7][28] ^ carry_bit_layer_adder[7][27]; // calculation of add result
assign carry_bit_layer_adder[7][28] = (layer_data_a[7][28] & layer_data_b[7][28]) | (layer_data_a[7][28] & carry_bit_layer_adder[7][27]) | (layer_data_b[7][28] & carry_bit_layer_adder[7][27]); // calculation of carry bit of adder
assign result_layer_adder[7][29] = layer_data_a[7][29] ^ layer_data_b[7][29] ^ carry_bit_layer_adder[7][28]; // calculation of add result
assign carry_bit_layer_adder[7][29] = (layer_data_a[7][29] & layer_data_b[7][29]) | (layer_data_a[7][29] & carry_bit_layer_adder[7][28]) | (layer_data_b[7][29] & carry_bit_layer_adder[7][28]); // calculation of carry bit of adder
assign result_layer_adder[7][30] = layer_data_a[7][30] ^ layer_data_b[7][30] ^ carry_bit_layer_adder[7][29]; // calculation of add result
assign carry_bit_layer_adder[7][30] = (layer_data_a[7][30] & layer_data_b[7][30]) | (layer_data_a[7][30] & carry_bit_layer_adder[7][29]) | (layer_data_b[7][30] & carry_bit_layer_adder[7][29]); // calculation of carry bit of adder
assign result_layer_adder[7][31] = layer_data_a[7][31] ^ layer_data_b[7][31] ^ carry_bit_layer_adder[7][30]; // calculation of add result
assign carry_bit_layer_adder[7][31] = (layer_data_a[7][31] & layer_data_b[7][31]) | (layer_data_a[7][31] & carry_bit_layer_adder[7][30]) | (layer_data_b[7][31] & carry_bit_layer_adder[7][30]); // calculation of carry bit of adder
assign result_layer_adder[7][32] = layer_data_a[7][32] ^ layer_data_b[7][32] ^ carry_bit_layer_adder[7][31]; // calculation of add result

// Layer 9
assign layer_data_a[8][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[7][32] == 1'b1) ? {layer_data_a[7][31:0], operand_a[24]} : {result_layer_adder[7][31:0], operand_a[24]}) : {1'b0, result_layer_adder[7][32:1]}; // data select for layer 9
assign layer_data_b[8][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[8] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 9

// Layer 9 adder
assign result_layer_adder[8][0] = layer_data_a[8][0] ^ layer_data_b[8][0]; // calculation of add result
assign carry_bit_layer_adder[8][0] = layer_data_a[8][0] & layer_data_b[8][0]; // calculation of carry bit of adder
assign result_layer_adder[8][1] = layer_data_a[8][1] ^ layer_data_b[8][1] ^ carry_bit_layer_adder[8][0]; // calculation of add result
assign carry_bit_layer_adder[8][1] = (layer_data_a[8][1] & layer_data_b[8][1]) | (layer_data_a[8][1] & carry_bit_layer_adder[8][0]) | (layer_data_b[8][1] & carry_bit_layer_adder[8][0]); // calculation of carry bit of adder
assign result_layer_adder[8][2] = layer_data_a[8][2] ^ layer_data_b[8][2] ^ carry_bit_layer_adder[8][1]; // calculation of add result
assign carry_bit_layer_adder[8][2] = (layer_data_a[8][2] & layer_data_b[8][2]) | (layer_data_a[8][2] & carry_bit_layer_adder[8][1]) | (layer_data_b[8][2] & carry_bit_layer_adder[8][1]); // calculation of carry bit of adder
assign result_layer_adder[8][3] = layer_data_a[8][3] ^ layer_data_b[8][3] ^ carry_bit_layer_adder[8][2]; // calculation of add result
assign carry_bit_layer_adder[8][3] = (layer_data_a[8][3] & layer_data_b[8][3]) | (layer_data_a[8][3] & carry_bit_layer_adder[8][2]) | (layer_data_b[8][3] & carry_bit_layer_adder[8][2]); // calculation of carry bit of adder
assign result_layer_adder[8][4] = layer_data_a[8][4] ^ layer_data_b[8][4] ^ carry_bit_layer_adder[8][3]; // calculation of add result
assign carry_bit_layer_adder[8][4] = (layer_data_a[8][4] & layer_data_b[8][4]) | (layer_data_a[8][4] & carry_bit_layer_adder[8][3]) | (layer_data_b[8][4] & carry_bit_layer_adder[8][3]); // calculation of carry bit of adder
assign result_layer_adder[8][5] = layer_data_a[8][5] ^ layer_data_b[8][5] ^ carry_bit_layer_adder[8][4]; // calculation of add result
assign carry_bit_layer_adder[8][5] = (layer_data_a[8][5] & layer_data_b[8][5]) | (layer_data_a[8][5] & carry_bit_layer_adder[8][4]) | (layer_data_b[8][5] & carry_bit_layer_adder[8][4]); // calculation of carry bit of adder
assign result_layer_adder[8][6] = layer_data_a[8][6] ^ layer_data_b[8][6] ^ carry_bit_layer_adder[8][5]; // calculation of add result
assign carry_bit_layer_adder[8][6] = (layer_data_a[8][6] & layer_data_b[8][6]) | (layer_data_a[8][6] & carry_bit_layer_adder[8][5]) | (layer_data_b[8][6] & carry_bit_layer_adder[8][5]); // calculation of carry bit of adder
assign result_layer_adder[8][7] = layer_data_a[8][7] ^ layer_data_b[8][7] ^ carry_bit_layer_adder[8][6]; // calculation of add result
assign carry_bit_layer_adder[8][7] = (layer_data_a[8][7] & layer_data_b[8][7]) | (layer_data_a[8][7] & carry_bit_layer_adder[8][6]) | (layer_data_b[8][7] & carry_bit_layer_adder[8][6]); // calculation of carry bit of adder
assign result_layer_adder[8][8] = layer_data_a[8][8] ^ layer_data_b[8][8] ^ carry_bit_layer_adder[8][7]; // calculation of add result
assign carry_bit_layer_adder[8][8] = (layer_data_a[8][8] & layer_data_b[8][8]) | (layer_data_a[8][8] & carry_bit_layer_adder[8][7]) | (layer_data_b[8][8] & carry_bit_layer_adder[8][7]); // calculation of carry bit of adder
assign result_layer_adder[8][9] = layer_data_a[8][9] ^ layer_data_b[8][9] ^ carry_bit_layer_adder[8][8]; // calculation of add result
assign carry_bit_layer_adder[8][9] = (layer_data_a[8][9] & layer_data_b[8][9]) | (layer_data_a[8][9] & carry_bit_layer_adder[8][8]) | (layer_data_b[8][9] & carry_bit_layer_adder[8][8]); // calculation of carry bit of adder
assign result_layer_adder[8][10] = layer_data_a[8][10] ^ layer_data_b[8][10] ^ carry_bit_layer_adder[8][9]; // calculation of add result
assign carry_bit_layer_adder[8][10] = (layer_data_a[8][10] & layer_data_b[8][10]) | (layer_data_a[8][10] & carry_bit_layer_adder[8][9]) | (layer_data_b[8][10] & carry_bit_layer_adder[8][9]); // calculation of carry bit of adder
assign result_layer_adder[8][11] = layer_data_a[8][11] ^ layer_data_b[8][11] ^ carry_bit_layer_adder[8][10]; // calculation of add result
assign carry_bit_layer_adder[8][11] = (layer_data_a[8][11] & layer_data_b[8][11]) | (layer_data_a[8][11] & carry_bit_layer_adder[8][10]) | (layer_data_b[8][11] & carry_bit_layer_adder[8][10]); // calculation of carry bit of adder
assign result_layer_adder[8][12] = layer_data_a[8][12] ^ layer_data_b[8][12] ^ carry_bit_layer_adder[8][11]; // calculation of add result
assign carry_bit_layer_adder[8][12] = (layer_data_a[8][12] & layer_data_b[8][12]) | (layer_data_a[8][12] & carry_bit_layer_adder[8][11]) | (layer_data_b[8][12] & carry_bit_layer_adder[8][11]); // calculation of carry bit of adder
assign result_layer_adder[8][13] = layer_data_a[8][13] ^ layer_data_b[8][13] ^ carry_bit_layer_adder[8][12]; // calculation of add result
assign carry_bit_layer_adder[8][13] = (layer_data_a[8][13] & layer_data_b[8][13]) | (layer_data_a[8][13] & carry_bit_layer_adder[8][12]) | (layer_data_b[8][13] & carry_bit_layer_adder[8][12]); // calculation of carry bit of adder
assign result_layer_adder[8][14] = layer_data_a[8][14] ^ layer_data_b[8][14] ^ carry_bit_layer_adder[8][13]; // calculation of add result
assign carry_bit_layer_adder[8][14] = (layer_data_a[8][14] & layer_data_b[8][14]) | (layer_data_a[8][14] & carry_bit_layer_adder[8][13]) | (layer_data_b[8][14] & carry_bit_layer_adder[8][13]); // calculation of carry bit of adder
assign result_layer_adder[8][15] = layer_data_a[8][15] ^ layer_data_b[8][15] ^ carry_bit_layer_adder[8][14]; // calculation of add result
assign carry_bit_layer_adder[8][15] = (layer_data_a[8][15] & layer_data_b[8][15]) | (layer_data_a[8][15] & carry_bit_layer_adder[8][14]) | (layer_data_b[8][15] & carry_bit_layer_adder[8][14]); // calculation of carry bit of adder
assign result_layer_adder[8][16] = layer_data_a[8][16] ^ layer_data_b[8][16] ^ carry_bit_layer_adder[8][15]; // calculation of add result
assign carry_bit_layer_adder[8][16] = (layer_data_a[8][16] & layer_data_b[8][16]) | (layer_data_a[8][16] & carry_bit_layer_adder[8][15]) | (layer_data_b[8][16] & carry_bit_layer_adder[8][15]); // calculation of carry bit of adder
assign result_layer_adder[8][17] = layer_data_a[8][17] ^ layer_data_b[8][17] ^ carry_bit_layer_adder[8][16]; // calculation of add result
assign carry_bit_layer_adder[8][17] = (layer_data_a[8][17] & layer_data_b[8][17]) | (layer_data_a[8][17] & carry_bit_layer_adder[8][16]) | (layer_data_b[8][17] & carry_bit_layer_adder[8][16]); // calculation of carry bit of adder
assign result_layer_adder[8][18] = layer_data_a[8][18] ^ layer_data_b[8][18] ^ carry_bit_layer_adder[8][17]; // calculation of add result
assign carry_bit_layer_adder[8][18] = (layer_data_a[8][18] & layer_data_b[8][18]) | (layer_data_a[8][18] & carry_bit_layer_adder[8][17]) | (layer_data_b[8][18] & carry_bit_layer_adder[8][17]); // calculation of carry bit of adder
assign result_layer_adder[8][19] = layer_data_a[8][19] ^ layer_data_b[8][19] ^ carry_bit_layer_adder[8][18]; // calculation of add result
assign carry_bit_layer_adder[8][19] = (layer_data_a[8][19] & layer_data_b[8][19]) | (layer_data_a[8][19] & carry_bit_layer_adder[8][18]) | (layer_data_b[8][19] & carry_bit_layer_adder[8][18]); // calculation of carry bit of adder
assign result_layer_adder[8][20] = layer_data_a[8][20] ^ layer_data_b[8][20] ^ carry_bit_layer_adder[8][19]; // calculation of add result
assign carry_bit_layer_adder[8][20] = (layer_data_a[8][20] & layer_data_b[8][20]) | (layer_data_a[8][20] & carry_bit_layer_adder[8][19]) | (layer_data_b[8][20] & carry_bit_layer_adder[8][19]); // calculation of carry bit of adder
assign result_layer_adder[8][21] = layer_data_a[8][21] ^ layer_data_b[8][21] ^ carry_bit_layer_adder[8][20]; // calculation of add result
assign carry_bit_layer_adder[8][21] = (layer_data_a[8][21] & layer_data_b[8][21]) | (layer_data_a[8][21] & carry_bit_layer_adder[8][20]) | (layer_data_b[8][21] & carry_bit_layer_adder[8][20]); // calculation of carry bit of adder
assign result_layer_adder[8][22] = layer_data_a[8][22] ^ layer_data_b[8][22] ^ carry_bit_layer_adder[8][21]; // calculation of add result
assign carry_bit_layer_adder[8][22] = (layer_data_a[8][22] & layer_data_b[8][22]) | (layer_data_a[8][22] & carry_bit_layer_adder[8][21]) | (layer_data_b[8][22] & carry_bit_layer_adder[8][21]); // calculation of carry bit of adder
assign result_layer_adder[8][23] = layer_data_a[8][23] ^ layer_data_b[8][23] ^ carry_bit_layer_adder[8][22]; // calculation of add result
assign carry_bit_layer_adder[8][23] = (layer_data_a[8][23] & layer_data_b[8][23]) | (layer_data_a[8][23] & carry_bit_layer_adder[8][22]) | (layer_data_b[8][23] & carry_bit_layer_adder[8][22]); // calculation of carry bit of adder
assign result_layer_adder[8][24] = layer_data_a[8][24] ^ layer_data_b[8][24] ^ carry_bit_layer_adder[8][23]; // calculation of add result
assign carry_bit_layer_adder[8][24] = (layer_data_a[8][24] & layer_data_b[8][24]) | (layer_data_a[8][24] & carry_bit_layer_adder[8][23]) | (layer_data_b[8][24] & carry_bit_layer_adder[8][23]); // calculation of carry bit of adder
assign result_layer_adder[8][25] = layer_data_a[8][25] ^ layer_data_b[8][25] ^ carry_bit_layer_adder[8][24]; // calculation of add result
assign carry_bit_layer_adder[8][25] = (layer_data_a[8][25] & layer_data_b[8][25]) | (layer_data_a[8][25] & carry_bit_layer_adder[8][24]) | (layer_data_b[8][25] & carry_bit_layer_adder[8][24]); // calculation of carry bit of adder
assign result_layer_adder[8][26] = layer_data_a[8][26] ^ layer_data_b[8][26] ^ carry_bit_layer_adder[8][25]; // calculation of add result
assign carry_bit_layer_adder[8][26] = (layer_data_a[8][26] & layer_data_b[8][26]) | (layer_data_a[8][26] & carry_bit_layer_adder[8][25]) | (layer_data_b[8][26] & carry_bit_layer_adder[8][25]); // calculation of carry bit of adder
assign result_layer_adder[8][27] = layer_data_a[8][27] ^ layer_data_b[8][27] ^ carry_bit_layer_adder[8][26]; // calculation of add result
assign carry_bit_layer_adder[8][27] = (layer_data_a[8][27] & layer_data_b[8][27]) | (layer_data_a[8][27] & carry_bit_layer_adder[8][26]) | (layer_data_b[8][27] & carry_bit_layer_adder[8][26]); // calculation of carry bit of adder
assign result_layer_adder[8][28] = layer_data_a[8][28] ^ layer_data_b[8][28] ^ carry_bit_layer_adder[8][27]; // calculation of add result
assign carry_bit_layer_adder[8][28] = (layer_data_a[8][28] & layer_data_b[8][28]) | (layer_data_a[8][28] & carry_bit_layer_adder[8][27]) | (layer_data_b[8][28] & carry_bit_layer_adder[8][27]); // calculation of carry bit of adder
assign result_layer_adder[8][29] = layer_data_a[8][29] ^ layer_data_b[8][29] ^ carry_bit_layer_adder[8][28]; // calculation of add result
assign carry_bit_layer_adder[8][29] = (layer_data_a[8][29] & layer_data_b[8][29]) | (layer_data_a[8][29] & carry_bit_layer_adder[8][28]) | (layer_data_b[8][29] & carry_bit_layer_adder[8][28]); // calculation of carry bit of adder
assign result_layer_adder[8][30] = layer_data_a[8][30] ^ layer_data_b[8][30] ^ carry_bit_layer_adder[8][29]; // calculation of add result
assign carry_bit_layer_adder[8][30] = (layer_data_a[8][30] & layer_data_b[8][30]) | (layer_data_a[8][30] & carry_bit_layer_adder[8][29]) | (layer_data_b[8][30] & carry_bit_layer_adder[8][29]); // calculation of carry bit of adder
assign result_layer_adder[8][31] = layer_data_a[8][31] ^ layer_data_b[8][31] ^ carry_bit_layer_adder[8][30]; // calculation of add result
assign carry_bit_layer_adder[8][31] = (layer_data_a[8][31] & layer_data_b[8][31]) | (layer_data_a[8][31] & carry_bit_layer_adder[8][30]) | (layer_data_b[8][31] & carry_bit_layer_adder[8][30]); // calculation of carry bit of adder
assign result_layer_adder[8][32] = layer_data_a[8][32] ^ layer_data_b[8][32] ^ carry_bit_layer_adder[8][31]; // calculation of add result

// Layer 10
assign layer_data_a[9][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[8][32] == 1'b1) ? {layer_data_a[8][31:0], operand_a[23]} : {result_layer_adder[8][31:0], operand_a[23]}) : {1'b0, result_layer_adder[8][32:1]}; // data select for layer 10
assign layer_data_b[9][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[9] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 10

// Layer 10 adder
assign result_layer_adder[9][0] = layer_data_a[9][0] ^ layer_data_b[9][0]; // calculation of add result
assign carry_bit_layer_adder[9][0] = layer_data_a[9][0] & layer_data_b[9][0]; // calculation of carry bit of adder
assign result_layer_adder[9][1] = layer_data_a[9][1] ^ layer_data_b[9][1] ^ carry_bit_layer_adder[9][0]; // calculation of add result
assign carry_bit_layer_adder[9][1] = (layer_data_a[9][1] & layer_data_b[9][1]) | (layer_data_a[9][1] & carry_bit_layer_adder[9][0]) | (layer_data_b[9][1] & carry_bit_layer_adder[9][0]); // calculation of carry bit of adder
assign result_layer_adder[9][2] = layer_data_a[9][2] ^ layer_data_b[9][2] ^ carry_bit_layer_adder[9][1]; // calculation of add result
assign carry_bit_layer_adder[9][2] = (layer_data_a[9][2] & layer_data_b[9][2]) | (layer_data_a[9][2] & carry_bit_layer_adder[9][1]) | (layer_data_b[9][2] & carry_bit_layer_adder[9][1]); // calculation of carry bit of adder
assign result_layer_adder[9][3] = layer_data_a[9][3] ^ layer_data_b[9][3] ^ carry_bit_layer_adder[9][2]; // calculation of add result
assign carry_bit_layer_adder[9][3] = (layer_data_a[9][3] & layer_data_b[9][3]) | (layer_data_a[9][3] & carry_bit_layer_adder[9][2]) | (layer_data_b[9][3] & carry_bit_layer_adder[9][2]); // calculation of carry bit of adder
assign result_layer_adder[9][4] = layer_data_a[9][4] ^ layer_data_b[9][4] ^ carry_bit_layer_adder[9][3]; // calculation of add result
assign carry_bit_layer_adder[9][4] = (layer_data_a[9][4] & layer_data_b[9][4]) | (layer_data_a[9][4] & carry_bit_layer_adder[9][3]) | (layer_data_b[9][4] & carry_bit_layer_adder[9][3]); // calculation of carry bit of adder
assign result_layer_adder[9][5] = layer_data_a[9][5] ^ layer_data_b[9][5] ^ carry_bit_layer_adder[9][4]; // calculation of add result
assign carry_bit_layer_adder[9][5] = (layer_data_a[9][5] & layer_data_b[9][5]) | (layer_data_a[9][5] & carry_bit_layer_adder[9][4]) | (layer_data_b[9][5] & carry_bit_layer_adder[9][4]); // calculation of carry bit of adder
assign result_layer_adder[9][6] = layer_data_a[9][6] ^ layer_data_b[9][6] ^ carry_bit_layer_adder[9][5]; // calculation of add result
assign carry_bit_layer_adder[9][6] = (layer_data_a[9][6] & layer_data_b[9][6]) | (layer_data_a[9][6] & carry_bit_layer_adder[9][5]) | (layer_data_b[9][6] & carry_bit_layer_adder[9][5]); // calculation of carry bit of adder
assign result_layer_adder[9][7] = layer_data_a[9][7] ^ layer_data_b[9][7] ^ carry_bit_layer_adder[9][6]; // calculation of add result
assign carry_bit_layer_adder[9][7] = (layer_data_a[9][7] & layer_data_b[9][7]) | (layer_data_a[9][7] & carry_bit_layer_adder[9][6]) | (layer_data_b[9][7] & carry_bit_layer_adder[9][6]); // calculation of carry bit of adder
assign result_layer_adder[9][8] = layer_data_a[9][8] ^ layer_data_b[9][8] ^ carry_bit_layer_adder[9][7]; // calculation of add result
assign carry_bit_layer_adder[9][8] = (layer_data_a[9][8] & layer_data_b[9][8]) | (layer_data_a[9][8] & carry_bit_layer_adder[9][7]) | (layer_data_b[9][8] & carry_bit_layer_adder[9][7]); // calculation of carry bit of adder
assign result_layer_adder[9][9] = layer_data_a[9][9] ^ layer_data_b[9][9] ^ carry_bit_layer_adder[9][8]; // calculation of add result
assign carry_bit_layer_adder[9][9] = (layer_data_a[9][9] & layer_data_b[9][9]) | (layer_data_a[9][9] & carry_bit_layer_adder[9][8]) | (layer_data_b[9][9] & carry_bit_layer_adder[9][8]); // calculation of carry bit of adder
assign result_layer_adder[9][10] = layer_data_a[9][10] ^ layer_data_b[9][10] ^ carry_bit_layer_adder[9][9]; // calculation of add result
assign carry_bit_layer_adder[9][10] = (layer_data_a[9][10] & layer_data_b[9][10]) | (layer_data_a[9][10] & carry_bit_layer_adder[9][9]) | (layer_data_b[9][10] & carry_bit_layer_adder[9][9]); // calculation of carry bit of adder
assign result_layer_adder[9][11] = layer_data_a[9][11] ^ layer_data_b[9][11] ^ carry_bit_layer_adder[9][10]; // calculation of add result
assign carry_bit_layer_adder[9][11] = (layer_data_a[9][11] & layer_data_b[9][11]) | (layer_data_a[9][11] & carry_bit_layer_adder[9][10]) | (layer_data_b[9][11] & carry_bit_layer_adder[9][10]); // calculation of carry bit of adder
assign result_layer_adder[9][12] = layer_data_a[9][12] ^ layer_data_b[9][12] ^ carry_bit_layer_adder[9][11]; // calculation of add result
assign carry_bit_layer_adder[9][12] = (layer_data_a[9][12] & layer_data_b[9][12]) | (layer_data_a[9][12] & carry_bit_layer_adder[9][11]) | (layer_data_b[9][12] & carry_bit_layer_adder[9][11]); // calculation of carry bit of adder
assign result_layer_adder[9][13] = layer_data_a[9][13] ^ layer_data_b[9][13] ^ carry_bit_layer_adder[9][12]; // calculation of add result
assign carry_bit_layer_adder[9][13] = (layer_data_a[9][13] & layer_data_b[9][13]) | (layer_data_a[9][13] & carry_bit_layer_adder[9][12]) | (layer_data_b[9][13] & carry_bit_layer_adder[9][12]); // calculation of carry bit of adder
assign result_layer_adder[9][14] = layer_data_a[9][14] ^ layer_data_b[9][14] ^ carry_bit_layer_adder[9][13]; // calculation of add result
assign carry_bit_layer_adder[9][14] = (layer_data_a[9][14] & layer_data_b[9][14]) | (layer_data_a[9][14] & carry_bit_layer_adder[9][13]) | (layer_data_b[9][14] & carry_bit_layer_adder[9][13]); // calculation of carry bit of adder
assign result_layer_adder[9][15] = layer_data_a[9][15] ^ layer_data_b[9][15] ^ carry_bit_layer_adder[9][14]; // calculation of add result
assign carry_bit_layer_adder[9][15] = (layer_data_a[9][15] & layer_data_b[9][15]) | (layer_data_a[9][15] & carry_bit_layer_adder[9][14]) | (layer_data_b[9][15] & carry_bit_layer_adder[9][14]); // calculation of carry bit of adder
assign result_layer_adder[9][16] = layer_data_a[9][16] ^ layer_data_b[9][16] ^ carry_bit_layer_adder[9][15]; // calculation of add result
assign carry_bit_layer_adder[9][16] = (layer_data_a[9][16] & layer_data_b[9][16]) | (layer_data_a[9][16] & carry_bit_layer_adder[9][15]) | (layer_data_b[9][16] & carry_bit_layer_adder[9][15]); // calculation of carry bit of adder
assign result_layer_adder[9][17] = layer_data_a[9][17] ^ layer_data_b[9][17] ^ carry_bit_layer_adder[9][16]; // calculation of add result
assign carry_bit_layer_adder[9][17] = (layer_data_a[9][17] & layer_data_b[9][17]) | (layer_data_a[9][17] & carry_bit_layer_adder[9][16]) | (layer_data_b[9][17] & carry_bit_layer_adder[9][16]); // calculation of carry bit of adder
assign result_layer_adder[9][18] = layer_data_a[9][18] ^ layer_data_b[9][18] ^ carry_bit_layer_adder[9][17]; // calculation of add result
assign carry_bit_layer_adder[9][18] = (layer_data_a[9][18] & layer_data_b[9][18]) | (layer_data_a[9][18] & carry_bit_layer_adder[9][17]) | (layer_data_b[9][18] & carry_bit_layer_adder[9][17]); // calculation of carry bit of adder
assign result_layer_adder[9][19] = layer_data_a[9][19] ^ layer_data_b[9][19] ^ carry_bit_layer_adder[9][18]; // calculation of add result
assign carry_bit_layer_adder[9][19] = (layer_data_a[9][19] & layer_data_b[9][19]) | (layer_data_a[9][19] & carry_bit_layer_adder[9][18]) | (layer_data_b[9][19] & carry_bit_layer_adder[9][18]); // calculation of carry bit of adder
assign result_layer_adder[9][20] = layer_data_a[9][20] ^ layer_data_b[9][20] ^ carry_bit_layer_adder[9][19]; // calculation of add result
assign carry_bit_layer_adder[9][20] = (layer_data_a[9][20] & layer_data_b[9][20]) | (layer_data_a[9][20] & carry_bit_layer_adder[9][19]) | (layer_data_b[9][20] & carry_bit_layer_adder[9][19]); // calculation of carry bit of adder
assign result_layer_adder[9][21] = layer_data_a[9][21] ^ layer_data_b[9][21] ^ carry_bit_layer_adder[9][20]; // calculation of add result
assign carry_bit_layer_adder[9][21] = (layer_data_a[9][21] & layer_data_b[9][21]) | (layer_data_a[9][21] & carry_bit_layer_adder[9][20]) | (layer_data_b[9][21] & carry_bit_layer_adder[9][20]); // calculation of carry bit of adder
assign result_layer_adder[9][22] = layer_data_a[9][22] ^ layer_data_b[9][22] ^ carry_bit_layer_adder[9][21]; // calculation of add result
assign carry_bit_layer_adder[9][22] = (layer_data_a[9][22] & layer_data_b[9][22]) | (layer_data_a[9][22] & carry_bit_layer_adder[9][21]) | (layer_data_b[9][22] & carry_bit_layer_adder[9][21]); // calculation of carry bit of adder
assign result_layer_adder[9][23] = layer_data_a[9][23] ^ layer_data_b[9][23] ^ carry_bit_layer_adder[9][22]; // calculation of add result
assign carry_bit_layer_adder[9][23] = (layer_data_a[9][23] & layer_data_b[9][23]) | (layer_data_a[9][23] & carry_bit_layer_adder[9][22]) | (layer_data_b[9][23] & carry_bit_layer_adder[9][22]); // calculation of carry bit of adder
assign result_layer_adder[9][24] = layer_data_a[9][24] ^ layer_data_b[9][24] ^ carry_bit_layer_adder[9][23]; // calculation of add result
assign carry_bit_layer_adder[9][24] = (layer_data_a[9][24] & layer_data_b[9][24]) | (layer_data_a[9][24] & carry_bit_layer_adder[9][23]) | (layer_data_b[9][24] & carry_bit_layer_adder[9][23]); // calculation of carry bit of adder
assign result_layer_adder[9][25] = layer_data_a[9][25] ^ layer_data_b[9][25] ^ carry_bit_layer_adder[9][24]; // calculation of add result
assign carry_bit_layer_adder[9][25] = (layer_data_a[9][25] & layer_data_b[9][25]) | (layer_data_a[9][25] & carry_bit_layer_adder[9][24]) | (layer_data_b[9][25] & carry_bit_layer_adder[9][24]); // calculation of carry bit of adder
assign result_layer_adder[9][26] = layer_data_a[9][26] ^ layer_data_b[9][26] ^ carry_bit_layer_adder[9][25]; // calculation of add result
assign carry_bit_layer_adder[9][26] = (layer_data_a[9][26] & layer_data_b[9][26]) | (layer_data_a[9][26] & carry_bit_layer_adder[9][25]) | (layer_data_b[9][26] & carry_bit_layer_adder[9][25]); // calculation of carry bit of adder
assign result_layer_adder[9][27] = layer_data_a[9][27] ^ layer_data_b[9][27] ^ carry_bit_layer_adder[9][26]; // calculation of add result
assign carry_bit_layer_adder[9][27] = (layer_data_a[9][27] & layer_data_b[9][27]) | (layer_data_a[9][27] & carry_bit_layer_adder[9][26]) | (layer_data_b[9][27] & carry_bit_layer_adder[9][26]); // calculation of carry bit of adder
assign result_layer_adder[9][28] = layer_data_a[9][28] ^ layer_data_b[9][28] ^ carry_bit_layer_adder[9][27]; // calculation of add result
assign carry_bit_layer_adder[9][28] = (layer_data_a[9][28] & layer_data_b[9][28]) | (layer_data_a[9][28] & carry_bit_layer_adder[9][27]) | (layer_data_b[9][28] & carry_bit_layer_adder[9][27]); // calculation of carry bit of adder
assign result_layer_adder[9][29] = layer_data_a[9][29] ^ layer_data_b[9][29] ^ carry_bit_layer_adder[9][28]; // calculation of add result
assign carry_bit_layer_adder[9][29] = (layer_data_a[9][29] & layer_data_b[9][29]) | (layer_data_a[9][29] & carry_bit_layer_adder[9][28]) | (layer_data_b[9][29] & carry_bit_layer_adder[9][28]); // calculation of carry bit of adder
assign result_layer_adder[9][30] = layer_data_a[9][30] ^ layer_data_b[9][30] ^ carry_bit_layer_adder[9][29]; // calculation of add result
assign carry_bit_layer_adder[9][30] = (layer_data_a[9][30] & layer_data_b[9][30]) | (layer_data_a[9][30] & carry_bit_layer_adder[9][29]) | (layer_data_b[9][30] & carry_bit_layer_adder[9][29]); // calculation of carry bit of adder
assign result_layer_adder[9][31] = layer_data_a[9][31] ^ layer_data_b[9][31] ^ carry_bit_layer_adder[9][30]; // calculation of add result
assign carry_bit_layer_adder[9][31] = (layer_data_a[9][31] & layer_data_b[9][31]) | (layer_data_a[9][31] & carry_bit_layer_adder[9][30]) | (layer_data_b[9][31] & carry_bit_layer_adder[9][30]); // calculation of carry bit of adder
assign result_layer_adder[9][32] = layer_data_a[9][32] ^ layer_data_b[9][32] ^ carry_bit_layer_adder[9][31]; // calculation of add result

// Layer 11
assign layer_data_a[10][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[9][32] == 1'b1) ? {layer_data_a[9][31:0], operand_a[22]} : {result_layer_adder[9][31:0], operand_a[22]}) : {1'b0, result_layer_adder[9][32:1]}; // data select for layer 11
assign layer_data_b[10][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[10] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 11

// Layer 11 adder
assign result_layer_adder[10][0] = layer_data_a[10][0] ^ layer_data_b[10][0]; // calculation of add result
assign carry_bit_layer_adder[10][0] = layer_data_a[10][0] & layer_data_b[10][0]; // calculation of carry bit of adder
assign result_layer_adder[10][1] = layer_data_a[10][1] ^ layer_data_b[10][1] ^ carry_bit_layer_adder[10][0]; // calculation of add result
assign carry_bit_layer_adder[10][1] = (layer_data_a[10][1] & layer_data_b[10][1]) | (layer_data_a[10][1] & carry_bit_layer_adder[10][0]) | (layer_data_b[10][1] & carry_bit_layer_adder[10][0]); // calculation of carry bit of adder
assign result_layer_adder[10][2] = layer_data_a[10][2] ^ layer_data_b[10][2] ^ carry_bit_layer_adder[10][1]; // calculation of add result
assign carry_bit_layer_adder[10][2] = (layer_data_a[10][2] & layer_data_b[10][2]) | (layer_data_a[10][2] & carry_bit_layer_adder[10][1]) | (layer_data_b[10][2] & carry_bit_layer_adder[10][1]); // calculation of carry bit of adder
assign result_layer_adder[10][3] = layer_data_a[10][3] ^ layer_data_b[10][3] ^ carry_bit_layer_adder[10][2]; // calculation of add result
assign carry_bit_layer_adder[10][3] = (layer_data_a[10][3] & layer_data_b[10][3]) | (layer_data_a[10][3] & carry_bit_layer_adder[10][2]) | (layer_data_b[10][3] & carry_bit_layer_adder[10][2]); // calculation of carry bit of adder
assign result_layer_adder[10][4] = layer_data_a[10][4] ^ layer_data_b[10][4] ^ carry_bit_layer_adder[10][3]; // calculation of add result
assign carry_bit_layer_adder[10][4] = (layer_data_a[10][4] & layer_data_b[10][4]) | (layer_data_a[10][4] & carry_bit_layer_adder[10][3]) | (layer_data_b[10][4] & carry_bit_layer_adder[10][3]); // calculation of carry bit of adder
assign result_layer_adder[10][5] = layer_data_a[10][5] ^ layer_data_b[10][5] ^ carry_bit_layer_adder[10][4]; // calculation of add result
assign carry_bit_layer_adder[10][5] = (layer_data_a[10][5] & layer_data_b[10][5]) | (layer_data_a[10][5] & carry_bit_layer_adder[10][4]) | (layer_data_b[10][5] & carry_bit_layer_adder[10][4]); // calculation of carry bit of adder
assign result_layer_adder[10][6] = layer_data_a[10][6] ^ layer_data_b[10][6] ^ carry_bit_layer_adder[10][5]; // calculation of add result
assign carry_bit_layer_adder[10][6] = (layer_data_a[10][6] & layer_data_b[10][6]) | (layer_data_a[10][6] & carry_bit_layer_adder[10][5]) | (layer_data_b[10][6] & carry_bit_layer_adder[10][5]); // calculation of carry bit of adder
assign result_layer_adder[10][7] = layer_data_a[10][7] ^ layer_data_b[10][7] ^ carry_bit_layer_adder[10][6]; // calculation of add result
assign carry_bit_layer_adder[10][7] = (layer_data_a[10][7] & layer_data_b[10][7]) | (layer_data_a[10][7] & carry_bit_layer_adder[10][6]) | (layer_data_b[10][7] & carry_bit_layer_adder[10][6]); // calculation of carry bit of adder
assign result_layer_adder[10][8] = layer_data_a[10][8] ^ layer_data_b[10][8] ^ carry_bit_layer_adder[10][7]; // calculation of add result
assign carry_bit_layer_adder[10][8] = (layer_data_a[10][8] & layer_data_b[10][8]) | (layer_data_a[10][8] & carry_bit_layer_adder[10][7]) | (layer_data_b[10][8] & carry_bit_layer_adder[10][7]); // calculation of carry bit of adder
assign result_layer_adder[10][9] = layer_data_a[10][9] ^ layer_data_b[10][9] ^ carry_bit_layer_adder[10][8]; // calculation of add result
assign carry_bit_layer_adder[10][9] = (layer_data_a[10][9] & layer_data_b[10][9]) | (layer_data_a[10][9] & carry_bit_layer_adder[10][8]) | (layer_data_b[10][9] & carry_bit_layer_adder[10][8]); // calculation of carry bit of adder
assign result_layer_adder[10][10] = layer_data_a[10][10] ^ layer_data_b[10][10] ^ carry_bit_layer_adder[10][9]; // calculation of add result
assign carry_bit_layer_adder[10][10] = (layer_data_a[10][10] & layer_data_b[10][10]) | (layer_data_a[10][10] & carry_bit_layer_adder[10][9]) | (layer_data_b[10][10] & carry_bit_layer_adder[10][9]); // calculation of carry bit of adder
assign result_layer_adder[10][11] = layer_data_a[10][11] ^ layer_data_b[10][11] ^ carry_bit_layer_adder[10][10]; // calculation of add result
assign carry_bit_layer_adder[10][11] = (layer_data_a[10][11] & layer_data_b[10][11]) | (layer_data_a[10][11] & carry_bit_layer_adder[10][10]) | (layer_data_b[10][11] & carry_bit_layer_adder[10][10]); // calculation of carry bit of adder
assign result_layer_adder[10][12] = layer_data_a[10][12] ^ layer_data_b[10][12] ^ carry_bit_layer_adder[10][11]; // calculation of add result
assign carry_bit_layer_adder[10][12] = (layer_data_a[10][12] & layer_data_b[10][12]) | (layer_data_a[10][12] & carry_bit_layer_adder[10][11]) | (layer_data_b[10][12] & carry_bit_layer_adder[10][11]); // calculation of carry bit of adder
assign result_layer_adder[10][13] = layer_data_a[10][13] ^ layer_data_b[10][13] ^ carry_bit_layer_adder[10][12]; // calculation of add result
assign carry_bit_layer_adder[10][13] = (layer_data_a[10][13] & layer_data_b[10][13]) | (layer_data_a[10][13] & carry_bit_layer_adder[10][12]) | (layer_data_b[10][13] & carry_bit_layer_adder[10][12]); // calculation of carry bit of adder
assign result_layer_adder[10][14] = layer_data_a[10][14] ^ layer_data_b[10][14] ^ carry_bit_layer_adder[10][13]; // calculation of add result
assign carry_bit_layer_adder[10][14] = (layer_data_a[10][14] & layer_data_b[10][14]) | (layer_data_a[10][14] & carry_bit_layer_adder[10][13]) | (layer_data_b[10][14] & carry_bit_layer_adder[10][13]); // calculation of carry bit of adder
assign result_layer_adder[10][15] = layer_data_a[10][15] ^ layer_data_b[10][15] ^ carry_bit_layer_adder[10][14]; // calculation of add result
assign carry_bit_layer_adder[10][15] = (layer_data_a[10][15] & layer_data_b[10][15]) | (layer_data_a[10][15] & carry_bit_layer_adder[10][14]) | (layer_data_b[10][15] & carry_bit_layer_adder[10][14]); // calculation of carry bit of adder
assign result_layer_adder[10][16] = layer_data_a[10][16] ^ layer_data_b[10][16] ^ carry_bit_layer_adder[10][15]; // calculation of add result
assign carry_bit_layer_adder[10][16] = (layer_data_a[10][16] & layer_data_b[10][16]) | (layer_data_a[10][16] & carry_bit_layer_adder[10][15]) | (layer_data_b[10][16] & carry_bit_layer_adder[10][15]); // calculation of carry bit of adder
assign result_layer_adder[10][17] = layer_data_a[10][17] ^ layer_data_b[10][17] ^ carry_bit_layer_adder[10][16]; // calculation of add result
assign carry_bit_layer_adder[10][17] = (layer_data_a[10][17] & layer_data_b[10][17]) | (layer_data_a[10][17] & carry_bit_layer_adder[10][16]) | (layer_data_b[10][17] & carry_bit_layer_adder[10][16]); // calculation of carry bit of adder
assign result_layer_adder[10][18] = layer_data_a[10][18] ^ layer_data_b[10][18] ^ carry_bit_layer_adder[10][17]; // calculation of add result
assign carry_bit_layer_adder[10][18] = (layer_data_a[10][18] & layer_data_b[10][18]) | (layer_data_a[10][18] & carry_bit_layer_adder[10][17]) | (layer_data_b[10][18] & carry_bit_layer_adder[10][17]); // calculation of carry bit of adder
assign result_layer_adder[10][19] = layer_data_a[10][19] ^ layer_data_b[10][19] ^ carry_bit_layer_adder[10][18]; // calculation of add result
assign carry_bit_layer_adder[10][19] = (layer_data_a[10][19] & layer_data_b[10][19]) | (layer_data_a[10][19] & carry_bit_layer_adder[10][18]) | (layer_data_b[10][19] & carry_bit_layer_adder[10][18]); // calculation of carry bit of adder
assign result_layer_adder[10][20] = layer_data_a[10][20] ^ layer_data_b[10][20] ^ carry_bit_layer_adder[10][19]; // calculation of add result
assign carry_bit_layer_adder[10][20] = (layer_data_a[10][20] & layer_data_b[10][20]) | (layer_data_a[10][20] & carry_bit_layer_adder[10][19]) | (layer_data_b[10][20] & carry_bit_layer_adder[10][19]); // calculation of carry bit of adder
assign result_layer_adder[10][21] = layer_data_a[10][21] ^ layer_data_b[10][21] ^ carry_bit_layer_adder[10][20]; // calculation of add result
assign carry_bit_layer_adder[10][21] = (layer_data_a[10][21] & layer_data_b[10][21]) | (layer_data_a[10][21] & carry_bit_layer_adder[10][20]) | (layer_data_b[10][21] & carry_bit_layer_adder[10][20]); // calculation of carry bit of adder
assign result_layer_adder[10][22] = layer_data_a[10][22] ^ layer_data_b[10][22] ^ carry_bit_layer_adder[10][21]; // calculation of add result
assign carry_bit_layer_adder[10][22] = (layer_data_a[10][22] & layer_data_b[10][22]) | (layer_data_a[10][22] & carry_bit_layer_adder[10][21]) | (layer_data_b[10][22] & carry_bit_layer_adder[10][21]); // calculation of carry bit of adder
assign result_layer_adder[10][23] = layer_data_a[10][23] ^ layer_data_b[10][23] ^ carry_bit_layer_adder[10][22]; // calculation of add result
assign carry_bit_layer_adder[10][23] = (layer_data_a[10][23] & layer_data_b[10][23]) | (layer_data_a[10][23] & carry_bit_layer_adder[10][22]) | (layer_data_b[10][23] & carry_bit_layer_adder[10][22]); // calculation of carry bit of adder
assign result_layer_adder[10][24] = layer_data_a[10][24] ^ layer_data_b[10][24] ^ carry_bit_layer_adder[10][23]; // calculation of add result
assign carry_bit_layer_adder[10][24] = (layer_data_a[10][24] & layer_data_b[10][24]) | (layer_data_a[10][24] & carry_bit_layer_adder[10][23]) | (layer_data_b[10][24] & carry_bit_layer_adder[10][23]); // calculation of carry bit of adder
assign result_layer_adder[10][25] = layer_data_a[10][25] ^ layer_data_b[10][25] ^ carry_bit_layer_adder[10][24]; // calculation of add result
assign carry_bit_layer_adder[10][25] = (layer_data_a[10][25] & layer_data_b[10][25]) | (layer_data_a[10][25] & carry_bit_layer_adder[10][24]) | (layer_data_b[10][25] & carry_bit_layer_adder[10][24]); // calculation of carry bit of adder
assign result_layer_adder[10][26] = layer_data_a[10][26] ^ layer_data_b[10][26] ^ carry_bit_layer_adder[10][25]; // calculation of add result
assign carry_bit_layer_adder[10][26] = (layer_data_a[10][26] & layer_data_b[10][26]) | (layer_data_a[10][26] & carry_bit_layer_adder[10][25]) | (layer_data_b[10][26] & carry_bit_layer_adder[10][25]); // calculation of carry bit of adder
assign result_layer_adder[10][27] = layer_data_a[10][27] ^ layer_data_b[10][27] ^ carry_bit_layer_adder[10][26]; // calculation of add result
assign carry_bit_layer_adder[10][27] = (layer_data_a[10][27] & layer_data_b[10][27]) | (layer_data_a[10][27] & carry_bit_layer_adder[10][26]) | (layer_data_b[10][27] & carry_bit_layer_adder[10][26]); // calculation of carry bit of adder
assign result_layer_adder[10][28] = layer_data_a[10][28] ^ layer_data_b[10][28] ^ carry_bit_layer_adder[10][27]; // calculation of add result
assign carry_bit_layer_adder[10][28] = (layer_data_a[10][28] & layer_data_b[10][28]) | (layer_data_a[10][28] & carry_bit_layer_adder[10][27]) | (layer_data_b[10][28] & carry_bit_layer_adder[10][27]); // calculation of carry bit of adder
assign result_layer_adder[10][29] = layer_data_a[10][29] ^ layer_data_b[10][29] ^ carry_bit_layer_adder[10][28]; // calculation of add result
assign carry_bit_layer_adder[10][29] = (layer_data_a[10][29] & layer_data_b[10][29]) | (layer_data_a[10][29] & carry_bit_layer_adder[10][28]) | (layer_data_b[10][29] & carry_bit_layer_adder[10][28]); // calculation of carry bit of adder
assign result_layer_adder[10][30] = layer_data_a[10][30] ^ layer_data_b[10][30] ^ carry_bit_layer_adder[10][29]; // calculation of add result
assign carry_bit_layer_adder[10][30] = (layer_data_a[10][30] & layer_data_b[10][30]) | (layer_data_a[10][30] & carry_bit_layer_adder[10][29]) | (layer_data_b[10][30] & carry_bit_layer_adder[10][29]); // calculation of carry bit of adder
assign result_layer_adder[10][31] = layer_data_a[10][31] ^ layer_data_b[10][31] ^ carry_bit_layer_adder[10][30]; // calculation of add result
assign carry_bit_layer_adder[10][31] = (layer_data_a[10][31] & layer_data_b[10][31]) | (layer_data_a[10][31] & carry_bit_layer_adder[10][30]) | (layer_data_b[10][31] & carry_bit_layer_adder[10][30]); // calculation of carry bit of adder
assign result_layer_adder[10][32] = layer_data_a[10][32] ^ layer_data_b[10][32] ^ carry_bit_layer_adder[10][31]; // calculation of add result

// Layer 12
assign layer_data_a[11][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[10][32] == 1'b1) ? {layer_data_a[10][31:0], operand_a[21]} : {result_layer_adder[10][31:0], operand_a[21]}) : {1'b0, result_layer_adder[10][32:1]}; // data select for layer 12
assign layer_data_b[11][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[11] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 12

// Layer 12 adder
assign result_layer_adder[11][0] = layer_data_a[11][0] ^ layer_data_b[11][0]; // calculation of add result
assign carry_bit_layer_adder[11][0] = layer_data_a[11][0] & layer_data_b[11][0]; // calculation of carry bit of adder
assign result_layer_adder[11][1] = layer_data_a[11][1] ^ layer_data_b[11][1] ^ carry_bit_layer_adder[11][0]; // calculation of add result
assign carry_bit_layer_adder[11][1] = (layer_data_a[11][1] & layer_data_b[11][1]) | (layer_data_a[11][1] & carry_bit_layer_adder[11][0]) | (layer_data_b[11][1] & carry_bit_layer_adder[11][0]); // calculation of carry bit of adder
assign result_layer_adder[11][2] = layer_data_a[11][2] ^ layer_data_b[11][2] ^ carry_bit_layer_adder[11][1]; // calculation of add result
assign carry_bit_layer_adder[11][2] = (layer_data_a[11][2] & layer_data_b[11][2]) | (layer_data_a[11][2] & carry_bit_layer_adder[11][1]) | (layer_data_b[11][2] & carry_bit_layer_adder[11][1]); // calculation of carry bit of adder
assign result_layer_adder[11][3] = layer_data_a[11][3] ^ layer_data_b[11][3] ^ carry_bit_layer_adder[11][2]; // calculation of add result
assign carry_bit_layer_adder[11][3] = (layer_data_a[11][3] & layer_data_b[11][3]) | (layer_data_a[11][3] & carry_bit_layer_adder[11][2]) | (layer_data_b[11][3] & carry_bit_layer_adder[11][2]); // calculation of carry bit of adder
assign result_layer_adder[11][4] = layer_data_a[11][4] ^ layer_data_b[11][4] ^ carry_bit_layer_adder[11][3]; // calculation of add result
assign carry_bit_layer_adder[11][4] = (layer_data_a[11][4] & layer_data_b[11][4]) | (layer_data_a[11][4] & carry_bit_layer_adder[11][3]) | (layer_data_b[11][4] & carry_bit_layer_adder[11][3]); // calculation of carry bit of adder
assign result_layer_adder[11][5] = layer_data_a[11][5] ^ layer_data_b[11][5] ^ carry_bit_layer_adder[11][4]; // calculation of add result
assign carry_bit_layer_adder[11][5] = (layer_data_a[11][5] & layer_data_b[11][5]) | (layer_data_a[11][5] & carry_bit_layer_adder[11][4]) | (layer_data_b[11][5] & carry_bit_layer_adder[11][4]); // calculation of carry bit of adder
assign result_layer_adder[11][6] = layer_data_a[11][6] ^ layer_data_b[11][6] ^ carry_bit_layer_adder[11][5]; // calculation of add result
assign carry_bit_layer_adder[11][6] = (layer_data_a[11][6] & layer_data_b[11][6]) | (layer_data_a[11][6] & carry_bit_layer_adder[11][5]) | (layer_data_b[11][6] & carry_bit_layer_adder[11][5]); // calculation of carry bit of adder
assign result_layer_adder[11][7] = layer_data_a[11][7] ^ layer_data_b[11][7] ^ carry_bit_layer_adder[11][6]; // calculation of add result
assign carry_bit_layer_adder[11][7] = (layer_data_a[11][7] & layer_data_b[11][7]) | (layer_data_a[11][7] & carry_bit_layer_adder[11][6]) | (layer_data_b[11][7] & carry_bit_layer_adder[11][6]); // calculation of carry bit of adder
assign result_layer_adder[11][8] = layer_data_a[11][8] ^ layer_data_b[11][8] ^ carry_bit_layer_adder[11][7]; // calculation of add result
assign carry_bit_layer_adder[11][8] = (layer_data_a[11][8] & layer_data_b[11][8]) | (layer_data_a[11][8] & carry_bit_layer_adder[11][7]) | (layer_data_b[11][8] & carry_bit_layer_adder[11][7]); // calculation of carry bit of adder
assign result_layer_adder[11][9] = layer_data_a[11][9] ^ layer_data_b[11][9] ^ carry_bit_layer_adder[11][8]; // calculation of add result
assign carry_bit_layer_adder[11][9] = (layer_data_a[11][9] & layer_data_b[11][9]) | (layer_data_a[11][9] & carry_bit_layer_adder[11][8]) | (layer_data_b[11][9] & carry_bit_layer_adder[11][8]); // calculation of carry bit of adder
assign result_layer_adder[11][10] = layer_data_a[11][10] ^ layer_data_b[11][10] ^ carry_bit_layer_adder[11][9]; // calculation of add result
assign carry_bit_layer_adder[11][10] = (layer_data_a[11][10] & layer_data_b[11][10]) | (layer_data_a[11][10] & carry_bit_layer_adder[11][9]) | (layer_data_b[11][10] & carry_bit_layer_adder[11][9]); // calculation of carry bit of adder
assign result_layer_adder[11][11] = layer_data_a[11][11] ^ layer_data_b[11][11] ^ carry_bit_layer_adder[11][10]; // calculation of add result
assign carry_bit_layer_adder[11][11] = (layer_data_a[11][11] & layer_data_b[11][11]) | (layer_data_a[11][11] & carry_bit_layer_adder[11][10]) | (layer_data_b[11][11] & carry_bit_layer_adder[11][10]); // calculation of carry bit of adder
assign result_layer_adder[11][12] = layer_data_a[11][12] ^ layer_data_b[11][12] ^ carry_bit_layer_adder[11][11]; // calculation of add result
assign carry_bit_layer_adder[11][12] = (layer_data_a[11][12] & layer_data_b[11][12]) | (layer_data_a[11][12] & carry_bit_layer_adder[11][11]) | (layer_data_b[11][12] & carry_bit_layer_adder[11][11]); // calculation of carry bit of adder
assign result_layer_adder[11][13] = layer_data_a[11][13] ^ layer_data_b[11][13] ^ carry_bit_layer_adder[11][12]; // calculation of add result
assign carry_bit_layer_adder[11][13] = (layer_data_a[11][13] & layer_data_b[11][13]) | (layer_data_a[11][13] & carry_bit_layer_adder[11][12]) | (layer_data_b[11][13] & carry_bit_layer_adder[11][12]); // calculation of carry bit of adder
assign result_layer_adder[11][14] = layer_data_a[11][14] ^ layer_data_b[11][14] ^ carry_bit_layer_adder[11][13]; // calculation of add result
assign carry_bit_layer_adder[11][14] = (layer_data_a[11][14] & layer_data_b[11][14]) | (layer_data_a[11][14] & carry_bit_layer_adder[11][13]) | (layer_data_b[11][14] & carry_bit_layer_adder[11][13]); // calculation of carry bit of adder
assign result_layer_adder[11][15] = layer_data_a[11][15] ^ layer_data_b[11][15] ^ carry_bit_layer_adder[11][14]; // calculation of add result
assign carry_bit_layer_adder[11][15] = (layer_data_a[11][15] & layer_data_b[11][15]) | (layer_data_a[11][15] & carry_bit_layer_adder[11][14]) | (layer_data_b[11][15] & carry_bit_layer_adder[11][14]); // calculation of carry bit of adder
assign result_layer_adder[11][16] = layer_data_a[11][16] ^ layer_data_b[11][16] ^ carry_bit_layer_adder[11][15]; // calculation of add result
assign carry_bit_layer_adder[11][16] = (layer_data_a[11][16] & layer_data_b[11][16]) | (layer_data_a[11][16] & carry_bit_layer_adder[11][15]) | (layer_data_b[11][16] & carry_bit_layer_adder[11][15]); // calculation of carry bit of adder
assign result_layer_adder[11][17] = layer_data_a[11][17] ^ layer_data_b[11][17] ^ carry_bit_layer_adder[11][16]; // calculation of add result
assign carry_bit_layer_adder[11][17] = (layer_data_a[11][17] & layer_data_b[11][17]) | (layer_data_a[11][17] & carry_bit_layer_adder[11][16]) | (layer_data_b[11][17] & carry_bit_layer_adder[11][16]); // calculation of carry bit of adder
assign result_layer_adder[11][18] = layer_data_a[11][18] ^ layer_data_b[11][18] ^ carry_bit_layer_adder[11][17]; // calculation of add result
assign carry_bit_layer_adder[11][18] = (layer_data_a[11][18] & layer_data_b[11][18]) | (layer_data_a[11][18] & carry_bit_layer_adder[11][17]) | (layer_data_b[11][18] & carry_bit_layer_adder[11][17]); // calculation of carry bit of adder
assign result_layer_adder[11][19] = layer_data_a[11][19] ^ layer_data_b[11][19] ^ carry_bit_layer_adder[11][18]; // calculation of add result
assign carry_bit_layer_adder[11][19] = (layer_data_a[11][19] & layer_data_b[11][19]) | (layer_data_a[11][19] & carry_bit_layer_adder[11][18]) | (layer_data_b[11][19] & carry_bit_layer_adder[11][18]); // calculation of carry bit of adder
assign result_layer_adder[11][20] = layer_data_a[11][20] ^ layer_data_b[11][20] ^ carry_bit_layer_adder[11][19]; // calculation of add result
assign carry_bit_layer_adder[11][20] = (layer_data_a[11][20] & layer_data_b[11][20]) | (layer_data_a[11][20] & carry_bit_layer_adder[11][19]) | (layer_data_b[11][20] & carry_bit_layer_adder[11][19]); // calculation of carry bit of adder
assign result_layer_adder[11][21] = layer_data_a[11][21] ^ layer_data_b[11][21] ^ carry_bit_layer_adder[11][20]; // calculation of add result
assign carry_bit_layer_adder[11][21] = (layer_data_a[11][21] & layer_data_b[11][21]) | (layer_data_a[11][21] & carry_bit_layer_adder[11][20]) | (layer_data_b[11][21] & carry_bit_layer_adder[11][20]); // calculation of carry bit of adder
assign result_layer_adder[11][22] = layer_data_a[11][22] ^ layer_data_b[11][22] ^ carry_bit_layer_adder[11][21]; // calculation of add result
assign carry_bit_layer_adder[11][22] = (layer_data_a[11][22] & layer_data_b[11][22]) | (layer_data_a[11][22] & carry_bit_layer_adder[11][21]) | (layer_data_b[11][22] & carry_bit_layer_adder[11][21]); // calculation of carry bit of adder
assign result_layer_adder[11][23] = layer_data_a[11][23] ^ layer_data_b[11][23] ^ carry_bit_layer_adder[11][22]; // calculation of add result
assign carry_bit_layer_adder[11][23] = (layer_data_a[11][23] & layer_data_b[11][23]) | (layer_data_a[11][23] & carry_bit_layer_adder[11][22]) | (layer_data_b[11][23] & carry_bit_layer_adder[11][22]); // calculation of carry bit of adder
assign result_layer_adder[11][24] = layer_data_a[11][24] ^ layer_data_b[11][24] ^ carry_bit_layer_adder[11][23]; // calculation of add result
assign carry_bit_layer_adder[11][24] = (layer_data_a[11][24] & layer_data_b[11][24]) | (layer_data_a[11][24] & carry_bit_layer_adder[11][23]) | (layer_data_b[11][24] & carry_bit_layer_adder[11][23]); // calculation of carry bit of adder
assign result_layer_adder[11][25] = layer_data_a[11][25] ^ layer_data_b[11][25] ^ carry_bit_layer_adder[11][24]; // calculation of add result
assign carry_bit_layer_adder[11][25] = (layer_data_a[11][25] & layer_data_b[11][25]) | (layer_data_a[11][25] & carry_bit_layer_adder[11][24]) | (layer_data_b[11][25] & carry_bit_layer_adder[11][24]); // calculation of carry bit of adder
assign result_layer_adder[11][26] = layer_data_a[11][26] ^ layer_data_b[11][26] ^ carry_bit_layer_adder[11][25]; // calculation of add result
assign carry_bit_layer_adder[11][26] = (layer_data_a[11][26] & layer_data_b[11][26]) | (layer_data_a[11][26] & carry_bit_layer_adder[11][25]) | (layer_data_b[11][26] & carry_bit_layer_adder[11][25]); // calculation of carry bit of adder
assign result_layer_adder[11][27] = layer_data_a[11][27] ^ layer_data_b[11][27] ^ carry_bit_layer_adder[11][26]; // calculation of add result
assign carry_bit_layer_adder[11][27] = (layer_data_a[11][27] & layer_data_b[11][27]) | (layer_data_a[11][27] & carry_bit_layer_adder[11][26]) | (layer_data_b[11][27] & carry_bit_layer_adder[11][26]); // calculation of carry bit of adder
assign result_layer_adder[11][28] = layer_data_a[11][28] ^ layer_data_b[11][28] ^ carry_bit_layer_adder[11][27]; // calculation of add result
assign carry_bit_layer_adder[11][28] = (layer_data_a[11][28] & layer_data_b[11][28]) | (layer_data_a[11][28] & carry_bit_layer_adder[11][27]) | (layer_data_b[11][28] & carry_bit_layer_adder[11][27]); // calculation of carry bit of adder
assign result_layer_adder[11][29] = layer_data_a[11][29] ^ layer_data_b[11][29] ^ carry_bit_layer_adder[11][28]; // calculation of add result
assign carry_bit_layer_adder[11][29] = (layer_data_a[11][29] & layer_data_b[11][29]) | (layer_data_a[11][29] & carry_bit_layer_adder[11][28]) | (layer_data_b[11][29] & carry_bit_layer_adder[11][28]); // calculation of carry bit of adder
assign result_layer_adder[11][30] = layer_data_a[11][30] ^ layer_data_b[11][30] ^ carry_bit_layer_adder[11][29]; // calculation of add result
assign carry_bit_layer_adder[11][30] = (layer_data_a[11][30] & layer_data_b[11][30]) | (layer_data_a[11][30] & carry_bit_layer_adder[11][29]) | (layer_data_b[11][30] & carry_bit_layer_adder[11][29]); // calculation of carry bit of adder
assign result_layer_adder[11][31] = layer_data_a[11][31] ^ layer_data_b[11][31] ^ carry_bit_layer_adder[11][30]; // calculation of add result
assign carry_bit_layer_adder[11][31] = (layer_data_a[11][31] & layer_data_b[11][31]) | (layer_data_a[11][31] & carry_bit_layer_adder[11][30]) | (layer_data_b[11][31] & carry_bit_layer_adder[11][30]); // calculation of carry bit of adder
assign result_layer_adder[11][32] = layer_data_a[11][32] ^ layer_data_b[11][32] ^ carry_bit_layer_adder[11][31]; // calculation of add result

// Layer 13
assign layer_data_a[12][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[11][32] == 1'b1) ? {layer_data_a[11][31:0], operand_a[20]} : {result_layer_adder[11][31:0], operand_a[20]}) : {1'b0, result_layer_adder[11][32:1]}; // data select for layer 13
assign layer_data_b[12][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[12] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 13

// Layer 13 adder
assign result_layer_adder[12][0] = layer_data_a[12][0] ^ layer_data_b[12][0]; // calculation of add result
assign carry_bit_layer_adder[12][0] = layer_data_a[12][0] & layer_data_b[12][0]; // calculation of carry bit of adder
assign result_layer_adder[12][1] = layer_data_a[12][1] ^ layer_data_b[12][1] ^ carry_bit_layer_adder[12][0]; // calculation of add result
assign carry_bit_layer_adder[12][1] = (layer_data_a[12][1] & layer_data_b[12][1]) | (layer_data_a[12][1] & carry_bit_layer_adder[12][0]) | (layer_data_b[12][1] & carry_bit_layer_adder[12][0]); // calculation of carry bit of adder
assign result_layer_adder[12][2] = layer_data_a[12][2] ^ layer_data_b[12][2] ^ carry_bit_layer_adder[12][1]; // calculation of add result
assign carry_bit_layer_adder[12][2] = (layer_data_a[12][2] & layer_data_b[12][2]) | (layer_data_a[12][2] & carry_bit_layer_adder[12][1]) | (layer_data_b[12][2] & carry_bit_layer_adder[12][1]); // calculation of carry bit of adder
assign result_layer_adder[12][3] = layer_data_a[12][3] ^ layer_data_b[12][3] ^ carry_bit_layer_adder[12][2]; // calculation of add result
assign carry_bit_layer_adder[12][3] = (layer_data_a[12][3] & layer_data_b[12][3]) | (layer_data_a[12][3] & carry_bit_layer_adder[12][2]) | (layer_data_b[12][3] & carry_bit_layer_adder[12][2]); // calculation of carry bit of adder
assign result_layer_adder[12][4] = layer_data_a[12][4] ^ layer_data_b[12][4] ^ carry_bit_layer_adder[12][3]; // calculation of add result
assign carry_bit_layer_adder[12][4] = (layer_data_a[12][4] & layer_data_b[12][4]) | (layer_data_a[12][4] & carry_bit_layer_adder[12][3]) | (layer_data_b[12][4] & carry_bit_layer_adder[12][3]); // calculation of carry bit of adder
assign result_layer_adder[12][5] = layer_data_a[12][5] ^ layer_data_b[12][5] ^ carry_bit_layer_adder[12][4]; // calculation of add result
assign carry_bit_layer_adder[12][5] = (layer_data_a[12][5] & layer_data_b[12][5]) | (layer_data_a[12][5] & carry_bit_layer_adder[12][4]) | (layer_data_b[12][5] & carry_bit_layer_adder[12][4]); // calculation of carry bit of adder
assign result_layer_adder[12][6] = layer_data_a[12][6] ^ layer_data_b[12][6] ^ carry_bit_layer_adder[12][5]; // calculation of add result
assign carry_bit_layer_adder[12][6] = (layer_data_a[12][6] & layer_data_b[12][6]) | (layer_data_a[12][6] & carry_bit_layer_adder[12][5]) | (layer_data_b[12][6] & carry_bit_layer_adder[12][5]); // calculation of carry bit of adder
assign result_layer_adder[12][7] = layer_data_a[12][7] ^ layer_data_b[12][7] ^ carry_bit_layer_adder[12][6]; // calculation of add result
assign carry_bit_layer_adder[12][7] = (layer_data_a[12][7] & layer_data_b[12][7]) | (layer_data_a[12][7] & carry_bit_layer_adder[12][6]) | (layer_data_b[12][7] & carry_bit_layer_adder[12][6]); // calculation of carry bit of adder
assign result_layer_adder[12][8] = layer_data_a[12][8] ^ layer_data_b[12][8] ^ carry_bit_layer_adder[12][7]; // calculation of add result
assign carry_bit_layer_adder[12][8] = (layer_data_a[12][8] & layer_data_b[12][8]) | (layer_data_a[12][8] & carry_bit_layer_adder[12][7]) | (layer_data_b[12][8] & carry_bit_layer_adder[12][7]); // calculation of carry bit of adder
assign result_layer_adder[12][9] = layer_data_a[12][9] ^ layer_data_b[12][9] ^ carry_bit_layer_adder[12][8]; // calculation of add result
assign carry_bit_layer_adder[12][9] = (layer_data_a[12][9] & layer_data_b[12][9]) | (layer_data_a[12][9] & carry_bit_layer_adder[12][8]) | (layer_data_b[12][9] & carry_bit_layer_adder[12][8]); // calculation of carry bit of adder
assign result_layer_adder[12][10] = layer_data_a[12][10] ^ layer_data_b[12][10] ^ carry_bit_layer_adder[12][9]; // calculation of add result
assign carry_bit_layer_adder[12][10] = (layer_data_a[12][10] & layer_data_b[12][10]) | (layer_data_a[12][10] & carry_bit_layer_adder[12][9]) | (layer_data_b[12][10] & carry_bit_layer_adder[12][9]); // calculation of carry bit of adder
assign result_layer_adder[12][11] = layer_data_a[12][11] ^ layer_data_b[12][11] ^ carry_bit_layer_adder[12][10]; // calculation of add result
assign carry_bit_layer_adder[12][11] = (layer_data_a[12][11] & layer_data_b[12][11]) | (layer_data_a[12][11] & carry_bit_layer_adder[12][10]) | (layer_data_b[12][11] & carry_bit_layer_adder[12][10]); // calculation of carry bit of adder
assign result_layer_adder[12][12] = layer_data_a[12][12] ^ layer_data_b[12][12] ^ carry_bit_layer_adder[12][11]; // calculation of add result
assign carry_bit_layer_adder[12][12] = (layer_data_a[12][12] & layer_data_b[12][12]) | (layer_data_a[12][12] & carry_bit_layer_adder[12][11]) | (layer_data_b[12][12] & carry_bit_layer_adder[12][11]); // calculation of carry bit of adder
assign result_layer_adder[12][13] = layer_data_a[12][13] ^ layer_data_b[12][13] ^ carry_bit_layer_adder[12][12]; // calculation of add result
assign carry_bit_layer_adder[12][13] = (layer_data_a[12][13] & layer_data_b[12][13]) | (layer_data_a[12][13] & carry_bit_layer_adder[12][12]) | (layer_data_b[12][13] & carry_bit_layer_adder[12][12]); // calculation of carry bit of adder
assign result_layer_adder[12][14] = layer_data_a[12][14] ^ layer_data_b[12][14] ^ carry_bit_layer_adder[12][13]; // calculation of add result
assign carry_bit_layer_adder[12][14] = (layer_data_a[12][14] & layer_data_b[12][14]) | (layer_data_a[12][14] & carry_bit_layer_adder[12][13]) | (layer_data_b[12][14] & carry_bit_layer_adder[12][13]); // calculation of carry bit of adder
assign result_layer_adder[12][15] = layer_data_a[12][15] ^ layer_data_b[12][15] ^ carry_bit_layer_adder[12][14]; // calculation of add result
assign carry_bit_layer_adder[12][15] = (layer_data_a[12][15] & layer_data_b[12][15]) | (layer_data_a[12][15] & carry_bit_layer_adder[12][14]) | (layer_data_b[12][15] & carry_bit_layer_adder[12][14]); // calculation of carry bit of adder
assign result_layer_adder[12][16] = layer_data_a[12][16] ^ layer_data_b[12][16] ^ carry_bit_layer_adder[12][15]; // calculation of add result
assign carry_bit_layer_adder[12][16] = (layer_data_a[12][16] & layer_data_b[12][16]) | (layer_data_a[12][16] & carry_bit_layer_adder[12][15]) | (layer_data_b[12][16] & carry_bit_layer_adder[12][15]); // calculation of carry bit of adder
assign result_layer_adder[12][17] = layer_data_a[12][17] ^ layer_data_b[12][17] ^ carry_bit_layer_adder[12][16]; // calculation of add result
assign carry_bit_layer_adder[12][17] = (layer_data_a[12][17] & layer_data_b[12][17]) | (layer_data_a[12][17] & carry_bit_layer_adder[12][16]) | (layer_data_b[12][17] & carry_bit_layer_adder[12][16]); // calculation of carry bit of adder
assign result_layer_adder[12][18] = layer_data_a[12][18] ^ layer_data_b[12][18] ^ carry_bit_layer_adder[12][17]; // calculation of add result
assign carry_bit_layer_adder[12][18] = (layer_data_a[12][18] & layer_data_b[12][18]) | (layer_data_a[12][18] & carry_bit_layer_adder[12][17]) | (layer_data_b[12][18] & carry_bit_layer_adder[12][17]); // calculation of carry bit of adder
assign result_layer_adder[12][19] = layer_data_a[12][19] ^ layer_data_b[12][19] ^ carry_bit_layer_adder[12][18]; // calculation of add result
assign carry_bit_layer_adder[12][19] = (layer_data_a[12][19] & layer_data_b[12][19]) | (layer_data_a[12][19] & carry_bit_layer_adder[12][18]) | (layer_data_b[12][19] & carry_bit_layer_adder[12][18]); // calculation of carry bit of adder
assign result_layer_adder[12][20] = layer_data_a[12][20] ^ layer_data_b[12][20] ^ carry_bit_layer_adder[12][19]; // calculation of add result
assign carry_bit_layer_adder[12][20] = (layer_data_a[12][20] & layer_data_b[12][20]) | (layer_data_a[12][20] & carry_bit_layer_adder[12][19]) | (layer_data_b[12][20] & carry_bit_layer_adder[12][19]); // calculation of carry bit of adder
assign result_layer_adder[12][21] = layer_data_a[12][21] ^ layer_data_b[12][21] ^ carry_bit_layer_adder[12][20]; // calculation of add result
assign carry_bit_layer_adder[12][21] = (layer_data_a[12][21] & layer_data_b[12][21]) | (layer_data_a[12][21] & carry_bit_layer_adder[12][20]) | (layer_data_b[12][21] & carry_bit_layer_adder[12][20]); // calculation of carry bit of adder
assign result_layer_adder[12][22] = layer_data_a[12][22] ^ layer_data_b[12][22] ^ carry_bit_layer_adder[12][21]; // calculation of add result
assign carry_bit_layer_adder[12][22] = (layer_data_a[12][22] & layer_data_b[12][22]) | (layer_data_a[12][22] & carry_bit_layer_adder[12][21]) | (layer_data_b[12][22] & carry_bit_layer_adder[12][21]); // calculation of carry bit of adder
assign result_layer_adder[12][23] = layer_data_a[12][23] ^ layer_data_b[12][23] ^ carry_bit_layer_adder[12][22]; // calculation of add result
assign carry_bit_layer_adder[12][23] = (layer_data_a[12][23] & layer_data_b[12][23]) | (layer_data_a[12][23] & carry_bit_layer_adder[12][22]) | (layer_data_b[12][23] & carry_bit_layer_adder[12][22]); // calculation of carry bit of adder
assign result_layer_adder[12][24] = layer_data_a[12][24] ^ layer_data_b[12][24] ^ carry_bit_layer_adder[12][23]; // calculation of add result
assign carry_bit_layer_adder[12][24] = (layer_data_a[12][24] & layer_data_b[12][24]) | (layer_data_a[12][24] & carry_bit_layer_adder[12][23]) | (layer_data_b[12][24] & carry_bit_layer_adder[12][23]); // calculation of carry bit of adder
assign result_layer_adder[12][25] = layer_data_a[12][25] ^ layer_data_b[12][25] ^ carry_bit_layer_adder[12][24]; // calculation of add result
assign carry_bit_layer_adder[12][25] = (layer_data_a[12][25] & layer_data_b[12][25]) | (layer_data_a[12][25] & carry_bit_layer_adder[12][24]) | (layer_data_b[12][25] & carry_bit_layer_adder[12][24]); // calculation of carry bit of adder
assign result_layer_adder[12][26] = layer_data_a[12][26] ^ layer_data_b[12][26] ^ carry_bit_layer_adder[12][25]; // calculation of add result
assign carry_bit_layer_adder[12][26] = (layer_data_a[12][26] & layer_data_b[12][26]) | (layer_data_a[12][26] & carry_bit_layer_adder[12][25]) | (layer_data_b[12][26] & carry_bit_layer_adder[12][25]); // calculation of carry bit of adder
assign result_layer_adder[12][27] = layer_data_a[12][27] ^ layer_data_b[12][27] ^ carry_bit_layer_adder[12][26]; // calculation of add result
assign carry_bit_layer_adder[12][27] = (layer_data_a[12][27] & layer_data_b[12][27]) | (layer_data_a[12][27] & carry_bit_layer_adder[12][26]) | (layer_data_b[12][27] & carry_bit_layer_adder[12][26]); // calculation of carry bit of adder
assign result_layer_adder[12][28] = layer_data_a[12][28] ^ layer_data_b[12][28] ^ carry_bit_layer_adder[12][27]; // calculation of add result
assign carry_bit_layer_adder[12][28] = (layer_data_a[12][28] & layer_data_b[12][28]) | (layer_data_a[12][28] & carry_bit_layer_adder[12][27]) | (layer_data_b[12][28] & carry_bit_layer_adder[12][27]); // calculation of carry bit of adder
assign result_layer_adder[12][29] = layer_data_a[12][29] ^ layer_data_b[12][29] ^ carry_bit_layer_adder[12][28]; // calculation of add result
assign carry_bit_layer_adder[12][29] = (layer_data_a[12][29] & layer_data_b[12][29]) | (layer_data_a[12][29] & carry_bit_layer_adder[12][28]) | (layer_data_b[12][29] & carry_bit_layer_adder[12][28]); // calculation of carry bit of adder
assign result_layer_adder[12][30] = layer_data_a[12][30] ^ layer_data_b[12][30] ^ carry_bit_layer_adder[12][29]; // calculation of add result
assign carry_bit_layer_adder[12][30] = (layer_data_a[12][30] & layer_data_b[12][30]) | (layer_data_a[12][30] & carry_bit_layer_adder[12][29]) | (layer_data_b[12][30] & carry_bit_layer_adder[12][29]); // calculation of carry bit of adder
assign result_layer_adder[12][31] = layer_data_a[12][31] ^ layer_data_b[12][31] ^ carry_bit_layer_adder[12][30]; // calculation of add result
assign carry_bit_layer_adder[12][31] = (layer_data_a[12][31] & layer_data_b[12][31]) | (layer_data_a[12][31] & carry_bit_layer_adder[12][30]) | (layer_data_b[12][31] & carry_bit_layer_adder[12][30]); // calculation of carry bit of adder
assign result_layer_adder[12][32] = layer_data_a[12][32] ^ layer_data_b[12][32] ^ carry_bit_layer_adder[12][31]; // calculation of add result

// Layer 14
assign layer_data_a[13][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[12][32] == 1'b1) ? {layer_data_a[12][31:0], operand_a[19]} : {result_layer_adder[12][31:0], operand_a[19]}) : {1'b0, result_layer_adder[12][32:1]}; // data select for layer 14
assign layer_data_b[13][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[13] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 14

// Layer 14 adder
assign result_layer_adder[13][0] = layer_data_a[13][0] ^ layer_data_b[13][0]; // calculation of add result
assign carry_bit_layer_adder[13][0] = layer_data_a[13][0] & layer_data_b[13][0]; // calculation of carry bit of adder
assign result_layer_adder[13][1] = layer_data_a[13][1] ^ layer_data_b[13][1] ^ carry_bit_layer_adder[13][0]; // calculation of add result
assign carry_bit_layer_adder[13][1] = (layer_data_a[13][1] & layer_data_b[13][1]) | (layer_data_a[13][1] & carry_bit_layer_adder[13][0]) | (layer_data_b[13][1] & carry_bit_layer_adder[13][0]); // calculation of carry bit of adder
assign result_layer_adder[13][2] = layer_data_a[13][2] ^ layer_data_b[13][2] ^ carry_bit_layer_adder[13][1]; // calculation of add result
assign carry_bit_layer_adder[13][2] = (layer_data_a[13][2] & layer_data_b[13][2]) | (layer_data_a[13][2] & carry_bit_layer_adder[13][1]) | (layer_data_b[13][2] & carry_bit_layer_adder[13][1]); // calculation of carry bit of adder
assign result_layer_adder[13][3] = layer_data_a[13][3] ^ layer_data_b[13][3] ^ carry_bit_layer_adder[13][2]; // calculation of add result
assign carry_bit_layer_adder[13][3] = (layer_data_a[13][3] & layer_data_b[13][3]) | (layer_data_a[13][3] & carry_bit_layer_adder[13][2]) | (layer_data_b[13][3] & carry_bit_layer_adder[13][2]); // calculation of carry bit of adder
assign result_layer_adder[13][4] = layer_data_a[13][4] ^ layer_data_b[13][4] ^ carry_bit_layer_adder[13][3]; // calculation of add result
assign carry_bit_layer_adder[13][4] = (layer_data_a[13][4] & layer_data_b[13][4]) | (layer_data_a[13][4] & carry_bit_layer_adder[13][3]) | (layer_data_b[13][4] & carry_bit_layer_adder[13][3]); // calculation of carry bit of adder
assign result_layer_adder[13][5] = layer_data_a[13][5] ^ layer_data_b[13][5] ^ carry_bit_layer_adder[13][4]; // calculation of add result
assign carry_bit_layer_adder[13][5] = (layer_data_a[13][5] & layer_data_b[13][5]) | (layer_data_a[13][5] & carry_bit_layer_adder[13][4]) | (layer_data_b[13][5] & carry_bit_layer_adder[13][4]); // calculation of carry bit of adder
assign result_layer_adder[13][6] = layer_data_a[13][6] ^ layer_data_b[13][6] ^ carry_bit_layer_adder[13][5]; // calculation of add result
assign carry_bit_layer_adder[13][6] = (layer_data_a[13][6] & layer_data_b[13][6]) | (layer_data_a[13][6] & carry_bit_layer_adder[13][5]) | (layer_data_b[13][6] & carry_bit_layer_adder[13][5]); // calculation of carry bit of adder
assign result_layer_adder[13][7] = layer_data_a[13][7] ^ layer_data_b[13][7] ^ carry_bit_layer_adder[13][6]; // calculation of add result
assign carry_bit_layer_adder[13][7] = (layer_data_a[13][7] & layer_data_b[13][7]) | (layer_data_a[13][7] & carry_bit_layer_adder[13][6]) | (layer_data_b[13][7] & carry_bit_layer_adder[13][6]); // calculation of carry bit of adder
assign result_layer_adder[13][8] = layer_data_a[13][8] ^ layer_data_b[13][8] ^ carry_bit_layer_adder[13][7]; // calculation of add result
assign carry_bit_layer_adder[13][8] = (layer_data_a[13][8] & layer_data_b[13][8]) | (layer_data_a[13][8] & carry_bit_layer_adder[13][7]) | (layer_data_b[13][8] & carry_bit_layer_adder[13][7]); // calculation of carry bit of adder
assign result_layer_adder[13][9] = layer_data_a[13][9] ^ layer_data_b[13][9] ^ carry_bit_layer_adder[13][8]; // calculation of add result
assign carry_bit_layer_adder[13][9] = (layer_data_a[13][9] & layer_data_b[13][9]) | (layer_data_a[13][9] & carry_bit_layer_adder[13][8]) | (layer_data_b[13][9] & carry_bit_layer_adder[13][8]); // calculation of carry bit of adder
assign result_layer_adder[13][10] = layer_data_a[13][10] ^ layer_data_b[13][10] ^ carry_bit_layer_adder[13][9]; // calculation of add result
assign carry_bit_layer_adder[13][10] = (layer_data_a[13][10] & layer_data_b[13][10]) | (layer_data_a[13][10] & carry_bit_layer_adder[13][9]) | (layer_data_b[13][10] & carry_bit_layer_adder[13][9]); // calculation of carry bit of adder
assign result_layer_adder[13][11] = layer_data_a[13][11] ^ layer_data_b[13][11] ^ carry_bit_layer_adder[13][10]; // calculation of add result
assign carry_bit_layer_adder[13][11] = (layer_data_a[13][11] & layer_data_b[13][11]) | (layer_data_a[13][11] & carry_bit_layer_adder[13][10]) | (layer_data_b[13][11] & carry_bit_layer_adder[13][10]); // calculation of carry bit of adder
assign result_layer_adder[13][12] = layer_data_a[13][12] ^ layer_data_b[13][12] ^ carry_bit_layer_adder[13][11]; // calculation of add result
assign carry_bit_layer_adder[13][12] = (layer_data_a[13][12] & layer_data_b[13][12]) | (layer_data_a[13][12] & carry_bit_layer_adder[13][11]) | (layer_data_b[13][12] & carry_bit_layer_adder[13][11]); // calculation of carry bit of adder
assign result_layer_adder[13][13] = layer_data_a[13][13] ^ layer_data_b[13][13] ^ carry_bit_layer_adder[13][12]; // calculation of add result
assign carry_bit_layer_adder[13][13] = (layer_data_a[13][13] & layer_data_b[13][13]) | (layer_data_a[13][13] & carry_bit_layer_adder[13][12]) | (layer_data_b[13][13] & carry_bit_layer_adder[13][12]); // calculation of carry bit of adder
assign result_layer_adder[13][14] = layer_data_a[13][14] ^ layer_data_b[13][14] ^ carry_bit_layer_adder[13][13]; // calculation of add result
assign carry_bit_layer_adder[13][14] = (layer_data_a[13][14] & layer_data_b[13][14]) | (layer_data_a[13][14] & carry_bit_layer_adder[13][13]) | (layer_data_b[13][14] & carry_bit_layer_adder[13][13]); // calculation of carry bit of adder
assign result_layer_adder[13][15] = layer_data_a[13][15] ^ layer_data_b[13][15] ^ carry_bit_layer_adder[13][14]; // calculation of add result
assign carry_bit_layer_adder[13][15] = (layer_data_a[13][15] & layer_data_b[13][15]) | (layer_data_a[13][15] & carry_bit_layer_adder[13][14]) | (layer_data_b[13][15] & carry_bit_layer_adder[13][14]); // calculation of carry bit of adder
assign result_layer_adder[13][16] = layer_data_a[13][16] ^ layer_data_b[13][16] ^ carry_bit_layer_adder[13][15]; // calculation of add result
assign carry_bit_layer_adder[13][16] = (layer_data_a[13][16] & layer_data_b[13][16]) | (layer_data_a[13][16] & carry_bit_layer_adder[13][15]) | (layer_data_b[13][16] & carry_bit_layer_adder[13][15]); // calculation of carry bit of adder
assign result_layer_adder[13][17] = layer_data_a[13][17] ^ layer_data_b[13][17] ^ carry_bit_layer_adder[13][16]; // calculation of add result
assign carry_bit_layer_adder[13][17] = (layer_data_a[13][17] & layer_data_b[13][17]) | (layer_data_a[13][17] & carry_bit_layer_adder[13][16]) | (layer_data_b[13][17] & carry_bit_layer_adder[13][16]); // calculation of carry bit of adder
assign result_layer_adder[13][18] = layer_data_a[13][18] ^ layer_data_b[13][18] ^ carry_bit_layer_adder[13][17]; // calculation of add result
assign carry_bit_layer_adder[13][18] = (layer_data_a[13][18] & layer_data_b[13][18]) | (layer_data_a[13][18] & carry_bit_layer_adder[13][17]) | (layer_data_b[13][18] & carry_bit_layer_adder[13][17]); // calculation of carry bit of adder
assign result_layer_adder[13][19] = layer_data_a[13][19] ^ layer_data_b[13][19] ^ carry_bit_layer_adder[13][18]; // calculation of add result
assign carry_bit_layer_adder[13][19] = (layer_data_a[13][19] & layer_data_b[13][19]) | (layer_data_a[13][19] & carry_bit_layer_adder[13][18]) | (layer_data_b[13][19] & carry_bit_layer_adder[13][18]); // calculation of carry bit of adder
assign result_layer_adder[13][20] = layer_data_a[13][20] ^ layer_data_b[13][20] ^ carry_bit_layer_adder[13][19]; // calculation of add result
assign carry_bit_layer_adder[13][20] = (layer_data_a[13][20] & layer_data_b[13][20]) | (layer_data_a[13][20] & carry_bit_layer_adder[13][19]) | (layer_data_b[13][20] & carry_bit_layer_adder[13][19]); // calculation of carry bit of adder
assign result_layer_adder[13][21] = layer_data_a[13][21] ^ layer_data_b[13][21] ^ carry_bit_layer_adder[13][20]; // calculation of add result
assign carry_bit_layer_adder[13][21] = (layer_data_a[13][21] & layer_data_b[13][21]) | (layer_data_a[13][21] & carry_bit_layer_adder[13][20]) | (layer_data_b[13][21] & carry_bit_layer_adder[13][20]); // calculation of carry bit of adder
assign result_layer_adder[13][22] = layer_data_a[13][22] ^ layer_data_b[13][22] ^ carry_bit_layer_adder[13][21]; // calculation of add result
assign carry_bit_layer_adder[13][22] = (layer_data_a[13][22] & layer_data_b[13][22]) | (layer_data_a[13][22] & carry_bit_layer_adder[13][21]) | (layer_data_b[13][22] & carry_bit_layer_adder[13][21]); // calculation of carry bit of adder
assign result_layer_adder[13][23] = layer_data_a[13][23] ^ layer_data_b[13][23] ^ carry_bit_layer_adder[13][22]; // calculation of add result
assign carry_bit_layer_adder[13][23] = (layer_data_a[13][23] & layer_data_b[13][23]) | (layer_data_a[13][23] & carry_bit_layer_adder[13][22]) | (layer_data_b[13][23] & carry_bit_layer_adder[13][22]); // calculation of carry bit of adder
assign result_layer_adder[13][24] = layer_data_a[13][24] ^ layer_data_b[13][24] ^ carry_bit_layer_adder[13][23]; // calculation of add result
assign carry_bit_layer_adder[13][24] = (layer_data_a[13][24] & layer_data_b[13][24]) | (layer_data_a[13][24] & carry_bit_layer_adder[13][23]) | (layer_data_b[13][24] & carry_bit_layer_adder[13][23]); // calculation of carry bit of adder
assign result_layer_adder[13][25] = layer_data_a[13][25] ^ layer_data_b[13][25] ^ carry_bit_layer_adder[13][24]; // calculation of add result
assign carry_bit_layer_adder[13][25] = (layer_data_a[13][25] & layer_data_b[13][25]) | (layer_data_a[13][25] & carry_bit_layer_adder[13][24]) | (layer_data_b[13][25] & carry_bit_layer_adder[13][24]); // calculation of carry bit of adder
assign result_layer_adder[13][26] = layer_data_a[13][26] ^ layer_data_b[13][26] ^ carry_bit_layer_adder[13][25]; // calculation of add result
assign carry_bit_layer_adder[13][26] = (layer_data_a[13][26] & layer_data_b[13][26]) | (layer_data_a[13][26] & carry_bit_layer_adder[13][25]) | (layer_data_b[13][26] & carry_bit_layer_adder[13][25]); // calculation of carry bit of adder
assign result_layer_adder[13][27] = layer_data_a[13][27] ^ layer_data_b[13][27] ^ carry_bit_layer_adder[13][26]; // calculation of add result
assign carry_bit_layer_adder[13][27] = (layer_data_a[13][27] & layer_data_b[13][27]) | (layer_data_a[13][27] & carry_bit_layer_adder[13][26]) | (layer_data_b[13][27] & carry_bit_layer_adder[13][26]); // calculation of carry bit of adder
assign result_layer_adder[13][28] = layer_data_a[13][28] ^ layer_data_b[13][28] ^ carry_bit_layer_adder[13][27]; // calculation of add result
assign carry_bit_layer_adder[13][28] = (layer_data_a[13][28] & layer_data_b[13][28]) | (layer_data_a[13][28] & carry_bit_layer_adder[13][27]) | (layer_data_b[13][28] & carry_bit_layer_adder[13][27]); // calculation of carry bit of adder
assign result_layer_adder[13][29] = layer_data_a[13][29] ^ layer_data_b[13][29] ^ carry_bit_layer_adder[13][28]; // calculation of add result
assign carry_bit_layer_adder[13][29] = (layer_data_a[13][29] & layer_data_b[13][29]) | (layer_data_a[13][29] & carry_bit_layer_adder[13][28]) | (layer_data_b[13][29] & carry_bit_layer_adder[13][28]); // calculation of carry bit of adder
assign result_layer_adder[13][30] = layer_data_a[13][30] ^ layer_data_b[13][30] ^ carry_bit_layer_adder[13][29]; // calculation of add result
assign carry_bit_layer_adder[13][30] = (layer_data_a[13][30] & layer_data_b[13][30]) | (layer_data_a[13][30] & carry_bit_layer_adder[13][29]) | (layer_data_b[13][30] & carry_bit_layer_adder[13][29]); // calculation of carry bit of adder
assign result_layer_adder[13][31] = layer_data_a[13][31] ^ layer_data_b[13][31] ^ carry_bit_layer_adder[13][30]; // calculation of add result
assign carry_bit_layer_adder[13][31] = (layer_data_a[13][31] & layer_data_b[13][31]) | (layer_data_a[13][31] & carry_bit_layer_adder[13][30]) | (layer_data_b[13][31] & carry_bit_layer_adder[13][30]); // calculation of carry bit of adder
assign result_layer_adder[13][32] = layer_data_a[13][32] ^ layer_data_b[13][32] ^ carry_bit_layer_adder[13][31]; // calculation of add result

// Layer 15
assign layer_data_a[14][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[13][32] == 1'b1) ? {layer_data_a[13][31:0], operand_a[18]} : {result_layer_adder[13][31:0], operand_a[18]}) : {1'b0, result_layer_adder[13][32:1]}; // data select for layer 15
assign layer_data_b[14][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[14] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 15

// Layer 15 adder
assign result_layer_adder[14][0] = layer_data_a[14][0] ^ layer_data_b[14][0]; // calculation of add result
assign carry_bit_layer_adder[14][0] = layer_data_a[14][0] & layer_data_b[14][0]; // calculation of carry bit of adder
assign result_layer_adder[14][1] = layer_data_a[14][1] ^ layer_data_b[14][1] ^ carry_bit_layer_adder[14][0]; // calculation of add result
assign carry_bit_layer_adder[14][1] = (layer_data_a[14][1] & layer_data_b[14][1]) | (layer_data_a[14][1] & carry_bit_layer_adder[14][0]) | (layer_data_b[14][1] & carry_bit_layer_adder[14][0]); // calculation of carry bit of adder
assign result_layer_adder[14][2] = layer_data_a[14][2] ^ layer_data_b[14][2] ^ carry_bit_layer_adder[14][1]; // calculation of add result
assign carry_bit_layer_adder[14][2] = (layer_data_a[14][2] & layer_data_b[14][2]) | (layer_data_a[14][2] & carry_bit_layer_adder[14][1]) | (layer_data_b[14][2] & carry_bit_layer_adder[14][1]); // calculation of carry bit of adder
assign result_layer_adder[14][3] = layer_data_a[14][3] ^ layer_data_b[14][3] ^ carry_bit_layer_adder[14][2]; // calculation of add result
assign carry_bit_layer_adder[14][3] = (layer_data_a[14][3] & layer_data_b[14][3]) | (layer_data_a[14][3] & carry_bit_layer_adder[14][2]) | (layer_data_b[14][3] & carry_bit_layer_adder[14][2]); // calculation of carry bit of adder
assign result_layer_adder[14][4] = layer_data_a[14][4] ^ layer_data_b[14][4] ^ carry_bit_layer_adder[14][3]; // calculation of add result
assign carry_bit_layer_adder[14][4] = (layer_data_a[14][4] & layer_data_b[14][4]) | (layer_data_a[14][4] & carry_bit_layer_adder[14][3]) | (layer_data_b[14][4] & carry_bit_layer_adder[14][3]); // calculation of carry bit of adder
assign result_layer_adder[14][5] = layer_data_a[14][5] ^ layer_data_b[14][5] ^ carry_bit_layer_adder[14][4]; // calculation of add result
assign carry_bit_layer_adder[14][5] = (layer_data_a[14][5] & layer_data_b[14][5]) | (layer_data_a[14][5] & carry_bit_layer_adder[14][4]) | (layer_data_b[14][5] & carry_bit_layer_adder[14][4]); // calculation of carry bit of adder
assign result_layer_adder[14][6] = layer_data_a[14][6] ^ layer_data_b[14][6] ^ carry_bit_layer_adder[14][5]; // calculation of add result
assign carry_bit_layer_adder[14][6] = (layer_data_a[14][6] & layer_data_b[14][6]) | (layer_data_a[14][6] & carry_bit_layer_adder[14][5]) | (layer_data_b[14][6] & carry_bit_layer_adder[14][5]); // calculation of carry bit of adder
assign result_layer_adder[14][7] = layer_data_a[14][7] ^ layer_data_b[14][7] ^ carry_bit_layer_adder[14][6]; // calculation of add result
assign carry_bit_layer_adder[14][7] = (layer_data_a[14][7] & layer_data_b[14][7]) | (layer_data_a[14][7] & carry_bit_layer_adder[14][6]) | (layer_data_b[14][7] & carry_bit_layer_adder[14][6]); // calculation of carry bit of adder
assign result_layer_adder[14][8] = layer_data_a[14][8] ^ layer_data_b[14][8] ^ carry_bit_layer_adder[14][7]; // calculation of add result
assign carry_bit_layer_adder[14][8] = (layer_data_a[14][8] & layer_data_b[14][8]) | (layer_data_a[14][8] & carry_bit_layer_adder[14][7]) | (layer_data_b[14][8] & carry_bit_layer_adder[14][7]); // calculation of carry bit of adder
assign result_layer_adder[14][9] = layer_data_a[14][9] ^ layer_data_b[14][9] ^ carry_bit_layer_adder[14][8]; // calculation of add result
assign carry_bit_layer_adder[14][9] = (layer_data_a[14][9] & layer_data_b[14][9]) | (layer_data_a[14][9] & carry_bit_layer_adder[14][8]) | (layer_data_b[14][9] & carry_bit_layer_adder[14][8]); // calculation of carry bit of adder
assign result_layer_adder[14][10] = layer_data_a[14][10] ^ layer_data_b[14][10] ^ carry_bit_layer_adder[14][9]; // calculation of add result
assign carry_bit_layer_adder[14][10] = (layer_data_a[14][10] & layer_data_b[14][10]) | (layer_data_a[14][10] & carry_bit_layer_adder[14][9]) | (layer_data_b[14][10] & carry_bit_layer_adder[14][9]); // calculation of carry bit of adder
assign result_layer_adder[14][11] = layer_data_a[14][11] ^ layer_data_b[14][11] ^ carry_bit_layer_adder[14][10]; // calculation of add result
assign carry_bit_layer_adder[14][11] = (layer_data_a[14][11] & layer_data_b[14][11]) | (layer_data_a[14][11] & carry_bit_layer_adder[14][10]) | (layer_data_b[14][11] & carry_bit_layer_adder[14][10]); // calculation of carry bit of adder
assign result_layer_adder[14][12] = layer_data_a[14][12] ^ layer_data_b[14][12] ^ carry_bit_layer_adder[14][11]; // calculation of add result
assign carry_bit_layer_adder[14][12] = (layer_data_a[14][12] & layer_data_b[14][12]) | (layer_data_a[14][12] & carry_bit_layer_adder[14][11]) | (layer_data_b[14][12] & carry_bit_layer_adder[14][11]); // calculation of carry bit of adder
assign result_layer_adder[14][13] = layer_data_a[14][13] ^ layer_data_b[14][13] ^ carry_bit_layer_adder[14][12]; // calculation of add result
assign carry_bit_layer_adder[14][13] = (layer_data_a[14][13] & layer_data_b[14][13]) | (layer_data_a[14][13] & carry_bit_layer_adder[14][12]) | (layer_data_b[14][13] & carry_bit_layer_adder[14][12]); // calculation of carry bit of adder
assign result_layer_adder[14][14] = layer_data_a[14][14] ^ layer_data_b[14][14] ^ carry_bit_layer_adder[14][13]; // calculation of add result
assign carry_bit_layer_adder[14][14] = (layer_data_a[14][14] & layer_data_b[14][14]) | (layer_data_a[14][14] & carry_bit_layer_adder[14][13]) | (layer_data_b[14][14] & carry_bit_layer_adder[14][13]); // calculation of carry bit of adder
assign result_layer_adder[14][15] = layer_data_a[14][15] ^ layer_data_b[14][15] ^ carry_bit_layer_adder[14][14]; // calculation of add result
assign carry_bit_layer_adder[14][15] = (layer_data_a[14][15] & layer_data_b[14][15]) | (layer_data_a[14][15] & carry_bit_layer_adder[14][14]) | (layer_data_b[14][15] & carry_bit_layer_adder[14][14]); // calculation of carry bit of adder
assign result_layer_adder[14][16] = layer_data_a[14][16] ^ layer_data_b[14][16] ^ carry_bit_layer_adder[14][15]; // calculation of add result
assign carry_bit_layer_adder[14][16] = (layer_data_a[14][16] & layer_data_b[14][16]) | (layer_data_a[14][16] & carry_bit_layer_adder[14][15]) | (layer_data_b[14][16] & carry_bit_layer_adder[14][15]); // calculation of carry bit of adder
assign result_layer_adder[14][17] = layer_data_a[14][17] ^ layer_data_b[14][17] ^ carry_bit_layer_adder[14][16]; // calculation of add result
assign carry_bit_layer_adder[14][17] = (layer_data_a[14][17] & layer_data_b[14][17]) | (layer_data_a[14][17] & carry_bit_layer_adder[14][16]) | (layer_data_b[14][17] & carry_bit_layer_adder[14][16]); // calculation of carry bit of adder
assign result_layer_adder[14][18] = layer_data_a[14][18] ^ layer_data_b[14][18] ^ carry_bit_layer_adder[14][17]; // calculation of add result
assign carry_bit_layer_adder[14][18] = (layer_data_a[14][18] & layer_data_b[14][18]) | (layer_data_a[14][18] & carry_bit_layer_adder[14][17]) | (layer_data_b[14][18] & carry_bit_layer_adder[14][17]); // calculation of carry bit of adder
assign result_layer_adder[14][19] = layer_data_a[14][19] ^ layer_data_b[14][19] ^ carry_bit_layer_adder[14][18]; // calculation of add result
assign carry_bit_layer_adder[14][19] = (layer_data_a[14][19] & layer_data_b[14][19]) | (layer_data_a[14][19] & carry_bit_layer_adder[14][18]) | (layer_data_b[14][19] & carry_bit_layer_adder[14][18]); // calculation of carry bit of adder
assign result_layer_adder[14][20] = layer_data_a[14][20] ^ layer_data_b[14][20] ^ carry_bit_layer_adder[14][19]; // calculation of add result
assign carry_bit_layer_adder[14][20] = (layer_data_a[14][20] & layer_data_b[14][20]) | (layer_data_a[14][20] & carry_bit_layer_adder[14][19]) | (layer_data_b[14][20] & carry_bit_layer_adder[14][19]); // calculation of carry bit of adder
assign result_layer_adder[14][21] = layer_data_a[14][21] ^ layer_data_b[14][21] ^ carry_bit_layer_adder[14][20]; // calculation of add result
assign carry_bit_layer_adder[14][21] = (layer_data_a[14][21] & layer_data_b[14][21]) | (layer_data_a[14][21] & carry_bit_layer_adder[14][20]) | (layer_data_b[14][21] & carry_bit_layer_adder[14][20]); // calculation of carry bit of adder
assign result_layer_adder[14][22] = layer_data_a[14][22] ^ layer_data_b[14][22] ^ carry_bit_layer_adder[14][21]; // calculation of add result
assign carry_bit_layer_adder[14][22] = (layer_data_a[14][22] & layer_data_b[14][22]) | (layer_data_a[14][22] & carry_bit_layer_adder[14][21]) | (layer_data_b[14][22] & carry_bit_layer_adder[14][21]); // calculation of carry bit of adder
assign result_layer_adder[14][23] = layer_data_a[14][23] ^ layer_data_b[14][23] ^ carry_bit_layer_adder[14][22]; // calculation of add result
assign carry_bit_layer_adder[14][23] = (layer_data_a[14][23] & layer_data_b[14][23]) | (layer_data_a[14][23] & carry_bit_layer_adder[14][22]) | (layer_data_b[14][23] & carry_bit_layer_adder[14][22]); // calculation of carry bit of adder
assign result_layer_adder[14][24] = layer_data_a[14][24] ^ layer_data_b[14][24] ^ carry_bit_layer_adder[14][23]; // calculation of add result
assign carry_bit_layer_adder[14][24] = (layer_data_a[14][24] & layer_data_b[14][24]) | (layer_data_a[14][24] & carry_bit_layer_adder[14][23]) | (layer_data_b[14][24] & carry_bit_layer_adder[14][23]); // calculation of carry bit of adder
assign result_layer_adder[14][25] = layer_data_a[14][25] ^ layer_data_b[14][25] ^ carry_bit_layer_adder[14][24]; // calculation of add result
assign carry_bit_layer_adder[14][25] = (layer_data_a[14][25] & layer_data_b[14][25]) | (layer_data_a[14][25] & carry_bit_layer_adder[14][24]) | (layer_data_b[14][25] & carry_bit_layer_adder[14][24]); // calculation of carry bit of adder
assign result_layer_adder[14][26] = layer_data_a[14][26] ^ layer_data_b[14][26] ^ carry_bit_layer_adder[14][25]; // calculation of add result
assign carry_bit_layer_adder[14][26] = (layer_data_a[14][26] & layer_data_b[14][26]) | (layer_data_a[14][26] & carry_bit_layer_adder[14][25]) | (layer_data_b[14][26] & carry_bit_layer_adder[14][25]); // calculation of carry bit of adder
assign result_layer_adder[14][27] = layer_data_a[14][27] ^ layer_data_b[14][27] ^ carry_bit_layer_adder[14][26]; // calculation of add result
assign carry_bit_layer_adder[14][27] = (layer_data_a[14][27] & layer_data_b[14][27]) | (layer_data_a[14][27] & carry_bit_layer_adder[14][26]) | (layer_data_b[14][27] & carry_bit_layer_adder[14][26]); // calculation of carry bit of adder
assign result_layer_adder[14][28] = layer_data_a[14][28] ^ layer_data_b[14][28] ^ carry_bit_layer_adder[14][27]; // calculation of add result
assign carry_bit_layer_adder[14][28] = (layer_data_a[14][28] & layer_data_b[14][28]) | (layer_data_a[14][28] & carry_bit_layer_adder[14][27]) | (layer_data_b[14][28] & carry_bit_layer_adder[14][27]); // calculation of carry bit of adder
assign result_layer_adder[14][29] = layer_data_a[14][29] ^ layer_data_b[14][29] ^ carry_bit_layer_adder[14][28]; // calculation of add result
assign carry_bit_layer_adder[14][29] = (layer_data_a[14][29] & layer_data_b[14][29]) | (layer_data_a[14][29] & carry_bit_layer_adder[14][28]) | (layer_data_b[14][29] & carry_bit_layer_adder[14][28]); // calculation of carry bit of adder
assign result_layer_adder[14][30] = layer_data_a[14][30] ^ layer_data_b[14][30] ^ carry_bit_layer_adder[14][29]; // calculation of add result
assign carry_bit_layer_adder[14][30] = (layer_data_a[14][30] & layer_data_b[14][30]) | (layer_data_a[14][30] & carry_bit_layer_adder[14][29]) | (layer_data_b[14][30] & carry_bit_layer_adder[14][29]); // calculation of carry bit of adder
assign result_layer_adder[14][31] = layer_data_a[14][31] ^ layer_data_b[14][31] ^ carry_bit_layer_adder[14][30]; // calculation of add result
assign carry_bit_layer_adder[14][31] = (layer_data_a[14][31] & layer_data_b[14][31]) | (layer_data_a[14][31] & carry_bit_layer_adder[14][30]) | (layer_data_b[14][31] & carry_bit_layer_adder[14][30]); // calculation of carry bit of adder
assign result_layer_adder[14][32] = layer_data_a[14][32] ^ layer_data_b[14][32] ^ carry_bit_layer_adder[14][31]; // calculation of add result

// Layer 16
assign layer_data_a[15][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[14][32] == 1'b1) ? {layer_data_a[14][31:0], operand_a[17]} : {result_layer_adder[14][31:0], operand_a[17]}) : {1'b0, result_layer_adder[14][32:1]}; // data select for layer 16
assign layer_data_b[15][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[15] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 16

// Layer 16 adder
assign result_layer_adder[15][0] = layer_data_a[15][0] ^ layer_data_b[15][0]; // calculation of add result
assign carry_bit_layer_adder[15][0] = layer_data_a[15][0] & layer_data_b[15][0]; // calculation of carry bit of adder
assign result_layer_adder[15][1] = layer_data_a[15][1] ^ layer_data_b[15][1] ^ carry_bit_layer_adder[15][0]; // calculation of add result
assign carry_bit_layer_adder[15][1] = (layer_data_a[15][1] & layer_data_b[15][1]) | (layer_data_a[15][1] & carry_bit_layer_adder[15][0]) | (layer_data_b[15][1] & carry_bit_layer_adder[15][0]); // calculation of carry bit of adder
assign result_layer_adder[15][2] = layer_data_a[15][2] ^ layer_data_b[15][2] ^ carry_bit_layer_adder[15][1]; // calculation of add result
assign carry_bit_layer_adder[15][2] = (layer_data_a[15][2] & layer_data_b[15][2]) | (layer_data_a[15][2] & carry_bit_layer_adder[15][1]) | (layer_data_b[15][2] & carry_bit_layer_adder[15][1]); // calculation of carry bit of adder
assign result_layer_adder[15][3] = layer_data_a[15][3] ^ layer_data_b[15][3] ^ carry_bit_layer_adder[15][2]; // calculation of add result
assign carry_bit_layer_adder[15][3] = (layer_data_a[15][3] & layer_data_b[15][3]) | (layer_data_a[15][3] & carry_bit_layer_adder[15][2]) | (layer_data_b[15][3] & carry_bit_layer_adder[15][2]); // calculation of carry bit of adder
assign result_layer_adder[15][4] = layer_data_a[15][4] ^ layer_data_b[15][4] ^ carry_bit_layer_adder[15][3]; // calculation of add result
assign carry_bit_layer_adder[15][4] = (layer_data_a[15][4] & layer_data_b[15][4]) | (layer_data_a[15][4] & carry_bit_layer_adder[15][3]) | (layer_data_b[15][4] & carry_bit_layer_adder[15][3]); // calculation of carry bit of adder
assign result_layer_adder[15][5] = layer_data_a[15][5] ^ layer_data_b[15][5] ^ carry_bit_layer_adder[15][4]; // calculation of add result
assign carry_bit_layer_adder[15][5] = (layer_data_a[15][5] & layer_data_b[15][5]) | (layer_data_a[15][5] & carry_bit_layer_adder[15][4]) | (layer_data_b[15][5] & carry_bit_layer_adder[15][4]); // calculation of carry bit of adder
assign result_layer_adder[15][6] = layer_data_a[15][6] ^ layer_data_b[15][6] ^ carry_bit_layer_adder[15][5]; // calculation of add result
assign carry_bit_layer_adder[15][6] = (layer_data_a[15][6] & layer_data_b[15][6]) | (layer_data_a[15][6] & carry_bit_layer_adder[15][5]) | (layer_data_b[15][6] & carry_bit_layer_adder[15][5]); // calculation of carry bit of adder
assign result_layer_adder[15][7] = layer_data_a[15][7] ^ layer_data_b[15][7] ^ carry_bit_layer_adder[15][6]; // calculation of add result
assign carry_bit_layer_adder[15][7] = (layer_data_a[15][7] & layer_data_b[15][7]) | (layer_data_a[15][7] & carry_bit_layer_adder[15][6]) | (layer_data_b[15][7] & carry_bit_layer_adder[15][6]); // calculation of carry bit of adder
assign result_layer_adder[15][8] = layer_data_a[15][8] ^ layer_data_b[15][8] ^ carry_bit_layer_adder[15][7]; // calculation of add result
assign carry_bit_layer_adder[15][8] = (layer_data_a[15][8] & layer_data_b[15][8]) | (layer_data_a[15][8] & carry_bit_layer_adder[15][7]) | (layer_data_b[15][8] & carry_bit_layer_adder[15][7]); // calculation of carry bit of adder
assign result_layer_adder[15][9] = layer_data_a[15][9] ^ layer_data_b[15][9] ^ carry_bit_layer_adder[15][8]; // calculation of add result
assign carry_bit_layer_adder[15][9] = (layer_data_a[15][9] & layer_data_b[15][9]) | (layer_data_a[15][9] & carry_bit_layer_adder[15][8]) | (layer_data_b[15][9] & carry_bit_layer_adder[15][8]); // calculation of carry bit of adder
assign result_layer_adder[15][10] = layer_data_a[15][10] ^ layer_data_b[15][10] ^ carry_bit_layer_adder[15][9]; // calculation of add result
assign carry_bit_layer_adder[15][10] = (layer_data_a[15][10] & layer_data_b[15][10]) | (layer_data_a[15][10] & carry_bit_layer_adder[15][9]) | (layer_data_b[15][10] & carry_bit_layer_adder[15][9]); // calculation of carry bit of adder
assign result_layer_adder[15][11] = layer_data_a[15][11] ^ layer_data_b[15][11] ^ carry_bit_layer_adder[15][10]; // calculation of add result
assign carry_bit_layer_adder[15][11] = (layer_data_a[15][11] & layer_data_b[15][11]) | (layer_data_a[15][11] & carry_bit_layer_adder[15][10]) | (layer_data_b[15][11] & carry_bit_layer_adder[15][10]); // calculation of carry bit of adder
assign result_layer_adder[15][12] = layer_data_a[15][12] ^ layer_data_b[15][12] ^ carry_bit_layer_adder[15][11]; // calculation of add result
assign carry_bit_layer_adder[15][12] = (layer_data_a[15][12] & layer_data_b[15][12]) | (layer_data_a[15][12] & carry_bit_layer_adder[15][11]) | (layer_data_b[15][12] & carry_bit_layer_adder[15][11]); // calculation of carry bit of adder
assign result_layer_adder[15][13] = layer_data_a[15][13] ^ layer_data_b[15][13] ^ carry_bit_layer_adder[15][12]; // calculation of add result
assign carry_bit_layer_adder[15][13] = (layer_data_a[15][13] & layer_data_b[15][13]) | (layer_data_a[15][13] & carry_bit_layer_adder[15][12]) | (layer_data_b[15][13] & carry_bit_layer_adder[15][12]); // calculation of carry bit of adder
assign result_layer_adder[15][14] = layer_data_a[15][14] ^ layer_data_b[15][14] ^ carry_bit_layer_adder[15][13]; // calculation of add result
assign carry_bit_layer_adder[15][14] = (layer_data_a[15][14] & layer_data_b[15][14]) | (layer_data_a[15][14] & carry_bit_layer_adder[15][13]) | (layer_data_b[15][14] & carry_bit_layer_adder[15][13]); // calculation of carry bit of adder
assign result_layer_adder[15][15] = layer_data_a[15][15] ^ layer_data_b[15][15] ^ carry_bit_layer_adder[15][14]; // calculation of add result
assign carry_bit_layer_adder[15][15] = (layer_data_a[15][15] & layer_data_b[15][15]) | (layer_data_a[15][15] & carry_bit_layer_adder[15][14]) | (layer_data_b[15][15] & carry_bit_layer_adder[15][14]); // calculation of carry bit of adder
assign result_layer_adder[15][16] = layer_data_a[15][16] ^ layer_data_b[15][16] ^ carry_bit_layer_adder[15][15]; // calculation of add result
assign carry_bit_layer_adder[15][16] = (layer_data_a[15][16] & layer_data_b[15][16]) | (layer_data_a[15][16] & carry_bit_layer_adder[15][15]) | (layer_data_b[15][16] & carry_bit_layer_adder[15][15]); // calculation of carry bit of adder
assign result_layer_adder[15][17] = layer_data_a[15][17] ^ layer_data_b[15][17] ^ carry_bit_layer_adder[15][16]; // calculation of add result
assign carry_bit_layer_adder[15][17] = (layer_data_a[15][17] & layer_data_b[15][17]) | (layer_data_a[15][17] & carry_bit_layer_adder[15][16]) | (layer_data_b[15][17] & carry_bit_layer_adder[15][16]); // calculation of carry bit of adder
assign result_layer_adder[15][18] = layer_data_a[15][18] ^ layer_data_b[15][18] ^ carry_bit_layer_adder[15][17]; // calculation of add result
assign carry_bit_layer_adder[15][18] = (layer_data_a[15][18] & layer_data_b[15][18]) | (layer_data_a[15][18] & carry_bit_layer_adder[15][17]) | (layer_data_b[15][18] & carry_bit_layer_adder[15][17]); // calculation of carry bit of adder
assign result_layer_adder[15][19] = layer_data_a[15][19] ^ layer_data_b[15][19] ^ carry_bit_layer_adder[15][18]; // calculation of add result
assign carry_bit_layer_adder[15][19] = (layer_data_a[15][19] & layer_data_b[15][19]) | (layer_data_a[15][19] & carry_bit_layer_adder[15][18]) | (layer_data_b[15][19] & carry_bit_layer_adder[15][18]); // calculation of carry bit of adder
assign result_layer_adder[15][20] = layer_data_a[15][20] ^ layer_data_b[15][20] ^ carry_bit_layer_adder[15][19]; // calculation of add result
assign carry_bit_layer_adder[15][20] = (layer_data_a[15][20] & layer_data_b[15][20]) | (layer_data_a[15][20] & carry_bit_layer_adder[15][19]) | (layer_data_b[15][20] & carry_bit_layer_adder[15][19]); // calculation of carry bit of adder
assign result_layer_adder[15][21] = layer_data_a[15][21] ^ layer_data_b[15][21] ^ carry_bit_layer_adder[15][20]; // calculation of add result
assign carry_bit_layer_adder[15][21] = (layer_data_a[15][21] & layer_data_b[15][21]) | (layer_data_a[15][21] & carry_bit_layer_adder[15][20]) | (layer_data_b[15][21] & carry_bit_layer_adder[15][20]); // calculation of carry bit of adder
assign result_layer_adder[15][22] = layer_data_a[15][22] ^ layer_data_b[15][22] ^ carry_bit_layer_adder[15][21]; // calculation of add result
assign carry_bit_layer_adder[15][22] = (layer_data_a[15][22] & layer_data_b[15][22]) | (layer_data_a[15][22] & carry_bit_layer_adder[15][21]) | (layer_data_b[15][22] & carry_bit_layer_adder[15][21]); // calculation of carry bit of adder
assign result_layer_adder[15][23] = layer_data_a[15][23] ^ layer_data_b[15][23] ^ carry_bit_layer_adder[15][22]; // calculation of add result
assign carry_bit_layer_adder[15][23] = (layer_data_a[15][23] & layer_data_b[15][23]) | (layer_data_a[15][23] & carry_bit_layer_adder[15][22]) | (layer_data_b[15][23] & carry_bit_layer_adder[15][22]); // calculation of carry bit of adder
assign result_layer_adder[15][24] = layer_data_a[15][24] ^ layer_data_b[15][24] ^ carry_bit_layer_adder[15][23]; // calculation of add result
assign carry_bit_layer_adder[15][24] = (layer_data_a[15][24] & layer_data_b[15][24]) | (layer_data_a[15][24] & carry_bit_layer_adder[15][23]) | (layer_data_b[15][24] & carry_bit_layer_adder[15][23]); // calculation of carry bit of adder
assign result_layer_adder[15][25] = layer_data_a[15][25] ^ layer_data_b[15][25] ^ carry_bit_layer_adder[15][24]; // calculation of add result
assign carry_bit_layer_adder[15][25] = (layer_data_a[15][25] & layer_data_b[15][25]) | (layer_data_a[15][25] & carry_bit_layer_adder[15][24]) | (layer_data_b[15][25] & carry_bit_layer_adder[15][24]); // calculation of carry bit of adder
assign result_layer_adder[15][26] = layer_data_a[15][26] ^ layer_data_b[15][26] ^ carry_bit_layer_adder[15][25]; // calculation of add result
assign carry_bit_layer_adder[15][26] = (layer_data_a[15][26] & layer_data_b[15][26]) | (layer_data_a[15][26] & carry_bit_layer_adder[15][25]) | (layer_data_b[15][26] & carry_bit_layer_adder[15][25]); // calculation of carry bit of adder
assign result_layer_adder[15][27] = layer_data_a[15][27] ^ layer_data_b[15][27] ^ carry_bit_layer_adder[15][26]; // calculation of add result
assign carry_bit_layer_adder[15][27] = (layer_data_a[15][27] & layer_data_b[15][27]) | (layer_data_a[15][27] & carry_bit_layer_adder[15][26]) | (layer_data_b[15][27] & carry_bit_layer_adder[15][26]); // calculation of carry bit of adder
assign result_layer_adder[15][28] = layer_data_a[15][28] ^ layer_data_b[15][28] ^ carry_bit_layer_adder[15][27]; // calculation of add result
assign carry_bit_layer_adder[15][28] = (layer_data_a[15][28] & layer_data_b[15][28]) | (layer_data_a[15][28] & carry_bit_layer_adder[15][27]) | (layer_data_b[15][28] & carry_bit_layer_adder[15][27]); // calculation of carry bit of adder
assign result_layer_adder[15][29] = layer_data_a[15][29] ^ layer_data_b[15][29] ^ carry_bit_layer_adder[15][28]; // calculation of add result
assign carry_bit_layer_adder[15][29] = (layer_data_a[15][29] & layer_data_b[15][29]) | (layer_data_a[15][29] & carry_bit_layer_adder[15][28]) | (layer_data_b[15][29] & carry_bit_layer_adder[15][28]); // calculation of carry bit of adder
assign result_layer_adder[15][30] = layer_data_a[15][30] ^ layer_data_b[15][30] ^ carry_bit_layer_adder[15][29]; // calculation of add result
assign carry_bit_layer_adder[15][30] = (layer_data_a[15][30] & layer_data_b[15][30]) | (layer_data_a[15][30] & carry_bit_layer_adder[15][29]) | (layer_data_b[15][30] & carry_bit_layer_adder[15][29]); // calculation of carry bit of adder
assign result_layer_adder[15][31] = layer_data_a[15][31] ^ layer_data_b[15][31] ^ carry_bit_layer_adder[15][30]; // calculation of add result
assign carry_bit_layer_adder[15][31] = (layer_data_a[15][31] & layer_data_b[15][31]) | (layer_data_a[15][31] & carry_bit_layer_adder[15][30]) | (layer_data_b[15][31] & carry_bit_layer_adder[15][30]); // calculation of carry bit of adder
assign result_layer_adder[15][32] = layer_data_a[15][32] ^ layer_data_b[15][32] ^ carry_bit_layer_adder[15][31]; // calculation of add result

// Layer 17
assign layer_data_a[16][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[15][32] == 1'b1) ? {layer_data_a[15][31:0], operand_a[16]} : {result_layer_adder[15][31:0], operand_a[16]}) : {1'b0, result_layer_adder[15][32:1]}; // data select for layer 17
assign layer_data_b[16][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[16] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 17

// Layer 17 adder
assign result_layer_adder[16][0] = layer_data_a[16][0] ^ layer_data_b[16][0]; // calculation of add result
assign carry_bit_layer_adder[16][0] = layer_data_a[16][0] & layer_data_b[16][0]; // calculation of carry bit of adder
assign result_layer_adder[16][1] = layer_data_a[16][1] ^ layer_data_b[16][1] ^ carry_bit_layer_adder[16][0]; // calculation of add result
assign carry_bit_layer_adder[16][1] = (layer_data_a[16][1] & layer_data_b[16][1]) | (layer_data_a[16][1] & carry_bit_layer_adder[16][0]) | (layer_data_b[16][1] & carry_bit_layer_adder[16][0]); // calculation of carry bit of adder
assign result_layer_adder[16][2] = layer_data_a[16][2] ^ layer_data_b[16][2] ^ carry_bit_layer_adder[16][1]; // calculation of add result
assign carry_bit_layer_adder[16][2] = (layer_data_a[16][2] & layer_data_b[16][2]) | (layer_data_a[16][2] & carry_bit_layer_adder[16][1]) | (layer_data_b[16][2] & carry_bit_layer_adder[16][1]); // calculation of carry bit of adder
assign result_layer_adder[16][3] = layer_data_a[16][3] ^ layer_data_b[16][3] ^ carry_bit_layer_adder[16][2]; // calculation of add result
assign carry_bit_layer_adder[16][3] = (layer_data_a[16][3] & layer_data_b[16][3]) | (layer_data_a[16][3] & carry_bit_layer_adder[16][2]) | (layer_data_b[16][3] & carry_bit_layer_adder[16][2]); // calculation of carry bit of adder
assign result_layer_adder[16][4] = layer_data_a[16][4] ^ layer_data_b[16][4] ^ carry_bit_layer_adder[16][3]; // calculation of add result
assign carry_bit_layer_adder[16][4] = (layer_data_a[16][4] & layer_data_b[16][4]) | (layer_data_a[16][4] & carry_bit_layer_adder[16][3]) | (layer_data_b[16][4] & carry_bit_layer_adder[16][3]); // calculation of carry bit of adder
assign result_layer_adder[16][5] = layer_data_a[16][5] ^ layer_data_b[16][5] ^ carry_bit_layer_adder[16][4]; // calculation of add result
assign carry_bit_layer_adder[16][5] = (layer_data_a[16][5] & layer_data_b[16][5]) | (layer_data_a[16][5] & carry_bit_layer_adder[16][4]) | (layer_data_b[16][5] & carry_bit_layer_adder[16][4]); // calculation of carry bit of adder
assign result_layer_adder[16][6] = layer_data_a[16][6] ^ layer_data_b[16][6] ^ carry_bit_layer_adder[16][5]; // calculation of add result
assign carry_bit_layer_adder[16][6] = (layer_data_a[16][6] & layer_data_b[16][6]) | (layer_data_a[16][6] & carry_bit_layer_adder[16][5]) | (layer_data_b[16][6] & carry_bit_layer_adder[16][5]); // calculation of carry bit of adder
assign result_layer_adder[16][7] = layer_data_a[16][7] ^ layer_data_b[16][7] ^ carry_bit_layer_adder[16][6]; // calculation of add result
assign carry_bit_layer_adder[16][7] = (layer_data_a[16][7] & layer_data_b[16][7]) | (layer_data_a[16][7] & carry_bit_layer_adder[16][6]) | (layer_data_b[16][7] & carry_bit_layer_adder[16][6]); // calculation of carry bit of adder
assign result_layer_adder[16][8] = layer_data_a[16][8] ^ layer_data_b[16][8] ^ carry_bit_layer_adder[16][7]; // calculation of add result
assign carry_bit_layer_adder[16][8] = (layer_data_a[16][8] & layer_data_b[16][8]) | (layer_data_a[16][8] & carry_bit_layer_adder[16][7]) | (layer_data_b[16][8] & carry_bit_layer_adder[16][7]); // calculation of carry bit of adder
assign result_layer_adder[16][9] = layer_data_a[16][9] ^ layer_data_b[16][9] ^ carry_bit_layer_adder[16][8]; // calculation of add result
assign carry_bit_layer_adder[16][9] = (layer_data_a[16][9] & layer_data_b[16][9]) | (layer_data_a[16][9] & carry_bit_layer_adder[16][8]) | (layer_data_b[16][9] & carry_bit_layer_adder[16][8]); // calculation of carry bit of adder
assign result_layer_adder[16][10] = layer_data_a[16][10] ^ layer_data_b[16][10] ^ carry_bit_layer_adder[16][9]; // calculation of add result
assign carry_bit_layer_adder[16][10] = (layer_data_a[16][10] & layer_data_b[16][10]) | (layer_data_a[16][10] & carry_bit_layer_adder[16][9]) | (layer_data_b[16][10] & carry_bit_layer_adder[16][9]); // calculation of carry bit of adder
assign result_layer_adder[16][11] = layer_data_a[16][11] ^ layer_data_b[16][11] ^ carry_bit_layer_adder[16][10]; // calculation of add result
assign carry_bit_layer_adder[16][11] = (layer_data_a[16][11] & layer_data_b[16][11]) | (layer_data_a[16][11] & carry_bit_layer_adder[16][10]) | (layer_data_b[16][11] & carry_bit_layer_adder[16][10]); // calculation of carry bit of adder
assign result_layer_adder[16][12] = layer_data_a[16][12] ^ layer_data_b[16][12] ^ carry_bit_layer_adder[16][11]; // calculation of add result
assign carry_bit_layer_adder[16][12] = (layer_data_a[16][12] & layer_data_b[16][12]) | (layer_data_a[16][12] & carry_bit_layer_adder[16][11]) | (layer_data_b[16][12] & carry_bit_layer_adder[16][11]); // calculation of carry bit of adder
assign result_layer_adder[16][13] = layer_data_a[16][13] ^ layer_data_b[16][13] ^ carry_bit_layer_adder[16][12]; // calculation of add result
assign carry_bit_layer_adder[16][13] = (layer_data_a[16][13] & layer_data_b[16][13]) | (layer_data_a[16][13] & carry_bit_layer_adder[16][12]) | (layer_data_b[16][13] & carry_bit_layer_adder[16][12]); // calculation of carry bit of adder
assign result_layer_adder[16][14] = layer_data_a[16][14] ^ layer_data_b[16][14] ^ carry_bit_layer_adder[16][13]; // calculation of add result
assign carry_bit_layer_adder[16][14] = (layer_data_a[16][14] & layer_data_b[16][14]) | (layer_data_a[16][14] & carry_bit_layer_adder[16][13]) | (layer_data_b[16][14] & carry_bit_layer_adder[16][13]); // calculation of carry bit of adder
assign result_layer_adder[16][15] = layer_data_a[16][15] ^ layer_data_b[16][15] ^ carry_bit_layer_adder[16][14]; // calculation of add result
assign carry_bit_layer_adder[16][15] = (layer_data_a[16][15] & layer_data_b[16][15]) | (layer_data_a[16][15] & carry_bit_layer_adder[16][14]) | (layer_data_b[16][15] & carry_bit_layer_adder[16][14]); // calculation of carry bit of adder
assign result_layer_adder[16][16] = layer_data_a[16][16] ^ layer_data_b[16][16] ^ carry_bit_layer_adder[16][15]; // calculation of add result
assign carry_bit_layer_adder[16][16] = (layer_data_a[16][16] & layer_data_b[16][16]) | (layer_data_a[16][16] & carry_bit_layer_adder[16][15]) | (layer_data_b[16][16] & carry_bit_layer_adder[16][15]); // calculation of carry bit of adder
assign result_layer_adder[16][17] = layer_data_a[16][17] ^ layer_data_b[16][17] ^ carry_bit_layer_adder[16][16]; // calculation of add result
assign carry_bit_layer_adder[16][17] = (layer_data_a[16][17] & layer_data_b[16][17]) | (layer_data_a[16][17] & carry_bit_layer_adder[16][16]) | (layer_data_b[16][17] & carry_bit_layer_adder[16][16]); // calculation of carry bit of adder
assign result_layer_adder[16][18] = layer_data_a[16][18] ^ layer_data_b[16][18] ^ carry_bit_layer_adder[16][17]; // calculation of add result
assign carry_bit_layer_adder[16][18] = (layer_data_a[16][18] & layer_data_b[16][18]) | (layer_data_a[16][18] & carry_bit_layer_adder[16][17]) | (layer_data_b[16][18] & carry_bit_layer_adder[16][17]); // calculation of carry bit of adder
assign result_layer_adder[16][19] = layer_data_a[16][19] ^ layer_data_b[16][19] ^ carry_bit_layer_adder[16][18]; // calculation of add result
assign carry_bit_layer_adder[16][19] = (layer_data_a[16][19] & layer_data_b[16][19]) | (layer_data_a[16][19] & carry_bit_layer_adder[16][18]) | (layer_data_b[16][19] & carry_bit_layer_adder[16][18]); // calculation of carry bit of adder
assign result_layer_adder[16][20] = layer_data_a[16][20] ^ layer_data_b[16][20] ^ carry_bit_layer_adder[16][19]; // calculation of add result
assign carry_bit_layer_adder[16][20] = (layer_data_a[16][20] & layer_data_b[16][20]) | (layer_data_a[16][20] & carry_bit_layer_adder[16][19]) | (layer_data_b[16][20] & carry_bit_layer_adder[16][19]); // calculation of carry bit of adder
assign result_layer_adder[16][21] = layer_data_a[16][21] ^ layer_data_b[16][21] ^ carry_bit_layer_adder[16][20]; // calculation of add result
assign carry_bit_layer_adder[16][21] = (layer_data_a[16][21] & layer_data_b[16][21]) | (layer_data_a[16][21] & carry_bit_layer_adder[16][20]) | (layer_data_b[16][21] & carry_bit_layer_adder[16][20]); // calculation of carry bit of adder
assign result_layer_adder[16][22] = layer_data_a[16][22] ^ layer_data_b[16][22] ^ carry_bit_layer_adder[16][21]; // calculation of add result
assign carry_bit_layer_adder[16][22] = (layer_data_a[16][22] & layer_data_b[16][22]) | (layer_data_a[16][22] & carry_bit_layer_adder[16][21]) | (layer_data_b[16][22] & carry_bit_layer_adder[16][21]); // calculation of carry bit of adder
assign result_layer_adder[16][23] = layer_data_a[16][23] ^ layer_data_b[16][23] ^ carry_bit_layer_adder[16][22]; // calculation of add result
assign carry_bit_layer_adder[16][23] = (layer_data_a[16][23] & layer_data_b[16][23]) | (layer_data_a[16][23] & carry_bit_layer_adder[16][22]) | (layer_data_b[16][23] & carry_bit_layer_adder[16][22]); // calculation of carry bit of adder
assign result_layer_adder[16][24] = layer_data_a[16][24] ^ layer_data_b[16][24] ^ carry_bit_layer_adder[16][23]; // calculation of add result
assign carry_bit_layer_adder[16][24] = (layer_data_a[16][24] & layer_data_b[16][24]) | (layer_data_a[16][24] & carry_bit_layer_adder[16][23]) | (layer_data_b[16][24] & carry_bit_layer_adder[16][23]); // calculation of carry bit of adder
assign result_layer_adder[16][25] = layer_data_a[16][25] ^ layer_data_b[16][25] ^ carry_bit_layer_adder[16][24]; // calculation of add result
assign carry_bit_layer_adder[16][25] = (layer_data_a[16][25] & layer_data_b[16][25]) | (layer_data_a[16][25] & carry_bit_layer_adder[16][24]) | (layer_data_b[16][25] & carry_bit_layer_adder[16][24]); // calculation of carry bit of adder
assign result_layer_adder[16][26] = layer_data_a[16][26] ^ layer_data_b[16][26] ^ carry_bit_layer_adder[16][25]; // calculation of add result
assign carry_bit_layer_adder[16][26] = (layer_data_a[16][26] & layer_data_b[16][26]) | (layer_data_a[16][26] & carry_bit_layer_adder[16][25]) | (layer_data_b[16][26] & carry_bit_layer_adder[16][25]); // calculation of carry bit of adder
assign result_layer_adder[16][27] = layer_data_a[16][27] ^ layer_data_b[16][27] ^ carry_bit_layer_adder[16][26]; // calculation of add result
assign carry_bit_layer_adder[16][27] = (layer_data_a[16][27] & layer_data_b[16][27]) | (layer_data_a[16][27] & carry_bit_layer_adder[16][26]) | (layer_data_b[16][27] & carry_bit_layer_adder[16][26]); // calculation of carry bit of adder
assign result_layer_adder[16][28] = layer_data_a[16][28] ^ layer_data_b[16][28] ^ carry_bit_layer_adder[16][27]; // calculation of add result
assign carry_bit_layer_adder[16][28] = (layer_data_a[16][28] & layer_data_b[16][28]) | (layer_data_a[16][28] & carry_bit_layer_adder[16][27]) | (layer_data_b[16][28] & carry_bit_layer_adder[16][27]); // calculation of carry bit of adder
assign result_layer_adder[16][29] = layer_data_a[16][29] ^ layer_data_b[16][29] ^ carry_bit_layer_adder[16][28]; // calculation of add result
assign carry_bit_layer_adder[16][29] = (layer_data_a[16][29] & layer_data_b[16][29]) | (layer_data_a[16][29] & carry_bit_layer_adder[16][28]) | (layer_data_b[16][29] & carry_bit_layer_adder[16][28]); // calculation of carry bit of adder
assign result_layer_adder[16][30] = layer_data_a[16][30] ^ layer_data_b[16][30] ^ carry_bit_layer_adder[16][29]; // calculation of add result
assign carry_bit_layer_adder[16][30] = (layer_data_a[16][30] & layer_data_b[16][30]) | (layer_data_a[16][30] & carry_bit_layer_adder[16][29]) | (layer_data_b[16][30] & carry_bit_layer_adder[16][29]); // calculation of carry bit of adder
assign result_layer_adder[16][31] = layer_data_a[16][31] ^ layer_data_b[16][31] ^ carry_bit_layer_adder[16][30]; // calculation of add result
assign carry_bit_layer_adder[16][31] = (layer_data_a[16][31] & layer_data_b[16][31]) | (layer_data_a[16][31] & carry_bit_layer_adder[16][30]) | (layer_data_b[16][31] & carry_bit_layer_adder[16][30]); // calculation of carry bit of adder
assign result_layer_adder[16][32] = layer_data_a[16][32] ^ layer_data_b[16][32] ^ carry_bit_layer_adder[16][31]; // calculation of add result

// Layer 18
assign layer_data_a[17][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[16][32] == 1'b1) ? {layer_data_a[16][31:0], operand_a[15]} : {result_layer_adder[16][31:0], operand_a[15]}) : {1'b0, result_layer_adder[16][32:1]}; // data select for layer 18
assign layer_data_b[17][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[17] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 18

// Layer 18 adder
assign result_layer_adder[17][0] = layer_data_a[17][0] ^ layer_data_b[17][0]; // calculation of add result
assign carry_bit_layer_adder[17][0] = layer_data_a[17][0] & layer_data_b[17][0]; // calculation of carry bit of adder
assign result_layer_adder[17][1] = layer_data_a[17][1] ^ layer_data_b[17][1] ^ carry_bit_layer_adder[17][0]; // calculation of add result
assign carry_bit_layer_adder[17][1] = (layer_data_a[17][1] & layer_data_b[17][1]) | (layer_data_a[17][1] & carry_bit_layer_adder[17][0]) | (layer_data_b[17][1] & carry_bit_layer_adder[17][0]); // calculation of carry bit of adder
assign result_layer_adder[17][2] = layer_data_a[17][2] ^ layer_data_b[17][2] ^ carry_bit_layer_adder[17][1]; // calculation of add result
assign carry_bit_layer_adder[17][2] = (layer_data_a[17][2] & layer_data_b[17][2]) | (layer_data_a[17][2] & carry_bit_layer_adder[17][1]) | (layer_data_b[17][2] & carry_bit_layer_adder[17][1]); // calculation of carry bit of adder
assign result_layer_adder[17][3] = layer_data_a[17][3] ^ layer_data_b[17][3] ^ carry_bit_layer_adder[17][2]; // calculation of add result
assign carry_bit_layer_adder[17][3] = (layer_data_a[17][3] & layer_data_b[17][3]) | (layer_data_a[17][3] & carry_bit_layer_adder[17][2]) | (layer_data_b[17][3] & carry_bit_layer_adder[17][2]); // calculation of carry bit of adder
assign result_layer_adder[17][4] = layer_data_a[17][4] ^ layer_data_b[17][4] ^ carry_bit_layer_adder[17][3]; // calculation of add result
assign carry_bit_layer_adder[17][4] = (layer_data_a[17][4] & layer_data_b[17][4]) | (layer_data_a[17][4] & carry_bit_layer_adder[17][3]) | (layer_data_b[17][4] & carry_bit_layer_adder[17][3]); // calculation of carry bit of adder
assign result_layer_adder[17][5] = layer_data_a[17][5] ^ layer_data_b[17][5] ^ carry_bit_layer_adder[17][4]; // calculation of add result
assign carry_bit_layer_adder[17][5] = (layer_data_a[17][5] & layer_data_b[17][5]) | (layer_data_a[17][5] & carry_bit_layer_adder[17][4]) | (layer_data_b[17][5] & carry_bit_layer_adder[17][4]); // calculation of carry bit of adder
assign result_layer_adder[17][6] = layer_data_a[17][6] ^ layer_data_b[17][6] ^ carry_bit_layer_adder[17][5]; // calculation of add result
assign carry_bit_layer_adder[17][6] = (layer_data_a[17][6] & layer_data_b[17][6]) | (layer_data_a[17][6] & carry_bit_layer_adder[17][5]) | (layer_data_b[17][6] & carry_bit_layer_adder[17][5]); // calculation of carry bit of adder
assign result_layer_adder[17][7] = layer_data_a[17][7] ^ layer_data_b[17][7] ^ carry_bit_layer_adder[17][6]; // calculation of add result
assign carry_bit_layer_adder[17][7] = (layer_data_a[17][7] & layer_data_b[17][7]) | (layer_data_a[17][7] & carry_bit_layer_adder[17][6]) | (layer_data_b[17][7] & carry_bit_layer_adder[17][6]); // calculation of carry bit of adder
assign result_layer_adder[17][8] = layer_data_a[17][8] ^ layer_data_b[17][8] ^ carry_bit_layer_adder[17][7]; // calculation of add result
assign carry_bit_layer_adder[17][8] = (layer_data_a[17][8] & layer_data_b[17][8]) | (layer_data_a[17][8] & carry_bit_layer_adder[17][7]) | (layer_data_b[17][8] & carry_bit_layer_adder[17][7]); // calculation of carry bit of adder
assign result_layer_adder[17][9] = layer_data_a[17][9] ^ layer_data_b[17][9] ^ carry_bit_layer_adder[17][8]; // calculation of add result
assign carry_bit_layer_adder[17][9] = (layer_data_a[17][9] & layer_data_b[17][9]) | (layer_data_a[17][9] & carry_bit_layer_adder[17][8]) | (layer_data_b[17][9] & carry_bit_layer_adder[17][8]); // calculation of carry bit of adder
assign result_layer_adder[17][10] = layer_data_a[17][10] ^ layer_data_b[17][10] ^ carry_bit_layer_adder[17][9]; // calculation of add result
assign carry_bit_layer_adder[17][10] = (layer_data_a[17][10] & layer_data_b[17][10]) | (layer_data_a[17][10] & carry_bit_layer_adder[17][9]) | (layer_data_b[17][10] & carry_bit_layer_adder[17][9]); // calculation of carry bit of adder
assign result_layer_adder[17][11] = layer_data_a[17][11] ^ layer_data_b[17][11] ^ carry_bit_layer_adder[17][10]; // calculation of add result
assign carry_bit_layer_adder[17][11] = (layer_data_a[17][11] & layer_data_b[17][11]) | (layer_data_a[17][11] & carry_bit_layer_adder[17][10]) | (layer_data_b[17][11] & carry_bit_layer_adder[17][10]); // calculation of carry bit of adder
assign result_layer_adder[17][12] = layer_data_a[17][12] ^ layer_data_b[17][12] ^ carry_bit_layer_adder[17][11]; // calculation of add result
assign carry_bit_layer_adder[17][12] = (layer_data_a[17][12] & layer_data_b[17][12]) | (layer_data_a[17][12] & carry_bit_layer_adder[17][11]) | (layer_data_b[17][12] & carry_bit_layer_adder[17][11]); // calculation of carry bit of adder
assign result_layer_adder[17][13] = layer_data_a[17][13] ^ layer_data_b[17][13] ^ carry_bit_layer_adder[17][12]; // calculation of add result
assign carry_bit_layer_adder[17][13] = (layer_data_a[17][13] & layer_data_b[17][13]) | (layer_data_a[17][13] & carry_bit_layer_adder[17][12]) | (layer_data_b[17][13] & carry_bit_layer_adder[17][12]); // calculation of carry bit of adder
assign result_layer_adder[17][14] = layer_data_a[17][14] ^ layer_data_b[17][14] ^ carry_bit_layer_adder[17][13]; // calculation of add result
assign carry_bit_layer_adder[17][14] = (layer_data_a[17][14] & layer_data_b[17][14]) | (layer_data_a[17][14] & carry_bit_layer_adder[17][13]) | (layer_data_b[17][14] & carry_bit_layer_adder[17][13]); // calculation of carry bit of adder
assign result_layer_adder[17][15] = layer_data_a[17][15] ^ layer_data_b[17][15] ^ carry_bit_layer_adder[17][14]; // calculation of add result
assign carry_bit_layer_adder[17][15] = (layer_data_a[17][15] & layer_data_b[17][15]) | (layer_data_a[17][15] & carry_bit_layer_adder[17][14]) | (layer_data_b[17][15] & carry_bit_layer_adder[17][14]); // calculation of carry bit of adder
assign result_layer_adder[17][16] = layer_data_a[17][16] ^ layer_data_b[17][16] ^ carry_bit_layer_adder[17][15]; // calculation of add result
assign carry_bit_layer_adder[17][16] = (layer_data_a[17][16] & layer_data_b[17][16]) | (layer_data_a[17][16] & carry_bit_layer_adder[17][15]) | (layer_data_b[17][16] & carry_bit_layer_adder[17][15]); // calculation of carry bit of adder
assign result_layer_adder[17][17] = layer_data_a[17][17] ^ layer_data_b[17][17] ^ carry_bit_layer_adder[17][16]; // calculation of add result
assign carry_bit_layer_adder[17][17] = (layer_data_a[17][17] & layer_data_b[17][17]) | (layer_data_a[17][17] & carry_bit_layer_adder[17][16]) | (layer_data_b[17][17] & carry_bit_layer_adder[17][16]); // calculation of carry bit of adder
assign result_layer_adder[17][18] = layer_data_a[17][18] ^ layer_data_b[17][18] ^ carry_bit_layer_adder[17][17]; // calculation of add result
assign carry_bit_layer_adder[17][18] = (layer_data_a[17][18] & layer_data_b[17][18]) | (layer_data_a[17][18] & carry_bit_layer_adder[17][17]) | (layer_data_b[17][18] & carry_bit_layer_adder[17][17]); // calculation of carry bit of adder
assign result_layer_adder[17][19] = layer_data_a[17][19] ^ layer_data_b[17][19] ^ carry_bit_layer_adder[17][18]; // calculation of add result
assign carry_bit_layer_adder[17][19] = (layer_data_a[17][19] & layer_data_b[17][19]) | (layer_data_a[17][19] & carry_bit_layer_adder[17][18]) | (layer_data_b[17][19] & carry_bit_layer_adder[17][18]); // calculation of carry bit of adder
assign result_layer_adder[17][20] = layer_data_a[17][20] ^ layer_data_b[17][20] ^ carry_bit_layer_adder[17][19]; // calculation of add result
assign carry_bit_layer_adder[17][20] = (layer_data_a[17][20] & layer_data_b[17][20]) | (layer_data_a[17][20] & carry_bit_layer_adder[17][19]) | (layer_data_b[17][20] & carry_bit_layer_adder[17][19]); // calculation of carry bit of adder
assign result_layer_adder[17][21] = layer_data_a[17][21] ^ layer_data_b[17][21] ^ carry_bit_layer_adder[17][20]; // calculation of add result
assign carry_bit_layer_adder[17][21] = (layer_data_a[17][21] & layer_data_b[17][21]) | (layer_data_a[17][21] & carry_bit_layer_adder[17][20]) | (layer_data_b[17][21] & carry_bit_layer_adder[17][20]); // calculation of carry bit of adder
assign result_layer_adder[17][22] = layer_data_a[17][22] ^ layer_data_b[17][22] ^ carry_bit_layer_adder[17][21]; // calculation of add result
assign carry_bit_layer_adder[17][22] = (layer_data_a[17][22] & layer_data_b[17][22]) | (layer_data_a[17][22] & carry_bit_layer_adder[17][21]) | (layer_data_b[17][22] & carry_bit_layer_adder[17][21]); // calculation of carry bit of adder
assign result_layer_adder[17][23] = layer_data_a[17][23] ^ layer_data_b[17][23] ^ carry_bit_layer_adder[17][22]; // calculation of add result
assign carry_bit_layer_adder[17][23] = (layer_data_a[17][23] & layer_data_b[17][23]) | (layer_data_a[17][23] & carry_bit_layer_adder[17][22]) | (layer_data_b[17][23] & carry_bit_layer_adder[17][22]); // calculation of carry bit of adder
assign result_layer_adder[17][24] = layer_data_a[17][24] ^ layer_data_b[17][24] ^ carry_bit_layer_adder[17][23]; // calculation of add result
assign carry_bit_layer_adder[17][24] = (layer_data_a[17][24] & layer_data_b[17][24]) | (layer_data_a[17][24] & carry_bit_layer_adder[17][23]) | (layer_data_b[17][24] & carry_bit_layer_adder[17][23]); // calculation of carry bit of adder
assign result_layer_adder[17][25] = layer_data_a[17][25] ^ layer_data_b[17][25] ^ carry_bit_layer_adder[17][24]; // calculation of add result
assign carry_bit_layer_adder[17][25] = (layer_data_a[17][25] & layer_data_b[17][25]) | (layer_data_a[17][25] & carry_bit_layer_adder[17][24]) | (layer_data_b[17][25] & carry_bit_layer_adder[17][24]); // calculation of carry bit of adder
assign result_layer_adder[17][26] = layer_data_a[17][26] ^ layer_data_b[17][26] ^ carry_bit_layer_adder[17][25]; // calculation of add result
assign carry_bit_layer_adder[17][26] = (layer_data_a[17][26] & layer_data_b[17][26]) | (layer_data_a[17][26] & carry_bit_layer_adder[17][25]) | (layer_data_b[17][26] & carry_bit_layer_adder[17][25]); // calculation of carry bit of adder
assign result_layer_adder[17][27] = layer_data_a[17][27] ^ layer_data_b[17][27] ^ carry_bit_layer_adder[17][26]; // calculation of add result
assign carry_bit_layer_adder[17][27] = (layer_data_a[17][27] & layer_data_b[17][27]) | (layer_data_a[17][27] & carry_bit_layer_adder[17][26]) | (layer_data_b[17][27] & carry_bit_layer_adder[17][26]); // calculation of carry bit of adder
assign result_layer_adder[17][28] = layer_data_a[17][28] ^ layer_data_b[17][28] ^ carry_bit_layer_adder[17][27]; // calculation of add result
assign carry_bit_layer_adder[17][28] = (layer_data_a[17][28] & layer_data_b[17][28]) | (layer_data_a[17][28] & carry_bit_layer_adder[17][27]) | (layer_data_b[17][28] & carry_bit_layer_adder[17][27]); // calculation of carry bit of adder
assign result_layer_adder[17][29] = layer_data_a[17][29] ^ layer_data_b[17][29] ^ carry_bit_layer_adder[17][28]; // calculation of add result
assign carry_bit_layer_adder[17][29] = (layer_data_a[17][29] & layer_data_b[17][29]) | (layer_data_a[17][29] & carry_bit_layer_adder[17][28]) | (layer_data_b[17][29] & carry_bit_layer_adder[17][28]); // calculation of carry bit of adder
assign result_layer_adder[17][30] = layer_data_a[17][30] ^ layer_data_b[17][30] ^ carry_bit_layer_adder[17][29]; // calculation of add result
assign carry_bit_layer_adder[17][30] = (layer_data_a[17][30] & layer_data_b[17][30]) | (layer_data_a[17][30] & carry_bit_layer_adder[17][29]) | (layer_data_b[17][30] & carry_bit_layer_adder[17][29]); // calculation of carry bit of adder
assign result_layer_adder[17][31] = layer_data_a[17][31] ^ layer_data_b[17][31] ^ carry_bit_layer_adder[17][30]; // calculation of add result
assign carry_bit_layer_adder[17][31] = (layer_data_a[17][31] & layer_data_b[17][31]) | (layer_data_a[17][31] & carry_bit_layer_adder[17][30]) | (layer_data_b[17][31] & carry_bit_layer_adder[17][30]); // calculation of carry bit of adder
assign result_layer_adder[17][32] = layer_data_a[17][32] ^ layer_data_b[17][32] ^ carry_bit_layer_adder[17][31]; // calculation of add result

// Layer 19
assign layer_data_a[18][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[17][32] == 1'b1) ? {layer_data_a[17][31:0], operand_a[14]} : {result_layer_adder[17][31:0], operand_a[14]}) : {1'b0, result_layer_adder[17][32:1]}; // data select for layer 19
assign layer_data_b[18][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[18] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 19

// Layer 19 adder
assign result_layer_adder[18][0] = layer_data_a[18][0] ^ layer_data_b[18][0]; // calculation of add result
assign carry_bit_layer_adder[18][0] = layer_data_a[18][0] & layer_data_b[18][0]; // calculation of carry bit of adder
assign result_layer_adder[18][1] = layer_data_a[18][1] ^ layer_data_b[18][1] ^ carry_bit_layer_adder[18][0]; // calculation of add result
assign carry_bit_layer_adder[18][1] = (layer_data_a[18][1] & layer_data_b[18][1]) | (layer_data_a[18][1] & carry_bit_layer_adder[18][0]) | (layer_data_b[18][1] & carry_bit_layer_adder[18][0]); // calculation of carry bit of adder
assign result_layer_adder[18][2] = layer_data_a[18][2] ^ layer_data_b[18][2] ^ carry_bit_layer_adder[18][1]; // calculation of add result
assign carry_bit_layer_adder[18][2] = (layer_data_a[18][2] & layer_data_b[18][2]) | (layer_data_a[18][2] & carry_bit_layer_adder[18][1]) | (layer_data_b[18][2] & carry_bit_layer_adder[18][1]); // calculation of carry bit of adder
assign result_layer_adder[18][3] = layer_data_a[18][3] ^ layer_data_b[18][3] ^ carry_bit_layer_adder[18][2]; // calculation of add result
assign carry_bit_layer_adder[18][3] = (layer_data_a[18][3] & layer_data_b[18][3]) | (layer_data_a[18][3] & carry_bit_layer_adder[18][2]) | (layer_data_b[18][3] & carry_bit_layer_adder[18][2]); // calculation of carry bit of adder
assign result_layer_adder[18][4] = layer_data_a[18][4] ^ layer_data_b[18][4] ^ carry_bit_layer_adder[18][3]; // calculation of add result
assign carry_bit_layer_adder[18][4] = (layer_data_a[18][4] & layer_data_b[18][4]) | (layer_data_a[18][4] & carry_bit_layer_adder[18][3]) | (layer_data_b[18][4] & carry_bit_layer_adder[18][3]); // calculation of carry bit of adder
assign result_layer_adder[18][5] = layer_data_a[18][5] ^ layer_data_b[18][5] ^ carry_bit_layer_adder[18][4]; // calculation of add result
assign carry_bit_layer_adder[18][5] = (layer_data_a[18][5] & layer_data_b[18][5]) | (layer_data_a[18][5] & carry_bit_layer_adder[18][4]) | (layer_data_b[18][5] & carry_bit_layer_adder[18][4]); // calculation of carry bit of adder
assign result_layer_adder[18][6] = layer_data_a[18][6] ^ layer_data_b[18][6] ^ carry_bit_layer_adder[18][5]; // calculation of add result
assign carry_bit_layer_adder[18][6] = (layer_data_a[18][6] & layer_data_b[18][6]) | (layer_data_a[18][6] & carry_bit_layer_adder[18][5]) | (layer_data_b[18][6] & carry_bit_layer_adder[18][5]); // calculation of carry bit of adder
assign result_layer_adder[18][7] = layer_data_a[18][7] ^ layer_data_b[18][7] ^ carry_bit_layer_adder[18][6]; // calculation of add result
assign carry_bit_layer_adder[18][7] = (layer_data_a[18][7] & layer_data_b[18][7]) | (layer_data_a[18][7] & carry_bit_layer_adder[18][6]) | (layer_data_b[18][7] & carry_bit_layer_adder[18][6]); // calculation of carry bit of adder
assign result_layer_adder[18][8] = layer_data_a[18][8] ^ layer_data_b[18][8] ^ carry_bit_layer_adder[18][7]; // calculation of add result
assign carry_bit_layer_adder[18][8] = (layer_data_a[18][8] & layer_data_b[18][8]) | (layer_data_a[18][8] & carry_bit_layer_adder[18][7]) | (layer_data_b[18][8] & carry_bit_layer_adder[18][7]); // calculation of carry bit of adder
assign result_layer_adder[18][9] = layer_data_a[18][9] ^ layer_data_b[18][9] ^ carry_bit_layer_adder[18][8]; // calculation of add result
assign carry_bit_layer_adder[18][9] = (layer_data_a[18][9] & layer_data_b[18][9]) | (layer_data_a[18][9] & carry_bit_layer_adder[18][8]) | (layer_data_b[18][9] & carry_bit_layer_adder[18][8]); // calculation of carry bit of adder
assign result_layer_adder[18][10] = layer_data_a[18][10] ^ layer_data_b[18][10] ^ carry_bit_layer_adder[18][9]; // calculation of add result
assign carry_bit_layer_adder[18][10] = (layer_data_a[18][10] & layer_data_b[18][10]) | (layer_data_a[18][10] & carry_bit_layer_adder[18][9]) | (layer_data_b[18][10] & carry_bit_layer_adder[18][9]); // calculation of carry bit of adder
assign result_layer_adder[18][11] = layer_data_a[18][11] ^ layer_data_b[18][11] ^ carry_bit_layer_adder[18][10]; // calculation of add result
assign carry_bit_layer_adder[18][11] = (layer_data_a[18][11] & layer_data_b[18][11]) | (layer_data_a[18][11] & carry_bit_layer_adder[18][10]) | (layer_data_b[18][11] & carry_bit_layer_adder[18][10]); // calculation of carry bit of adder
assign result_layer_adder[18][12] = layer_data_a[18][12] ^ layer_data_b[18][12] ^ carry_bit_layer_adder[18][11]; // calculation of add result
assign carry_bit_layer_adder[18][12] = (layer_data_a[18][12] & layer_data_b[18][12]) | (layer_data_a[18][12] & carry_bit_layer_adder[18][11]) | (layer_data_b[18][12] & carry_bit_layer_adder[18][11]); // calculation of carry bit of adder
assign result_layer_adder[18][13] = layer_data_a[18][13] ^ layer_data_b[18][13] ^ carry_bit_layer_adder[18][12]; // calculation of add result
assign carry_bit_layer_adder[18][13] = (layer_data_a[18][13] & layer_data_b[18][13]) | (layer_data_a[18][13] & carry_bit_layer_adder[18][12]) | (layer_data_b[18][13] & carry_bit_layer_adder[18][12]); // calculation of carry bit of adder
assign result_layer_adder[18][14] = layer_data_a[18][14] ^ layer_data_b[18][14] ^ carry_bit_layer_adder[18][13]; // calculation of add result
assign carry_bit_layer_adder[18][14] = (layer_data_a[18][14] & layer_data_b[18][14]) | (layer_data_a[18][14] & carry_bit_layer_adder[18][13]) | (layer_data_b[18][14] & carry_bit_layer_adder[18][13]); // calculation of carry bit of adder
assign result_layer_adder[18][15] = layer_data_a[18][15] ^ layer_data_b[18][15] ^ carry_bit_layer_adder[18][14]; // calculation of add result
assign carry_bit_layer_adder[18][15] = (layer_data_a[18][15] & layer_data_b[18][15]) | (layer_data_a[18][15] & carry_bit_layer_adder[18][14]) | (layer_data_b[18][15] & carry_bit_layer_adder[18][14]); // calculation of carry bit of adder
assign result_layer_adder[18][16] = layer_data_a[18][16] ^ layer_data_b[18][16] ^ carry_bit_layer_adder[18][15]; // calculation of add result
assign carry_bit_layer_adder[18][16] = (layer_data_a[18][16] & layer_data_b[18][16]) | (layer_data_a[18][16] & carry_bit_layer_adder[18][15]) | (layer_data_b[18][16] & carry_bit_layer_adder[18][15]); // calculation of carry bit of adder
assign result_layer_adder[18][17] = layer_data_a[18][17] ^ layer_data_b[18][17] ^ carry_bit_layer_adder[18][16]; // calculation of add result
assign carry_bit_layer_adder[18][17] = (layer_data_a[18][17] & layer_data_b[18][17]) | (layer_data_a[18][17] & carry_bit_layer_adder[18][16]) | (layer_data_b[18][17] & carry_bit_layer_adder[18][16]); // calculation of carry bit of adder
assign result_layer_adder[18][18] = layer_data_a[18][18] ^ layer_data_b[18][18] ^ carry_bit_layer_adder[18][17]; // calculation of add result
assign carry_bit_layer_adder[18][18] = (layer_data_a[18][18] & layer_data_b[18][18]) | (layer_data_a[18][18] & carry_bit_layer_adder[18][17]) | (layer_data_b[18][18] & carry_bit_layer_adder[18][17]); // calculation of carry bit of adder
assign result_layer_adder[18][19] = layer_data_a[18][19] ^ layer_data_b[18][19] ^ carry_bit_layer_adder[18][18]; // calculation of add result
assign carry_bit_layer_adder[18][19] = (layer_data_a[18][19] & layer_data_b[18][19]) | (layer_data_a[18][19] & carry_bit_layer_adder[18][18]) | (layer_data_b[18][19] & carry_bit_layer_adder[18][18]); // calculation of carry bit of adder
assign result_layer_adder[18][20] = layer_data_a[18][20] ^ layer_data_b[18][20] ^ carry_bit_layer_adder[18][19]; // calculation of add result
assign carry_bit_layer_adder[18][20] = (layer_data_a[18][20] & layer_data_b[18][20]) | (layer_data_a[18][20] & carry_bit_layer_adder[18][19]) | (layer_data_b[18][20] & carry_bit_layer_adder[18][19]); // calculation of carry bit of adder
assign result_layer_adder[18][21] = layer_data_a[18][21] ^ layer_data_b[18][21] ^ carry_bit_layer_adder[18][20]; // calculation of add result
assign carry_bit_layer_adder[18][21] = (layer_data_a[18][21] & layer_data_b[18][21]) | (layer_data_a[18][21] & carry_bit_layer_adder[18][20]) | (layer_data_b[18][21] & carry_bit_layer_adder[18][20]); // calculation of carry bit of adder
assign result_layer_adder[18][22] = layer_data_a[18][22] ^ layer_data_b[18][22] ^ carry_bit_layer_adder[18][21]; // calculation of add result
assign carry_bit_layer_adder[18][22] = (layer_data_a[18][22] & layer_data_b[18][22]) | (layer_data_a[18][22] & carry_bit_layer_adder[18][21]) | (layer_data_b[18][22] & carry_bit_layer_adder[18][21]); // calculation of carry bit of adder
assign result_layer_adder[18][23] = layer_data_a[18][23] ^ layer_data_b[18][23] ^ carry_bit_layer_adder[18][22]; // calculation of add result
assign carry_bit_layer_adder[18][23] = (layer_data_a[18][23] & layer_data_b[18][23]) | (layer_data_a[18][23] & carry_bit_layer_adder[18][22]) | (layer_data_b[18][23] & carry_bit_layer_adder[18][22]); // calculation of carry bit of adder
assign result_layer_adder[18][24] = layer_data_a[18][24] ^ layer_data_b[18][24] ^ carry_bit_layer_adder[18][23]; // calculation of add result
assign carry_bit_layer_adder[18][24] = (layer_data_a[18][24] & layer_data_b[18][24]) | (layer_data_a[18][24] & carry_bit_layer_adder[18][23]) | (layer_data_b[18][24] & carry_bit_layer_adder[18][23]); // calculation of carry bit of adder
assign result_layer_adder[18][25] = layer_data_a[18][25] ^ layer_data_b[18][25] ^ carry_bit_layer_adder[18][24]; // calculation of add result
assign carry_bit_layer_adder[18][25] = (layer_data_a[18][25] & layer_data_b[18][25]) | (layer_data_a[18][25] & carry_bit_layer_adder[18][24]) | (layer_data_b[18][25] & carry_bit_layer_adder[18][24]); // calculation of carry bit of adder
assign result_layer_adder[18][26] = layer_data_a[18][26] ^ layer_data_b[18][26] ^ carry_bit_layer_adder[18][25]; // calculation of add result
assign carry_bit_layer_adder[18][26] = (layer_data_a[18][26] & layer_data_b[18][26]) | (layer_data_a[18][26] & carry_bit_layer_adder[18][25]) | (layer_data_b[18][26] & carry_bit_layer_adder[18][25]); // calculation of carry bit of adder
assign result_layer_adder[18][27] = layer_data_a[18][27] ^ layer_data_b[18][27] ^ carry_bit_layer_adder[18][26]; // calculation of add result
assign carry_bit_layer_adder[18][27] = (layer_data_a[18][27] & layer_data_b[18][27]) | (layer_data_a[18][27] & carry_bit_layer_adder[18][26]) | (layer_data_b[18][27] & carry_bit_layer_adder[18][26]); // calculation of carry bit of adder
assign result_layer_adder[18][28] = layer_data_a[18][28] ^ layer_data_b[18][28] ^ carry_bit_layer_adder[18][27]; // calculation of add result
assign carry_bit_layer_adder[18][28] = (layer_data_a[18][28] & layer_data_b[18][28]) | (layer_data_a[18][28] & carry_bit_layer_adder[18][27]) | (layer_data_b[18][28] & carry_bit_layer_adder[18][27]); // calculation of carry bit of adder
assign result_layer_adder[18][29] = layer_data_a[18][29] ^ layer_data_b[18][29] ^ carry_bit_layer_adder[18][28]; // calculation of add result
assign carry_bit_layer_adder[18][29] = (layer_data_a[18][29] & layer_data_b[18][29]) | (layer_data_a[18][29] & carry_bit_layer_adder[18][28]) | (layer_data_b[18][29] & carry_bit_layer_adder[18][28]); // calculation of carry bit of adder
assign result_layer_adder[18][30] = layer_data_a[18][30] ^ layer_data_b[18][30] ^ carry_bit_layer_adder[18][29]; // calculation of add result
assign carry_bit_layer_adder[18][30] = (layer_data_a[18][30] & layer_data_b[18][30]) | (layer_data_a[18][30] & carry_bit_layer_adder[18][29]) | (layer_data_b[18][30] & carry_bit_layer_adder[18][29]); // calculation of carry bit of adder
assign result_layer_adder[18][31] = layer_data_a[18][31] ^ layer_data_b[18][31] ^ carry_bit_layer_adder[18][30]; // calculation of add result
assign carry_bit_layer_adder[18][31] = (layer_data_a[18][31] & layer_data_b[18][31]) | (layer_data_a[18][31] & carry_bit_layer_adder[18][30]) | (layer_data_b[18][31] & carry_bit_layer_adder[18][30]); // calculation of carry bit of adder
assign result_layer_adder[18][32] = layer_data_a[18][32] ^ layer_data_b[18][32] ^ carry_bit_layer_adder[18][31]; // calculation of add result

// Layer 20
assign layer_data_a[19][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[18][32] == 1'b1) ? {layer_data_a[18][31:0], operand_a[13]} : {result_layer_adder[18][31:0], operand_a[13]}) : {1'b0, result_layer_adder[18][32:1]}; // data select for layer 20
assign layer_data_b[19][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[19] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 20

// Layer 20 adder
assign result_layer_adder[19][0] = layer_data_a[19][0] ^ layer_data_b[19][0]; // calculation of add result
assign carry_bit_layer_adder[19][0] = layer_data_a[19][0] & layer_data_b[19][0]; // calculation of carry bit of adder
assign result_layer_adder[19][1] = layer_data_a[19][1] ^ layer_data_b[19][1] ^ carry_bit_layer_adder[19][0]; // calculation of add result
assign carry_bit_layer_adder[19][1] = (layer_data_a[19][1] & layer_data_b[19][1]) | (layer_data_a[19][1] & carry_bit_layer_adder[19][0]) | (layer_data_b[19][1] & carry_bit_layer_adder[19][0]); // calculation of carry bit of adder
assign result_layer_adder[19][2] = layer_data_a[19][2] ^ layer_data_b[19][2] ^ carry_bit_layer_adder[19][1]; // calculation of add result
assign carry_bit_layer_adder[19][2] = (layer_data_a[19][2] & layer_data_b[19][2]) | (layer_data_a[19][2] & carry_bit_layer_adder[19][1]) | (layer_data_b[19][2] & carry_bit_layer_adder[19][1]); // calculation of carry bit of adder
assign result_layer_adder[19][3] = layer_data_a[19][3] ^ layer_data_b[19][3] ^ carry_bit_layer_adder[19][2]; // calculation of add result
assign carry_bit_layer_adder[19][3] = (layer_data_a[19][3] & layer_data_b[19][3]) | (layer_data_a[19][3] & carry_bit_layer_adder[19][2]) | (layer_data_b[19][3] & carry_bit_layer_adder[19][2]); // calculation of carry bit of adder
assign result_layer_adder[19][4] = layer_data_a[19][4] ^ layer_data_b[19][4] ^ carry_bit_layer_adder[19][3]; // calculation of add result
assign carry_bit_layer_adder[19][4] = (layer_data_a[19][4] & layer_data_b[19][4]) | (layer_data_a[19][4] & carry_bit_layer_adder[19][3]) | (layer_data_b[19][4] & carry_bit_layer_adder[19][3]); // calculation of carry bit of adder
assign result_layer_adder[19][5] = layer_data_a[19][5] ^ layer_data_b[19][5] ^ carry_bit_layer_adder[19][4]; // calculation of add result
assign carry_bit_layer_adder[19][5] = (layer_data_a[19][5] & layer_data_b[19][5]) | (layer_data_a[19][5] & carry_bit_layer_adder[19][4]) | (layer_data_b[19][5] & carry_bit_layer_adder[19][4]); // calculation of carry bit of adder
assign result_layer_adder[19][6] = layer_data_a[19][6] ^ layer_data_b[19][6] ^ carry_bit_layer_adder[19][5]; // calculation of add result
assign carry_bit_layer_adder[19][6] = (layer_data_a[19][6] & layer_data_b[19][6]) | (layer_data_a[19][6] & carry_bit_layer_adder[19][5]) | (layer_data_b[19][6] & carry_bit_layer_adder[19][5]); // calculation of carry bit of adder
assign result_layer_adder[19][7] = layer_data_a[19][7] ^ layer_data_b[19][7] ^ carry_bit_layer_adder[19][6]; // calculation of add result
assign carry_bit_layer_adder[19][7] = (layer_data_a[19][7] & layer_data_b[19][7]) | (layer_data_a[19][7] & carry_bit_layer_adder[19][6]) | (layer_data_b[19][7] & carry_bit_layer_adder[19][6]); // calculation of carry bit of adder
assign result_layer_adder[19][8] = layer_data_a[19][8] ^ layer_data_b[19][8] ^ carry_bit_layer_adder[19][7]; // calculation of add result
assign carry_bit_layer_adder[19][8] = (layer_data_a[19][8] & layer_data_b[19][8]) | (layer_data_a[19][8] & carry_bit_layer_adder[19][7]) | (layer_data_b[19][8] & carry_bit_layer_adder[19][7]); // calculation of carry bit of adder
assign result_layer_adder[19][9] = layer_data_a[19][9] ^ layer_data_b[19][9] ^ carry_bit_layer_adder[19][8]; // calculation of add result
assign carry_bit_layer_adder[19][9] = (layer_data_a[19][9] & layer_data_b[19][9]) | (layer_data_a[19][9] & carry_bit_layer_adder[19][8]) | (layer_data_b[19][9] & carry_bit_layer_adder[19][8]); // calculation of carry bit of adder
assign result_layer_adder[19][10] = layer_data_a[19][10] ^ layer_data_b[19][10] ^ carry_bit_layer_adder[19][9]; // calculation of add result
assign carry_bit_layer_adder[19][10] = (layer_data_a[19][10] & layer_data_b[19][10]) | (layer_data_a[19][10] & carry_bit_layer_adder[19][9]) | (layer_data_b[19][10] & carry_bit_layer_adder[19][9]); // calculation of carry bit of adder
assign result_layer_adder[19][11] = layer_data_a[19][11] ^ layer_data_b[19][11] ^ carry_bit_layer_adder[19][10]; // calculation of add result
assign carry_bit_layer_adder[19][11] = (layer_data_a[19][11] & layer_data_b[19][11]) | (layer_data_a[19][11] & carry_bit_layer_adder[19][10]) | (layer_data_b[19][11] & carry_bit_layer_adder[19][10]); // calculation of carry bit of adder
assign result_layer_adder[19][12] = layer_data_a[19][12] ^ layer_data_b[19][12] ^ carry_bit_layer_adder[19][11]; // calculation of add result
assign carry_bit_layer_adder[19][12] = (layer_data_a[19][12] & layer_data_b[19][12]) | (layer_data_a[19][12] & carry_bit_layer_adder[19][11]) | (layer_data_b[19][12] & carry_bit_layer_adder[19][11]); // calculation of carry bit of adder
assign result_layer_adder[19][13] = layer_data_a[19][13] ^ layer_data_b[19][13] ^ carry_bit_layer_adder[19][12]; // calculation of add result
assign carry_bit_layer_adder[19][13] = (layer_data_a[19][13] & layer_data_b[19][13]) | (layer_data_a[19][13] & carry_bit_layer_adder[19][12]) | (layer_data_b[19][13] & carry_bit_layer_adder[19][12]); // calculation of carry bit of adder
assign result_layer_adder[19][14] = layer_data_a[19][14] ^ layer_data_b[19][14] ^ carry_bit_layer_adder[19][13]; // calculation of add result
assign carry_bit_layer_adder[19][14] = (layer_data_a[19][14] & layer_data_b[19][14]) | (layer_data_a[19][14] & carry_bit_layer_adder[19][13]) | (layer_data_b[19][14] & carry_bit_layer_adder[19][13]); // calculation of carry bit of adder
assign result_layer_adder[19][15] = layer_data_a[19][15] ^ layer_data_b[19][15] ^ carry_bit_layer_adder[19][14]; // calculation of add result
assign carry_bit_layer_adder[19][15] = (layer_data_a[19][15] & layer_data_b[19][15]) | (layer_data_a[19][15] & carry_bit_layer_adder[19][14]) | (layer_data_b[19][15] & carry_bit_layer_adder[19][14]); // calculation of carry bit of adder
assign result_layer_adder[19][16] = layer_data_a[19][16] ^ layer_data_b[19][16] ^ carry_bit_layer_adder[19][15]; // calculation of add result
assign carry_bit_layer_adder[19][16] = (layer_data_a[19][16] & layer_data_b[19][16]) | (layer_data_a[19][16] & carry_bit_layer_adder[19][15]) | (layer_data_b[19][16] & carry_bit_layer_adder[19][15]); // calculation of carry bit of adder
assign result_layer_adder[19][17] = layer_data_a[19][17] ^ layer_data_b[19][17] ^ carry_bit_layer_adder[19][16]; // calculation of add result
assign carry_bit_layer_adder[19][17] = (layer_data_a[19][17] & layer_data_b[19][17]) | (layer_data_a[19][17] & carry_bit_layer_adder[19][16]) | (layer_data_b[19][17] & carry_bit_layer_adder[19][16]); // calculation of carry bit of adder
assign result_layer_adder[19][18] = layer_data_a[19][18] ^ layer_data_b[19][18] ^ carry_bit_layer_adder[19][17]; // calculation of add result
assign carry_bit_layer_adder[19][18] = (layer_data_a[19][18] & layer_data_b[19][18]) | (layer_data_a[19][18] & carry_bit_layer_adder[19][17]) | (layer_data_b[19][18] & carry_bit_layer_adder[19][17]); // calculation of carry bit of adder
assign result_layer_adder[19][19] = layer_data_a[19][19] ^ layer_data_b[19][19] ^ carry_bit_layer_adder[19][18]; // calculation of add result
assign carry_bit_layer_adder[19][19] = (layer_data_a[19][19] & layer_data_b[19][19]) | (layer_data_a[19][19] & carry_bit_layer_adder[19][18]) | (layer_data_b[19][19] & carry_bit_layer_adder[19][18]); // calculation of carry bit of adder
assign result_layer_adder[19][20] = layer_data_a[19][20] ^ layer_data_b[19][20] ^ carry_bit_layer_adder[19][19]; // calculation of add result
assign carry_bit_layer_adder[19][20] = (layer_data_a[19][20] & layer_data_b[19][20]) | (layer_data_a[19][20] & carry_bit_layer_adder[19][19]) | (layer_data_b[19][20] & carry_bit_layer_adder[19][19]); // calculation of carry bit of adder
assign result_layer_adder[19][21] = layer_data_a[19][21] ^ layer_data_b[19][21] ^ carry_bit_layer_adder[19][20]; // calculation of add result
assign carry_bit_layer_adder[19][21] = (layer_data_a[19][21] & layer_data_b[19][21]) | (layer_data_a[19][21] & carry_bit_layer_adder[19][20]) | (layer_data_b[19][21] & carry_bit_layer_adder[19][20]); // calculation of carry bit of adder
assign result_layer_adder[19][22] = layer_data_a[19][22] ^ layer_data_b[19][22] ^ carry_bit_layer_adder[19][21]; // calculation of add result
assign carry_bit_layer_adder[19][22] = (layer_data_a[19][22] & layer_data_b[19][22]) | (layer_data_a[19][22] & carry_bit_layer_adder[19][21]) | (layer_data_b[19][22] & carry_bit_layer_adder[19][21]); // calculation of carry bit of adder
assign result_layer_adder[19][23] = layer_data_a[19][23] ^ layer_data_b[19][23] ^ carry_bit_layer_adder[19][22]; // calculation of add result
assign carry_bit_layer_adder[19][23] = (layer_data_a[19][23] & layer_data_b[19][23]) | (layer_data_a[19][23] & carry_bit_layer_adder[19][22]) | (layer_data_b[19][23] & carry_bit_layer_adder[19][22]); // calculation of carry bit of adder
assign result_layer_adder[19][24] = layer_data_a[19][24] ^ layer_data_b[19][24] ^ carry_bit_layer_adder[19][23]; // calculation of add result
assign carry_bit_layer_adder[19][24] = (layer_data_a[19][24] & layer_data_b[19][24]) | (layer_data_a[19][24] & carry_bit_layer_adder[19][23]) | (layer_data_b[19][24] & carry_bit_layer_adder[19][23]); // calculation of carry bit of adder
assign result_layer_adder[19][25] = layer_data_a[19][25] ^ layer_data_b[19][25] ^ carry_bit_layer_adder[19][24]; // calculation of add result
assign carry_bit_layer_adder[19][25] = (layer_data_a[19][25] & layer_data_b[19][25]) | (layer_data_a[19][25] & carry_bit_layer_adder[19][24]) | (layer_data_b[19][25] & carry_bit_layer_adder[19][24]); // calculation of carry bit of adder
assign result_layer_adder[19][26] = layer_data_a[19][26] ^ layer_data_b[19][26] ^ carry_bit_layer_adder[19][25]; // calculation of add result
assign carry_bit_layer_adder[19][26] = (layer_data_a[19][26] & layer_data_b[19][26]) | (layer_data_a[19][26] & carry_bit_layer_adder[19][25]) | (layer_data_b[19][26] & carry_bit_layer_adder[19][25]); // calculation of carry bit of adder
assign result_layer_adder[19][27] = layer_data_a[19][27] ^ layer_data_b[19][27] ^ carry_bit_layer_adder[19][26]; // calculation of add result
assign carry_bit_layer_adder[19][27] = (layer_data_a[19][27] & layer_data_b[19][27]) | (layer_data_a[19][27] & carry_bit_layer_adder[19][26]) | (layer_data_b[19][27] & carry_bit_layer_adder[19][26]); // calculation of carry bit of adder
assign result_layer_adder[19][28] = layer_data_a[19][28] ^ layer_data_b[19][28] ^ carry_bit_layer_adder[19][27]; // calculation of add result
assign carry_bit_layer_adder[19][28] = (layer_data_a[19][28] & layer_data_b[19][28]) | (layer_data_a[19][28] & carry_bit_layer_adder[19][27]) | (layer_data_b[19][28] & carry_bit_layer_adder[19][27]); // calculation of carry bit of adder
assign result_layer_adder[19][29] = layer_data_a[19][29] ^ layer_data_b[19][29] ^ carry_bit_layer_adder[19][28]; // calculation of add result
assign carry_bit_layer_adder[19][29] = (layer_data_a[19][29] & layer_data_b[19][29]) | (layer_data_a[19][29] & carry_bit_layer_adder[19][28]) | (layer_data_b[19][29] & carry_bit_layer_adder[19][28]); // calculation of carry bit of adder
assign result_layer_adder[19][30] = layer_data_a[19][30] ^ layer_data_b[19][30] ^ carry_bit_layer_adder[19][29]; // calculation of add result
assign carry_bit_layer_adder[19][30] = (layer_data_a[19][30] & layer_data_b[19][30]) | (layer_data_a[19][30] & carry_bit_layer_adder[19][29]) | (layer_data_b[19][30] & carry_bit_layer_adder[19][29]); // calculation of carry bit of adder
assign result_layer_adder[19][31] = layer_data_a[19][31] ^ layer_data_b[19][31] ^ carry_bit_layer_adder[19][30]; // calculation of add result
assign carry_bit_layer_adder[19][31] = (layer_data_a[19][31] & layer_data_b[19][31]) | (layer_data_a[19][31] & carry_bit_layer_adder[19][30]) | (layer_data_b[19][31] & carry_bit_layer_adder[19][30]); // calculation of carry bit of adder
assign result_layer_adder[19][32] = layer_data_a[19][32] ^ layer_data_b[19][32] ^ carry_bit_layer_adder[19][31]; // calculation of add result

// Layer 21
assign layer_data_a[20][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[19][32] == 1'b1) ? {layer_data_a[19][31:0], operand_a[12]} : {result_layer_adder[19][31:0], operand_a[12]}) : {1'b0, result_layer_adder[19][32:1]}; // data select for layer 21
assign layer_data_b[20][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[20] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 21

// Layer 21 adder
assign result_layer_adder[20][0] = layer_data_a[20][0] ^ layer_data_b[20][0]; // calculation of add result
assign carry_bit_layer_adder[20][0] = layer_data_a[20][0] & layer_data_b[20][0]; // calculation of carry bit of adder
assign result_layer_adder[20][1] = layer_data_a[20][1] ^ layer_data_b[20][1] ^ carry_bit_layer_adder[20][0]; // calculation of add result
assign carry_bit_layer_adder[20][1] = (layer_data_a[20][1] & layer_data_b[20][1]) | (layer_data_a[20][1] & carry_bit_layer_adder[20][0]) | (layer_data_b[20][1] & carry_bit_layer_adder[20][0]); // calculation of carry bit of adder
assign result_layer_adder[20][2] = layer_data_a[20][2] ^ layer_data_b[20][2] ^ carry_bit_layer_adder[20][1]; // calculation of add result
assign carry_bit_layer_adder[20][2] = (layer_data_a[20][2] & layer_data_b[20][2]) | (layer_data_a[20][2] & carry_bit_layer_adder[20][1]) | (layer_data_b[20][2] & carry_bit_layer_adder[20][1]); // calculation of carry bit of adder
assign result_layer_adder[20][3] = layer_data_a[20][3] ^ layer_data_b[20][3] ^ carry_bit_layer_adder[20][2]; // calculation of add result
assign carry_bit_layer_adder[20][3] = (layer_data_a[20][3] & layer_data_b[20][3]) | (layer_data_a[20][3] & carry_bit_layer_adder[20][2]) | (layer_data_b[20][3] & carry_bit_layer_adder[20][2]); // calculation of carry bit of adder
assign result_layer_adder[20][4] = layer_data_a[20][4] ^ layer_data_b[20][4] ^ carry_bit_layer_adder[20][3]; // calculation of add result
assign carry_bit_layer_adder[20][4] = (layer_data_a[20][4] & layer_data_b[20][4]) | (layer_data_a[20][4] & carry_bit_layer_adder[20][3]) | (layer_data_b[20][4] & carry_bit_layer_adder[20][3]); // calculation of carry bit of adder
assign result_layer_adder[20][5] = layer_data_a[20][5] ^ layer_data_b[20][5] ^ carry_bit_layer_adder[20][4]; // calculation of add result
assign carry_bit_layer_adder[20][5] = (layer_data_a[20][5] & layer_data_b[20][5]) | (layer_data_a[20][5] & carry_bit_layer_adder[20][4]) | (layer_data_b[20][5] & carry_bit_layer_adder[20][4]); // calculation of carry bit of adder
assign result_layer_adder[20][6] = layer_data_a[20][6] ^ layer_data_b[20][6] ^ carry_bit_layer_adder[20][5]; // calculation of add result
assign carry_bit_layer_adder[20][6] = (layer_data_a[20][6] & layer_data_b[20][6]) | (layer_data_a[20][6] & carry_bit_layer_adder[20][5]) | (layer_data_b[20][6] & carry_bit_layer_adder[20][5]); // calculation of carry bit of adder
assign result_layer_adder[20][7] = layer_data_a[20][7] ^ layer_data_b[20][7] ^ carry_bit_layer_adder[20][6]; // calculation of add result
assign carry_bit_layer_adder[20][7] = (layer_data_a[20][7] & layer_data_b[20][7]) | (layer_data_a[20][7] & carry_bit_layer_adder[20][6]) | (layer_data_b[20][7] & carry_bit_layer_adder[20][6]); // calculation of carry bit of adder
assign result_layer_adder[20][8] = layer_data_a[20][8] ^ layer_data_b[20][8] ^ carry_bit_layer_adder[20][7]; // calculation of add result
assign carry_bit_layer_adder[20][8] = (layer_data_a[20][8] & layer_data_b[20][8]) | (layer_data_a[20][8] & carry_bit_layer_adder[20][7]) | (layer_data_b[20][8] & carry_bit_layer_adder[20][7]); // calculation of carry bit of adder
assign result_layer_adder[20][9] = layer_data_a[20][9] ^ layer_data_b[20][9] ^ carry_bit_layer_adder[20][8]; // calculation of add result
assign carry_bit_layer_adder[20][9] = (layer_data_a[20][9] & layer_data_b[20][9]) | (layer_data_a[20][9] & carry_bit_layer_adder[20][8]) | (layer_data_b[20][9] & carry_bit_layer_adder[20][8]); // calculation of carry bit of adder
assign result_layer_adder[20][10] = layer_data_a[20][10] ^ layer_data_b[20][10] ^ carry_bit_layer_adder[20][9]; // calculation of add result
assign carry_bit_layer_adder[20][10] = (layer_data_a[20][10] & layer_data_b[20][10]) | (layer_data_a[20][10] & carry_bit_layer_adder[20][9]) | (layer_data_b[20][10] & carry_bit_layer_adder[20][9]); // calculation of carry bit of adder
assign result_layer_adder[20][11] = layer_data_a[20][11] ^ layer_data_b[20][11] ^ carry_bit_layer_adder[20][10]; // calculation of add result
assign carry_bit_layer_adder[20][11] = (layer_data_a[20][11] & layer_data_b[20][11]) | (layer_data_a[20][11] & carry_bit_layer_adder[20][10]) | (layer_data_b[20][11] & carry_bit_layer_adder[20][10]); // calculation of carry bit of adder
assign result_layer_adder[20][12] = layer_data_a[20][12] ^ layer_data_b[20][12] ^ carry_bit_layer_adder[20][11]; // calculation of add result
assign carry_bit_layer_adder[20][12] = (layer_data_a[20][12] & layer_data_b[20][12]) | (layer_data_a[20][12] & carry_bit_layer_adder[20][11]) | (layer_data_b[20][12] & carry_bit_layer_adder[20][11]); // calculation of carry bit of adder
assign result_layer_adder[20][13] = layer_data_a[20][13] ^ layer_data_b[20][13] ^ carry_bit_layer_adder[20][12]; // calculation of add result
assign carry_bit_layer_adder[20][13] = (layer_data_a[20][13] & layer_data_b[20][13]) | (layer_data_a[20][13] & carry_bit_layer_adder[20][12]) | (layer_data_b[20][13] & carry_bit_layer_adder[20][12]); // calculation of carry bit of adder
assign result_layer_adder[20][14] = layer_data_a[20][14] ^ layer_data_b[20][14] ^ carry_bit_layer_adder[20][13]; // calculation of add result
assign carry_bit_layer_adder[20][14] = (layer_data_a[20][14] & layer_data_b[20][14]) | (layer_data_a[20][14] & carry_bit_layer_adder[20][13]) | (layer_data_b[20][14] & carry_bit_layer_adder[20][13]); // calculation of carry bit of adder
assign result_layer_adder[20][15] = layer_data_a[20][15] ^ layer_data_b[20][15] ^ carry_bit_layer_adder[20][14]; // calculation of add result
assign carry_bit_layer_adder[20][15] = (layer_data_a[20][15] & layer_data_b[20][15]) | (layer_data_a[20][15] & carry_bit_layer_adder[20][14]) | (layer_data_b[20][15] & carry_bit_layer_adder[20][14]); // calculation of carry bit of adder
assign result_layer_adder[20][16] = layer_data_a[20][16] ^ layer_data_b[20][16] ^ carry_bit_layer_adder[20][15]; // calculation of add result
assign carry_bit_layer_adder[20][16] = (layer_data_a[20][16] & layer_data_b[20][16]) | (layer_data_a[20][16] & carry_bit_layer_adder[20][15]) | (layer_data_b[20][16] & carry_bit_layer_adder[20][15]); // calculation of carry bit of adder
assign result_layer_adder[20][17] = layer_data_a[20][17] ^ layer_data_b[20][17] ^ carry_bit_layer_adder[20][16]; // calculation of add result
assign carry_bit_layer_adder[20][17] = (layer_data_a[20][17] & layer_data_b[20][17]) | (layer_data_a[20][17] & carry_bit_layer_adder[20][16]) | (layer_data_b[20][17] & carry_bit_layer_adder[20][16]); // calculation of carry bit of adder
assign result_layer_adder[20][18] = layer_data_a[20][18] ^ layer_data_b[20][18] ^ carry_bit_layer_adder[20][17]; // calculation of add result
assign carry_bit_layer_adder[20][18] = (layer_data_a[20][18] & layer_data_b[20][18]) | (layer_data_a[20][18] & carry_bit_layer_adder[20][17]) | (layer_data_b[20][18] & carry_bit_layer_adder[20][17]); // calculation of carry bit of adder
assign result_layer_adder[20][19] = layer_data_a[20][19] ^ layer_data_b[20][19] ^ carry_bit_layer_adder[20][18]; // calculation of add result
assign carry_bit_layer_adder[20][19] = (layer_data_a[20][19] & layer_data_b[20][19]) | (layer_data_a[20][19] & carry_bit_layer_adder[20][18]) | (layer_data_b[20][19] & carry_bit_layer_adder[20][18]); // calculation of carry bit of adder
assign result_layer_adder[20][20] = layer_data_a[20][20] ^ layer_data_b[20][20] ^ carry_bit_layer_adder[20][19]; // calculation of add result
assign carry_bit_layer_adder[20][20] = (layer_data_a[20][20] & layer_data_b[20][20]) | (layer_data_a[20][20] & carry_bit_layer_adder[20][19]) | (layer_data_b[20][20] & carry_bit_layer_adder[20][19]); // calculation of carry bit of adder
assign result_layer_adder[20][21] = layer_data_a[20][21] ^ layer_data_b[20][21] ^ carry_bit_layer_adder[20][20]; // calculation of add result
assign carry_bit_layer_adder[20][21] = (layer_data_a[20][21] & layer_data_b[20][21]) | (layer_data_a[20][21] & carry_bit_layer_adder[20][20]) | (layer_data_b[20][21] & carry_bit_layer_adder[20][20]); // calculation of carry bit of adder
assign result_layer_adder[20][22] = layer_data_a[20][22] ^ layer_data_b[20][22] ^ carry_bit_layer_adder[20][21]; // calculation of add result
assign carry_bit_layer_adder[20][22] = (layer_data_a[20][22] & layer_data_b[20][22]) | (layer_data_a[20][22] & carry_bit_layer_adder[20][21]) | (layer_data_b[20][22] & carry_bit_layer_adder[20][21]); // calculation of carry bit of adder
assign result_layer_adder[20][23] = layer_data_a[20][23] ^ layer_data_b[20][23] ^ carry_bit_layer_adder[20][22]; // calculation of add result
assign carry_bit_layer_adder[20][23] = (layer_data_a[20][23] & layer_data_b[20][23]) | (layer_data_a[20][23] & carry_bit_layer_adder[20][22]) | (layer_data_b[20][23] & carry_bit_layer_adder[20][22]); // calculation of carry bit of adder
assign result_layer_adder[20][24] = layer_data_a[20][24] ^ layer_data_b[20][24] ^ carry_bit_layer_adder[20][23]; // calculation of add result
assign carry_bit_layer_adder[20][24] = (layer_data_a[20][24] & layer_data_b[20][24]) | (layer_data_a[20][24] & carry_bit_layer_adder[20][23]) | (layer_data_b[20][24] & carry_bit_layer_adder[20][23]); // calculation of carry bit of adder
assign result_layer_adder[20][25] = layer_data_a[20][25] ^ layer_data_b[20][25] ^ carry_bit_layer_adder[20][24]; // calculation of add result
assign carry_bit_layer_adder[20][25] = (layer_data_a[20][25] & layer_data_b[20][25]) | (layer_data_a[20][25] & carry_bit_layer_adder[20][24]) | (layer_data_b[20][25] & carry_bit_layer_adder[20][24]); // calculation of carry bit of adder
assign result_layer_adder[20][26] = layer_data_a[20][26] ^ layer_data_b[20][26] ^ carry_bit_layer_adder[20][25]; // calculation of add result
assign carry_bit_layer_adder[20][26] = (layer_data_a[20][26] & layer_data_b[20][26]) | (layer_data_a[20][26] & carry_bit_layer_adder[20][25]) | (layer_data_b[20][26] & carry_bit_layer_adder[20][25]); // calculation of carry bit of adder
assign result_layer_adder[20][27] = layer_data_a[20][27] ^ layer_data_b[20][27] ^ carry_bit_layer_adder[20][26]; // calculation of add result
assign carry_bit_layer_adder[20][27] = (layer_data_a[20][27] & layer_data_b[20][27]) | (layer_data_a[20][27] & carry_bit_layer_adder[20][26]) | (layer_data_b[20][27] & carry_bit_layer_adder[20][26]); // calculation of carry bit of adder
assign result_layer_adder[20][28] = layer_data_a[20][28] ^ layer_data_b[20][28] ^ carry_bit_layer_adder[20][27]; // calculation of add result
assign carry_bit_layer_adder[20][28] = (layer_data_a[20][28] & layer_data_b[20][28]) | (layer_data_a[20][28] & carry_bit_layer_adder[20][27]) | (layer_data_b[20][28] & carry_bit_layer_adder[20][27]); // calculation of carry bit of adder
assign result_layer_adder[20][29] = layer_data_a[20][29] ^ layer_data_b[20][29] ^ carry_bit_layer_adder[20][28]; // calculation of add result
assign carry_bit_layer_adder[20][29] = (layer_data_a[20][29] & layer_data_b[20][29]) | (layer_data_a[20][29] & carry_bit_layer_adder[20][28]) | (layer_data_b[20][29] & carry_bit_layer_adder[20][28]); // calculation of carry bit of adder
assign result_layer_adder[20][30] = layer_data_a[20][30] ^ layer_data_b[20][30] ^ carry_bit_layer_adder[20][29]; // calculation of add result
assign carry_bit_layer_adder[20][30] = (layer_data_a[20][30] & layer_data_b[20][30]) | (layer_data_a[20][30] & carry_bit_layer_adder[20][29]) | (layer_data_b[20][30] & carry_bit_layer_adder[20][29]); // calculation of carry bit of adder
assign result_layer_adder[20][31] = layer_data_a[20][31] ^ layer_data_b[20][31] ^ carry_bit_layer_adder[20][30]; // calculation of add result
assign carry_bit_layer_adder[20][31] = (layer_data_a[20][31] & layer_data_b[20][31]) | (layer_data_a[20][31] & carry_bit_layer_adder[20][30]) | (layer_data_b[20][31] & carry_bit_layer_adder[20][30]); // calculation of carry bit of adder
assign result_layer_adder[20][32] = layer_data_a[20][32] ^ layer_data_b[20][32] ^ carry_bit_layer_adder[20][31]; // calculation of add result

// Layer 22
assign layer_data_a[21][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[20][32] == 1'b1) ? {layer_data_a[20][31:0], operand_a[11]} : {result_layer_adder[20][31:0], operand_a[11]}) : {1'b0, result_layer_adder[20][32:1]}; // data select for layer 22
assign layer_data_b[21][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[21] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 22

// Layer 22 adder
assign result_layer_adder[21][0] = layer_data_a[21][0] ^ layer_data_b[21][0]; // calculation of add result
assign carry_bit_layer_adder[21][0] = layer_data_a[21][0] & layer_data_b[21][0]; // calculation of carry bit of adder
assign result_layer_adder[21][1] = layer_data_a[21][1] ^ layer_data_b[21][1] ^ carry_bit_layer_adder[21][0]; // calculation of add result
assign carry_bit_layer_adder[21][1] = (layer_data_a[21][1] & layer_data_b[21][1]) | (layer_data_a[21][1] & carry_bit_layer_adder[21][0]) | (layer_data_b[21][1] & carry_bit_layer_adder[21][0]); // calculation of carry bit of adder
assign result_layer_adder[21][2] = layer_data_a[21][2] ^ layer_data_b[21][2] ^ carry_bit_layer_adder[21][1]; // calculation of add result
assign carry_bit_layer_adder[21][2] = (layer_data_a[21][2] & layer_data_b[21][2]) | (layer_data_a[21][2] & carry_bit_layer_adder[21][1]) | (layer_data_b[21][2] & carry_bit_layer_adder[21][1]); // calculation of carry bit of adder
assign result_layer_adder[21][3] = layer_data_a[21][3] ^ layer_data_b[21][3] ^ carry_bit_layer_adder[21][2]; // calculation of add result
assign carry_bit_layer_adder[21][3] = (layer_data_a[21][3] & layer_data_b[21][3]) | (layer_data_a[21][3] & carry_bit_layer_adder[21][2]) | (layer_data_b[21][3] & carry_bit_layer_adder[21][2]); // calculation of carry bit of adder
assign result_layer_adder[21][4] = layer_data_a[21][4] ^ layer_data_b[21][4] ^ carry_bit_layer_adder[21][3]; // calculation of add result
assign carry_bit_layer_adder[21][4] = (layer_data_a[21][4] & layer_data_b[21][4]) | (layer_data_a[21][4] & carry_bit_layer_adder[21][3]) | (layer_data_b[21][4] & carry_bit_layer_adder[21][3]); // calculation of carry bit of adder
assign result_layer_adder[21][5] = layer_data_a[21][5] ^ layer_data_b[21][5] ^ carry_bit_layer_adder[21][4]; // calculation of add result
assign carry_bit_layer_adder[21][5] = (layer_data_a[21][5] & layer_data_b[21][5]) | (layer_data_a[21][5] & carry_bit_layer_adder[21][4]) | (layer_data_b[21][5] & carry_bit_layer_adder[21][4]); // calculation of carry bit of adder
assign result_layer_adder[21][6] = layer_data_a[21][6] ^ layer_data_b[21][6] ^ carry_bit_layer_adder[21][5]; // calculation of add result
assign carry_bit_layer_adder[21][6] = (layer_data_a[21][6] & layer_data_b[21][6]) | (layer_data_a[21][6] & carry_bit_layer_adder[21][5]) | (layer_data_b[21][6] & carry_bit_layer_adder[21][5]); // calculation of carry bit of adder
assign result_layer_adder[21][7] = layer_data_a[21][7] ^ layer_data_b[21][7] ^ carry_bit_layer_adder[21][6]; // calculation of add result
assign carry_bit_layer_adder[21][7] = (layer_data_a[21][7] & layer_data_b[21][7]) | (layer_data_a[21][7] & carry_bit_layer_adder[21][6]) | (layer_data_b[21][7] & carry_bit_layer_adder[21][6]); // calculation of carry bit of adder
assign result_layer_adder[21][8] = layer_data_a[21][8] ^ layer_data_b[21][8] ^ carry_bit_layer_adder[21][7]; // calculation of add result
assign carry_bit_layer_adder[21][8] = (layer_data_a[21][8] & layer_data_b[21][8]) | (layer_data_a[21][8] & carry_bit_layer_adder[21][7]) | (layer_data_b[21][8] & carry_bit_layer_adder[21][7]); // calculation of carry bit of adder
assign result_layer_adder[21][9] = layer_data_a[21][9] ^ layer_data_b[21][9] ^ carry_bit_layer_adder[21][8]; // calculation of add result
assign carry_bit_layer_adder[21][9] = (layer_data_a[21][9] & layer_data_b[21][9]) | (layer_data_a[21][9] & carry_bit_layer_adder[21][8]) | (layer_data_b[21][9] & carry_bit_layer_adder[21][8]); // calculation of carry bit of adder
assign result_layer_adder[21][10] = layer_data_a[21][10] ^ layer_data_b[21][10] ^ carry_bit_layer_adder[21][9]; // calculation of add result
assign carry_bit_layer_adder[21][10] = (layer_data_a[21][10] & layer_data_b[21][10]) | (layer_data_a[21][10] & carry_bit_layer_adder[21][9]) | (layer_data_b[21][10] & carry_bit_layer_adder[21][9]); // calculation of carry bit of adder
assign result_layer_adder[21][11] = layer_data_a[21][11] ^ layer_data_b[21][11] ^ carry_bit_layer_adder[21][10]; // calculation of add result
assign carry_bit_layer_adder[21][11] = (layer_data_a[21][11] & layer_data_b[21][11]) | (layer_data_a[21][11] & carry_bit_layer_adder[21][10]) | (layer_data_b[21][11] & carry_bit_layer_adder[21][10]); // calculation of carry bit of adder
assign result_layer_adder[21][12] = layer_data_a[21][12] ^ layer_data_b[21][12] ^ carry_bit_layer_adder[21][11]; // calculation of add result
assign carry_bit_layer_adder[21][12] = (layer_data_a[21][12] & layer_data_b[21][12]) | (layer_data_a[21][12] & carry_bit_layer_adder[21][11]) | (layer_data_b[21][12] & carry_bit_layer_adder[21][11]); // calculation of carry bit of adder
assign result_layer_adder[21][13] = layer_data_a[21][13] ^ layer_data_b[21][13] ^ carry_bit_layer_adder[21][12]; // calculation of add result
assign carry_bit_layer_adder[21][13] = (layer_data_a[21][13] & layer_data_b[21][13]) | (layer_data_a[21][13] & carry_bit_layer_adder[21][12]) | (layer_data_b[21][13] & carry_bit_layer_adder[21][12]); // calculation of carry bit of adder
assign result_layer_adder[21][14] = layer_data_a[21][14] ^ layer_data_b[21][14] ^ carry_bit_layer_adder[21][13]; // calculation of add result
assign carry_bit_layer_adder[21][14] = (layer_data_a[21][14] & layer_data_b[21][14]) | (layer_data_a[21][14] & carry_bit_layer_adder[21][13]) | (layer_data_b[21][14] & carry_bit_layer_adder[21][13]); // calculation of carry bit of adder
assign result_layer_adder[21][15] = layer_data_a[21][15] ^ layer_data_b[21][15] ^ carry_bit_layer_adder[21][14]; // calculation of add result
assign carry_bit_layer_adder[21][15] = (layer_data_a[21][15] & layer_data_b[21][15]) | (layer_data_a[21][15] & carry_bit_layer_adder[21][14]) | (layer_data_b[21][15] & carry_bit_layer_adder[21][14]); // calculation of carry bit of adder
assign result_layer_adder[21][16] = layer_data_a[21][16] ^ layer_data_b[21][16] ^ carry_bit_layer_adder[21][15]; // calculation of add result
assign carry_bit_layer_adder[21][16] = (layer_data_a[21][16] & layer_data_b[21][16]) | (layer_data_a[21][16] & carry_bit_layer_adder[21][15]) | (layer_data_b[21][16] & carry_bit_layer_adder[21][15]); // calculation of carry bit of adder
assign result_layer_adder[21][17] = layer_data_a[21][17] ^ layer_data_b[21][17] ^ carry_bit_layer_adder[21][16]; // calculation of add result
assign carry_bit_layer_adder[21][17] = (layer_data_a[21][17] & layer_data_b[21][17]) | (layer_data_a[21][17] & carry_bit_layer_adder[21][16]) | (layer_data_b[21][17] & carry_bit_layer_adder[21][16]); // calculation of carry bit of adder
assign result_layer_adder[21][18] = layer_data_a[21][18] ^ layer_data_b[21][18] ^ carry_bit_layer_adder[21][17]; // calculation of add result
assign carry_bit_layer_adder[21][18] = (layer_data_a[21][18] & layer_data_b[21][18]) | (layer_data_a[21][18] & carry_bit_layer_adder[21][17]) | (layer_data_b[21][18] & carry_bit_layer_adder[21][17]); // calculation of carry bit of adder
assign result_layer_adder[21][19] = layer_data_a[21][19] ^ layer_data_b[21][19] ^ carry_bit_layer_adder[21][18]; // calculation of add result
assign carry_bit_layer_adder[21][19] = (layer_data_a[21][19] & layer_data_b[21][19]) | (layer_data_a[21][19] & carry_bit_layer_adder[21][18]) | (layer_data_b[21][19] & carry_bit_layer_adder[21][18]); // calculation of carry bit of adder
assign result_layer_adder[21][20] = layer_data_a[21][20] ^ layer_data_b[21][20] ^ carry_bit_layer_adder[21][19]; // calculation of add result
assign carry_bit_layer_adder[21][20] = (layer_data_a[21][20] & layer_data_b[21][20]) | (layer_data_a[21][20] & carry_bit_layer_adder[21][19]) | (layer_data_b[21][20] & carry_bit_layer_adder[21][19]); // calculation of carry bit of adder
assign result_layer_adder[21][21] = layer_data_a[21][21] ^ layer_data_b[21][21] ^ carry_bit_layer_adder[21][20]; // calculation of add result
assign carry_bit_layer_adder[21][21] = (layer_data_a[21][21] & layer_data_b[21][21]) | (layer_data_a[21][21] & carry_bit_layer_adder[21][20]) | (layer_data_b[21][21] & carry_bit_layer_adder[21][20]); // calculation of carry bit of adder
assign result_layer_adder[21][22] = layer_data_a[21][22] ^ layer_data_b[21][22] ^ carry_bit_layer_adder[21][21]; // calculation of add result
assign carry_bit_layer_adder[21][22] = (layer_data_a[21][22] & layer_data_b[21][22]) | (layer_data_a[21][22] & carry_bit_layer_adder[21][21]) | (layer_data_b[21][22] & carry_bit_layer_adder[21][21]); // calculation of carry bit of adder
assign result_layer_adder[21][23] = layer_data_a[21][23] ^ layer_data_b[21][23] ^ carry_bit_layer_adder[21][22]; // calculation of add result
assign carry_bit_layer_adder[21][23] = (layer_data_a[21][23] & layer_data_b[21][23]) | (layer_data_a[21][23] & carry_bit_layer_adder[21][22]) | (layer_data_b[21][23] & carry_bit_layer_adder[21][22]); // calculation of carry bit of adder
assign result_layer_adder[21][24] = layer_data_a[21][24] ^ layer_data_b[21][24] ^ carry_bit_layer_adder[21][23]; // calculation of add result
assign carry_bit_layer_adder[21][24] = (layer_data_a[21][24] & layer_data_b[21][24]) | (layer_data_a[21][24] & carry_bit_layer_adder[21][23]) | (layer_data_b[21][24] & carry_bit_layer_adder[21][23]); // calculation of carry bit of adder
assign result_layer_adder[21][25] = layer_data_a[21][25] ^ layer_data_b[21][25] ^ carry_bit_layer_adder[21][24]; // calculation of add result
assign carry_bit_layer_adder[21][25] = (layer_data_a[21][25] & layer_data_b[21][25]) | (layer_data_a[21][25] & carry_bit_layer_adder[21][24]) | (layer_data_b[21][25] & carry_bit_layer_adder[21][24]); // calculation of carry bit of adder
assign result_layer_adder[21][26] = layer_data_a[21][26] ^ layer_data_b[21][26] ^ carry_bit_layer_adder[21][25]; // calculation of add result
assign carry_bit_layer_adder[21][26] = (layer_data_a[21][26] & layer_data_b[21][26]) | (layer_data_a[21][26] & carry_bit_layer_adder[21][25]) | (layer_data_b[21][26] & carry_bit_layer_adder[21][25]); // calculation of carry bit of adder
assign result_layer_adder[21][27] = layer_data_a[21][27] ^ layer_data_b[21][27] ^ carry_bit_layer_adder[21][26]; // calculation of add result
assign carry_bit_layer_adder[21][27] = (layer_data_a[21][27] & layer_data_b[21][27]) | (layer_data_a[21][27] & carry_bit_layer_adder[21][26]) | (layer_data_b[21][27] & carry_bit_layer_adder[21][26]); // calculation of carry bit of adder
assign result_layer_adder[21][28] = layer_data_a[21][28] ^ layer_data_b[21][28] ^ carry_bit_layer_adder[21][27]; // calculation of add result
assign carry_bit_layer_adder[21][28] = (layer_data_a[21][28] & layer_data_b[21][28]) | (layer_data_a[21][28] & carry_bit_layer_adder[21][27]) | (layer_data_b[21][28] & carry_bit_layer_adder[21][27]); // calculation of carry bit of adder
assign result_layer_adder[21][29] = layer_data_a[21][29] ^ layer_data_b[21][29] ^ carry_bit_layer_adder[21][28]; // calculation of add result
assign carry_bit_layer_adder[21][29] = (layer_data_a[21][29] & layer_data_b[21][29]) | (layer_data_a[21][29] & carry_bit_layer_adder[21][28]) | (layer_data_b[21][29] & carry_bit_layer_adder[21][28]); // calculation of carry bit of adder
assign result_layer_adder[21][30] = layer_data_a[21][30] ^ layer_data_b[21][30] ^ carry_bit_layer_adder[21][29]; // calculation of add result
assign carry_bit_layer_adder[21][30] = (layer_data_a[21][30] & layer_data_b[21][30]) | (layer_data_a[21][30] & carry_bit_layer_adder[21][29]) | (layer_data_b[21][30] & carry_bit_layer_adder[21][29]); // calculation of carry bit of adder
assign result_layer_adder[21][31] = layer_data_a[21][31] ^ layer_data_b[21][31] ^ carry_bit_layer_adder[21][30]; // calculation of add result
assign carry_bit_layer_adder[21][31] = (layer_data_a[21][31] & layer_data_b[21][31]) | (layer_data_a[21][31] & carry_bit_layer_adder[21][30]) | (layer_data_b[21][31] & carry_bit_layer_adder[21][30]); // calculation of carry bit of adder
assign result_layer_adder[21][32] = layer_data_a[21][32] ^ layer_data_b[21][32] ^ carry_bit_layer_adder[21][31]; // calculation of add result

// Layer 23
assign layer_data_a[22][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[21][32] == 1'b1) ? {layer_data_a[21][31:0], operand_a[10]} : {result_layer_adder[21][31:0], operand_a[10]}) : {1'b0, result_layer_adder[21][32:1]}; // data select for layer 23
assign layer_data_b[22][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[22] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 23

// Layer 23 adder
assign result_layer_adder[22][0] = layer_data_a[22][0] ^ layer_data_b[22][0]; // calculation of add result
assign carry_bit_layer_adder[22][0] = layer_data_a[22][0] & layer_data_b[22][0]; // calculation of carry bit of adder
assign result_layer_adder[22][1] = layer_data_a[22][1] ^ layer_data_b[22][1] ^ carry_bit_layer_adder[22][0]; // calculation of add result
assign carry_bit_layer_adder[22][1] = (layer_data_a[22][1] & layer_data_b[22][1]) | (layer_data_a[22][1] & carry_bit_layer_adder[22][0]) | (layer_data_b[22][1] & carry_bit_layer_adder[22][0]); // calculation of carry bit of adder
assign result_layer_adder[22][2] = layer_data_a[22][2] ^ layer_data_b[22][2] ^ carry_bit_layer_adder[22][1]; // calculation of add result
assign carry_bit_layer_adder[22][2] = (layer_data_a[22][2] & layer_data_b[22][2]) | (layer_data_a[22][2] & carry_bit_layer_adder[22][1]) | (layer_data_b[22][2] & carry_bit_layer_adder[22][1]); // calculation of carry bit of adder
assign result_layer_adder[22][3] = layer_data_a[22][3] ^ layer_data_b[22][3] ^ carry_bit_layer_adder[22][2]; // calculation of add result
assign carry_bit_layer_adder[22][3] = (layer_data_a[22][3] & layer_data_b[22][3]) | (layer_data_a[22][3] & carry_bit_layer_adder[22][2]) | (layer_data_b[22][3] & carry_bit_layer_adder[22][2]); // calculation of carry bit of adder
assign result_layer_adder[22][4] = layer_data_a[22][4] ^ layer_data_b[22][4] ^ carry_bit_layer_adder[22][3]; // calculation of add result
assign carry_bit_layer_adder[22][4] = (layer_data_a[22][4] & layer_data_b[22][4]) | (layer_data_a[22][4] & carry_bit_layer_adder[22][3]) | (layer_data_b[22][4] & carry_bit_layer_adder[22][3]); // calculation of carry bit of adder
assign result_layer_adder[22][5] = layer_data_a[22][5] ^ layer_data_b[22][5] ^ carry_bit_layer_adder[22][4]; // calculation of add result
assign carry_bit_layer_adder[22][5] = (layer_data_a[22][5] & layer_data_b[22][5]) | (layer_data_a[22][5] & carry_bit_layer_adder[22][4]) | (layer_data_b[22][5] & carry_bit_layer_adder[22][4]); // calculation of carry bit of adder
assign result_layer_adder[22][6] = layer_data_a[22][6] ^ layer_data_b[22][6] ^ carry_bit_layer_adder[22][5]; // calculation of add result
assign carry_bit_layer_adder[22][6] = (layer_data_a[22][6] & layer_data_b[22][6]) | (layer_data_a[22][6] & carry_bit_layer_adder[22][5]) | (layer_data_b[22][6] & carry_bit_layer_adder[22][5]); // calculation of carry bit of adder
assign result_layer_adder[22][7] = layer_data_a[22][7] ^ layer_data_b[22][7] ^ carry_bit_layer_adder[22][6]; // calculation of add result
assign carry_bit_layer_adder[22][7] = (layer_data_a[22][7] & layer_data_b[22][7]) | (layer_data_a[22][7] & carry_bit_layer_adder[22][6]) | (layer_data_b[22][7] & carry_bit_layer_adder[22][6]); // calculation of carry bit of adder
assign result_layer_adder[22][8] = layer_data_a[22][8] ^ layer_data_b[22][8] ^ carry_bit_layer_adder[22][7]; // calculation of add result
assign carry_bit_layer_adder[22][8] = (layer_data_a[22][8] & layer_data_b[22][8]) | (layer_data_a[22][8] & carry_bit_layer_adder[22][7]) | (layer_data_b[22][8] & carry_bit_layer_adder[22][7]); // calculation of carry bit of adder
assign result_layer_adder[22][9] = layer_data_a[22][9] ^ layer_data_b[22][9] ^ carry_bit_layer_adder[22][8]; // calculation of add result
assign carry_bit_layer_adder[22][9] = (layer_data_a[22][9] & layer_data_b[22][9]) | (layer_data_a[22][9] & carry_bit_layer_adder[22][8]) | (layer_data_b[22][9] & carry_bit_layer_adder[22][8]); // calculation of carry bit of adder
assign result_layer_adder[22][10] = layer_data_a[22][10] ^ layer_data_b[22][10] ^ carry_bit_layer_adder[22][9]; // calculation of add result
assign carry_bit_layer_adder[22][10] = (layer_data_a[22][10] & layer_data_b[22][10]) | (layer_data_a[22][10] & carry_bit_layer_adder[22][9]) | (layer_data_b[22][10] & carry_bit_layer_adder[22][9]); // calculation of carry bit of adder
assign result_layer_adder[22][11] = layer_data_a[22][11] ^ layer_data_b[22][11] ^ carry_bit_layer_adder[22][10]; // calculation of add result
assign carry_bit_layer_adder[22][11] = (layer_data_a[22][11] & layer_data_b[22][11]) | (layer_data_a[22][11] & carry_bit_layer_adder[22][10]) | (layer_data_b[22][11] & carry_bit_layer_adder[22][10]); // calculation of carry bit of adder
assign result_layer_adder[22][12] = layer_data_a[22][12] ^ layer_data_b[22][12] ^ carry_bit_layer_adder[22][11]; // calculation of add result
assign carry_bit_layer_adder[22][12] = (layer_data_a[22][12] & layer_data_b[22][12]) | (layer_data_a[22][12] & carry_bit_layer_adder[22][11]) | (layer_data_b[22][12] & carry_bit_layer_adder[22][11]); // calculation of carry bit of adder
assign result_layer_adder[22][13] = layer_data_a[22][13] ^ layer_data_b[22][13] ^ carry_bit_layer_adder[22][12]; // calculation of add result
assign carry_bit_layer_adder[22][13] = (layer_data_a[22][13] & layer_data_b[22][13]) | (layer_data_a[22][13] & carry_bit_layer_adder[22][12]) | (layer_data_b[22][13] & carry_bit_layer_adder[22][12]); // calculation of carry bit of adder
assign result_layer_adder[22][14] = layer_data_a[22][14] ^ layer_data_b[22][14] ^ carry_bit_layer_adder[22][13]; // calculation of add result
assign carry_bit_layer_adder[22][14] = (layer_data_a[22][14] & layer_data_b[22][14]) | (layer_data_a[22][14] & carry_bit_layer_adder[22][13]) | (layer_data_b[22][14] & carry_bit_layer_adder[22][13]); // calculation of carry bit of adder
assign result_layer_adder[22][15] = layer_data_a[22][15] ^ layer_data_b[22][15] ^ carry_bit_layer_adder[22][14]; // calculation of add result
assign carry_bit_layer_adder[22][15] = (layer_data_a[22][15] & layer_data_b[22][15]) | (layer_data_a[22][15] & carry_bit_layer_adder[22][14]) | (layer_data_b[22][15] & carry_bit_layer_adder[22][14]); // calculation of carry bit of adder
assign result_layer_adder[22][16] = layer_data_a[22][16] ^ layer_data_b[22][16] ^ carry_bit_layer_adder[22][15]; // calculation of add result
assign carry_bit_layer_adder[22][16] = (layer_data_a[22][16] & layer_data_b[22][16]) | (layer_data_a[22][16] & carry_bit_layer_adder[22][15]) | (layer_data_b[22][16] & carry_bit_layer_adder[22][15]); // calculation of carry bit of adder
assign result_layer_adder[22][17] = layer_data_a[22][17] ^ layer_data_b[22][17] ^ carry_bit_layer_adder[22][16]; // calculation of add result
assign carry_bit_layer_adder[22][17] = (layer_data_a[22][17] & layer_data_b[22][17]) | (layer_data_a[22][17] & carry_bit_layer_adder[22][16]) | (layer_data_b[22][17] & carry_bit_layer_adder[22][16]); // calculation of carry bit of adder
assign result_layer_adder[22][18] = layer_data_a[22][18] ^ layer_data_b[22][18] ^ carry_bit_layer_adder[22][17]; // calculation of add result
assign carry_bit_layer_adder[22][18] = (layer_data_a[22][18] & layer_data_b[22][18]) | (layer_data_a[22][18] & carry_bit_layer_adder[22][17]) | (layer_data_b[22][18] & carry_bit_layer_adder[22][17]); // calculation of carry bit of adder
assign result_layer_adder[22][19] = layer_data_a[22][19] ^ layer_data_b[22][19] ^ carry_bit_layer_adder[22][18]; // calculation of add result
assign carry_bit_layer_adder[22][19] = (layer_data_a[22][19] & layer_data_b[22][19]) | (layer_data_a[22][19] & carry_bit_layer_adder[22][18]) | (layer_data_b[22][19] & carry_bit_layer_adder[22][18]); // calculation of carry bit of adder
assign result_layer_adder[22][20] = layer_data_a[22][20] ^ layer_data_b[22][20] ^ carry_bit_layer_adder[22][19]; // calculation of add result
assign carry_bit_layer_adder[22][20] = (layer_data_a[22][20] & layer_data_b[22][20]) | (layer_data_a[22][20] & carry_bit_layer_adder[22][19]) | (layer_data_b[22][20] & carry_bit_layer_adder[22][19]); // calculation of carry bit of adder
assign result_layer_adder[22][21] = layer_data_a[22][21] ^ layer_data_b[22][21] ^ carry_bit_layer_adder[22][20]; // calculation of add result
assign carry_bit_layer_adder[22][21] = (layer_data_a[22][21] & layer_data_b[22][21]) | (layer_data_a[22][21] & carry_bit_layer_adder[22][20]) | (layer_data_b[22][21] & carry_bit_layer_adder[22][20]); // calculation of carry bit of adder
assign result_layer_adder[22][22] = layer_data_a[22][22] ^ layer_data_b[22][22] ^ carry_bit_layer_adder[22][21]; // calculation of add result
assign carry_bit_layer_adder[22][22] = (layer_data_a[22][22] & layer_data_b[22][22]) | (layer_data_a[22][22] & carry_bit_layer_adder[22][21]) | (layer_data_b[22][22] & carry_bit_layer_adder[22][21]); // calculation of carry bit of adder
assign result_layer_adder[22][23] = layer_data_a[22][23] ^ layer_data_b[22][23] ^ carry_bit_layer_adder[22][22]; // calculation of add result
assign carry_bit_layer_adder[22][23] = (layer_data_a[22][23] & layer_data_b[22][23]) | (layer_data_a[22][23] & carry_bit_layer_adder[22][22]) | (layer_data_b[22][23] & carry_bit_layer_adder[22][22]); // calculation of carry bit of adder
assign result_layer_adder[22][24] = layer_data_a[22][24] ^ layer_data_b[22][24] ^ carry_bit_layer_adder[22][23]; // calculation of add result
assign carry_bit_layer_adder[22][24] = (layer_data_a[22][24] & layer_data_b[22][24]) | (layer_data_a[22][24] & carry_bit_layer_adder[22][23]) | (layer_data_b[22][24] & carry_bit_layer_adder[22][23]); // calculation of carry bit of adder
assign result_layer_adder[22][25] = layer_data_a[22][25] ^ layer_data_b[22][25] ^ carry_bit_layer_adder[22][24]; // calculation of add result
assign carry_bit_layer_adder[22][25] = (layer_data_a[22][25] & layer_data_b[22][25]) | (layer_data_a[22][25] & carry_bit_layer_adder[22][24]) | (layer_data_b[22][25] & carry_bit_layer_adder[22][24]); // calculation of carry bit of adder
assign result_layer_adder[22][26] = layer_data_a[22][26] ^ layer_data_b[22][26] ^ carry_bit_layer_adder[22][25]; // calculation of add result
assign carry_bit_layer_adder[22][26] = (layer_data_a[22][26] & layer_data_b[22][26]) | (layer_data_a[22][26] & carry_bit_layer_adder[22][25]) | (layer_data_b[22][26] & carry_bit_layer_adder[22][25]); // calculation of carry bit of adder
assign result_layer_adder[22][27] = layer_data_a[22][27] ^ layer_data_b[22][27] ^ carry_bit_layer_adder[22][26]; // calculation of add result
assign carry_bit_layer_adder[22][27] = (layer_data_a[22][27] & layer_data_b[22][27]) | (layer_data_a[22][27] & carry_bit_layer_adder[22][26]) | (layer_data_b[22][27] & carry_bit_layer_adder[22][26]); // calculation of carry bit of adder
assign result_layer_adder[22][28] = layer_data_a[22][28] ^ layer_data_b[22][28] ^ carry_bit_layer_adder[22][27]; // calculation of add result
assign carry_bit_layer_adder[22][28] = (layer_data_a[22][28] & layer_data_b[22][28]) | (layer_data_a[22][28] & carry_bit_layer_adder[22][27]) | (layer_data_b[22][28] & carry_bit_layer_adder[22][27]); // calculation of carry bit of adder
assign result_layer_adder[22][29] = layer_data_a[22][29] ^ layer_data_b[22][29] ^ carry_bit_layer_adder[22][28]; // calculation of add result
assign carry_bit_layer_adder[22][29] = (layer_data_a[22][29] & layer_data_b[22][29]) | (layer_data_a[22][29] & carry_bit_layer_adder[22][28]) | (layer_data_b[22][29] & carry_bit_layer_adder[22][28]); // calculation of carry bit of adder
assign result_layer_adder[22][30] = layer_data_a[22][30] ^ layer_data_b[22][30] ^ carry_bit_layer_adder[22][29]; // calculation of add result
assign carry_bit_layer_adder[22][30] = (layer_data_a[22][30] & layer_data_b[22][30]) | (layer_data_a[22][30] & carry_bit_layer_adder[22][29]) | (layer_data_b[22][30] & carry_bit_layer_adder[22][29]); // calculation of carry bit of adder
assign result_layer_adder[22][31] = layer_data_a[22][31] ^ layer_data_b[22][31] ^ carry_bit_layer_adder[22][30]; // calculation of add result
assign carry_bit_layer_adder[22][31] = (layer_data_a[22][31] & layer_data_b[22][31]) | (layer_data_a[22][31] & carry_bit_layer_adder[22][30]) | (layer_data_b[22][31] & carry_bit_layer_adder[22][30]); // calculation of carry bit of adder
assign result_layer_adder[22][32] = layer_data_a[22][32] ^ layer_data_b[22][32] ^ carry_bit_layer_adder[22][31]; // calculation of add result

// Layer 24
assign layer_data_a[23][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[22][32] == 1'b1) ? {layer_data_a[22][31:0], operand_a[9]} : {result_layer_adder[22][31:0], operand_a[9]}) : {1'b0, result_layer_adder[22][32:1]}; // data select for layer 24
assign layer_data_b[23][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[23] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 24

// Layer 24 adder
assign result_layer_adder[23][0] = layer_data_a[23][0] ^ layer_data_b[23][0]; // calculation of add result
assign carry_bit_layer_adder[23][0] = layer_data_a[23][0] & layer_data_b[23][0]; // calculation of carry bit of adder
assign result_layer_adder[23][1] = layer_data_a[23][1] ^ layer_data_b[23][1] ^ carry_bit_layer_adder[23][0]; // calculation of add result
assign carry_bit_layer_adder[23][1] = (layer_data_a[23][1] & layer_data_b[23][1]) | (layer_data_a[23][1] & carry_bit_layer_adder[23][0]) | (layer_data_b[23][1] & carry_bit_layer_adder[23][0]); // calculation of carry bit of adder
assign result_layer_adder[23][2] = layer_data_a[23][2] ^ layer_data_b[23][2] ^ carry_bit_layer_adder[23][1]; // calculation of add result
assign carry_bit_layer_adder[23][2] = (layer_data_a[23][2] & layer_data_b[23][2]) | (layer_data_a[23][2] & carry_bit_layer_adder[23][1]) | (layer_data_b[23][2] & carry_bit_layer_adder[23][1]); // calculation of carry bit of adder
assign result_layer_adder[23][3] = layer_data_a[23][3] ^ layer_data_b[23][3] ^ carry_bit_layer_adder[23][2]; // calculation of add result
assign carry_bit_layer_adder[23][3] = (layer_data_a[23][3] & layer_data_b[23][3]) | (layer_data_a[23][3] & carry_bit_layer_adder[23][2]) | (layer_data_b[23][3] & carry_bit_layer_adder[23][2]); // calculation of carry bit of adder
assign result_layer_adder[23][4] = layer_data_a[23][4] ^ layer_data_b[23][4] ^ carry_bit_layer_adder[23][3]; // calculation of add result
assign carry_bit_layer_adder[23][4] = (layer_data_a[23][4] & layer_data_b[23][4]) | (layer_data_a[23][4] & carry_bit_layer_adder[23][3]) | (layer_data_b[23][4] & carry_bit_layer_adder[23][3]); // calculation of carry bit of adder
assign result_layer_adder[23][5] = layer_data_a[23][5] ^ layer_data_b[23][5] ^ carry_bit_layer_adder[23][4]; // calculation of add result
assign carry_bit_layer_adder[23][5] = (layer_data_a[23][5] & layer_data_b[23][5]) | (layer_data_a[23][5] & carry_bit_layer_adder[23][4]) | (layer_data_b[23][5] & carry_bit_layer_adder[23][4]); // calculation of carry bit of adder
assign result_layer_adder[23][6] = layer_data_a[23][6] ^ layer_data_b[23][6] ^ carry_bit_layer_adder[23][5]; // calculation of add result
assign carry_bit_layer_adder[23][6] = (layer_data_a[23][6] & layer_data_b[23][6]) | (layer_data_a[23][6] & carry_bit_layer_adder[23][5]) | (layer_data_b[23][6] & carry_bit_layer_adder[23][5]); // calculation of carry bit of adder
assign result_layer_adder[23][7] = layer_data_a[23][7] ^ layer_data_b[23][7] ^ carry_bit_layer_adder[23][6]; // calculation of add result
assign carry_bit_layer_adder[23][7] = (layer_data_a[23][7] & layer_data_b[23][7]) | (layer_data_a[23][7] & carry_bit_layer_adder[23][6]) | (layer_data_b[23][7] & carry_bit_layer_adder[23][6]); // calculation of carry bit of adder
assign result_layer_adder[23][8] = layer_data_a[23][8] ^ layer_data_b[23][8] ^ carry_bit_layer_adder[23][7]; // calculation of add result
assign carry_bit_layer_adder[23][8] = (layer_data_a[23][8] & layer_data_b[23][8]) | (layer_data_a[23][8] & carry_bit_layer_adder[23][7]) | (layer_data_b[23][8] & carry_bit_layer_adder[23][7]); // calculation of carry bit of adder
assign result_layer_adder[23][9] = layer_data_a[23][9] ^ layer_data_b[23][9] ^ carry_bit_layer_adder[23][8]; // calculation of add result
assign carry_bit_layer_adder[23][9] = (layer_data_a[23][9] & layer_data_b[23][9]) | (layer_data_a[23][9] & carry_bit_layer_adder[23][8]) | (layer_data_b[23][9] & carry_bit_layer_adder[23][8]); // calculation of carry bit of adder
assign result_layer_adder[23][10] = layer_data_a[23][10] ^ layer_data_b[23][10] ^ carry_bit_layer_adder[23][9]; // calculation of add result
assign carry_bit_layer_adder[23][10] = (layer_data_a[23][10] & layer_data_b[23][10]) | (layer_data_a[23][10] & carry_bit_layer_adder[23][9]) | (layer_data_b[23][10] & carry_bit_layer_adder[23][9]); // calculation of carry bit of adder
assign result_layer_adder[23][11] = layer_data_a[23][11] ^ layer_data_b[23][11] ^ carry_bit_layer_adder[23][10]; // calculation of add result
assign carry_bit_layer_adder[23][11] = (layer_data_a[23][11] & layer_data_b[23][11]) | (layer_data_a[23][11] & carry_bit_layer_adder[23][10]) | (layer_data_b[23][11] & carry_bit_layer_adder[23][10]); // calculation of carry bit of adder
assign result_layer_adder[23][12] = layer_data_a[23][12] ^ layer_data_b[23][12] ^ carry_bit_layer_adder[23][11]; // calculation of add result
assign carry_bit_layer_adder[23][12] = (layer_data_a[23][12] & layer_data_b[23][12]) | (layer_data_a[23][12] & carry_bit_layer_adder[23][11]) | (layer_data_b[23][12] & carry_bit_layer_adder[23][11]); // calculation of carry bit of adder
assign result_layer_adder[23][13] = layer_data_a[23][13] ^ layer_data_b[23][13] ^ carry_bit_layer_adder[23][12]; // calculation of add result
assign carry_bit_layer_adder[23][13] = (layer_data_a[23][13] & layer_data_b[23][13]) | (layer_data_a[23][13] & carry_bit_layer_adder[23][12]) | (layer_data_b[23][13] & carry_bit_layer_adder[23][12]); // calculation of carry bit of adder
assign result_layer_adder[23][14] = layer_data_a[23][14] ^ layer_data_b[23][14] ^ carry_bit_layer_adder[23][13]; // calculation of add result
assign carry_bit_layer_adder[23][14] = (layer_data_a[23][14] & layer_data_b[23][14]) | (layer_data_a[23][14] & carry_bit_layer_adder[23][13]) | (layer_data_b[23][14] & carry_bit_layer_adder[23][13]); // calculation of carry bit of adder
assign result_layer_adder[23][15] = layer_data_a[23][15] ^ layer_data_b[23][15] ^ carry_bit_layer_adder[23][14]; // calculation of add result
assign carry_bit_layer_adder[23][15] = (layer_data_a[23][15] & layer_data_b[23][15]) | (layer_data_a[23][15] & carry_bit_layer_adder[23][14]) | (layer_data_b[23][15] & carry_bit_layer_adder[23][14]); // calculation of carry bit of adder
assign result_layer_adder[23][16] = layer_data_a[23][16] ^ layer_data_b[23][16] ^ carry_bit_layer_adder[23][15]; // calculation of add result
assign carry_bit_layer_adder[23][16] = (layer_data_a[23][16] & layer_data_b[23][16]) | (layer_data_a[23][16] & carry_bit_layer_adder[23][15]) | (layer_data_b[23][16] & carry_bit_layer_adder[23][15]); // calculation of carry bit of adder
assign result_layer_adder[23][17] = layer_data_a[23][17] ^ layer_data_b[23][17] ^ carry_bit_layer_adder[23][16]; // calculation of add result
assign carry_bit_layer_adder[23][17] = (layer_data_a[23][17] & layer_data_b[23][17]) | (layer_data_a[23][17] & carry_bit_layer_adder[23][16]) | (layer_data_b[23][17] & carry_bit_layer_adder[23][16]); // calculation of carry bit of adder
assign result_layer_adder[23][18] = layer_data_a[23][18] ^ layer_data_b[23][18] ^ carry_bit_layer_adder[23][17]; // calculation of add result
assign carry_bit_layer_adder[23][18] = (layer_data_a[23][18] & layer_data_b[23][18]) | (layer_data_a[23][18] & carry_bit_layer_adder[23][17]) | (layer_data_b[23][18] & carry_bit_layer_adder[23][17]); // calculation of carry bit of adder
assign result_layer_adder[23][19] = layer_data_a[23][19] ^ layer_data_b[23][19] ^ carry_bit_layer_adder[23][18]; // calculation of add result
assign carry_bit_layer_adder[23][19] = (layer_data_a[23][19] & layer_data_b[23][19]) | (layer_data_a[23][19] & carry_bit_layer_adder[23][18]) | (layer_data_b[23][19] & carry_bit_layer_adder[23][18]); // calculation of carry bit of adder
assign result_layer_adder[23][20] = layer_data_a[23][20] ^ layer_data_b[23][20] ^ carry_bit_layer_adder[23][19]; // calculation of add result
assign carry_bit_layer_adder[23][20] = (layer_data_a[23][20] & layer_data_b[23][20]) | (layer_data_a[23][20] & carry_bit_layer_adder[23][19]) | (layer_data_b[23][20] & carry_bit_layer_adder[23][19]); // calculation of carry bit of adder
assign result_layer_adder[23][21] = layer_data_a[23][21] ^ layer_data_b[23][21] ^ carry_bit_layer_adder[23][20]; // calculation of add result
assign carry_bit_layer_adder[23][21] = (layer_data_a[23][21] & layer_data_b[23][21]) | (layer_data_a[23][21] & carry_bit_layer_adder[23][20]) | (layer_data_b[23][21] & carry_bit_layer_adder[23][20]); // calculation of carry bit of adder
assign result_layer_adder[23][22] = layer_data_a[23][22] ^ layer_data_b[23][22] ^ carry_bit_layer_adder[23][21]; // calculation of add result
assign carry_bit_layer_adder[23][22] = (layer_data_a[23][22] & layer_data_b[23][22]) | (layer_data_a[23][22] & carry_bit_layer_adder[23][21]) | (layer_data_b[23][22] & carry_bit_layer_adder[23][21]); // calculation of carry bit of adder
assign result_layer_adder[23][23] = layer_data_a[23][23] ^ layer_data_b[23][23] ^ carry_bit_layer_adder[23][22]; // calculation of add result
assign carry_bit_layer_adder[23][23] = (layer_data_a[23][23] & layer_data_b[23][23]) | (layer_data_a[23][23] & carry_bit_layer_adder[23][22]) | (layer_data_b[23][23] & carry_bit_layer_adder[23][22]); // calculation of carry bit of adder
assign result_layer_adder[23][24] = layer_data_a[23][24] ^ layer_data_b[23][24] ^ carry_bit_layer_adder[23][23]; // calculation of add result
assign carry_bit_layer_adder[23][24] = (layer_data_a[23][24] & layer_data_b[23][24]) | (layer_data_a[23][24] & carry_bit_layer_adder[23][23]) | (layer_data_b[23][24] & carry_bit_layer_adder[23][23]); // calculation of carry bit of adder
assign result_layer_adder[23][25] = layer_data_a[23][25] ^ layer_data_b[23][25] ^ carry_bit_layer_adder[23][24]; // calculation of add result
assign carry_bit_layer_adder[23][25] = (layer_data_a[23][25] & layer_data_b[23][25]) | (layer_data_a[23][25] & carry_bit_layer_adder[23][24]) | (layer_data_b[23][25] & carry_bit_layer_adder[23][24]); // calculation of carry bit of adder
assign result_layer_adder[23][26] = layer_data_a[23][26] ^ layer_data_b[23][26] ^ carry_bit_layer_adder[23][25]; // calculation of add result
assign carry_bit_layer_adder[23][26] = (layer_data_a[23][26] & layer_data_b[23][26]) | (layer_data_a[23][26] & carry_bit_layer_adder[23][25]) | (layer_data_b[23][26] & carry_bit_layer_adder[23][25]); // calculation of carry bit of adder
assign result_layer_adder[23][27] = layer_data_a[23][27] ^ layer_data_b[23][27] ^ carry_bit_layer_adder[23][26]; // calculation of add result
assign carry_bit_layer_adder[23][27] = (layer_data_a[23][27] & layer_data_b[23][27]) | (layer_data_a[23][27] & carry_bit_layer_adder[23][26]) | (layer_data_b[23][27] & carry_bit_layer_adder[23][26]); // calculation of carry bit of adder
assign result_layer_adder[23][28] = layer_data_a[23][28] ^ layer_data_b[23][28] ^ carry_bit_layer_adder[23][27]; // calculation of add result
assign carry_bit_layer_adder[23][28] = (layer_data_a[23][28] & layer_data_b[23][28]) | (layer_data_a[23][28] & carry_bit_layer_adder[23][27]) | (layer_data_b[23][28] & carry_bit_layer_adder[23][27]); // calculation of carry bit of adder
assign result_layer_adder[23][29] = layer_data_a[23][29] ^ layer_data_b[23][29] ^ carry_bit_layer_adder[23][28]; // calculation of add result
assign carry_bit_layer_adder[23][29] = (layer_data_a[23][29] & layer_data_b[23][29]) | (layer_data_a[23][29] & carry_bit_layer_adder[23][28]) | (layer_data_b[23][29] & carry_bit_layer_adder[23][28]); // calculation of carry bit of adder
assign result_layer_adder[23][30] = layer_data_a[23][30] ^ layer_data_b[23][30] ^ carry_bit_layer_adder[23][29]; // calculation of add result
assign carry_bit_layer_adder[23][30] = (layer_data_a[23][30] & layer_data_b[23][30]) | (layer_data_a[23][30] & carry_bit_layer_adder[23][29]) | (layer_data_b[23][30] & carry_bit_layer_adder[23][29]); // calculation of carry bit of adder
assign result_layer_adder[23][31] = layer_data_a[23][31] ^ layer_data_b[23][31] ^ carry_bit_layer_adder[23][30]; // calculation of add result
assign carry_bit_layer_adder[23][31] = (layer_data_a[23][31] & layer_data_b[23][31]) | (layer_data_a[23][31] & carry_bit_layer_adder[23][30]) | (layer_data_b[23][31] & carry_bit_layer_adder[23][30]); // calculation of carry bit of adder
assign result_layer_adder[23][32] = layer_data_a[23][32] ^ layer_data_b[23][32] ^ carry_bit_layer_adder[23][31]; // calculation of add result

// Layer 25
assign layer_data_a[24][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[23][32] == 1'b1) ? {layer_data_a[23][31:0], operand_a[8]} : {result_layer_adder[23][31:0], operand_a[8]}) : {1'b0, result_layer_adder[23][32:1]}; // data select for layer 25
assign layer_data_b[24][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[24] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 25

// Layer 25 adder
assign result_layer_adder[24][0] = layer_data_a[24][0] ^ layer_data_b[24][0]; // calculation of add result
assign carry_bit_layer_adder[24][0] = layer_data_a[24][0] & layer_data_b[24][0]; // calculation of carry bit of adder
assign result_layer_adder[24][1] = layer_data_a[24][1] ^ layer_data_b[24][1] ^ carry_bit_layer_adder[24][0]; // calculation of add result
assign carry_bit_layer_adder[24][1] = (layer_data_a[24][1] & layer_data_b[24][1]) | (layer_data_a[24][1] & carry_bit_layer_adder[24][0]) | (layer_data_b[24][1] & carry_bit_layer_adder[24][0]); // calculation of carry bit of adder
assign result_layer_adder[24][2] = layer_data_a[24][2] ^ layer_data_b[24][2] ^ carry_bit_layer_adder[24][1]; // calculation of add result
assign carry_bit_layer_adder[24][2] = (layer_data_a[24][2] & layer_data_b[24][2]) | (layer_data_a[24][2] & carry_bit_layer_adder[24][1]) | (layer_data_b[24][2] & carry_bit_layer_adder[24][1]); // calculation of carry bit of adder
assign result_layer_adder[24][3] = layer_data_a[24][3] ^ layer_data_b[24][3] ^ carry_bit_layer_adder[24][2]; // calculation of add result
assign carry_bit_layer_adder[24][3] = (layer_data_a[24][3] & layer_data_b[24][3]) | (layer_data_a[24][3] & carry_bit_layer_adder[24][2]) | (layer_data_b[24][3] & carry_bit_layer_adder[24][2]); // calculation of carry bit of adder
assign result_layer_adder[24][4] = layer_data_a[24][4] ^ layer_data_b[24][4] ^ carry_bit_layer_adder[24][3]; // calculation of add result
assign carry_bit_layer_adder[24][4] = (layer_data_a[24][4] & layer_data_b[24][4]) | (layer_data_a[24][4] & carry_bit_layer_adder[24][3]) | (layer_data_b[24][4] & carry_bit_layer_adder[24][3]); // calculation of carry bit of adder
assign result_layer_adder[24][5] = layer_data_a[24][5] ^ layer_data_b[24][5] ^ carry_bit_layer_adder[24][4]; // calculation of add result
assign carry_bit_layer_adder[24][5] = (layer_data_a[24][5] & layer_data_b[24][5]) | (layer_data_a[24][5] & carry_bit_layer_adder[24][4]) | (layer_data_b[24][5] & carry_bit_layer_adder[24][4]); // calculation of carry bit of adder
assign result_layer_adder[24][6] = layer_data_a[24][6] ^ layer_data_b[24][6] ^ carry_bit_layer_adder[24][5]; // calculation of add result
assign carry_bit_layer_adder[24][6] = (layer_data_a[24][6] & layer_data_b[24][6]) | (layer_data_a[24][6] & carry_bit_layer_adder[24][5]) | (layer_data_b[24][6] & carry_bit_layer_adder[24][5]); // calculation of carry bit of adder
assign result_layer_adder[24][7] = layer_data_a[24][7] ^ layer_data_b[24][7] ^ carry_bit_layer_adder[24][6]; // calculation of add result
assign carry_bit_layer_adder[24][7] = (layer_data_a[24][7] & layer_data_b[24][7]) | (layer_data_a[24][7] & carry_bit_layer_adder[24][6]) | (layer_data_b[24][7] & carry_bit_layer_adder[24][6]); // calculation of carry bit of adder
assign result_layer_adder[24][8] = layer_data_a[24][8] ^ layer_data_b[24][8] ^ carry_bit_layer_adder[24][7]; // calculation of add result
assign carry_bit_layer_adder[24][8] = (layer_data_a[24][8] & layer_data_b[24][8]) | (layer_data_a[24][8] & carry_bit_layer_adder[24][7]) | (layer_data_b[24][8] & carry_bit_layer_adder[24][7]); // calculation of carry bit of adder
assign result_layer_adder[24][9] = layer_data_a[24][9] ^ layer_data_b[24][9] ^ carry_bit_layer_adder[24][8]; // calculation of add result
assign carry_bit_layer_adder[24][9] = (layer_data_a[24][9] & layer_data_b[24][9]) | (layer_data_a[24][9] & carry_bit_layer_adder[24][8]) | (layer_data_b[24][9] & carry_bit_layer_adder[24][8]); // calculation of carry bit of adder
assign result_layer_adder[24][10] = layer_data_a[24][10] ^ layer_data_b[24][10] ^ carry_bit_layer_adder[24][9]; // calculation of add result
assign carry_bit_layer_adder[24][10] = (layer_data_a[24][10] & layer_data_b[24][10]) | (layer_data_a[24][10] & carry_bit_layer_adder[24][9]) | (layer_data_b[24][10] & carry_bit_layer_adder[24][9]); // calculation of carry bit of adder
assign result_layer_adder[24][11] = layer_data_a[24][11] ^ layer_data_b[24][11] ^ carry_bit_layer_adder[24][10]; // calculation of add result
assign carry_bit_layer_adder[24][11] = (layer_data_a[24][11] & layer_data_b[24][11]) | (layer_data_a[24][11] & carry_bit_layer_adder[24][10]) | (layer_data_b[24][11] & carry_bit_layer_adder[24][10]); // calculation of carry bit of adder
assign result_layer_adder[24][12] = layer_data_a[24][12] ^ layer_data_b[24][12] ^ carry_bit_layer_adder[24][11]; // calculation of add result
assign carry_bit_layer_adder[24][12] = (layer_data_a[24][12] & layer_data_b[24][12]) | (layer_data_a[24][12] & carry_bit_layer_adder[24][11]) | (layer_data_b[24][12] & carry_bit_layer_adder[24][11]); // calculation of carry bit of adder
assign result_layer_adder[24][13] = layer_data_a[24][13] ^ layer_data_b[24][13] ^ carry_bit_layer_adder[24][12]; // calculation of add result
assign carry_bit_layer_adder[24][13] = (layer_data_a[24][13] & layer_data_b[24][13]) | (layer_data_a[24][13] & carry_bit_layer_adder[24][12]) | (layer_data_b[24][13] & carry_bit_layer_adder[24][12]); // calculation of carry bit of adder
assign result_layer_adder[24][14] = layer_data_a[24][14] ^ layer_data_b[24][14] ^ carry_bit_layer_adder[24][13]; // calculation of add result
assign carry_bit_layer_adder[24][14] = (layer_data_a[24][14] & layer_data_b[24][14]) | (layer_data_a[24][14] & carry_bit_layer_adder[24][13]) | (layer_data_b[24][14] & carry_bit_layer_adder[24][13]); // calculation of carry bit of adder
assign result_layer_adder[24][15] = layer_data_a[24][15] ^ layer_data_b[24][15] ^ carry_bit_layer_adder[24][14]; // calculation of add result
assign carry_bit_layer_adder[24][15] = (layer_data_a[24][15] & layer_data_b[24][15]) | (layer_data_a[24][15] & carry_bit_layer_adder[24][14]) | (layer_data_b[24][15] & carry_bit_layer_adder[24][14]); // calculation of carry bit of adder
assign result_layer_adder[24][16] = layer_data_a[24][16] ^ layer_data_b[24][16] ^ carry_bit_layer_adder[24][15]; // calculation of add result
assign carry_bit_layer_adder[24][16] = (layer_data_a[24][16] & layer_data_b[24][16]) | (layer_data_a[24][16] & carry_bit_layer_adder[24][15]) | (layer_data_b[24][16] & carry_bit_layer_adder[24][15]); // calculation of carry bit of adder
assign result_layer_adder[24][17] = layer_data_a[24][17] ^ layer_data_b[24][17] ^ carry_bit_layer_adder[24][16]; // calculation of add result
assign carry_bit_layer_adder[24][17] = (layer_data_a[24][17] & layer_data_b[24][17]) | (layer_data_a[24][17] & carry_bit_layer_adder[24][16]) | (layer_data_b[24][17] & carry_bit_layer_adder[24][16]); // calculation of carry bit of adder
assign result_layer_adder[24][18] = layer_data_a[24][18] ^ layer_data_b[24][18] ^ carry_bit_layer_adder[24][17]; // calculation of add result
assign carry_bit_layer_adder[24][18] = (layer_data_a[24][18] & layer_data_b[24][18]) | (layer_data_a[24][18] & carry_bit_layer_adder[24][17]) | (layer_data_b[24][18] & carry_bit_layer_adder[24][17]); // calculation of carry bit of adder
assign result_layer_adder[24][19] = layer_data_a[24][19] ^ layer_data_b[24][19] ^ carry_bit_layer_adder[24][18]; // calculation of add result
assign carry_bit_layer_adder[24][19] = (layer_data_a[24][19] & layer_data_b[24][19]) | (layer_data_a[24][19] & carry_bit_layer_adder[24][18]) | (layer_data_b[24][19] & carry_bit_layer_adder[24][18]); // calculation of carry bit of adder
assign result_layer_adder[24][20] = layer_data_a[24][20] ^ layer_data_b[24][20] ^ carry_bit_layer_adder[24][19]; // calculation of add result
assign carry_bit_layer_adder[24][20] = (layer_data_a[24][20] & layer_data_b[24][20]) | (layer_data_a[24][20] & carry_bit_layer_adder[24][19]) | (layer_data_b[24][20] & carry_bit_layer_adder[24][19]); // calculation of carry bit of adder
assign result_layer_adder[24][21] = layer_data_a[24][21] ^ layer_data_b[24][21] ^ carry_bit_layer_adder[24][20]; // calculation of add result
assign carry_bit_layer_adder[24][21] = (layer_data_a[24][21] & layer_data_b[24][21]) | (layer_data_a[24][21] & carry_bit_layer_adder[24][20]) | (layer_data_b[24][21] & carry_bit_layer_adder[24][20]); // calculation of carry bit of adder
assign result_layer_adder[24][22] = layer_data_a[24][22] ^ layer_data_b[24][22] ^ carry_bit_layer_adder[24][21]; // calculation of add result
assign carry_bit_layer_adder[24][22] = (layer_data_a[24][22] & layer_data_b[24][22]) | (layer_data_a[24][22] & carry_bit_layer_adder[24][21]) | (layer_data_b[24][22] & carry_bit_layer_adder[24][21]); // calculation of carry bit of adder
assign result_layer_adder[24][23] = layer_data_a[24][23] ^ layer_data_b[24][23] ^ carry_bit_layer_adder[24][22]; // calculation of add result
assign carry_bit_layer_adder[24][23] = (layer_data_a[24][23] & layer_data_b[24][23]) | (layer_data_a[24][23] & carry_bit_layer_adder[24][22]) | (layer_data_b[24][23] & carry_bit_layer_adder[24][22]); // calculation of carry bit of adder
assign result_layer_adder[24][24] = layer_data_a[24][24] ^ layer_data_b[24][24] ^ carry_bit_layer_adder[24][23]; // calculation of add result
assign carry_bit_layer_adder[24][24] = (layer_data_a[24][24] & layer_data_b[24][24]) | (layer_data_a[24][24] & carry_bit_layer_adder[24][23]) | (layer_data_b[24][24] & carry_bit_layer_adder[24][23]); // calculation of carry bit of adder
assign result_layer_adder[24][25] = layer_data_a[24][25] ^ layer_data_b[24][25] ^ carry_bit_layer_adder[24][24]; // calculation of add result
assign carry_bit_layer_adder[24][25] = (layer_data_a[24][25] & layer_data_b[24][25]) | (layer_data_a[24][25] & carry_bit_layer_adder[24][24]) | (layer_data_b[24][25] & carry_bit_layer_adder[24][24]); // calculation of carry bit of adder
assign result_layer_adder[24][26] = layer_data_a[24][26] ^ layer_data_b[24][26] ^ carry_bit_layer_adder[24][25]; // calculation of add result
assign carry_bit_layer_adder[24][26] = (layer_data_a[24][26] & layer_data_b[24][26]) | (layer_data_a[24][26] & carry_bit_layer_adder[24][25]) | (layer_data_b[24][26] & carry_bit_layer_adder[24][25]); // calculation of carry bit of adder
assign result_layer_adder[24][27] = layer_data_a[24][27] ^ layer_data_b[24][27] ^ carry_bit_layer_adder[24][26]; // calculation of add result
assign carry_bit_layer_adder[24][27] = (layer_data_a[24][27] & layer_data_b[24][27]) | (layer_data_a[24][27] & carry_bit_layer_adder[24][26]) | (layer_data_b[24][27] & carry_bit_layer_adder[24][26]); // calculation of carry bit of adder
assign result_layer_adder[24][28] = layer_data_a[24][28] ^ layer_data_b[24][28] ^ carry_bit_layer_adder[24][27]; // calculation of add result
assign carry_bit_layer_adder[24][28] = (layer_data_a[24][28] & layer_data_b[24][28]) | (layer_data_a[24][28] & carry_bit_layer_adder[24][27]) | (layer_data_b[24][28] & carry_bit_layer_adder[24][27]); // calculation of carry bit of adder
assign result_layer_adder[24][29] = layer_data_a[24][29] ^ layer_data_b[24][29] ^ carry_bit_layer_adder[24][28]; // calculation of add result
assign carry_bit_layer_adder[24][29] = (layer_data_a[24][29] & layer_data_b[24][29]) | (layer_data_a[24][29] & carry_bit_layer_adder[24][28]) | (layer_data_b[24][29] & carry_bit_layer_adder[24][28]); // calculation of carry bit of adder
assign result_layer_adder[24][30] = layer_data_a[24][30] ^ layer_data_b[24][30] ^ carry_bit_layer_adder[24][29]; // calculation of add result
assign carry_bit_layer_adder[24][30] = (layer_data_a[24][30] & layer_data_b[24][30]) | (layer_data_a[24][30] & carry_bit_layer_adder[24][29]) | (layer_data_b[24][30] & carry_bit_layer_adder[24][29]); // calculation of carry bit of adder
assign result_layer_adder[24][31] = layer_data_a[24][31] ^ layer_data_b[24][31] ^ carry_bit_layer_adder[24][30]; // calculation of add result
assign carry_bit_layer_adder[24][31] = (layer_data_a[24][31] & layer_data_b[24][31]) | (layer_data_a[24][31] & carry_bit_layer_adder[24][30]) | (layer_data_b[24][31] & carry_bit_layer_adder[24][30]); // calculation of carry bit of adder
assign result_layer_adder[24][32] = layer_data_a[24][32] ^ layer_data_b[24][32] ^ carry_bit_layer_adder[24][31]; // calculation of add result

// Layer 26
assign layer_data_a[25][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[24][32] == 1'b1) ? {layer_data_a[24][31:0], operand_a[7]} : {result_layer_adder[24][31:0], operand_a[7]}) : {1'b0, result_layer_adder[24][32:1]}; // data select for layer 26
assign layer_data_b[25][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[25] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 26

// Layer 26 adder
assign result_layer_adder[25][0] = layer_data_a[25][0] ^ layer_data_b[25][0]; // calculation of add result
assign carry_bit_layer_adder[25][0] = layer_data_a[25][0] & layer_data_b[25][0]; // calculation of carry bit of adder
assign result_layer_adder[25][1] = layer_data_a[25][1] ^ layer_data_b[25][1] ^ carry_bit_layer_adder[25][0]; // calculation of add result
assign carry_bit_layer_adder[25][1] = (layer_data_a[25][1] & layer_data_b[25][1]) | (layer_data_a[25][1] & carry_bit_layer_adder[25][0]) | (layer_data_b[25][1] & carry_bit_layer_adder[25][0]); // calculation of carry bit of adder
assign result_layer_adder[25][2] = layer_data_a[25][2] ^ layer_data_b[25][2] ^ carry_bit_layer_adder[25][1]; // calculation of add result
assign carry_bit_layer_adder[25][2] = (layer_data_a[25][2] & layer_data_b[25][2]) | (layer_data_a[25][2] & carry_bit_layer_adder[25][1]) | (layer_data_b[25][2] & carry_bit_layer_adder[25][1]); // calculation of carry bit of adder
assign result_layer_adder[25][3] = layer_data_a[25][3] ^ layer_data_b[25][3] ^ carry_bit_layer_adder[25][2]; // calculation of add result
assign carry_bit_layer_adder[25][3] = (layer_data_a[25][3] & layer_data_b[25][3]) | (layer_data_a[25][3] & carry_bit_layer_adder[25][2]) | (layer_data_b[25][3] & carry_bit_layer_adder[25][2]); // calculation of carry bit of adder
assign result_layer_adder[25][4] = layer_data_a[25][4] ^ layer_data_b[25][4] ^ carry_bit_layer_adder[25][3]; // calculation of add result
assign carry_bit_layer_adder[25][4] = (layer_data_a[25][4] & layer_data_b[25][4]) | (layer_data_a[25][4] & carry_bit_layer_adder[25][3]) | (layer_data_b[25][4] & carry_bit_layer_adder[25][3]); // calculation of carry bit of adder
assign result_layer_adder[25][5] = layer_data_a[25][5] ^ layer_data_b[25][5] ^ carry_bit_layer_adder[25][4]; // calculation of add result
assign carry_bit_layer_adder[25][5] = (layer_data_a[25][5] & layer_data_b[25][5]) | (layer_data_a[25][5] & carry_bit_layer_adder[25][4]) | (layer_data_b[25][5] & carry_bit_layer_adder[25][4]); // calculation of carry bit of adder
assign result_layer_adder[25][6] = layer_data_a[25][6] ^ layer_data_b[25][6] ^ carry_bit_layer_adder[25][5]; // calculation of add result
assign carry_bit_layer_adder[25][6] = (layer_data_a[25][6] & layer_data_b[25][6]) | (layer_data_a[25][6] & carry_bit_layer_adder[25][5]) | (layer_data_b[25][6] & carry_bit_layer_adder[25][5]); // calculation of carry bit of adder
assign result_layer_adder[25][7] = layer_data_a[25][7] ^ layer_data_b[25][7] ^ carry_bit_layer_adder[25][6]; // calculation of add result
assign carry_bit_layer_adder[25][7] = (layer_data_a[25][7] & layer_data_b[25][7]) | (layer_data_a[25][7] & carry_bit_layer_adder[25][6]) | (layer_data_b[25][7] & carry_bit_layer_adder[25][6]); // calculation of carry bit of adder
assign result_layer_adder[25][8] = layer_data_a[25][8] ^ layer_data_b[25][8] ^ carry_bit_layer_adder[25][7]; // calculation of add result
assign carry_bit_layer_adder[25][8] = (layer_data_a[25][8] & layer_data_b[25][8]) | (layer_data_a[25][8] & carry_bit_layer_adder[25][7]) | (layer_data_b[25][8] & carry_bit_layer_adder[25][7]); // calculation of carry bit of adder
assign result_layer_adder[25][9] = layer_data_a[25][9] ^ layer_data_b[25][9] ^ carry_bit_layer_adder[25][8]; // calculation of add result
assign carry_bit_layer_adder[25][9] = (layer_data_a[25][9] & layer_data_b[25][9]) | (layer_data_a[25][9] & carry_bit_layer_adder[25][8]) | (layer_data_b[25][9] & carry_bit_layer_adder[25][8]); // calculation of carry bit of adder
assign result_layer_adder[25][10] = layer_data_a[25][10] ^ layer_data_b[25][10] ^ carry_bit_layer_adder[25][9]; // calculation of add result
assign carry_bit_layer_adder[25][10] = (layer_data_a[25][10] & layer_data_b[25][10]) | (layer_data_a[25][10] & carry_bit_layer_adder[25][9]) | (layer_data_b[25][10] & carry_bit_layer_adder[25][9]); // calculation of carry bit of adder
assign result_layer_adder[25][11] = layer_data_a[25][11] ^ layer_data_b[25][11] ^ carry_bit_layer_adder[25][10]; // calculation of add result
assign carry_bit_layer_adder[25][11] = (layer_data_a[25][11] & layer_data_b[25][11]) | (layer_data_a[25][11] & carry_bit_layer_adder[25][10]) | (layer_data_b[25][11] & carry_bit_layer_adder[25][10]); // calculation of carry bit of adder
assign result_layer_adder[25][12] = layer_data_a[25][12] ^ layer_data_b[25][12] ^ carry_bit_layer_adder[25][11]; // calculation of add result
assign carry_bit_layer_adder[25][12] = (layer_data_a[25][12] & layer_data_b[25][12]) | (layer_data_a[25][12] & carry_bit_layer_adder[25][11]) | (layer_data_b[25][12] & carry_bit_layer_adder[25][11]); // calculation of carry bit of adder
assign result_layer_adder[25][13] = layer_data_a[25][13] ^ layer_data_b[25][13] ^ carry_bit_layer_adder[25][12]; // calculation of add result
assign carry_bit_layer_adder[25][13] = (layer_data_a[25][13] & layer_data_b[25][13]) | (layer_data_a[25][13] & carry_bit_layer_adder[25][12]) | (layer_data_b[25][13] & carry_bit_layer_adder[25][12]); // calculation of carry bit of adder
assign result_layer_adder[25][14] = layer_data_a[25][14] ^ layer_data_b[25][14] ^ carry_bit_layer_adder[25][13]; // calculation of add result
assign carry_bit_layer_adder[25][14] = (layer_data_a[25][14] & layer_data_b[25][14]) | (layer_data_a[25][14] & carry_bit_layer_adder[25][13]) | (layer_data_b[25][14] & carry_bit_layer_adder[25][13]); // calculation of carry bit of adder
assign result_layer_adder[25][15] = layer_data_a[25][15] ^ layer_data_b[25][15] ^ carry_bit_layer_adder[25][14]; // calculation of add result
assign carry_bit_layer_adder[25][15] = (layer_data_a[25][15] & layer_data_b[25][15]) | (layer_data_a[25][15] & carry_bit_layer_adder[25][14]) | (layer_data_b[25][15] & carry_bit_layer_adder[25][14]); // calculation of carry bit of adder
assign result_layer_adder[25][16] = layer_data_a[25][16] ^ layer_data_b[25][16] ^ carry_bit_layer_adder[25][15]; // calculation of add result
assign carry_bit_layer_adder[25][16] = (layer_data_a[25][16] & layer_data_b[25][16]) | (layer_data_a[25][16] & carry_bit_layer_adder[25][15]) | (layer_data_b[25][16] & carry_bit_layer_adder[25][15]); // calculation of carry bit of adder
assign result_layer_adder[25][17] = layer_data_a[25][17] ^ layer_data_b[25][17] ^ carry_bit_layer_adder[25][16]; // calculation of add result
assign carry_bit_layer_adder[25][17] = (layer_data_a[25][17] & layer_data_b[25][17]) | (layer_data_a[25][17] & carry_bit_layer_adder[25][16]) | (layer_data_b[25][17] & carry_bit_layer_adder[25][16]); // calculation of carry bit of adder
assign result_layer_adder[25][18] = layer_data_a[25][18] ^ layer_data_b[25][18] ^ carry_bit_layer_adder[25][17]; // calculation of add result
assign carry_bit_layer_adder[25][18] = (layer_data_a[25][18] & layer_data_b[25][18]) | (layer_data_a[25][18] & carry_bit_layer_adder[25][17]) | (layer_data_b[25][18] & carry_bit_layer_adder[25][17]); // calculation of carry bit of adder
assign result_layer_adder[25][19] = layer_data_a[25][19] ^ layer_data_b[25][19] ^ carry_bit_layer_adder[25][18]; // calculation of add result
assign carry_bit_layer_adder[25][19] = (layer_data_a[25][19] & layer_data_b[25][19]) | (layer_data_a[25][19] & carry_bit_layer_adder[25][18]) | (layer_data_b[25][19] & carry_bit_layer_adder[25][18]); // calculation of carry bit of adder
assign result_layer_adder[25][20] = layer_data_a[25][20] ^ layer_data_b[25][20] ^ carry_bit_layer_adder[25][19]; // calculation of add result
assign carry_bit_layer_adder[25][20] = (layer_data_a[25][20] & layer_data_b[25][20]) | (layer_data_a[25][20] & carry_bit_layer_adder[25][19]) | (layer_data_b[25][20] & carry_bit_layer_adder[25][19]); // calculation of carry bit of adder
assign result_layer_adder[25][21] = layer_data_a[25][21] ^ layer_data_b[25][21] ^ carry_bit_layer_adder[25][20]; // calculation of add result
assign carry_bit_layer_adder[25][21] = (layer_data_a[25][21] & layer_data_b[25][21]) | (layer_data_a[25][21] & carry_bit_layer_adder[25][20]) | (layer_data_b[25][21] & carry_bit_layer_adder[25][20]); // calculation of carry bit of adder
assign result_layer_adder[25][22] = layer_data_a[25][22] ^ layer_data_b[25][22] ^ carry_bit_layer_adder[25][21]; // calculation of add result
assign carry_bit_layer_adder[25][22] = (layer_data_a[25][22] & layer_data_b[25][22]) | (layer_data_a[25][22] & carry_bit_layer_adder[25][21]) | (layer_data_b[25][22] & carry_bit_layer_adder[25][21]); // calculation of carry bit of adder
assign result_layer_adder[25][23] = layer_data_a[25][23] ^ layer_data_b[25][23] ^ carry_bit_layer_adder[25][22]; // calculation of add result
assign carry_bit_layer_adder[25][23] = (layer_data_a[25][23] & layer_data_b[25][23]) | (layer_data_a[25][23] & carry_bit_layer_adder[25][22]) | (layer_data_b[25][23] & carry_bit_layer_adder[25][22]); // calculation of carry bit of adder
assign result_layer_adder[25][24] = layer_data_a[25][24] ^ layer_data_b[25][24] ^ carry_bit_layer_adder[25][23]; // calculation of add result
assign carry_bit_layer_adder[25][24] = (layer_data_a[25][24] & layer_data_b[25][24]) | (layer_data_a[25][24] & carry_bit_layer_adder[25][23]) | (layer_data_b[25][24] & carry_bit_layer_adder[25][23]); // calculation of carry bit of adder
assign result_layer_adder[25][25] = layer_data_a[25][25] ^ layer_data_b[25][25] ^ carry_bit_layer_adder[25][24]; // calculation of add result
assign carry_bit_layer_adder[25][25] = (layer_data_a[25][25] & layer_data_b[25][25]) | (layer_data_a[25][25] & carry_bit_layer_adder[25][24]) | (layer_data_b[25][25] & carry_bit_layer_adder[25][24]); // calculation of carry bit of adder
assign result_layer_adder[25][26] = layer_data_a[25][26] ^ layer_data_b[25][26] ^ carry_bit_layer_adder[25][25]; // calculation of add result
assign carry_bit_layer_adder[25][26] = (layer_data_a[25][26] & layer_data_b[25][26]) | (layer_data_a[25][26] & carry_bit_layer_adder[25][25]) | (layer_data_b[25][26] & carry_bit_layer_adder[25][25]); // calculation of carry bit of adder
assign result_layer_adder[25][27] = layer_data_a[25][27] ^ layer_data_b[25][27] ^ carry_bit_layer_adder[25][26]; // calculation of add result
assign carry_bit_layer_adder[25][27] = (layer_data_a[25][27] & layer_data_b[25][27]) | (layer_data_a[25][27] & carry_bit_layer_adder[25][26]) | (layer_data_b[25][27] & carry_bit_layer_adder[25][26]); // calculation of carry bit of adder
assign result_layer_adder[25][28] = layer_data_a[25][28] ^ layer_data_b[25][28] ^ carry_bit_layer_adder[25][27]; // calculation of add result
assign carry_bit_layer_adder[25][28] = (layer_data_a[25][28] & layer_data_b[25][28]) | (layer_data_a[25][28] & carry_bit_layer_adder[25][27]) | (layer_data_b[25][28] & carry_bit_layer_adder[25][27]); // calculation of carry bit of adder
assign result_layer_adder[25][29] = layer_data_a[25][29] ^ layer_data_b[25][29] ^ carry_bit_layer_adder[25][28]; // calculation of add result
assign carry_bit_layer_adder[25][29] = (layer_data_a[25][29] & layer_data_b[25][29]) | (layer_data_a[25][29] & carry_bit_layer_adder[25][28]) | (layer_data_b[25][29] & carry_bit_layer_adder[25][28]); // calculation of carry bit of adder
assign result_layer_adder[25][30] = layer_data_a[25][30] ^ layer_data_b[25][30] ^ carry_bit_layer_adder[25][29]; // calculation of add result
assign carry_bit_layer_adder[25][30] = (layer_data_a[25][30] & layer_data_b[25][30]) | (layer_data_a[25][30] & carry_bit_layer_adder[25][29]) | (layer_data_b[25][30] & carry_bit_layer_adder[25][29]); // calculation of carry bit of adder
assign result_layer_adder[25][31] = layer_data_a[25][31] ^ layer_data_b[25][31] ^ carry_bit_layer_adder[25][30]; // calculation of add result
assign carry_bit_layer_adder[25][31] = (layer_data_a[25][31] & layer_data_b[25][31]) | (layer_data_a[25][31] & carry_bit_layer_adder[25][30]) | (layer_data_b[25][31] & carry_bit_layer_adder[25][30]); // calculation of carry bit of adder
assign result_layer_adder[25][32] = layer_data_a[25][32] ^ layer_data_b[25][32] ^ carry_bit_layer_adder[25][31]; // calculation of add result

// Layer 27
assign layer_data_a[26][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[25][32] == 1'b1) ? {layer_data_a[25][31:0], operand_a[6]} : {result_layer_adder[25][31:0], operand_a[6]}) : {1'b0, result_layer_adder[25][32:1]}; // data select for layer 27
assign layer_data_b[26][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[26] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 27

// Layer 27 adder
assign result_layer_adder[26][0] = layer_data_a[26][0] ^ layer_data_b[26][0]; // calculation of add result
assign carry_bit_layer_adder[26][0] = layer_data_a[26][0] & layer_data_b[26][0]; // calculation of carry bit of adder
assign result_layer_adder[26][1] = layer_data_a[26][1] ^ layer_data_b[26][1] ^ carry_bit_layer_adder[26][0]; // calculation of add result
assign carry_bit_layer_adder[26][1] = (layer_data_a[26][1] & layer_data_b[26][1]) | (layer_data_a[26][1] & carry_bit_layer_adder[26][0]) | (layer_data_b[26][1] & carry_bit_layer_adder[26][0]); // calculation of carry bit of adder
assign result_layer_adder[26][2] = layer_data_a[26][2] ^ layer_data_b[26][2] ^ carry_bit_layer_adder[26][1]; // calculation of add result
assign carry_bit_layer_adder[26][2] = (layer_data_a[26][2] & layer_data_b[26][2]) | (layer_data_a[26][2] & carry_bit_layer_adder[26][1]) | (layer_data_b[26][2] & carry_bit_layer_adder[26][1]); // calculation of carry bit of adder
assign result_layer_adder[26][3] = layer_data_a[26][3] ^ layer_data_b[26][3] ^ carry_bit_layer_adder[26][2]; // calculation of add result
assign carry_bit_layer_adder[26][3] = (layer_data_a[26][3] & layer_data_b[26][3]) | (layer_data_a[26][3] & carry_bit_layer_adder[26][2]) | (layer_data_b[26][3] & carry_bit_layer_adder[26][2]); // calculation of carry bit of adder
assign result_layer_adder[26][4] = layer_data_a[26][4] ^ layer_data_b[26][4] ^ carry_bit_layer_adder[26][3]; // calculation of add result
assign carry_bit_layer_adder[26][4] = (layer_data_a[26][4] & layer_data_b[26][4]) | (layer_data_a[26][4] & carry_bit_layer_adder[26][3]) | (layer_data_b[26][4] & carry_bit_layer_adder[26][3]); // calculation of carry bit of adder
assign result_layer_adder[26][5] = layer_data_a[26][5] ^ layer_data_b[26][5] ^ carry_bit_layer_adder[26][4]; // calculation of add result
assign carry_bit_layer_adder[26][5] = (layer_data_a[26][5] & layer_data_b[26][5]) | (layer_data_a[26][5] & carry_bit_layer_adder[26][4]) | (layer_data_b[26][5] & carry_bit_layer_adder[26][4]); // calculation of carry bit of adder
assign result_layer_adder[26][6] = layer_data_a[26][6] ^ layer_data_b[26][6] ^ carry_bit_layer_adder[26][5]; // calculation of add result
assign carry_bit_layer_adder[26][6] = (layer_data_a[26][6] & layer_data_b[26][6]) | (layer_data_a[26][6] & carry_bit_layer_adder[26][5]) | (layer_data_b[26][6] & carry_bit_layer_adder[26][5]); // calculation of carry bit of adder
assign result_layer_adder[26][7] = layer_data_a[26][7] ^ layer_data_b[26][7] ^ carry_bit_layer_adder[26][6]; // calculation of add result
assign carry_bit_layer_adder[26][7] = (layer_data_a[26][7] & layer_data_b[26][7]) | (layer_data_a[26][7] & carry_bit_layer_adder[26][6]) | (layer_data_b[26][7] & carry_bit_layer_adder[26][6]); // calculation of carry bit of adder
assign result_layer_adder[26][8] = layer_data_a[26][8] ^ layer_data_b[26][8] ^ carry_bit_layer_adder[26][7]; // calculation of add result
assign carry_bit_layer_adder[26][8] = (layer_data_a[26][8] & layer_data_b[26][8]) | (layer_data_a[26][8] & carry_bit_layer_adder[26][7]) | (layer_data_b[26][8] & carry_bit_layer_adder[26][7]); // calculation of carry bit of adder
assign result_layer_adder[26][9] = layer_data_a[26][9] ^ layer_data_b[26][9] ^ carry_bit_layer_adder[26][8]; // calculation of add result
assign carry_bit_layer_adder[26][9] = (layer_data_a[26][9] & layer_data_b[26][9]) | (layer_data_a[26][9] & carry_bit_layer_adder[26][8]) | (layer_data_b[26][9] & carry_bit_layer_adder[26][8]); // calculation of carry bit of adder
assign result_layer_adder[26][10] = layer_data_a[26][10] ^ layer_data_b[26][10] ^ carry_bit_layer_adder[26][9]; // calculation of add result
assign carry_bit_layer_adder[26][10] = (layer_data_a[26][10] & layer_data_b[26][10]) | (layer_data_a[26][10] & carry_bit_layer_adder[26][9]) | (layer_data_b[26][10] & carry_bit_layer_adder[26][9]); // calculation of carry bit of adder
assign result_layer_adder[26][11] = layer_data_a[26][11] ^ layer_data_b[26][11] ^ carry_bit_layer_adder[26][10]; // calculation of add result
assign carry_bit_layer_adder[26][11] = (layer_data_a[26][11] & layer_data_b[26][11]) | (layer_data_a[26][11] & carry_bit_layer_adder[26][10]) | (layer_data_b[26][11] & carry_bit_layer_adder[26][10]); // calculation of carry bit of adder
assign result_layer_adder[26][12] = layer_data_a[26][12] ^ layer_data_b[26][12] ^ carry_bit_layer_adder[26][11]; // calculation of add result
assign carry_bit_layer_adder[26][12] = (layer_data_a[26][12] & layer_data_b[26][12]) | (layer_data_a[26][12] & carry_bit_layer_adder[26][11]) | (layer_data_b[26][12] & carry_bit_layer_adder[26][11]); // calculation of carry bit of adder
assign result_layer_adder[26][13] = layer_data_a[26][13] ^ layer_data_b[26][13] ^ carry_bit_layer_adder[26][12]; // calculation of add result
assign carry_bit_layer_adder[26][13] = (layer_data_a[26][13] & layer_data_b[26][13]) | (layer_data_a[26][13] & carry_bit_layer_adder[26][12]) | (layer_data_b[26][13] & carry_bit_layer_adder[26][12]); // calculation of carry bit of adder
assign result_layer_adder[26][14] = layer_data_a[26][14] ^ layer_data_b[26][14] ^ carry_bit_layer_adder[26][13]; // calculation of add result
assign carry_bit_layer_adder[26][14] = (layer_data_a[26][14] & layer_data_b[26][14]) | (layer_data_a[26][14] & carry_bit_layer_adder[26][13]) | (layer_data_b[26][14] & carry_bit_layer_adder[26][13]); // calculation of carry bit of adder
assign result_layer_adder[26][15] = layer_data_a[26][15] ^ layer_data_b[26][15] ^ carry_bit_layer_adder[26][14]; // calculation of add result
assign carry_bit_layer_adder[26][15] = (layer_data_a[26][15] & layer_data_b[26][15]) | (layer_data_a[26][15] & carry_bit_layer_adder[26][14]) | (layer_data_b[26][15] & carry_bit_layer_adder[26][14]); // calculation of carry bit of adder
assign result_layer_adder[26][16] = layer_data_a[26][16] ^ layer_data_b[26][16] ^ carry_bit_layer_adder[26][15]; // calculation of add result
assign carry_bit_layer_adder[26][16] = (layer_data_a[26][16] & layer_data_b[26][16]) | (layer_data_a[26][16] & carry_bit_layer_adder[26][15]) | (layer_data_b[26][16] & carry_bit_layer_adder[26][15]); // calculation of carry bit of adder
assign result_layer_adder[26][17] = layer_data_a[26][17] ^ layer_data_b[26][17] ^ carry_bit_layer_adder[26][16]; // calculation of add result
assign carry_bit_layer_adder[26][17] = (layer_data_a[26][17] & layer_data_b[26][17]) | (layer_data_a[26][17] & carry_bit_layer_adder[26][16]) | (layer_data_b[26][17] & carry_bit_layer_adder[26][16]); // calculation of carry bit of adder
assign result_layer_adder[26][18] = layer_data_a[26][18] ^ layer_data_b[26][18] ^ carry_bit_layer_adder[26][17]; // calculation of add result
assign carry_bit_layer_adder[26][18] = (layer_data_a[26][18] & layer_data_b[26][18]) | (layer_data_a[26][18] & carry_bit_layer_adder[26][17]) | (layer_data_b[26][18] & carry_bit_layer_adder[26][17]); // calculation of carry bit of adder
assign result_layer_adder[26][19] = layer_data_a[26][19] ^ layer_data_b[26][19] ^ carry_bit_layer_adder[26][18]; // calculation of add result
assign carry_bit_layer_adder[26][19] = (layer_data_a[26][19] & layer_data_b[26][19]) | (layer_data_a[26][19] & carry_bit_layer_adder[26][18]) | (layer_data_b[26][19] & carry_bit_layer_adder[26][18]); // calculation of carry bit of adder
assign result_layer_adder[26][20] = layer_data_a[26][20] ^ layer_data_b[26][20] ^ carry_bit_layer_adder[26][19]; // calculation of add result
assign carry_bit_layer_adder[26][20] = (layer_data_a[26][20] & layer_data_b[26][20]) | (layer_data_a[26][20] & carry_bit_layer_adder[26][19]) | (layer_data_b[26][20] & carry_bit_layer_adder[26][19]); // calculation of carry bit of adder
assign result_layer_adder[26][21] = layer_data_a[26][21] ^ layer_data_b[26][21] ^ carry_bit_layer_adder[26][20]; // calculation of add result
assign carry_bit_layer_adder[26][21] = (layer_data_a[26][21] & layer_data_b[26][21]) | (layer_data_a[26][21] & carry_bit_layer_adder[26][20]) | (layer_data_b[26][21] & carry_bit_layer_adder[26][20]); // calculation of carry bit of adder
assign result_layer_adder[26][22] = layer_data_a[26][22] ^ layer_data_b[26][22] ^ carry_bit_layer_adder[26][21]; // calculation of add result
assign carry_bit_layer_adder[26][22] = (layer_data_a[26][22] & layer_data_b[26][22]) | (layer_data_a[26][22] & carry_bit_layer_adder[26][21]) | (layer_data_b[26][22] & carry_bit_layer_adder[26][21]); // calculation of carry bit of adder
assign result_layer_adder[26][23] = layer_data_a[26][23] ^ layer_data_b[26][23] ^ carry_bit_layer_adder[26][22]; // calculation of add result
assign carry_bit_layer_adder[26][23] = (layer_data_a[26][23] & layer_data_b[26][23]) | (layer_data_a[26][23] & carry_bit_layer_adder[26][22]) | (layer_data_b[26][23] & carry_bit_layer_adder[26][22]); // calculation of carry bit of adder
assign result_layer_adder[26][24] = layer_data_a[26][24] ^ layer_data_b[26][24] ^ carry_bit_layer_adder[26][23]; // calculation of add result
assign carry_bit_layer_adder[26][24] = (layer_data_a[26][24] & layer_data_b[26][24]) | (layer_data_a[26][24] & carry_bit_layer_adder[26][23]) | (layer_data_b[26][24] & carry_bit_layer_adder[26][23]); // calculation of carry bit of adder
assign result_layer_adder[26][25] = layer_data_a[26][25] ^ layer_data_b[26][25] ^ carry_bit_layer_adder[26][24]; // calculation of add result
assign carry_bit_layer_adder[26][25] = (layer_data_a[26][25] & layer_data_b[26][25]) | (layer_data_a[26][25] & carry_bit_layer_adder[26][24]) | (layer_data_b[26][25] & carry_bit_layer_adder[26][24]); // calculation of carry bit of adder
assign result_layer_adder[26][26] = layer_data_a[26][26] ^ layer_data_b[26][26] ^ carry_bit_layer_adder[26][25]; // calculation of add result
assign carry_bit_layer_adder[26][26] = (layer_data_a[26][26] & layer_data_b[26][26]) | (layer_data_a[26][26] & carry_bit_layer_adder[26][25]) | (layer_data_b[26][26] & carry_bit_layer_adder[26][25]); // calculation of carry bit of adder
assign result_layer_adder[26][27] = layer_data_a[26][27] ^ layer_data_b[26][27] ^ carry_bit_layer_adder[26][26]; // calculation of add result
assign carry_bit_layer_adder[26][27] = (layer_data_a[26][27] & layer_data_b[26][27]) | (layer_data_a[26][27] & carry_bit_layer_adder[26][26]) | (layer_data_b[26][27] & carry_bit_layer_adder[26][26]); // calculation of carry bit of adder
assign result_layer_adder[26][28] = layer_data_a[26][28] ^ layer_data_b[26][28] ^ carry_bit_layer_adder[26][27]; // calculation of add result
assign carry_bit_layer_adder[26][28] = (layer_data_a[26][28] & layer_data_b[26][28]) | (layer_data_a[26][28] & carry_bit_layer_adder[26][27]) | (layer_data_b[26][28] & carry_bit_layer_adder[26][27]); // calculation of carry bit of adder
assign result_layer_adder[26][29] = layer_data_a[26][29] ^ layer_data_b[26][29] ^ carry_bit_layer_adder[26][28]; // calculation of add result
assign carry_bit_layer_adder[26][29] = (layer_data_a[26][29] & layer_data_b[26][29]) | (layer_data_a[26][29] & carry_bit_layer_adder[26][28]) | (layer_data_b[26][29] & carry_bit_layer_adder[26][28]); // calculation of carry bit of adder
assign result_layer_adder[26][30] = layer_data_a[26][30] ^ layer_data_b[26][30] ^ carry_bit_layer_adder[26][29]; // calculation of add result
assign carry_bit_layer_adder[26][30] = (layer_data_a[26][30] & layer_data_b[26][30]) | (layer_data_a[26][30] & carry_bit_layer_adder[26][29]) | (layer_data_b[26][30] & carry_bit_layer_adder[26][29]); // calculation of carry bit of adder
assign result_layer_adder[26][31] = layer_data_a[26][31] ^ layer_data_b[26][31] ^ carry_bit_layer_adder[26][30]; // calculation of add result
assign carry_bit_layer_adder[26][31] = (layer_data_a[26][31] & layer_data_b[26][31]) | (layer_data_a[26][31] & carry_bit_layer_adder[26][30]) | (layer_data_b[26][31] & carry_bit_layer_adder[26][30]); // calculation of carry bit of adder
assign result_layer_adder[26][32] = layer_data_a[26][32] ^ layer_data_b[26][32] ^ carry_bit_layer_adder[26][31]; // calculation of add result

// Layer 28
assign layer_data_a[27][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[26][32] == 1'b1) ? {layer_data_a[26][31:0], operand_a[5]} : {result_layer_adder[26][31:0], operand_a[5]}) : {1'b0, result_layer_adder[26][32:1]}; // data select for layer 28
assign layer_data_b[27][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[27] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 28

// Layer 28 adder
assign result_layer_adder[27][0] = layer_data_a[27][0] ^ layer_data_b[27][0]; // calculation of add result
assign carry_bit_layer_adder[27][0] = layer_data_a[27][0] & layer_data_b[27][0]; // calculation of carry bit of adder
assign result_layer_adder[27][1] = layer_data_a[27][1] ^ layer_data_b[27][1] ^ carry_bit_layer_adder[27][0]; // calculation of add result
assign carry_bit_layer_adder[27][1] = (layer_data_a[27][1] & layer_data_b[27][1]) | (layer_data_a[27][1] & carry_bit_layer_adder[27][0]) | (layer_data_b[27][1] & carry_bit_layer_adder[27][0]); // calculation of carry bit of adder
assign result_layer_adder[27][2] = layer_data_a[27][2] ^ layer_data_b[27][2] ^ carry_bit_layer_adder[27][1]; // calculation of add result
assign carry_bit_layer_adder[27][2] = (layer_data_a[27][2] & layer_data_b[27][2]) | (layer_data_a[27][2] & carry_bit_layer_adder[27][1]) | (layer_data_b[27][2] & carry_bit_layer_adder[27][1]); // calculation of carry bit of adder
assign result_layer_adder[27][3] = layer_data_a[27][3] ^ layer_data_b[27][3] ^ carry_bit_layer_adder[27][2]; // calculation of add result
assign carry_bit_layer_adder[27][3] = (layer_data_a[27][3] & layer_data_b[27][3]) | (layer_data_a[27][3] & carry_bit_layer_adder[27][2]) | (layer_data_b[27][3] & carry_bit_layer_adder[27][2]); // calculation of carry bit of adder
assign result_layer_adder[27][4] = layer_data_a[27][4] ^ layer_data_b[27][4] ^ carry_bit_layer_adder[27][3]; // calculation of add result
assign carry_bit_layer_adder[27][4] = (layer_data_a[27][4] & layer_data_b[27][4]) | (layer_data_a[27][4] & carry_bit_layer_adder[27][3]) | (layer_data_b[27][4] & carry_bit_layer_adder[27][3]); // calculation of carry bit of adder
assign result_layer_adder[27][5] = layer_data_a[27][5] ^ layer_data_b[27][5] ^ carry_bit_layer_adder[27][4]; // calculation of add result
assign carry_bit_layer_adder[27][5] = (layer_data_a[27][5] & layer_data_b[27][5]) | (layer_data_a[27][5] & carry_bit_layer_adder[27][4]) | (layer_data_b[27][5] & carry_bit_layer_adder[27][4]); // calculation of carry bit of adder
assign result_layer_adder[27][6] = layer_data_a[27][6] ^ layer_data_b[27][6] ^ carry_bit_layer_adder[27][5]; // calculation of add result
assign carry_bit_layer_adder[27][6] = (layer_data_a[27][6] & layer_data_b[27][6]) | (layer_data_a[27][6] & carry_bit_layer_adder[27][5]) | (layer_data_b[27][6] & carry_bit_layer_adder[27][5]); // calculation of carry bit of adder
assign result_layer_adder[27][7] = layer_data_a[27][7] ^ layer_data_b[27][7] ^ carry_bit_layer_adder[27][6]; // calculation of add result
assign carry_bit_layer_adder[27][7] = (layer_data_a[27][7] & layer_data_b[27][7]) | (layer_data_a[27][7] & carry_bit_layer_adder[27][6]) | (layer_data_b[27][7] & carry_bit_layer_adder[27][6]); // calculation of carry bit of adder
assign result_layer_adder[27][8] = layer_data_a[27][8] ^ layer_data_b[27][8] ^ carry_bit_layer_adder[27][7]; // calculation of add result
assign carry_bit_layer_adder[27][8] = (layer_data_a[27][8] & layer_data_b[27][8]) | (layer_data_a[27][8] & carry_bit_layer_adder[27][7]) | (layer_data_b[27][8] & carry_bit_layer_adder[27][7]); // calculation of carry bit of adder
assign result_layer_adder[27][9] = layer_data_a[27][9] ^ layer_data_b[27][9] ^ carry_bit_layer_adder[27][8]; // calculation of add result
assign carry_bit_layer_adder[27][9] = (layer_data_a[27][9] & layer_data_b[27][9]) | (layer_data_a[27][9] & carry_bit_layer_adder[27][8]) | (layer_data_b[27][9] & carry_bit_layer_adder[27][8]); // calculation of carry bit of adder
assign result_layer_adder[27][10] = layer_data_a[27][10] ^ layer_data_b[27][10] ^ carry_bit_layer_adder[27][9]; // calculation of add result
assign carry_bit_layer_adder[27][10] = (layer_data_a[27][10] & layer_data_b[27][10]) | (layer_data_a[27][10] & carry_bit_layer_adder[27][9]) | (layer_data_b[27][10] & carry_bit_layer_adder[27][9]); // calculation of carry bit of adder
assign result_layer_adder[27][11] = layer_data_a[27][11] ^ layer_data_b[27][11] ^ carry_bit_layer_adder[27][10]; // calculation of add result
assign carry_bit_layer_adder[27][11] = (layer_data_a[27][11] & layer_data_b[27][11]) | (layer_data_a[27][11] & carry_bit_layer_adder[27][10]) | (layer_data_b[27][11] & carry_bit_layer_adder[27][10]); // calculation of carry bit of adder
assign result_layer_adder[27][12] = layer_data_a[27][12] ^ layer_data_b[27][12] ^ carry_bit_layer_adder[27][11]; // calculation of add result
assign carry_bit_layer_adder[27][12] = (layer_data_a[27][12] & layer_data_b[27][12]) | (layer_data_a[27][12] & carry_bit_layer_adder[27][11]) | (layer_data_b[27][12] & carry_bit_layer_adder[27][11]); // calculation of carry bit of adder
assign result_layer_adder[27][13] = layer_data_a[27][13] ^ layer_data_b[27][13] ^ carry_bit_layer_adder[27][12]; // calculation of add result
assign carry_bit_layer_adder[27][13] = (layer_data_a[27][13] & layer_data_b[27][13]) | (layer_data_a[27][13] & carry_bit_layer_adder[27][12]) | (layer_data_b[27][13] & carry_bit_layer_adder[27][12]); // calculation of carry bit of adder
assign result_layer_adder[27][14] = layer_data_a[27][14] ^ layer_data_b[27][14] ^ carry_bit_layer_adder[27][13]; // calculation of add result
assign carry_bit_layer_adder[27][14] = (layer_data_a[27][14] & layer_data_b[27][14]) | (layer_data_a[27][14] & carry_bit_layer_adder[27][13]) | (layer_data_b[27][14] & carry_bit_layer_adder[27][13]); // calculation of carry bit of adder
assign result_layer_adder[27][15] = layer_data_a[27][15] ^ layer_data_b[27][15] ^ carry_bit_layer_adder[27][14]; // calculation of add result
assign carry_bit_layer_adder[27][15] = (layer_data_a[27][15] & layer_data_b[27][15]) | (layer_data_a[27][15] & carry_bit_layer_adder[27][14]) | (layer_data_b[27][15] & carry_bit_layer_adder[27][14]); // calculation of carry bit of adder
assign result_layer_adder[27][16] = layer_data_a[27][16] ^ layer_data_b[27][16] ^ carry_bit_layer_adder[27][15]; // calculation of add result
assign carry_bit_layer_adder[27][16] = (layer_data_a[27][16] & layer_data_b[27][16]) | (layer_data_a[27][16] & carry_bit_layer_adder[27][15]) | (layer_data_b[27][16] & carry_bit_layer_adder[27][15]); // calculation of carry bit of adder
assign result_layer_adder[27][17] = layer_data_a[27][17] ^ layer_data_b[27][17] ^ carry_bit_layer_adder[27][16]; // calculation of add result
assign carry_bit_layer_adder[27][17] = (layer_data_a[27][17] & layer_data_b[27][17]) | (layer_data_a[27][17] & carry_bit_layer_adder[27][16]) | (layer_data_b[27][17] & carry_bit_layer_adder[27][16]); // calculation of carry bit of adder
assign result_layer_adder[27][18] = layer_data_a[27][18] ^ layer_data_b[27][18] ^ carry_bit_layer_adder[27][17]; // calculation of add result
assign carry_bit_layer_adder[27][18] = (layer_data_a[27][18] & layer_data_b[27][18]) | (layer_data_a[27][18] & carry_bit_layer_adder[27][17]) | (layer_data_b[27][18] & carry_bit_layer_adder[27][17]); // calculation of carry bit of adder
assign result_layer_adder[27][19] = layer_data_a[27][19] ^ layer_data_b[27][19] ^ carry_bit_layer_adder[27][18]; // calculation of add result
assign carry_bit_layer_adder[27][19] = (layer_data_a[27][19] & layer_data_b[27][19]) | (layer_data_a[27][19] & carry_bit_layer_adder[27][18]) | (layer_data_b[27][19] & carry_bit_layer_adder[27][18]); // calculation of carry bit of adder
assign result_layer_adder[27][20] = layer_data_a[27][20] ^ layer_data_b[27][20] ^ carry_bit_layer_adder[27][19]; // calculation of add result
assign carry_bit_layer_adder[27][20] = (layer_data_a[27][20] & layer_data_b[27][20]) | (layer_data_a[27][20] & carry_bit_layer_adder[27][19]) | (layer_data_b[27][20] & carry_bit_layer_adder[27][19]); // calculation of carry bit of adder
assign result_layer_adder[27][21] = layer_data_a[27][21] ^ layer_data_b[27][21] ^ carry_bit_layer_adder[27][20]; // calculation of add result
assign carry_bit_layer_adder[27][21] = (layer_data_a[27][21] & layer_data_b[27][21]) | (layer_data_a[27][21] & carry_bit_layer_adder[27][20]) | (layer_data_b[27][21] & carry_bit_layer_adder[27][20]); // calculation of carry bit of adder
assign result_layer_adder[27][22] = layer_data_a[27][22] ^ layer_data_b[27][22] ^ carry_bit_layer_adder[27][21]; // calculation of add result
assign carry_bit_layer_adder[27][22] = (layer_data_a[27][22] & layer_data_b[27][22]) | (layer_data_a[27][22] & carry_bit_layer_adder[27][21]) | (layer_data_b[27][22] & carry_bit_layer_adder[27][21]); // calculation of carry bit of adder
assign result_layer_adder[27][23] = layer_data_a[27][23] ^ layer_data_b[27][23] ^ carry_bit_layer_adder[27][22]; // calculation of add result
assign carry_bit_layer_adder[27][23] = (layer_data_a[27][23] & layer_data_b[27][23]) | (layer_data_a[27][23] & carry_bit_layer_adder[27][22]) | (layer_data_b[27][23] & carry_bit_layer_adder[27][22]); // calculation of carry bit of adder
assign result_layer_adder[27][24] = layer_data_a[27][24] ^ layer_data_b[27][24] ^ carry_bit_layer_adder[27][23]; // calculation of add result
assign carry_bit_layer_adder[27][24] = (layer_data_a[27][24] & layer_data_b[27][24]) | (layer_data_a[27][24] & carry_bit_layer_adder[27][23]) | (layer_data_b[27][24] & carry_bit_layer_adder[27][23]); // calculation of carry bit of adder
assign result_layer_adder[27][25] = layer_data_a[27][25] ^ layer_data_b[27][25] ^ carry_bit_layer_adder[27][24]; // calculation of add result
assign carry_bit_layer_adder[27][25] = (layer_data_a[27][25] & layer_data_b[27][25]) | (layer_data_a[27][25] & carry_bit_layer_adder[27][24]) | (layer_data_b[27][25] & carry_bit_layer_adder[27][24]); // calculation of carry bit of adder
assign result_layer_adder[27][26] = layer_data_a[27][26] ^ layer_data_b[27][26] ^ carry_bit_layer_adder[27][25]; // calculation of add result
assign carry_bit_layer_adder[27][26] = (layer_data_a[27][26] & layer_data_b[27][26]) | (layer_data_a[27][26] & carry_bit_layer_adder[27][25]) | (layer_data_b[27][26] & carry_bit_layer_adder[27][25]); // calculation of carry bit of adder
assign result_layer_adder[27][27] = layer_data_a[27][27] ^ layer_data_b[27][27] ^ carry_bit_layer_adder[27][26]; // calculation of add result
assign carry_bit_layer_adder[27][27] = (layer_data_a[27][27] & layer_data_b[27][27]) | (layer_data_a[27][27] & carry_bit_layer_adder[27][26]) | (layer_data_b[27][27] & carry_bit_layer_adder[27][26]); // calculation of carry bit of adder
assign result_layer_adder[27][28] = layer_data_a[27][28] ^ layer_data_b[27][28] ^ carry_bit_layer_adder[27][27]; // calculation of add result
assign carry_bit_layer_adder[27][28] = (layer_data_a[27][28] & layer_data_b[27][28]) | (layer_data_a[27][28] & carry_bit_layer_adder[27][27]) | (layer_data_b[27][28] & carry_bit_layer_adder[27][27]); // calculation of carry bit of adder
assign result_layer_adder[27][29] = layer_data_a[27][29] ^ layer_data_b[27][29] ^ carry_bit_layer_adder[27][28]; // calculation of add result
assign carry_bit_layer_adder[27][29] = (layer_data_a[27][29] & layer_data_b[27][29]) | (layer_data_a[27][29] & carry_bit_layer_adder[27][28]) | (layer_data_b[27][29] & carry_bit_layer_adder[27][28]); // calculation of carry bit of adder
assign result_layer_adder[27][30] = layer_data_a[27][30] ^ layer_data_b[27][30] ^ carry_bit_layer_adder[27][29]; // calculation of add result
assign carry_bit_layer_adder[27][30] = (layer_data_a[27][30] & layer_data_b[27][30]) | (layer_data_a[27][30] & carry_bit_layer_adder[27][29]) | (layer_data_b[27][30] & carry_bit_layer_adder[27][29]); // calculation of carry bit of adder
assign result_layer_adder[27][31] = layer_data_a[27][31] ^ layer_data_b[27][31] ^ carry_bit_layer_adder[27][30]; // calculation of add result
assign carry_bit_layer_adder[27][31] = (layer_data_a[27][31] & layer_data_b[27][31]) | (layer_data_a[27][31] & carry_bit_layer_adder[27][30]) | (layer_data_b[27][31] & carry_bit_layer_adder[27][30]); // calculation of carry bit of adder
assign result_layer_adder[27][32] = layer_data_a[27][32] ^ layer_data_b[27][32] ^ carry_bit_layer_adder[27][31]; // calculation of add result

// Layer 29
assign layer_data_a[28][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[27][32] == 1'b1) ? {layer_data_a[27][31:0], operand_a[4]} : {result_layer_adder[27][31:0], operand_a[4]}) : {1'b0, result_layer_adder[27][32:1]}; // data select for layer 29
assign layer_data_b[28][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[28] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 29

// Layer 29 adder
assign result_layer_adder[28][0] = layer_data_a[28][0] ^ layer_data_b[28][0]; // calculation of add result
assign carry_bit_layer_adder[28][0] = layer_data_a[28][0] & layer_data_b[28][0]; // calculation of carry bit of adder
assign result_layer_adder[28][1] = layer_data_a[28][1] ^ layer_data_b[28][1] ^ carry_bit_layer_adder[28][0]; // calculation of add result
assign carry_bit_layer_adder[28][1] = (layer_data_a[28][1] & layer_data_b[28][1]) | (layer_data_a[28][1] & carry_bit_layer_adder[28][0]) | (layer_data_b[28][1] & carry_bit_layer_adder[28][0]); // calculation of carry bit of adder
assign result_layer_adder[28][2] = layer_data_a[28][2] ^ layer_data_b[28][2] ^ carry_bit_layer_adder[28][1]; // calculation of add result
assign carry_bit_layer_adder[28][2] = (layer_data_a[28][2] & layer_data_b[28][2]) | (layer_data_a[28][2] & carry_bit_layer_adder[28][1]) | (layer_data_b[28][2] & carry_bit_layer_adder[28][1]); // calculation of carry bit of adder
assign result_layer_adder[28][3] = layer_data_a[28][3] ^ layer_data_b[28][3] ^ carry_bit_layer_adder[28][2]; // calculation of add result
assign carry_bit_layer_adder[28][3] = (layer_data_a[28][3] & layer_data_b[28][3]) | (layer_data_a[28][3] & carry_bit_layer_adder[28][2]) | (layer_data_b[28][3] & carry_bit_layer_adder[28][2]); // calculation of carry bit of adder
assign result_layer_adder[28][4] = layer_data_a[28][4] ^ layer_data_b[28][4] ^ carry_bit_layer_adder[28][3]; // calculation of add result
assign carry_bit_layer_adder[28][4] = (layer_data_a[28][4] & layer_data_b[28][4]) | (layer_data_a[28][4] & carry_bit_layer_adder[28][3]) | (layer_data_b[28][4] & carry_bit_layer_adder[28][3]); // calculation of carry bit of adder
assign result_layer_adder[28][5] = layer_data_a[28][5] ^ layer_data_b[28][5] ^ carry_bit_layer_adder[28][4]; // calculation of add result
assign carry_bit_layer_adder[28][5] = (layer_data_a[28][5] & layer_data_b[28][5]) | (layer_data_a[28][5] & carry_bit_layer_adder[28][4]) | (layer_data_b[28][5] & carry_bit_layer_adder[28][4]); // calculation of carry bit of adder
assign result_layer_adder[28][6] = layer_data_a[28][6] ^ layer_data_b[28][6] ^ carry_bit_layer_adder[28][5]; // calculation of add result
assign carry_bit_layer_adder[28][6] = (layer_data_a[28][6] & layer_data_b[28][6]) | (layer_data_a[28][6] & carry_bit_layer_adder[28][5]) | (layer_data_b[28][6] & carry_bit_layer_adder[28][5]); // calculation of carry bit of adder
assign result_layer_adder[28][7] = layer_data_a[28][7] ^ layer_data_b[28][7] ^ carry_bit_layer_adder[28][6]; // calculation of add result
assign carry_bit_layer_adder[28][7] = (layer_data_a[28][7] & layer_data_b[28][7]) | (layer_data_a[28][7] & carry_bit_layer_adder[28][6]) | (layer_data_b[28][7] & carry_bit_layer_adder[28][6]); // calculation of carry bit of adder
assign result_layer_adder[28][8] = layer_data_a[28][8] ^ layer_data_b[28][8] ^ carry_bit_layer_adder[28][7]; // calculation of add result
assign carry_bit_layer_adder[28][8] = (layer_data_a[28][8] & layer_data_b[28][8]) | (layer_data_a[28][8] & carry_bit_layer_adder[28][7]) | (layer_data_b[28][8] & carry_bit_layer_adder[28][7]); // calculation of carry bit of adder
assign result_layer_adder[28][9] = layer_data_a[28][9] ^ layer_data_b[28][9] ^ carry_bit_layer_adder[28][8]; // calculation of add result
assign carry_bit_layer_adder[28][9] = (layer_data_a[28][9] & layer_data_b[28][9]) | (layer_data_a[28][9] & carry_bit_layer_adder[28][8]) | (layer_data_b[28][9] & carry_bit_layer_adder[28][8]); // calculation of carry bit of adder
assign result_layer_adder[28][10] = layer_data_a[28][10] ^ layer_data_b[28][10] ^ carry_bit_layer_adder[28][9]; // calculation of add result
assign carry_bit_layer_adder[28][10] = (layer_data_a[28][10] & layer_data_b[28][10]) | (layer_data_a[28][10] & carry_bit_layer_adder[28][9]) | (layer_data_b[28][10] & carry_bit_layer_adder[28][9]); // calculation of carry bit of adder
assign result_layer_adder[28][11] = layer_data_a[28][11] ^ layer_data_b[28][11] ^ carry_bit_layer_adder[28][10]; // calculation of add result
assign carry_bit_layer_adder[28][11] = (layer_data_a[28][11] & layer_data_b[28][11]) | (layer_data_a[28][11] & carry_bit_layer_adder[28][10]) | (layer_data_b[28][11] & carry_bit_layer_adder[28][10]); // calculation of carry bit of adder
assign result_layer_adder[28][12] = layer_data_a[28][12] ^ layer_data_b[28][12] ^ carry_bit_layer_adder[28][11]; // calculation of add result
assign carry_bit_layer_adder[28][12] = (layer_data_a[28][12] & layer_data_b[28][12]) | (layer_data_a[28][12] & carry_bit_layer_adder[28][11]) | (layer_data_b[28][12] & carry_bit_layer_adder[28][11]); // calculation of carry bit of adder
assign result_layer_adder[28][13] = layer_data_a[28][13] ^ layer_data_b[28][13] ^ carry_bit_layer_adder[28][12]; // calculation of add result
assign carry_bit_layer_adder[28][13] = (layer_data_a[28][13] & layer_data_b[28][13]) | (layer_data_a[28][13] & carry_bit_layer_adder[28][12]) | (layer_data_b[28][13] & carry_bit_layer_adder[28][12]); // calculation of carry bit of adder
assign result_layer_adder[28][14] = layer_data_a[28][14] ^ layer_data_b[28][14] ^ carry_bit_layer_adder[28][13]; // calculation of add result
assign carry_bit_layer_adder[28][14] = (layer_data_a[28][14] & layer_data_b[28][14]) | (layer_data_a[28][14] & carry_bit_layer_adder[28][13]) | (layer_data_b[28][14] & carry_bit_layer_adder[28][13]); // calculation of carry bit of adder
assign result_layer_adder[28][15] = layer_data_a[28][15] ^ layer_data_b[28][15] ^ carry_bit_layer_adder[28][14]; // calculation of add result
assign carry_bit_layer_adder[28][15] = (layer_data_a[28][15] & layer_data_b[28][15]) | (layer_data_a[28][15] & carry_bit_layer_adder[28][14]) | (layer_data_b[28][15] & carry_bit_layer_adder[28][14]); // calculation of carry bit of adder
assign result_layer_adder[28][16] = layer_data_a[28][16] ^ layer_data_b[28][16] ^ carry_bit_layer_adder[28][15]; // calculation of add result
assign carry_bit_layer_adder[28][16] = (layer_data_a[28][16] & layer_data_b[28][16]) | (layer_data_a[28][16] & carry_bit_layer_adder[28][15]) | (layer_data_b[28][16] & carry_bit_layer_adder[28][15]); // calculation of carry bit of adder
assign result_layer_adder[28][17] = layer_data_a[28][17] ^ layer_data_b[28][17] ^ carry_bit_layer_adder[28][16]; // calculation of add result
assign carry_bit_layer_adder[28][17] = (layer_data_a[28][17] & layer_data_b[28][17]) | (layer_data_a[28][17] & carry_bit_layer_adder[28][16]) | (layer_data_b[28][17] & carry_bit_layer_adder[28][16]); // calculation of carry bit of adder
assign result_layer_adder[28][18] = layer_data_a[28][18] ^ layer_data_b[28][18] ^ carry_bit_layer_adder[28][17]; // calculation of add result
assign carry_bit_layer_adder[28][18] = (layer_data_a[28][18] & layer_data_b[28][18]) | (layer_data_a[28][18] & carry_bit_layer_adder[28][17]) | (layer_data_b[28][18] & carry_bit_layer_adder[28][17]); // calculation of carry bit of adder
assign result_layer_adder[28][19] = layer_data_a[28][19] ^ layer_data_b[28][19] ^ carry_bit_layer_adder[28][18]; // calculation of add result
assign carry_bit_layer_adder[28][19] = (layer_data_a[28][19] & layer_data_b[28][19]) | (layer_data_a[28][19] & carry_bit_layer_adder[28][18]) | (layer_data_b[28][19] & carry_bit_layer_adder[28][18]); // calculation of carry bit of adder
assign result_layer_adder[28][20] = layer_data_a[28][20] ^ layer_data_b[28][20] ^ carry_bit_layer_adder[28][19]; // calculation of add result
assign carry_bit_layer_adder[28][20] = (layer_data_a[28][20] & layer_data_b[28][20]) | (layer_data_a[28][20] & carry_bit_layer_adder[28][19]) | (layer_data_b[28][20] & carry_bit_layer_adder[28][19]); // calculation of carry bit of adder
assign result_layer_adder[28][21] = layer_data_a[28][21] ^ layer_data_b[28][21] ^ carry_bit_layer_adder[28][20]; // calculation of add result
assign carry_bit_layer_adder[28][21] = (layer_data_a[28][21] & layer_data_b[28][21]) | (layer_data_a[28][21] & carry_bit_layer_adder[28][20]) | (layer_data_b[28][21] & carry_bit_layer_adder[28][20]); // calculation of carry bit of adder
assign result_layer_adder[28][22] = layer_data_a[28][22] ^ layer_data_b[28][22] ^ carry_bit_layer_adder[28][21]; // calculation of add result
assign carry_bit_layer_adder[28][22] = (layer_data_a[28][22] & layer_data_b[28][22]) | (layer_data_a[28][22] & carry_bit_layer_adder[28][21]) | (layer_data_b[28][22] & carry_bit_layer_adder[28][21]); // calculation of carry bit of adder
assign result_layer_adder[28][23] = layer_data_a[28][23] ^ layer_data_b[28][23] ^ carry_bit_layer_adder[28][22]; // calculation of add result
assign carry_bit_layer_adder[28][23] = (layer_data_a[28][23] & layer_data_b[28][23]) | (layer_data_a[28][23] & carry_bit_layer_adder[28][22]) | (layer_data_b[28][23] & carry_bit_layer_adder[28][22]); // calculation of carry bit of adder
assign result_layer_adder[28][24] = layer_data_a[28][24] ^ layer_data_b[28][24] ^ carry_bit_layer_adder[28][23]; // calculation of add result
assign carry_bit_layer_adder[28][24] = (layer_data_a[28][24] & layer_data_b[28][24]) | (layer_data_a[28][24] & carry_bit_layer_adder[28][23]) | (layer_data_b[28][24] & carry_bit_layer_adder[28][23]); // calculation of carry bit of adder
assign result_layer_adder[28][25] = layer_data_a[28][25] ^ layer_data_b[28][25] ^ carry_bit_layer_adder[28][24]; // calculation of add result
assign carry_bit_layer_adder[28][25] = (layer_data_a[28][25] & layer_data_b[28][25]) | (layer_data_a[28][25] & carry_bit_layer_adder[28][24]) | (layer_data_b[28][25] & carry_bit_layer_adder[28][24]); // calculation of carry bit of adder
assign result_layer_adder[28][26] = layer_data_a[28][26] ^ layer_data_b[28][26] ^ carry_bit_layer_adder[28][25]; // calculation of add result
assign carry_bit_layer_adder[28][26] = (layer_data_a[28][26] & layer_data_b[28][26]) | (layer_data_a[28][26] & carry_bit_layer_adder[28][25]) | (layer_data_b[28][26] & carry_bit_layer_adder[28][25]); // calculation of carry bit of adder
assign result_layer_adder[28][27] = layer_data_a[28][27] ^ layer_data_b[28][27] ^ carry_bit_layer_adder[28][26]; // calculation of add result
assign carry_bit_layer_adder[28][27] = (layer_data_a[28][27] & layer_data_b[28][27]) | (layer_data_a[28][27] & carry_bit_layer_adder[28][26]) | (layer_data_b[28][27] & carry_bit_layer_adder[28][26]); // calculation of carry bit of adder
assign result_layer_adder[28][28] = layer_data_a[28][28] ^ layer_data_b[28][28] ^ carry_bit_layer_adder[28][27]; // calculation of add result
assign carry_bit_layer_adder[28][28] = (layer_data_a[28][28] & layer_data_b[28][28]) | (layer_data_a[28][28] & carry_bit_layer_adder[28][27]) | (layer_data_b[28][28] & carry_bit_layer_adder[28][27]); // calculation of carry bit of adder
assign result_layer_adder[28][29] = layer_data_a[28][29] ^ layer_data_b[28][29] ^ carry_bit_layer_adder[28][28]; // calculation of add result
assign carry_bit_layer_adder[28][29] = (layer_data_a[28][29] & layer_data_b[28][29]) | (layer_data_a[28][29] & carry_bit_layer_adder[28][28]) | (layer_data_b[28][29] & carry_bit_layer_adder[28][28]); // calculation of carry bit of adder
assign result_layer_adder[28][30] = layer_data_a[28][30] ^ layer_data_b[28][30] ^ carry_bit_layer_adder[28][29]; // calculation of add result
assign carry_bit_layer_adder[28][30] = (layer_data_a[28][30] & layer_data_b[28][30]) | (layer_data_a[28][30] & carry_bit_layer_adder[28][29]) | (layer_data_b[28][30] & carry_bit_layer_adder[28][29]); // calculation of carry bit of adder
assign result_layer_adder[28][31] = layer_data_a[28][31] ^ layer_data_b[28][31] ^ carry_bit_layer_adder[28][30]; // calculation of add result
assign carry_bit_layer_adder[28][31] = (layer_data_a[28][31] & layer_data_b[28][31]) | (layer_data_a[28][31] & carry_bit_layer_adder[28][30]) | (layer_data_b[28][31] & carry_bit_layer_adder[28][30]); // calculation of carry bit of adder
assign result_layer_adder[28][32] = layer_data_a[28][32] ^ layer_data_b[28][32] ^ carry_bit_layer_adder[28][31]; // calculation of add result

// Layer 30
assign layer_data_a[29][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[28][32] == 1'b1) ? {layer_data_a[28][31:0], operand_a[3]} : {result_layer_adder[28][31:0], operand_a[3]}) : {1'b0, result_layer_adder[28][32:1]}; // data select for layer 30
assign layer_data_b[29][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[29] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 30

// Layer 30 adder
assign result_layer_adder[29][0] = layer_data_a[29][0] ^ layer_data_b[29][0]; // calculation of add result
assign carry_bit_layer_adder[29][0] = layer_data_a[29][0] & layer_data_b[29][0]; // calculation of carry bit of adder
assign result_layer_adder[29][1] = layer_data_a[29][1] ^ layer_data_b[29][1] ^ carry_bit_layer_adder[29][0]; // calculation of add result
assign carry_bit_layer_adder[29][1] = (layer_data_a[29][1] & layer_data_b[29][1]) | (layer_data_a[29][1] & carry_bit_layer_adder[29][0]) | (layer_data_b[29][1] & carry_bit_layer_adder[29][0]); // calculation of carry bit of adder
assign result_layer_adder[29][2] = layer_data_a[29][2] ^ layer_data_b[29][2] ^ carry_bit_layer_adder[29][1]; // calculation of add result
assign carry_bit_layer_adder[29][2] = (layer_data_a[29][2] & layer_data_b[29][2]) | (layer_data_a[29][2] & carry_bit_layer_adder[29][1]) | (layer_data_b[29][2] & carry_bit_layer_adder[29][1]); // calculation of carry bit of adder
assign result_layer_adder[29][3] = layer_data_a[29][3] ^ layer_data_b[29][3] ^ carry_bit_layer_adder[29][2]; // calculation of add result
assign carry_bit_layer_adder[29][3] = (layer_data_a[29][3] & layer_data_b[29][3]) | (layer_data_a[29][3] & carry_bit_layer_adder[29][2]) | (layer_data_b[29][3] & carry_bit_layer_adder[29][2]); // calculation of carry bit of adder
assign result_layer_adder[29][4] = layer_data_a[29][4] ^ layer_data_b[29][4] ^ carry_bit_layer_adder[29][3]; // calculation of add result
assign carry_bit_layer_adder[29][4] = (layer_data_a[29][4] & layer_data_b[29][4]) | (layer_data_a[29][4] & carry_bit_layer_adder[29][3]) | (layer_data_b[29][4] & carry_bit_layer_adder[29][3]); // calculation of carry bit of adder
assign result_layer_adder[29][5] = layer_data_a[29][5] ^ layer_data_b[29][5] ^ carry_bit_layer_adder[29][4]; // calculation of add result
assign carry_bit_layer_adder[29][5] = (layer_data_a[29][5] & layer_data_b[29][5]) | (layer_data_a[29][5] & carry_bit_layer_adder[29][4]) | (layer_data_b[29][5] & carry_bit_layer_adder[29][4]); // calculation of carry bit of adder
assign result_layer_adder[29][6] = layer_data_a[29][6] ^ layer_data_b[29][6] ^ carry_bit_layer_adder[29][5]; // calculation of add result
assign carry_bit_layer_adder[29][6] = (layer_data_a[29][6] & layer_data_b[29][6]) | (layer_data_a[29][6] & carry_bit_layer_adder[29][5]) | (layer_data_b[29][6] & carry_bit_layer_adder[29][5]); // calculation of carry bit of adder
assign result_layer_adder[29][7] = layer_data_a[29][7] ^ layer_data_b[29][7] ^ carry_bit_layer_adder[29][6]; // calculation of add result
assign carry_bit_layer_adder[29][7] = (layer_data_a[29][7] & layer_data_b[29][7]) | (layer_data_a[29][7] & carry_bit_layer_adder[29][6]) | (layer_data_b[29][7] & carry_bit_layer_adder[29][6]); // calculation of carry bit of adder
assign result_layer_adder[29][8] = layer_data_a[29][8] ^ layer_data_b[29][8] ^ carry_bit_layer_adder[29][7]; // calculation of add result
assign carry_bit_layer_adder[29][8] = (layer_data_a[29][8] & layer_data_b[29][8]) | (layer_data_a[29][8] & carry_bit_layer_adder[29][7]) | (layer_data_b[29][8] & carry_bit_layer_adder[29][7]); // calculation of carry bit of adder
assign result_layer_adder[29][9] = layer_data_a[29][9] ^ layer_data_b[29][9] ^ carry_bit_layer_adder[29][8]; // calculation of add result
assign carry_bit_layer_adder[29][9] = (layer_data_a[29][9] & layer_data_b[29][9]) | (layer_data_a[29][9] & carry_bit_layer_adder[29][8]) | (layer_data_b[29][9] & carry_bit_layer_adder[29][8]); // calculation of carry bit of adder
assign result_layer_adder[29][10] = layer_data_a[29][10] ^ layer_data_b[29][10] ^ carry_bit_layer_adder[29][9]; // calculation of add result
assign carry_bit_layer_adder[29][10] = (layer_data_a[29][10] & layer_data_b[29][10]) | (layer_data_a[29][10] & carry_bit_layer_adder[29][9]) | (layer_data_b[29][10] & carry_bit_layer_adder[29][9]); // calculation of carry bit of adder
assign result_layer_adder[29][11] = layer_data_a[29][11] ^ layer_data_b[29][11] ^ carry_bit_layer_adder[29][10]; // calculation of add result
assign carry_bit_layer_adder[29][11] = (layer_data_a[29][11] & layer_data_b[29][11]) | (layer_data_a[29][11] & carry_bit_layer_adder[29][10]) | (layer_data_b[29][11] & carry_bit_layer_adder[29][10]); // calculation of carry bit of adder
assign result_layer_adder[29][12] = layer_data_a[29][12] ^ layer_data_b[29][12] ^ carry_bit_layer_adder[29][11]; // calculation of add result
assign carry_bit_layer_adder[29][12] = (layer_data_a[29][12] & layer_data_b[29][12]) | (layer_data_a[29][12] & carry_bit_layer_adder[29][11]) | (layer_data_b[29][12] & carry_bit_layer_adder[29][11]); // calculation of carry bit of adder
assign result_layer_adder[29][13] = layer_data_a[29][13] ^ layer_data_b[29][13] ^ carry_bit_layer_adder[29][12]; // calculation of add result
assign carry_bit_layer_adder[29][13] = (layer_data_a[29][13] & layer_data_b[29][13]) | (layer_data_a[29][13] & carry_bit_layer_adder[29][12]) | (layer_data_b[29][13] & carry_bit_layer_adder[29][12]); // calculation of carry bit of adder
assign result_layer_adder[29][14] = layer_data_a[29][14] ^ layer_data_b[29][14] ^ carry_bit_layer_adder[29][13]; // calculation of add result
assign carry_bit_layer_adder[29][14] = (layer_data_a[29][14] & layer_data_b[29][14]) | (layer_data_a[29][14] & carry_bit_layer_adder[29][13]) | (layer_data_b[29][14] & carry_bit_layer_adder[29][13]); // calculation of carry bit of adder
assign result_layer_adder[29][15] = layer_data_a[29][15] ^ layer_data_b[29][15] ^ carry_bit_layer_adder[29][14]; // calculation of add result
assign carry_bit_layer_adder[29][15] = (layer_data_a[29][15] & layer_data_b[29][15]) | (layer_data_a[29][15] & carry_bit_layer_adder[29][14]) | (layer_data_b[29][15] & carry_bit_layer_adder[29][14]); // calculation of carry bit of adder
assign result_layer_adder[29][16] = layer_data_a[29][16] ^ layer_data_b[29][16] ^ carry_bit_layer_adder[29][15]; // calculation of add result
assign carry_bit_layer_adder[29][16] = (layer_data_a[29][16] & layer_data_b[29][16]) | (layer_data_a[29][16] & carry_bit_layer_adder[29][15]) | (layer_data_b[29][16] & carry_bit_layer_adder[29][15]); // calculation of carry bit of adder
assign result_layer_adder[29][17] = layer_data_a[29][17] ^ layer_data_b[29][17] ^ carry_bit_layer_adder[29][16]; // calculation of add result
assign carry_bit_layer_adder[29][17] = (layer_data_a[29][17] & layer_data_b[29][17]) | (layer_data_a[29][17] & carry_bit_layer_adder[29][16]) | (layer_data_b[29][17] & carry_bit_layer_adder[29][16]); // calculation of carry bit of adder
assign result_layer_adder[29][18] = layer_data_a[29][18] ^ layer_data_b[29][18] ^ carry_bit_layer_adder[29][17]; // calculation of add result
assign carry_bit_layer_adder[29][18] = (layer_data_a[29][18] & layer_data_b[29][18]) | (layer_data_a[29][18] & carry_bit_layer_adder[29][17]) | (layer_data_b[29][18] & carry_bit_layer_adder[29][17]); // calculation of carry bit of adder
assign result_layer_adder[29][19] = layer_data_a[29][19] ^ layer_data_b[29][19] ^ carry_bit_layer_adder[29][18]; // calculation of add result
assign carry_bit_layer_adder[29][19] = (layer_data_a[29][19] & layer_data_b[29][19]) | (layer_data_a[29][19] & carry_bit_layer_adder[29][18]) | (layer_data_b[29][19] & carry_bit_layer_adder[29][18]); // calculation of carry bit of adder
assign result_layer_adder[29][20] = layer_data_a[29][20] ^ layer_data_b[29][20] ^ carry_bit_layer_adder[29][19]; // calculation of add result
assign carry_bit_layer_adder[29][20] = (layer_data_a[29][20] & layer_data_b[29][20]) | (layer_data_a[29][20] & carry_bit_layer_adder[29][19]) | (layer_data_b[29][20] & carry_bit_layer_adder[29][19]); // calculation of carry bit of adder
assign result_layer_adder[29][21] = layer_data_a[29][21] ^ layer_data_b[29][21] ^ carry_bit_layer_adder[29][20]; // calculation of add result
assign carry_bit_layer_adder[29][21] = (layer_data_a[29][21] & layer_data_b[29][21]) | (layer_data_a[29][21] & carry_bit_layer_adder[29][20]) | (layer_data_b[29][21] & carry_bit_layer_adder[29][20]); // calculation of carry bit of adder
assign result_layer_adder[29][22] = layer_data_a[29][22] ^ layer_data_b[29][22] ^ carry_bit_layer_adder[29][21]; // calculation of add result
assign carry_bit_layer_adder[29][22] = (layer_data_a[29][22] & layer_data_b[29][22]) | (layer_data_a[29][22] & carry_bit_layer_adder[29][21]) | (layer_data_b[29][22] & carry_bit_layer_adder[29][21]); // calculation of carry bit of adder
assign result_layer_adder[29][23] = layer_data_a[29][23] ^ layer_data_b[29][23] ^ carry_bit_layer_adder[29][22]; // calculation of add result
assign carry_bit_layer_adder[29][23] = (layer_data_a[29][23] & layer_data_b[29][23]) | (layer_data_a[29][23] & carry_bit_layer_adder[29][22]) | (layer_data_b[29][23] & carry_bit_layer_adder[29][22]); // calculation of carry bit of adder
assign result_layer_adder[29][24] = layer_data_a[29][24] ^ layer_data_b[29][24] ^ carry_bit_layer_adder[29][23]; // calculation of add result
assign carry_bit_layer_adder[29][24] = (layer_data_a[29][24] & layer_data_b[29][24]) | (layer_data_a[29][24] & carry_bit_layer_adder[29][23]) | (layer_data_b[29][24] & carry_bit_layer_adder[29][23]); // calculation of carry bit of adder
assign result_layer_adder[29][25] = layer_data_a[29][25] ^ layer_data_b[29][25] ^ carry_bit_layer_adder[29][24]; // calculation of add result
assign carry_bit_layer_adder[29][25] = (layer_data_a[29][25] & layer_data_b[29][25]) | (layer_data_a[29][25] & carry_bit_layer_adder[29][24]) | (layer_data_b[29][25] & carry_bit_layer_adder[29][24]); // calculation of carry bit of adder
assign result_layer_adder[29][26] = layer_data_a[29][26] ^ layer_data_b[29][26] ^ carry_bit_layer_adder[29][25]; // calculation of add result
assign carry_bit_layer_adder[29][26] = (layer_data_a[29][26] & layer_data_b[29][26]) | (layer_data_a[29][26] & carry_bit_layer_adder[29][25]) | (layer_data_b[29][26] & carry_bit_layer_adder[29][25]); // calculation of carry bit of adder
assign result_layer_adder[29][27] = layer_data_a[29][27] ^ layer_data_b[29][27] ^ carry_bit_layer_adder[29][26]; // calculation of add result
assign carry_bit_layer_adder[29][27] = (layer_data_a[29][27] & layer_data_b[29][27]) | (layer_data_a[29][27] & carry_bit_layer_adder[29][26]) | (layer_data_b[29][27] & carry_bit_layer_adder[29][26]); // calculation of carry bit of adder
assign result_layer_adder[29][28] = layer_data_a[29][28] ^ layer_data_b[29][28] ^ carry_bit_layer_adder[29][27]; // calculation of add result
assign carry_bit_layer_adder[29][28] = (layer_data_a[29][28] & layer_data_b[29][28]) | (layer_data_a[29][28] & carry_bit_layer_adder[29][27]) | (layer_data_b[29][28] & carry_bit_layer_adder[29][27]); // calculation of carry bit of adder
assign result_layer_adder[29][29] = layer_data_a[29][29] ^ layer_data_b[29][29] ^ carry_bit_layer_adder[29][28]; // calculation of add result
assign carry_bit_layer_adder[29][29] = (layer_data_a[29][29] & layer_data_b[29][29]) | (layer_data_a[29][29] & carry_bit_layer_adder[29][28]) | (layer_data_b[29][29] & carry_bit_layer_adder[29][28]); // calculation of carry bit of adder
assign result_layer_adder[29][30] = layer_data_a[29][30] ^ layer_data_b[29][30] ^ carry_bit_layer_adder[29][29]; // calculation of add result
assign carry_bit_layer_adder[29][30] = (layer_data_a[29][30] & layer_data_b[29][30]) | (layer_data_a[29][30] & carry_bit_layer_adder[29][29]) | (layer_data_b[29][30] & carry_bit_layer_adder[29][29]); // calculation of carry bit of adder
assign result_layer_adder[29][31] = layer_data_a[29][31] ^ layer_data_b[29][31] ^ carry_bit_layer_adder[29][30]; // calculation of add result
assign carry_bit_layer_adder[29][31] = (layer_data_a[29][31] & layer_data_b[29][31]) | (layer_data_a[29][31] & carry_bit_layer_adder[29][30]) | (layer_data_b[29][31] & carry_bit_layer_adder[29][30]); // calculation of carry bit of adder
assign result_layer_adder[29][32] = layer_data_a[29][32] ^ layer_data_b[29][32] ^ carry_bit_layer_adder[29][31]; // calculation of add result

// Layer 31
assign layer_data_a[30][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[29][32] == 1'b1) ? {layer_data_a[29][31:0], operand_a[2]} : {result_layer_adder[29][31:0], operand_a[2]}) : {1'b0, result_layer_adder[29][32:1]}; // data select for layer 31
assign layer_data_b[30][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[30] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 31

// Layer 31 adder
assign result_layer_adder[30][0] = layer_data_a[30][0] ^ layer_data_b[30][0]; // calculation of add result
assign carry_bit_layer_adder[30][0] = layer_data_a[30][0] & layer_data_b[30][0]; // calculation of carry bit of adder
assign result_layer_adder[30][1] = layer_data_a[30][1] ^ layer_data_b[30][1] ^ carry_bit_layer_adder[30][0]; // calculation of add result
assign carry_bit_layer_adder[30][1] = (layer_data_a[30][1] & layer_data_b[30][1]) | (layer_data_a[30][1] & carry_bit_layer_adder[30][0]) | (layer_data_b[30][1] & carry_bit_layer_adder[30][0]); // calculation of carry bit of adder
assign result_layer_adder[30][2] = layer_data_a[30][2] ^ layer_data_b[30][2] ^ carry_bit_layer_adder[30][1]; // calculation of add result
assign carry_bit_layer_adder[30][2] = (layer_data_a[30][2] & layer_data_b[30][2]) | (layer_data_a[30][2] & carry_bit_layer_adder[30][1]) | (layer_data_b[30][2] & carry_bit_layer_adder[30][1]); // calculation of carry bit of adder
assign result_layer_adder[30][3] = layer_data_a[30][3] ^ layer_data_b[30][3] ^ carry_bit_layer_adder[30][2]; // calculation of add result
assign carry_bit_layer_adder[30][3] = (layer_data_a[30][3] & layer_data_b[30][3]) | (layer_data_a[30][3] & carry_bit_layer_adder[30][2]) | (layer_data_b[30][3] & carry_bit_layer_adder[30][2]); // calculation of carry bit of adder
assign result_layer_adder[30][4] = layer_data_a[30][4] ^ layer_data_b[30][4] ^ carry_bit_layer_adder[30][3]; // calculation of add result
assign carry_bit_layer_adder[30][4] = (layer_data_a[30][4] & layer_data_b[30][4]) | (layer_data_a[30][4] & carry_bit_layer_adder[30][3]) | (layer_data_b[30][4] & carry_bit_layer_adder[30][3]); // calculation of carry bit of adder
assign result_layer_adder[30][5] = layer_data_a[30][5] ^ layer_data_b[30][5] ^ carry_bit_layer_adder[30][4]; // calculation of add result
assign carry_bit_layer_adder[30][5] = (layer_data_a[30][5] & layer_data_b[30][5]) | (layer_data_a[30][5] & carry_bit_layer_adder[30][4]) | (layer_data_b[30][5] & carry_bit_layer_adder[30][4]); // calculation of carry bit of adder
assign result_layer_adder[30][6] = layer_data_a[30][6] ^ layer_data_b[30][6] ^ carry_bit_layer_adder[30][5]; // calculation of add result
assign carry_bit_layer_adder[30][6] = (layer_data_a[30][6] & layer_data_b[30][6]) | (layer_data_a[30][6] & carry_bit_layer_adder[30][5]) | (layer_data_b[30][6] & carry_bit_layer_adder[30][5]); // calculation of carry bit of adder
assign result_layer_adder[30][7] = layer_data_a[30][7] ^ layer_data_b[30][7] ^ carry_bit_layer_adder[30][6]; // calculation of add result
assign carry_bit_layer_adder[30][7] = (layer_data_a[30][7] & layer_data_b[30][7]) | (layer_data_a[30][7] & carry_bit_layer_adder[30][6]) | (layer_data_b[30][7] & carry_bit_layer_adder[30][6]); // calculation of carry bit of adder
assign result_layer_adder[30][8] = layer_data_a[30][8] ^ layer_data_b[30][8] ^ carry_bit_layer_adder[30][7]; // calculation of add result
assign carry_bit_layer_adder[30][8] = (layer_data_a[30][8] & layer_data_b[30][8]) | (layer_data_a[30][8] & carry_bit_layer_adder[30][7]) | (layer_data_b[30][8] & carry_bit_layer_adder[30][7]); // calculation of carry bit of adder
assign result_layer_adder[30][9] = layer_data_a[30][9] ^ layer_data_b[30][9] ^ carry_bit_layer_adder[30][8]; // calculation of add result
assign carry_bit_layer_adder[30][9] = (layer_data_a[30][9] & layer_data_b[30][9]) | (layer_data_a[30][9] & carry_bit_layer_adder[30][8]) | (layer_data_b[30][9] & carry_bit_layer_adder[30][8]); // calculation of carry bit of adder
assign result_layer_adder[30][10] = layer_data_a[30][10] ^ layer_data_b[30][10] ^ carry_bit_layer_adder[30][9]; // calculation of add result
assign carry_bit_layer_adder[30][10] = (layer_data_a[30][10] & layer_data_b[30][10]) | (layer_data_a[30][10] & carry_bit_layer_adder[30][9]) | (layer_data_b[30][10] & carry_bit_layer_adder[30][9]); // calculation of carry bit of adder
assign result_layer_adder[30][11] = layer_data_a[30][11] ^ layer_data_b[30][11] ^ carry_bit_layer_adder[30][10]; // calculation of add result
assign carry_bit_layer_adder[30][11] = (layer_data_a[30][11] & layer_data_b[30][11]) | (layer_data_a[30][11] & carry_bit_layer_adder[30][10]) | (layer_data_b[30][11] & carry_bit_layer_adder[30][10]); // calculation of carry bit of adder
assign result_layer_adder[30][12] = layer_data_a[30][12] ^ layer_data_b[30][12] ^ carry_bit_layer_adder[30][11]; // calculation of add result
assign carry_bit_layer_adder[30][12] = (layer_data_a[30][12] & layer_data_b[30][12]) | (layer_data_a[30][12] & carry_bit_layer_adder[30][11]) | (layer_data_b[30][12] & carry_bit_layer_adder[30][11]); // calculation of carry bit of adder
assign result_layer_adder[30][13] = layer_data_a[30][13] ^ layer_data_b[30][13] ^ carry_bit_layer_adder[30][12]; // calculation of add result
assign carry_bit_layer_adder[30][13] = (layer_data_a[30][13] & layer_data_b[30][13]) | (layer_data_a[30][13] & carry_bit_layer_adder[30][12]) | (layer_data_b[30][13] & carry_bit_layer_adder[30][12]); // calculation of carry bit of adder
assign result_layer_adder[30][14] = layer_data_a[30][14] ^ layer_data_b[30][14] ^ carry_bit_layer_adder[30][13]; // calculation of add result
assign carry_bit_layer_adder[30][14] = (layer_data_a[30][14] & layer_data_b[30][14]) | (layer_data_a[30][14] & carry_bit_layer_adder[30][13]) | (layer_data_b[30][14] & carry_bit_layer_adder[30][13]); // calculation of carry bit of adder
assign result_layer_adder[30][15] = layer_data_a[30][15] ^ layer_data_b[30][15] ^ carry_bit_layer_adder[30][14]; // calculation of add result
assign carry_bit_layer_adder[30][15] = (layer_data_a[30][15] & layer_data_b[30][15]) | (layer_data_a[30][15] & carry_bit_layer_adder[30][14]) | (layer_data_b[30][15] & carry_bit_layer_adder[30][14]); // calculation of carry bit of adder
assign result_layer_adder[30][16] = layer_data_a[30][16] ^ layer_data_b[30][16] ^ carry_bit_layer_adder[30][15]; // calculation of add result
assign carry_bit_layer_adder[30][16] = (layer_data_a[30][16] & layer_data_b[30][16]) | (layer_data_a[30][16] & carry_bit_layer_adder[30][15]) | (layer_data_b[30][16] & carry_bit_layer_adder[30][15]); // calculation of carry bit of adder
assign result_layer_adder[30][17] = layer_data_a[30][17] ^ layer_data_b[30][17] ^ carry_bit_layer_adder[30][16]; // calculation of add result
assign carry_bit_layer_adder[30][17] = (layer_data_a[30][17] & layer_data_b[30][17]) | (layer_data_a[30][17] & carry_bit_layer_adder[30][16]) | (layer_data_b[30][17] & carry_bit_layer_adder[30][16]); // calculation of carry bit of adder
assign result_layer_adder[30][18] = layer_data_a[30][18] ^ layer_data_b[30][18] ^ carry_bit_layer_adder[30][17]; // calculation of add result
assign carry_bit_layer_adder[30][18] = (layer_data_a[30][18] & layer_data_b[30][18]) | (layer_data_a[30][18] & carry_bit_layer_adder[30][17]) | (layer_data_b[30][18] & carry_bit_layer_adder[30][17]); // calculation of carry bit of adder
assign result_layer_adder[30][19] = layer_data_a[30][19] ^ layer_data_b[30][19] ^ carry_bit_layer_adder[30][18]; // calculation of add result
assign carry_bit_layer_adder[30][19] = (layer_data_a[30][19] & layer_data_b[30][19]) | (layer_data_a[30][19] & carry_bit_layer_adder[30][18]) | (layer_data_b[30][19] & carry_bit_layer_adder[30][18]); // calculation of carry bit of adder
assign result_layer_adder[30][20] = layer_data_a[30][20] ^ layer_data_b[30][20] ^ carry_bit_layer_adder[30][19]; // calculation of add result
assign carry_bit_layer_adder[30][20] = (layer_data_a[30][20] & layer_data_b[30][20]) | (layer_data_a[30][20] & carry_bit_layer_adder[30][19]) | (layer_data_b[30][20] & carry_bit_layer_adder[30][19]); // calculation of carry bit of adder
assign result_layer_adder[30][21] = layer_data_a[30][21] ^ layer_data_b[30][21] ^ carry_bit_layer_adder[30][20]; // calculation of add result
assign carry_bit_layer_adder[30][21] = (layer_data_a[30][21] & layer_data_b[30][21]) | (layer_data_a[30][21] & carry_bit_layer_adder[30][20]) | (layer_data_b[30][21] & carry_bit_layer_adder[30][20]); // calculation of carry bit of adder
assign result_layer_adder[30][22] = layer_data_a[30][22] ^ layer_data_b[30][22] ^ carry_bit_layer_adder[30][21]; // calculation of add result
assign carry_bit_layer_adder[30][22] = (layer_data_a[30][22] & layer_data_b[30][22]) | (layer_data_a[30][22] & carry_bit_layer_adder[30][21]) | (layer_data_b[30][22] & carry_bit_layer_adder[30][21]); // calculation of carry bit of adder
assign result_layer_adder[30][23] = layer_data_a[30][23] ^ layer_data_b[30][23] ^ carry_bit_layer_adder[30][22]; // calculation of add result
assign carry_bit_layer_adder[30][23] = (layer_data_a[30][23] & layer_data_b[30][23]) | (layer_data_a[30][23] & carry_bit_layer_adder[30][22]) | (layer_data_b[30][23] & carry_bit_layer_adder[30][22]); // calculation of carry bit of adder
assign result_layer_adder[30][24] = layer_data_a[30][24] ^ layer_data_b[30][24] ^ carry_bit_layer_adder[30][23]; // calculation of add result
assign carry_bit_layer_adder[30][24] = (layer_data_a[30][24] & layer_data_b[30][24]) | (layer_data_a[30][24] & carry_bit_layer_adder[30][23]) | (layer_data_b[30][24] & carry_bit_layer_adder[30][23]); // calculation of carry bit of adder
assign result_layer_adder[30][25] = layer_data_a[30][25] ^ layer_data_b[30][25] ^ carry_bit_layer_adder[30][24]; // calculation of add result
assign carry_bit_layer_adder[30][25] = (layer_data_a[30][25] & layer_data_b[30][25]) | (layer_data_a[30][25] & carry_bit_layer_adder[30][24]) | (layer_data_b[30][25] & carry_bit_layer_adder[30][24]); // calculation of carry bit of adder
assign result_layer_adder[30][26] = layer_data_a[30][26] ^ layer_data_b[30][26] ^ carry_bit_layer_adder[30][25]; // calculation of add result
assign carry_bit_layer_adder[30][26] = (layer_data_a[30][26] & layer_data_b[30][26]) | (layer_data_a[30][26] & carry_bit_layer_adder[30][25]) | (layer_data_b[30][26] & carry_bit_layer_adder[30][25]); // calculation of carry bit of adder
assign result_layer_adder[30][27] = layer_data_a[30][27] ^ layer_data_b[30][27] ^ carry_bit_layer_adder[30][26]; // calculation of add result
assign carry_bit_layer_adder[30][27] = (layer_data_a[30][27] & layer_data_b[30][27]) | (layer_data_a[30][27] & carry_bit_layer_adder[30][26]) | (layer_data_b[30][27] & carry_bit_layer_adder[30][26]); // calculation of carry bit of adder
assign result_layer_adder[30][28] = layer_data_a[30][28] ^ layer_data_b[30][28] ^ carry_bit_layer_adder[30][27]; // calculation of add result
assign carry_bit_layer_adder[30][28] = (layer_data_a[30][28] & layer_data_b[30][28]) | (layer_data_a[30][28] & carry_bit_layer_adder[30][27]) | (layer_data_b[30][28] & carry_bit_layer_adder[30][27]); // calculation of carry bit of adder
assign result_layer_adder[30][29] = layer_data_a[30][29] ^ layer_data_b[30][29] ^ carry_bit_layer_adder[30][28]; // calculation of add result
assign carry_bit_layer_adder[30][29] = (layer_data_a[30][29] & layer_data_b[30][29]) | (layer_data_a[30][29] & carry_bit_layer_adder[30][28]) | (layer_data_b[30][29] & carry_bit_layer_adder[30][28]); // calculation of carry bit of adder
assign result_layer_adder[30][30] = layer_data_a[30][30] ^ layer_data_b[30][30] ^ carry_bit_layer_adder[30][29]; // calculation of add result
assign carry_bit_layer_adder[30][30] = (layer_data_a[30][30] & layer_data_b[30][30]) | (layer_data_a[30][30] & carry_bit_layer_adder[30][29]) | (layer_data_b[30][30] & carry_bit_layer_adder[30][29]); // calculation of carry bit of adder
assign result_layer_adder[30][31] = layer_data_a[30][31] ^ layer_data_b[30][31] ^ carry_bit_layer_adder[30][30]; // calculation of add result
assign carry_bit_layer_adder[30][31] = (layer_data_a[30][31] & layer_data_b[30][31]) | (layer_data_a[30][31] & carry_bit_layer_adder[30][30]) | (layer_data_b[30][31] & carry_bit_layer_adder[30][30]); // calculation of carry bit of adder
assign result_layer_adder[30][32] = layer_data_a[30][32] ^ layer_data_b[30][32] ^ carry_bit_layer_adder[30][31]; // calculation of add result

// Layer 32
assign layer_data_a[31][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[30][32] == 1'b1) ? {layer_data_a[30][31:0], operand_a[1]} : {result_layer_adder[30][31:0], operand_a[1]}) : {1'b0, result_layer_adder[30][32:1]}; // data select for layer 32
assign layer_data_b[31][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[31] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 32

// Layer 32 adder
assign result_layer_adder[31][0] = layer_data_a[31][0] ^ layer_data_b[31][0]; // calculation of add result
assign carry_bit_layer_adder[31][0] = layer_data_a[31][0] & layer_data_b[31][0]; // calculation of carry bit of adder
assign result_layer_adder[31][1] = layer_data_a[31][1] ^ layer_data_b[31][1] ^ carry_bit_layer_adder[31][0]; // calculation of add result
assign carry_bit_layer_adder[31][1] = (layer_data_a[31][1] & layer_data_b[31][1]) | (layer_data_a[31][1] & carry_bit_layer_adder[31][0]) | (layer_data_b[31][1] & carry_bit_layer_adder[31][0]); // calculation of carry bit of adder
assign result_layer_adder[31][2] = layer_data_a[31][2] ^ layer_data_b[31][2] ^ carry_bit_layer_adder[31][1]; // calculation of add result
assign carry_bit_layer_adder[31][2] = (layer_data_a[31][2] & layer_data_b[31][2]) | (layer_data_a[31][2] & carry_bit_layer_adder[31][1]) | (layer_data_b[31][2] & carry_bit_layer_adder[31][1]); // calculation of carry bit of adder
assign result_layer_adder[31][3] = layer_data_a[31][3] ^ layer_data_b[31][3] ^ carry_bit_layer_adder[31][2]; // calculation of add result
assign carry_bit_layer_adder[31][3] = (layer_data_a[31][3] & layer_data_b[31][3]) | (layer_data_a[31][3] & carry_bit_layer_adder[31][2]) | (layer_data_b[31][3] & carry_bit_layer_adder[31][2]); // calculation of carry bit of adder
assign result_layer_adder[31][4] = layer_data_a[31][4] ^ layer_data_b[31][4] ^ carry_bit_layer_adder[31][3]; // calculation of add result
assign carry_bit_layer_adder[31][4] = (layer_data_a[31][4] & layer_data_b[31][4]) | (layer_data_a[31][4] & carry_bit_layer_adder[31][3]) | (layer_data_b[31][4] & carry_bit_layer_adder[31][3]); // calculation of carry bit of adder
assign result_layer_adder[31][5] = layer_data_a[31][5] ^ layer_data_b[31][5] ^ carry_bit_layer_adder[31][4]; // calculation of add result
assign carry_bit_layer_adder[31][5] = (layer_data_a[31][5] & layer_data_b[31][5]) | (layer_data_a[31][5] & carry_bit_layer_adder[31][4]) | (layer_data_b[31][5] & carry_bit_layer_adder[31][4]); // calculation of carry bit of adder
assign result_layer_adder[31][6] = layer_data_a[31][6] ^ layer_data_b[31][6] ^ carry_bit_layer_adder[31][5]; // calculation of add result
assign carry_bit_layer_adder[31][6] = (layer_data_a[31][6] & layer_data_b[31][6]) | (layer_data_a[31][6] & carry_bit_layer_adder[31][5]) | (layer_data_b[31][6] & carry_bit_layer_adder[31][5]); // calculation of carry bit of adder
assign result_layer_adder[31][7] = layer_data_a[31][7] ^ layer_data_b[31][7] ^ carry_bit_layer_adder[31][6]; // calculation of add result
assign carry_bit_layer_adder[31][7] = (layer_data_a[31][7] & layer_data_b[31][7]) | (layer_data_a[31][7] & carry_bit_layer_adder[31][6]) | (layer_data_b[31][7] & carry_bit_layer_adder[31][6]); // calculation of carry bit of adder
assign result_layer_adder[31][8] = layer_data_a[31][8] ^ layer_data_b[31][8] ^ carry_bit_layer_adder[31][7]; // calculation of add result
assign carry_bit_layer_adder[31][8] = (layer_data_a[31][8] & layer_data_b[31][8]) | (layer_data_a[31][8] & carry_bit_layer_adder[31][7]) | (layer_data_b[31][8] & carry_bit_layer_adder[31][7]); // calculation of carry bit of adder
assign result_layer_adder[31][9] = layer_data_a[31][9] ^ layer_data_b[31][9] ^ carry_bit_layer_adder[31][8]; // calculation of add result
assign carry_bit_layer_adder[31][9] = (layer_data_a[31][9] & layer_data_b[31][9]) | (layer_data_a[31][9] & carry_bit_layer_adder[31][8]) | (layer_data_b[31][9] & carry_bit_layer_adder[31][8]); // calculation of carry bit of adder
assign result_layer_adder[31][10] = layer_data_a[31][10] ^ layer_data_b[31][10] ^ carry_bit_layer_adder[31][9]; // calculation of add result
assign carry_bit_layer_adder[31][10] = (layer_data_a[31][10] & layer_data_b[31][10]) | (layer_data_a[31][10] & carry_bit_layer_adder[31][9]) | (layer_data_b[31][10] & carry_bit_layer_adder[31][9]); // calculation of carry bit of adder
assign result_layer_adder[31][11] = layer_data_a[31][11] ^ layer_data_b[31][11] ^ carry_bit_layer_adder[31][10]; // calculation of add result
assign carry_bit_layer_adder[31][11] = (layer_data_a[31][11] & layer_data_b[31][11]) | (layer_data_a[31][11] & carry_bit_layer_adder[31][10]) | (layer_data_b[31][11] & carry_bit_layer_adder[31][10]); // calculation of carry bit of adder
assign result_layer_adder[31][12] = layer_data_a[31][12] ^ layer_data_b[31][12] ^ carry_bit_layer_adder[31][11]; // calculation of add result
assign carry_bit_layer_adder[31][12] = (layer_data_a[31][12] & layer_data_b[31][12]) | (layer_data_a[31][12] & carry_bit_layer_adder[31][11]) | (layer_data_b[31][12] & carry_bit_layer_adder[31][11]); // calculation of carry bit of adder
assign result_layer_adder[31][13] = layer_data_a[31][13] ^ layer_data_b[31][13] ^ carry_bit_layer_adder[31][12]; // calculation of add result
assign carry_bit_layer_adder[31][13] = (layer_data_a[31][13] & layer_data_b[31][13]) | (layer_data_a[31][13] & carry_bit_layer_adder[31][12]) | (layer_data_b[31][13] & carry_bit_layer_adder[31][12]); // calculation of carry bit of adder
assign result_layer_adder[31][14] = layer_data_a[31][14] ^ layer_data_b[31][14] ^ carry_bit_layer_adder[31][13]; // calculation of add result
assign carry_bit_layer_adder[31][14] = (layer_data_a[31][14] & layer_data_b[31][14]) | (layer_data_a[31][14] & carry_bit_layer_adder[31][13]) | (layer_data_b[31][14] & carry_bit_layer_adder[31][13]); // calculation of carry bit of adder
assign result_layer_adder[31][15] = layer_data_a[31][15] ^ layer_data_b[31][15] ^ carry_bit_layer_adder[31][14]; // calculation of add result
assign carry_bit_layer_adder[31][15] = (layer_data_a[31][15] & layer_data_b[31][15]) | (layer_data_a[31][15] & carry_bit_layer_adder[31][14]) | (layer_data_b[31][15] & carry_bit_layer_adder[31][14]); // calculation of carry bit of adder
assign result_layer_adder[31][16] = layer_data_a[31][16] ^ layer_data_b[31][16] ^ carry_bit_layer_adder[31][15]; // calculation of add result
assign carry_bit_layer_adder[31][16] = (layer_data_a[31][16] & layer_data_b[31][16]) | (layer_data_a[31][16] & carry_bit_layer_adder[31][15]) | (layer_data_b[31][16] & carry_bit_layer_adder[31][15]); // calculation of carry bit of adder
assign result_layer_adder[31][17] = layer_data_a[31][17] ^ layer_data_b[31][17] ^ carry_bit_layer_adder[31][16]; // calculation of add result
assign carry_bit_layer_adder[31][17] = (layer_data_a[31][17] & layer_data_b[31][17]) | (layer_data_a[31][17] & carry_bit_layer_adder[31][16]) | (layer_data_b[31][17] & carry_bit_layer_adder[31][16]); // calculation of carry bit of adder
assign result_layer_adder[31][18] = layer_data_a[31][18] ^ layer_data_b[31][18] ^ carry_bit_layer_adder[31][17]; // calculation of add result
assign carry_bit_layer_adder[31][18] = (layer_data_a[31][18] & layer_data_b[31][18]) | (layer_data_a[31][18] & carry_bit_layer_adder[31][17]) | (layer_data_b[31][18] & carry_bit_layer_adder[31][17]); // calculation of carry bit of adder
assign result_layer_adder[31][19] = layer_data_a[31][19] ^ layer_data_b[31][19] ^ carry_bit_layer_adder[31][18]; // calculation of add result
assign carry_bit_layer_adder[31][19] = (layer_data_a[31][19] & layer_data_b[31][19]) | (layer_data_a[31][19] & carry_bit_layer_adder[31][18]) | (layer_data_b[31][19] & carry_bit_layer_adder[31][18]); // calculation of carry bit of adder
assign result_layer_adder[31][20] = layer_data_a[31][20] ^ layer_data_b[31][20] ^ carry_bit_layer_adder[31][19]; // calculation of add result
assign carry_bit_layer_adder[31][20] = (layer_data_a[31][20] & layer_data_b[31][20]) | (layer_data_a[31][20] & carry_bit_layer_adder[31][19]) | (layer_data_b[31][20] & carry_bit_layer_adder[31][19]); // calculation of carry bit of adder
assign result_layer_adder[31][21] = layer_data_a[31][21] ^ layer_data_b[31][21] ^ carry_bit_layer_adder[31][20]; // calculation of add result
assign carry_bit_layer_adder[31][21] = (layer_data_a[31][21] & layer_data_b[31][21]) | (layer_data_a[31][21] & carry_bit_layer_adder[31][20]) | (layer_data_b[31][21] & carry_bit_layer_adder[31][20]); // calculation of carry bit of adder
assign result_layer_adder[31][22] = layer_data_a[31][22] ^ layer_data_b[31][22] ^ carry_bit_layer_adder[31][21]; // calculation of add result
assign carry_bit_layer_adder[31][22] = (layer_data_a[31][22] & layer_data_b[31][22]) | (layer_data_a[31][22] & carry_bit_layer_adder[31][21]) | (layer_data_b[31][22] & carry_bit_layer_adder[31][21]); // calculation of carry bit of adder
assign result_layer_adder[31][23] = layer_data_a[31][23] ^ layer_data_b[31][23] ^ carry_bit_layer_adder[31][22]; // calculation of add result
assign carry_bit_layer_adder[31][23] = (layer_data_a[31][23] & layer_data_b[31][23]) | (layer_data_a[31][23] & carry_bit_layer_adder[31][22]) | (layer_data_b[31][23] & carry_bit_layer_adder[31][22]); // calculation of carry bit of adder
assign result_layer_adder[31][24] = layer_data_a[31][24] ^ layer_data_b[31][24] ^ carry_bit_layer_adder[31][23]; // calculation of add result
assign carry_bit_layer_adder[31][24] = (layer_data_a[31][24] & layer_data_b[31][24]) | (layer_data_a[31][24] & carry_bit_layer_adder[31][23]) | (layer_data_b[31][24] & carry_bit_layer_adder[31][23]); // calculation of carry bit of adder
assign result_layer_adder[31][25] = layer_data_a[31][25] ^ layer_data_b[31][25] ^ carry_bit_layer_adder[31][24]; // calculation of add result
assign carry_bit_layer_adder[31][25] = (layer_data_a[31][25] & layer_data_b[31][25]) | (layer_data_a[31][25] & carry_bit_layer_adder[31][24]) | (layer_data_b[31][25] & carry_bit_layer_adder[31][24]); // calculation of carry bit of adder
assign result_layer_adder[31][26] = layer_data_a[31][26] ^ layer_data_b[31][26] ^ carry_bit_layer_adder[31][25]; // calculation of add result
assign carry_bit_layer_adder[31][26] = (layer_data_a[31][26] & layer_data_b[31][26]) | (layer_data_a[31][26] & carry_bit_layer_adder[31][25]) | (layer_data_b[31][26] & carry_bit_layer_adder[31][25]); // calculation of carry bit of adder
assign result_layer_adder[31][27] = layer_data_a[31][27] ^ layer_data_b[31][27] ^ carry_bit_layer_adder[31][26]; // calculation of add result
assign carry_bit_layer_adder[31][27] = (layer_data_a[31][27] & layer_data_b[31][27]) | (layer_data_a[31][27] & carry_bit_layer_adder[31][26]) | (layer_data_b[31][27] & carry_bit_layer_adder[31][26]); // calculation of carry bit of adder
assign result_layer_adder[31][28] = layer_data_a[31][28] ^ layer_data_b[31][28] ^ carry_bit_layer_adder[31][27]; // calculation of add result
assign carry_bit_layer_adder[31][28] = (layer_data_a[31][28] & layer_data_b[31][28]) | (layer_data_a[31][28] & carry_bit_layer_adder[31][27]) | (layer_data_b[31][28] & carry_bit_layer_adder[31][27]); // calculation of carry bit of adder
assign result_layer_adder[31][29] = layer_data_a[31][29] ^ layer_data_b[31][29] ^ carry_bit_layer_adder[31][28]; // calculation of add result
assign carry_bit_layer_adder[31][29] = (layer_data_a[31][29] & layer_data_b[31][29]) | (layer_data_a[31][29] & carry_bit_layer_adder[31][28]) | (layer_data_b[31][29] & carry_bit_layer_adder[31][28]); // calculation of carry bit of adder
assign result_layer_adder[31][30] = layer_data_a[31][30] ^ layer_data_b[31][30] ^ carry_bit_layer_adder[31][29]; // calculation of add result
assign carry_bit_layer_adder[31][30] = (layer_data_a[31][30] & layer_data_b[31][30]) | (layer_data_a[31][30] & carry_bit_layer_adder[31][29]) | (layer_data_b[31][30] & carry_bit_layer_adder[31][29]); // calculation of carry bit of adder
assign result_layer_adder[31][31] = layer_data_a[31][31] ^ layer_data_b[31][31] ^ carry_bit_layer_adder[31][30]; // calculation of add result
assign carry_bit_layer_adder[31][31] = (layer_data_a[31][31] & layer_data_b[31][31]) | (layer_data_a[31][31] & carry_bit_layer_adder[31][30]) | (layer_data_b[31][31] & carry_bit_layer_adder[31][30]); // calculation of carry bit of adder
assign result_layer_adder[31][32] = layer_data_a[31][32] ^ layer_data_b[31][32] ^ carry_bit_layer_adder[31][31]; // calculation of add result

// Layer 33
assign layer_data_a[32][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[31][32] == 1'b1) ? {layer_data_a[31][31:0], operand_a[0]} : {result_layer_adder[31][31:0], operand_a[0]}) : {1'b0, result_layer_adder[31][32:1]}; // data select for layer 33
assign layer_data_b[32][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[32] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 33

// Layer 33 adder
assign result_layer_adder[32][0] = layer_data_a[32][0] ^ layer_data_b[32][0]; // calculation of add result
assign carry_bit_layer_adder[32][0] = layer_data_a[32][0] & layer_data_b[32][0]; // calculation of carry bit of adder
assign result_layer_adder[32][1] = layer_data_a[32][1] ^ layer_data_b[32][1] ^ carry_bit_layer_adder[32][0]; // calculation of add result
assign carry_bit_layer_adder[32][1] = (layer_data_a[32][1] & layer_data_b[32][1]) | (layer_data_a[32][1] & carry_bit_layer_adder[32][0]) | (layer_data_b[32][1] & carry_bit_layer_adder[32][0]); // calculation of carry bit of adder
assign result_layer_adder[32][2] = layer_data_a[32][2] ^ layer_data_b[32][2] ^ carry_bit_layer_adder[32][1]; // calculation of add result
assign carry_bit_layer_adder[32][2] = (layer_data_a[32][2] & layer_data_b[32][2]) | (layer_data_a[32][2] & carry_bit_layer_adder[32][1]) | (layer_data_b[32][2] & carry_bit_layer_adder[32][1]); // calculation of carry bit of adder
assign result_layer_adder[32][3] = layer_data_a[32][3] ^ layer_data_b[32][3] ^ carry_bit_layer_adder[32][2]; // calculation of add result
assign carry_bit_layer_adder[32][3] = (layer_data_a[32][3] & layer_data_b[32][3]) | (layer_data_a[32][3] & carry_bit_layer_adder[32][2]) | (layer_data_b[32][3] & carry_bit_layer_adder[32][2]); // calculation of carry bit of adder
assign result_layer_adder[32][4] = layer_data_a[32][4] ^ layer_data_b[32][4] ^ carry_bit_layer_adder[32][3]; // calculation of add result
assign carry_bit_layer_adder[32][4] = (layer_data_a[32][4] & layer_data_b[32][4]) | (layer_data_a[32][4] & carry_bit_layer_adder[32][3]) | (layer_data_b[32][4] & carry_bit_layer_adder[32][3]); // calculation of carry bit of adder
assign result_layer_adder[32][5] = layer_data_a[32][5] ^ layer_data_b[32][5] ^ carry_bit_layer_adder[32][4]; // calculation of add result
assign carry_bit_layer_adder[32][5] = (layer_data_a[32][5] & layer_data_b[32][5]) | (layer_data_a[32][5] & carry_bit_layer_adder[32][4]) | (layer_data_b[32][5] & carry_bit_layer_adder[32][4]); // calculation of carry bit of adder
assign result_layer_adder[32][6] = layer_data_a[32][6] ^ layer_data_b[32][6] ^ carry_bit_layer_adder[32][5]; // calculation of add result
assign carry_bit_layer_adder[32][6] = (layer_data_a[32][6] & layer_data_b[32][6]) | (layer_data_a[32][6] & carry_bit_layer_adder[32][5]) | (layer_data_b[32][6] & carry_bit_layer_adder[32][5]); // calculation of carry bit of adder
assign result_layer_adder[32][7] = layer_data_a[32][7] ^ layer_data_b[32][7] ^ carry_bit_layer_adder[32][6]; // calculation of add result
assign carry_bit_layer_adder[32][7] = (layer_data_a[32][7] & layer_data_b[32][7]) | (layer_data_a[32][7] & carry_bit_layer_adder[32][6]) | (layer_data_b[32][7] & carry_bit_layer_adder[32][6]); // calculation of carry bit of adder
assign result_layer_adder[32][8] = layer_data_a[32][8] ^ layer_data_b[32][8] ^ carry_bit_layer_adder[32][7]; // calculation of add result
assign carry_bit_layer_adder[32][8] = (layer_data_a[32][8] & layer_data_b[32][8]) | (layer_data_a[32][8] & carry_bit_layer_adder[32][7]) | (layer_data_b[32][8] & carry_bit_layer_adder[32][7]); // calculation of carry bit of adder
assign result_layer_adder[32][9] = layer_data_a[32][9] ^ layer_data_b[32][9] ^ carry_bit_layer_adder[32][8]; // calculation of add result
assign carry_bit_layer_adder[32][9] = (layer_data_a[32][9] & layer_data_b[32][9]) | (layer_data_a[32][9] & carry_bit_layer_adder[32][8]) | (layer_data_b[32][9] & carry_bit_layer_adder[32][8]); // calculation of carry bit of adder
assign result_layer_adder[32][10] = layer_data_a[32][10] ^ layer_data_b[32][10] ^ carry_bit_layer_adder[32][9]; // calculation of add result
assign carry_bit_layer_adder[32][10] = (layer_data_a[32][10] & layer_data_b[32][10]) | (layer_data_a[32][10] & carry_bit_layer_adder[32][9]) | (layer_data_b[32][10] & carry_bit_layer_adder[32][9]); // calculation of carry bit of adder
assign result_layer_adder[32][11] = layer_data_a[32][11] ^ layer_data_b[32][11] ^ carry_bit_layer_adder[32][10]; // calculation of add result
assign carry_bit_layer_adder[32][11] = (layer_data_a[32][11] & layer_data_b[32][11]) | (layer_data_a[32][11] & carry_bit_layer_adder[32][10]) | (layer_data_b[32][11] & carry_bit_layer_adder[32][10]); // calculation of carry bit of adder
assign result_layer_adder[32][12] = layer_data_a[32][12] ^ layer_data_b[32][12] ^ carry_bit_layer_adder[32][11]; // calculation of add result
assign carry_bit_layer_adder[32][12] = (layer_data_a[32][12] & layer_data_b[32][12]) | (layer_data_a[32][12] & carry_bit_layer_adder[32][11]) | (layer_data_b[32][12] & carry_bit_layer_adder[32][11]); // calculation of carry bit of adder
assign result_layer_adder[32][13] = layer_data_a[32][13] ^ layer_data_b[32][13] ^ carry_bit_layer_adder[32][12]; // calculation of add result
assign carry_bit_layer_adder[32][13] = (layer_data_a[32][13] & layer_data_b[32][13]) | (layer_data_a[32][13] & carry_bit_layer_adder[32][12]) | (layer_data_b[32][13] & carry_bit_layer_adder[32][12]); // calculation of carry bit of adder
assign result_layer_adder[32][14] = layer_data_a[32][14] ^ layer_data_b[32][14] ^ carry_bit_layer_adder[32][13]; // calculation of add result
assign carry_bit_layer_adder[32][14] = (layer_data_a[32][14] & layer_data_b[32][14]) | (layer_data_a[32][14] & carry_bit_layer_adder[32][13]) | (layer_data_b[32][14] & carry_bit_layer_adder[32][13]); // calculation of carry bit of adder
assign result_layer_adder[32][15] = layer_data_a[32][15] ^ layer_data_b[32][15] ^ carry_bit_layer_adder[32][14]; // calculation of add result
assign carry_bit_layer_adder[32][15] = (layer_data_a[32][15] & layer_data_b[32][15]) | (layer_data_a[32][15] & carry_bit_layer_adder[32][14]) | (layer_data_b[32][15] & carry_bit_layer_adder[32][14]); // calculation of carry bit of adder
assign result_layer_adder[32][16] = layer_data_a[32][16] ^ layer_data_b[32][16] ^ carry_bit_layer_adder[32][15]; // calculation of add result
assign carry_bit_layer_adder[32][16] = (layer_data_a[32][16] & layer_data_b[32][16]) | (layer_data_a[32][16] & carry_bit_layer_adder[32][15]) | (layer_data_b[32][16] & carry_bit_layer_adder[32][15]); // calculation of carry bit of adder
assign result_layer_adder[32][17] = layer_data_a[32][17] ^ layer_data_b[32][17] ^ carry_bit_layer_adder[32][16]; // calculation of add result
assign carry_bit_layer_adder[32][17] = (layer_data_a[32][17] & layer_data_b[32][17]) | (layer_data_a[32][17] & carry_bit_layer_adder[32][16]) | (layer_data_b[32][17] & carry_bit_layer_adder[32][16]); // calculation of carry bit of adder
assign result_layer_adder[32][18] = layer_data_a[32][18] ^ layer_data_b[32][18] ^ carry_bit_layer_adder[32][17]; // calculation of add result
assign carry_bit_layer_adder[32][18] = (layer_data_a[32][18] & layer_data_b[32][18]) | (layer_data_a[32][18] & carry_bit_layer_adder[32][17]) | (layer_data_b[32][18] & carry_bit_layer_adder[32][17]); // calculation of carry bit of adder
assign result_layer_adder[32][19] = layer_data_a[32][19] ^ layer_data_b[32][19] ^ carry_bit_layer_adder[32][18]; // calculation of add result
assign carry_bit_layer_adder[32][19] = (layer_data_a[32][19] & layer_data_b[32][19]) | (layer_data_a[32][19] & carry_bit_layer_adder[32][18]) | (layer_data_b[32][19] & carry_bit_layer_adder[32][18]); // calculation of carry bit of adder
assign result_layer_adder[32][20] = layer_data_a[32][20] ^ layer_data_b[32][20] ^ carry_bit_layer_adder[32][19]; // calculation of add result
assign carry_bit_layer_adder[32][20] = (layer_data_a[32][20] & layer_data_b[32][20]) | (layer_data_a[32][20] & carry_bit_layer_adder[32][19]) | (layer_data_b[32][20] & carry_bit_layer_adder[32][19]); // calculation of carry bit of adder
assign result_layer_adder[32][21] = layer_data_a[32][21] ^ layer_data_b[32][21] ^ carry_bit_layer_adder[32][20]; // calculation of add result
assign carry_bit_layer_adder[32][21] = (layer_data_a[32][21] & layer_data_b[32][21]) | (layer_data_a[32][21] & carry_bit_layer_adder[32][20]) | (layer_data_b[32][21] & carry_bit_layer_adder[32][20]); // calculation of carry bit of adder
assign result_layer_adder[32][22] = layer_data_a[32][22] ^ layer_data_b[32][22] ^ carry_bit_layer_adder[32][21]; // calculation of add result
assign carry_bit_layer_adder[32][22] = (layer_data_a[32][22] & layer_data_b[32][22]) | (layer_data_a[32][22] & carry_bit_layer_adder[32][21]) | (layer_data_b[32][22] & carry_bit_layer_adder[32][21]); // calculation of carry bit of adder
assign result_layer_adder[32][23] = layer_data_a[32][23] ^ layer_data_b[32][23] ^ carry_bit_layer_adder[32][22]; // calculation of add result
assign carry_bit_layer_adder[32][23] = (layer_data_a[32][23] & layer_data_b[32][23]) | (layer_data_a[32][23] & carry_bit_layer_adder[32][22]) | (layer_data_b[32][23] & carry_bit_layer_adder[32][22]); // calculation of carry bit of adder
assign result_layer_adder[32][24] = layer_data_a[32][24] ^ layer_data_b[32][24] ^ carry_bit_layer_adder[32][23]; // calculation of add result
assign carry_bit_layer_adder[32][24] = (layer_data_a[32][24] & layer_data_b[32][24]) | (layer_data_a[32][24] & carry_bit_layer_adder[32][23]) | (layer_data_b[32][24] & carry_bit_layer_adder[32][23]); // calculation of carry bit of adder
assign result_layer_adder[32][25] = layer_data_a[32][25] ^ layer_data_b[32][25] ^ carry_bit_layer_adder[32][24]; // calculation of add result
assign carry_bit_layer_adder[32][25] = (layer_data_a[32][25] & layer_data_b[32][25]) | (layer_data_a[32][25] & carry_bit_layer_adder[32][24]) | (layer_data_b[32][25] & carry_bit_layer_adder[32][24]); // calculation of carry bit of adder
assign result_layer_adder[32][26] = layer_data_a[32][26] ^ layer_data_b[32][26] ^ carry_bit_layer_adder[32][25]; // calculation of add result
assign carry_bit_layer_adder[32][26] = (layer_data_a[32][26] & layer_data_b[32][26]) | (layer_data_a[32][26] & carry_bit_layer_adder[32][25]) | (layer_data_b[32][26] & carry_bit_layer_adder[32][25]); // calculation of carry bit of adder
assign result_layer_adder[32][27] = layer_data_a[32][27] ^ layer_data_b[32][27] ^ carry_bit_layer_adder[32][26]; // calculation of add result
assign carry_bit_layer_adder[32][27] = (layer_data_a[32][27] & layer_data_b[32][27]) | (layer_data_a[32][27] & carry_bit_layer_adder[32][26]) | (layer_data_b[32][27] & carry_bit_layer_adder[32][26]); // calculation of carry bit of adder
assign result_layer_adder[32][28] = layer_data_a[32][28] ^ layer_data_b[32][28] ^ carry_bit_layer_adder[32][27]; // calculation of add result
assign carry_bit_layer_adder[32][28] = (layer_data_a[32][28] & layer_data_b[32][28]) | (layer_data_a[32][28] & carry_bit_layer_adder[32][27]) | (layer_data_b[32][28] & carry_bit_layer_adder[32][27]); // calculation of carry bit of adder
assign result_layer_adder[32][29] = layer_data_a[32][29] ^ layer_data_b[32][29] ^ carry_bit_layer_adder[32][28]; // calculation of add result
assign carry_bit_layer_adder[32][29] = (layer_data_a[32][29] & layer_data_b[32][29]) | (layer_data_a[32][29] & carry_bit_layer_adder[32][28]) | (layer_data_b[32][29] & carry_bit_layer_adder[32][28]); // calculation of carry bit of adder
assign result_layer_adder[32][30] = layer_data_a[32][30] ^ layer_data_b[32][30] ^ carry_bit_layer_adder[32][29]; // calculation of add result
assign carry_bit_layer_adder[32][30] = (layer_data_a[32][30] & layer_data_b[32][30]) | (layer_data_a[32][30] & carry_bit_layer_adder[32][29]) | (layer_data_b[32][30] & carry_bit_layer_adder[32][29]); // calculation of carry bit of adder
assign result_layer_adder[32][31] = layer_data_a[32][31] ^ layer_data_b[32][31] ^ carry_bit_layer_adder[32][30]; // calculation of add result
assign carry_bit_layer_adder[32][31] = (layer_data_a[32][31] & layer_data_b[32][31]) | (layer_data_a[32][31] & carry_bit_layer_adder[32][30]) | (layer_data_b[32][31] & carry_bit_layer_adder[32][30]); // calculation of carry bit of adder
assign result_layer_adder[32][32] = layer_data_a[32][32] ^ layer_data_b[32][32] ^ carry_bit_layer_adder[32][31]; // calculation of add result

// result of operation
assign result_MUL[31:0] = {result_layer_adder[31][0], result_layer_adder[30][0], result_layer_adder[29][0], result_layer_adder[28][0], result_layer_adder[27][0], result_layer_adder[26][0], result_layer_adder[25][0], result_layer_adder[24][0], result_layer_adder[23][0], result_layer_adder[22][0], result_layer_adder[21][0], result_layer_adder[20][0], result_layer_adder[19][0], result_layer_adder[18][0], result_layer_adder[17][0], result_layer_adder[16][0], result_layer_adder[15][0], result_layer_adder[14][0], result_layer_adder[13][0], result_layer_adder[12][0], result_layer_adder[11][0], result_layer_adder[10][0], result_layer_adder[9][0], result_layer_adder[8][0], result_layer_adder[7][0], result_layer_adder[6][0], result_layer_adder[5][0], result_layer_adder[4][0], result_layer_adder[3][0], result_layer_adder[2][0], result_layer_adder[1][0], result_layer_adder[0][0]}; // MUL result
assign result_MULH[31:0] = result_layer_adder[32][31:0]; // MULH result
assign result_DIV[31:0] = ~{result_layer_adder[1][32], result_layer_adder[2][32], result_layer_adder[3][32], result_layer_adder[4][32], result_layer_adder[5][32], result_layer_adder[6][32], result_layer_adder[7][32], result_layer_adder[8][32], result_layer_adder[9][32], result_layer_adder[10][32], result_layer_adder[11][32], result_layer_adder[12][32], result_layer_adder[13][32], result_layer_adder[14][32], result_layer_adder[15][32], result_layer_adder[16][32], result_layer_adder[17][32], result_layer_adder[18][32], result_layer_adder[19][32], result_layer_adder[20][32], result_layer_adder[21][32], result_layer_adder[22][32], result_layer_adder[23][32], result_layer_adder[24][32], result_layer_adder[25][32], result_layer_adder[26][32], result_layer_adder[27][32], result_layer_adder[28][32], result_layer_adder[29][32], result_layer_adder[30][32], result_layer_adder[31][32], result_layer_adder[32][32]}; // quotient
assign result_REM[31:0] = (result_layer_adder[32][32] == 1'b1) ? layer_data_a[32][31:0] : result_layer_adder[32][31:0]; // remainder

// output result control
assign result_ctrl[0] = &ip_funct_3[2:1]; // output quotient or remainder of division result
assign result_ctrl[1] = ip_funct_3[2]; // output multiplication result or division result

// result selection
assign result[31:0] = (result_ctrl[1] == 1'b1) ? ((result_ctrl[0] == 1'b1) ? result_REM[31:0] : result_DIV[31:0]) : result_MUL[31:0]; // select the result
assign result[63:32] = result_MULH[31:0];

// convert result from negative to positive
assign invert_result[63:0] = ~result[63:0];
assign carry_bit_convert_result_adder[0] = 1'b1;
assign result_convert_result_adder[0] = invert_result[0] ^ carry_bit_convert_result_adder[0]; // calculation of add result
assign carry_bit_convert_result_adder[1] = invert_result[0] & carry_bit_convert_result_adder[0]; // calculation of carry bit of adder
assign result_convert_result_adder[1] = invert_result[1] ^ carry_bit_convert_result_adder[1]; // calculation of add result
assign carry_bit_convert_result_adder[2] = invert_result[1] & carry_bit_convert_result_adder[1]; // calculation of carry bit of adder
assign result_convert_result_adder[2] = invert_result[2] ^ carry_bit_convert_result_adder[2]; // calculation of add result
assign carry_bit_convert_result_adder[3] = invert_result[2] & carry_bit_convert_result_adder[2]; // calculation of carry bit of adder
assign result_convert_result_adder[3] = invert_result[3] ^ carry_bit_convert_result_adder[3]; // calculation of add result
assign carry_bit_convert_result_adder[4] = invert_result[3] & carry_bit_convert_result_adder[3]; // calculation of carry bit of adder
assign result_convert_result_adder[4] = invert_result[4] ^ carry_bit_convert_result_adder[4]; // calculation of add result
assign carry_bit_convert_result_adder[5] = invert_result[4] & carry_bit_convert_result_adder[4]; // calculation of carry bit of adder
assign result_convert_result_adder[5] = invert_result[5] ^ carry_bit_convert_result_adder[5]; // calculation of add result
assign carry_bit_convert_result_adder[6] = invert_result[5] & carry_bit_convert_result_adder[5]; // calculation of carry bit of adder
assign result_convert_result_adder[6] = invert_result[6] ^ carry_bit_convert_result_adder[6]; // calculation of add result
assign carry_bit_convert_result_adder[7] = invert_result[6] & carry_bit_convert_result_adder[6]; // calculation of carry bit of adder
assign result_convert_result_adder[7] = invert_result[7] ^ carry_bit_convert_result_adder[7]; // calculation of add result
assign carry_bit_convert_result_adder[8] = invert_result[7] & carry_bit_convert_result_adder[7]; // calculation of carry bit of adder
assign result_convert_result_adder[8] = invert_result[8] ^ carry_bit_convert_result_adder[8]; // calculation of add result
assign carry_bit_convert_result_adder[9] = invert_result[8] & carry_bit_convert_result_adder[8]; // calculation of carry bit of adder
assign result_convert_result_adder[9] = invert_result[9] ^ carry_bit_convert_result_adder[9]; // calculation of add result
assign carry_bit_convert_result_adder[10] = invert_result[9] & carry_bit_convert_result_adder[9]; // calculation of carry bit of adder
assign result_convert_result_adder[10] = invert_result[10] ^ carry_bit_convert_result_adder[10]; // calculation of add result
assign carry_bit_convert_result_adder[11] = invert_result[10] & carry_bit_convert_result_adder[10]; // calculation of carry bit of adder
assign result_convert_result_adder[11] = invert_result[11] ^ carry_bit_convert_result_adder[11]; // calculation of add result
assign carry_bit_convert_result_adder[12] = invert_result[11] & carry_bit_convert_result_adder[11]; // calculation of carry bit of adder
assign result_convert_result_adder[12] = invert_result[12] ^ carry_bit_convert_result_adder[12]; // calculation of add result
assign carry_bit_convert_result_adder[13] = invert_result[12] & carry_bit_convert_result_adder[12]; // calculation of carry bit of adder
assign result_convert_result_adder[13] = invert_result[13] ^ carry_bit_convert_result_adder[13]; // calculation of add result
assign carry_bit_convert_result_adder[14] = invert_result[13] & carry_bit_convert_result_adder[13]; // calculation of carry bit of adder
assign result_convert_result_adder[14] = invert_result[14] ^ carry_bit_convert_result_adder[14]; // calculation of add result
assign carry_bit_convert_result_adder[15] = invert_result[14] & carry_bit_convert_result_adder[14]; // calculation of carry bit of adder
assign result_convert_result_adder[15] = invert_result[15] ^ carry_bit_convert_result_adder[15]; // calculation of add result
assign carry_bit_convert_result_adder[16] = invert_result[15] & carry_bit_convert_result_adder[15]; // calculation of carry bit of adder
assign result_convert_result_adder[16] = invert_result[16] ^ carry_bit_convert_result_adder[16]; // calculation of add result
assign carry_bit_convert_result_adder[17] = invert_result[16] & carry_bit_convert_result_adder[16]; // calculation of carry bit of adder
assign result_convert_result_adder[17] = invert_result[17] ^ carry_bit_convert_result_adder[17]; // calculation of add result
assign carry_bit_convert_result_adder[18] = invert_result[17] & carry_bit_convert_result_adder[17]; // calculation of carry bit of adder
assign result_convert_result_adder[18] = invert_result[18] ^ carry_bit_convert_result_adder[18]; // calculation of add result
assign carry_bit_convert_result_adder[19] = invert_result[18] & carry_bit_convert_result_adder[18]; // calculation of carry bit of adder
assign result_convert_result_adder[19] = invert_result[19] ^ carry_bit_convert_result_adder[19]; // calculation of add result
assign carry_bit_convert_result_adder[20] = invert_result[19] & carry_bit_convert_result_adder[19]; // calculation of carry bit of adder
assign result_convert_result_adder[20] = invert_result[20] ^ carry_bit_convert_result_adder[20]; // calculation of add result
assign carry_bit_convert_result_adder[21] = invert_result[20] & carry_bit_convert_result_adder[20]; // calculation of carry bit of adder
assign result_convert_result_adder[21] = invert_result[21] ^ carry_bit_convert_result_adder[21]; // calculation of add result
assign carry_bit_convert_result_adder[22] = invert_result[21] & carry_bit_convert_result_adder[21]; // calculation of carry bit of adder
assign result_convert_result_adder[22] = invert_result[22] ^ carry_bit_convert_result_adder[22]; // calculation of add result
assign carry_bit_convert_result_adder[23] = invert_result[22] & carry_bit_convert_result_adder[22]; // calculation of carry bit of adder
assign result_convert_result_adder[23] = invert_result[23] ^ carry_bit_convert_result_adder[23]; // calculation of add result
assign carry_bit_convert_result_adder[24] = invert_result[23] & carry_bit_convert_result_adder[23]; // calculation of carry bit of adder
assign result_convert_result_adder[24] = invert_result[24] ^ carry_bit_convert_result_adder[24]; // calculation of add result
assign carry_bit_convert_result_adder[25] = invert_result[24] & carry_bit_convert_result_adder[24]; // calculation of carry bit of adder
assign result_convert_result_adder[25] = invert_result[25] ^ carry_bit_convert_result_adder[25]; // calculation of add result
assign carry_bit_convert_result_adder[26] = invert_result[25] & carry_bit_convert_result_adder[25]; // calculation of carry bit of adder
assign result_convert_result_adder[26] = invert_result[26] ^ carry_bit_convert_result_adder[26]; // calculation of add result
assign carry_bit_convert_result_adder[27] = invert_result[26] & carry_bit_convert_result_adder[26]; // calculation of carry bit of adder
assign result_convert_result_adder[27] = invert_result[27] ^ carry_bit_convert_result_adder[27]; // calculation of add result
assign carry_bit_convert_result_adder[28] = invert_result[27] & carry_bit_convert_result_adder[27]; // calculation of carry bit of adder
assign result_convert_result_adder[28] = invert_result[28] ^ carry_bit_convert_result_adder[28]; // calculation of add result
assign carry_bit_convert_result_adder[29] = invert_result[28] & carry_bit_convert_result_adder[28]; // calculation of carry bit of adder
assign result_convert_result_adder[29] = invert_result[29] ^ carry_bit_convert_result_adder[29]; // calculation of add result
assign carry_bit_convert_result_adder[30] = invert_result[29] & carry_bit_convert_result_adder[29]; // calculation of carry bit of adder
assign result_convert_result_adder[30] = invert_result[30] ^ carry_bit_convert_result_adder[30]; // calculation of add result
assign carry_bit_convert_result_adder[31] = invert_result[30] & carry_bit_convert_result_adder[30]; // calculation of carry bit of adder
assign result_convert_result_adder[31] = invert_result[31] ^ carry_bit_convert_result_adder[31]; // calculation of add result
assign carry_bit_convert_result_adder[32] = invert_result[31] & carry_bit_convert_result_adder[31]; // calculation of carry bit of adder
assign result_convert_result_adder[32] = invert_result[32] ^ carry_bit_convert_result_adder[32]; // calculation of add result
assign carry_bit_convert_result_adder[33] = invert_result[32] & carry_bit_convert_result_adder[32]; // calculation of carry bit of adder
assign result_convert_result_adder[33] = invert_result[33] ^ carry_bit_convert_result_adder[33]; // calculation of add result
assign carry_bit_convert_result_adder[34] = invert_result[33] & carry_bit_convert_result_adder[33]; // calculation of carry bit of adder
assign result_convert_result_adder[34] = invert_result[34] ^ carry_bit_convert_result_adder[34]; // calculation of add result
assign carry_bit_convert_result_adder[35] = invert_result[34] & carry_bit_convert_result_adder[34]; // calculation of carry bit of adder
assign result_convert_result_adder[35] = invert_result[35] ^ carry_bit_convert_result_adder[35]; // calculation of add result
assign carry_bit_convert_result_adder[36] = invert_result[35] & carry_bit_convert_result_adder[35]; // calculation of carry bit of adder
assign result_convert_result_adder[36] = invert_result[36] ^ carry_bit_convert_result_adder[36]; // calculation of add result
assign carry_bit_convert_result_adder[37] = invert_result[36] & carry_bit_convert_result_adder[36]; // calculation of carry bit of adder
assign result_convert_result_adder[37] = invert_result[37] ^ carry_bit_convert_result_adder[37]; // calculation of add result
assign carry_bit_convert_result_adder[38] = invert_result[37] & carry_bit_convert_result_adder[37]; // calculation of carry bit of adder
assign result_convert_result_adder[38] = invert_result[38] ^ carry_bit_convert_result_adder[38]; // calculation of add result
assign carry_bit_convert_result_adder[39] = invert_result[38] & carry_bit_convert_result_adder[38]; // calculation of carry bit of adder
assign result_convert_result_adder[39] = invert_result[39] ^ carry_bit_convert_result_adder[39]; // calculation of add result
assign carry_bit_convert_result_adder[40] = invert_result[39] & carry_bit_convert_result_adder[39]; // calculation of carry bit of adder
assign result_convert_result_adder[40] = invert_result[40] ^ carry_bit_convert_result_adder[40]; // calculation of add result
assign carry_bit_convert_result_adder[41] = invert_result[40] & carry_bit_convert_result_adder[40]; // calculation of carry bit of adder
assign result_convert_result_adder[41] = invert_result[41] ^ carry_bit_convert_result_adder[41]; // calculation of add result
assign carry_bit_convert_result_adder[42] = invert_result[41] & carry_bit_convert_result_adder[41]; // calculation of carry bit of adder
assign result_convert_result_adder[42] = invert_result[42] ^ carry_bit_convert_result_adder[42]; // calculation of add result
assign carry_bit_convert_result_adder[43] = invert_result[42] & carry_bit_convert_result_adder[42]; // calculation of carry bit of adder
assign result_convert_result_adder[43] = invert_result[43] ^ carry_bit_convert_result_adder[43]; // calculation of add result
assign carry_bit_convert_result_adder[44] = invert_result[43] & carry_bit_convert_result_adder[43]; // calculation of carry bit of adder
assign result_convert_result_adder[44] = invert_result[44] ^ carry_bit_convert_result_adder[44]; // calculation of add result
assign carry_bit_convert_result_adder[45] = invert_result[44] & carry_bit_convert_result_adder[44]; // calculation of carry bit of adder
assign result_convert_result_adder[45] = invert_result[45] ^ carry_bit_convert_result_adder[45]; // calculation of add result
assign carry_bit_convert_result_adder[46] = invert_result[45] & carry_bit_convert_result_adder[45]; // calculation of carry bit of adder
assign result_convert_result_adder[46] = invert_result[46] ^ carry_bit_convert_result_adder[46]; // calculation of add result
assign carry_bit_convert_result_adder[47] = invert_result[46] & carry_bit_convert_result_adder[46]; // calculation of carry bit of adder
assign result_convert_result_adder[47] = invert_result[47] ^ carry_bit_convert_result_adder[47]; // calculation of add result
assign carry_bit_convert_result_adder[48] = invert_result[47] & carry_bit_convert_result_adder[47]; // calculation of carry bit of adder
assign result_convert_result_adder[48] = invert_result[48] ^ carry_bit_convert_result_adder[48]; // calculation of add result
assign carry_bit_convert_result_adder[49] = invert_result[48] & carry_bit_convert_result_adder[48]; // calculation of carry bit of adder
assign result_convert_result_adder[49] = invert_result[49] ^ carry_bit_convert_result_adder[49]; // calculation of add result
assign carry_bit_convert_result_adder[50] = invert_result[49] & carry_bit_convert_result_adder[49]; // calculation of carry bit of adder
assign result_convert_result_adder[50] = invert_result[50] ^ carry_bit_convert_result_adder[50]; // calculation of add result
assign carry_bit_convert_result_adder[51] = invert_result[50] & carry_bit_convert_result_adder[50]; // calculation of carry bit of adder
assign result_convert_result_adder[51] = invert_result[51] ^ carry_bit_convert_result_adder[51]; // calculation of add result
assign carry_bit_convert_result_adder[52] = invert_result[51] & carry_bit_convert_result_adder[51]; // calculation of carry bit of adder
assign result_convert_result_adder[52] = invert_result[52] ^ carry_bit_convert_result_adder[52]; // calculation of add result
assign carry_bit_convert_result_adder[53] = invert_result[52] & carry_bit_convert_result_adder[52]; // calculation of carry bit of adder
assign result_convert_result_adder[53] = invert_result[53] ^ carry_bit_convert_result_adder[53]; // calculation of add result
assign carry_bit_convert_result_adder[54] = invert_result[53] & carry_bit_convert_result_adder[53]; // calculation of carry bit of adder
assign result_convert_result_adder[54] = invert_result[54] ^ carry_bit_convert_result_adder[54]; // calculation of add result
assign carry_bit_convert_result_adder[55] = invert_result[54] & carry_bit_convert_result_adder[54]; // calculation of carry bit of adder
assign result_convert_result_adder[55] = invert_result[55] ^ carry_bit_convert_result_adder[55]; // calculation of add result
assign carry_bit_convert_result_adder[56] = invert_result[55] & carry_bit_convert_result_adder[55]; // calculation of carry bit of adder
assign result_convert_result_adder[56] = invert_result[56] ^ carry_bit_convert_result_adder[56]; // calculation of add result
assign carry_bit_convert_result_adder[57] = invert_result[56] & carry_bit_convert_result_adder[56]; // calculation of carry bit of adder
assign result_convert_result_adder[57] = invert_result[57] ^ carry_bit_convert_result_adder[57]; // calculation of add result
assign carry_bit_convert_result_adder[58] = invert_result[57] & carry_bit_convert_result_adder[57]; // calculation of carry bit of adder
assign result_convert_result_adder[58] = invert_result[58] ^ carry_bit_convert_result_adder[58]; // calculation of add result
assign carry_bit_convert_result_adder[59] = invert_result[58] & carry_bit_convert_result_adder[58]; // calculation of carry bit of adder
assign result_convert_result_adder[59] = invert_result[59] ^ carry_bit_convert_result_adder[59]; // calculation of add result
assign carry_bit_convert_result_adder[60] = invert_result[59] & carry_bit_convert_result_adder[59]; // calculation of carry bit of adder
assign result_convert_result_adder[60] = invert_result[60] ^ carry_bit_convert_result_adder[60]; // calculation of add result
assign carry_bit_convert_result_adder[61] = invert_result[60] & carry_bit_convert_result_adder[60]; // calculation of carry bit of adder
assign result_convert_result_adder[61] = invert_result[61] ^ carry_bit_convert_result_adder[61]; // calculation of add result
assign carry_bit_convert_result_adder[62] = invert_result[61] & carry_bit_convert_result_adder[61]; // calculation of carry bit of adder
assign result_convert_result_adder[62] = invert_result[62] ^ carry_bit_convert_result_adder[62]; // calculation of add result
assign carry_bit_convert_result_adder[63] = invert_result[62] & carry_bit_convert_result_adder[62]; // calculation of carry bit of adder
assign result_convert_result_adder[63] = invert_result[63] ^ carry_bit_convert_result_adder[63]; // calculation of add result

// output final result control
assign multiplication_result_ctrl = (~ip_funct_3[2]) & (|ip_funct_3[1:0]); // output lower bit or higher bit of multiplication result
assign result_convert_ctrl = ((ip_rs1[31] ^ ip_rs2[31]) & (multiplication_fully_sign | (division_sign & (~ip_funct_3[1])))) | (ip_rs1[31] & (((~ip_funct_3[2]) & ip_funct_3[1] & (~ip_funct_3[0])) | (division_sign & ip_funct_3[1]))); // result convert control if result must be negative

// output result
assign op_result[31:0] = (multiplication_result_ctrl == 1'b1) ? ((result_convert_ctrl == 1'b1) ? result_convert_result_adder[63:32] : result[63:32]) : ((result_convert_ctrl == 1'b1) ? result_convert_result_adder[31:0] : result[31:0]); // output normal result or converted result
assign op_overflow = ip_funct_3[2] & ((~|ip_rs2[31:0]) | ((~ip_funct_3[0]) & ip_rs1[31] & (~|ip_rs1[30:0]) & (&ip_rs2[31:0]))); // overflow detection (if divide by 0 or largest negative number divide by -1)
endmodule