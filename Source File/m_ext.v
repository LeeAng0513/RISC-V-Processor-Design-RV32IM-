/**********************************************************************
Project: Develop 32-bit RISC-V Processor
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
	input wire ip_clk,
	input wire [31:0] ip_rs1, ip_rs2,
	input wire [2:0] ip_funct_3,
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
wire [31:0] carry_bit_convert_rs1_adder; // carry bit of adder after invert rs1
wire [32:0] result_convert_rs1_adder; // result of convert rs1 from negative to positive
wire [32:0] invert_rs2; // invert of rs2
wire [31:0] carry_bit_convert_rs2_adder; // carry bit of adder after invert rs2
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
wire [62:0] carry_bit_convert_result_adder; // carry bit of adder after invert result
wire [63:0] result_convert_result_adder; // result of convert result from negative to positive
wire result_convert_ctrl; // data select for final result

// variable
genvar i;
genvar j;
genvar k;

// wire assignment
// pre execution control
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
assign result_convert_rs1_adder[0] = invert_rs1[0] ^ 1'b1; // calculation of add result
assign carry_bit_convert_rs1_adder[0] = invert_rs1[0] & 1'b1; // calculation of carry bit of adder
assign result_convert_rs1_adder[1] = invert_rs1[1] ^ carry_bit_convert_rs1_adder[0]; // calculation of add result
generate
	for (i = 1; i < 32; i = i + 1) begin
		assign carry_bit_convert_rs1_adder[i] = invert_rs1[i] & carry_bit_convert_rs1_adder[i - 1]; // calculation of carry bit of adder
		assign result_convert_rs1_adder[i + 1] = invert_rs1[i + 1] ^ carry_bit_convert_rs1_adder[i]; // calculation of add result
	end
endgenerate

// convert rs2 from negative to positive
assign invert_rs2[32:0] = ~{rs2_sign_neg, ip_rs2[31:0]};
assign result_convert_rs2_adder[0] = invert_rs2[0] ^ 1'b1; // calculation of add result
assign carry_bit_convert_rs2_adder[0] = invert_rs2[0] & 1'b1; // calculation of carry bit of adder
assign result_convert_rs2_adder[1] = invert_rs2[1] ^ carry_bit_convert_rs2_adder[0]; // calculation of add result
generate
	for (i = 1; i < 32; i = i + 1) begin
		assign carry_bit_convert_rs2_adder[i] = invert_rs2[i] & carry_bit_convert_rs2_adder[i - 1]; // calculation of carry bit of adder
		assign result_convert_rs2_adder[i + 1] = invert_rs2[i + 1] ^ carry_bit_convert_rs2_adder[i]; // calculation of add result
	end
endgenerate

// input convert control
assign rs1_convert_ctrl = rs1_sign_neg; // convert rs1 signal
assign rs2_convert_ctrl = multiplication_rs2_sign_neg | ((~ip_rs2[31]) & division_sign) | (ip_funct_3[2] & ip_funct_3[0]); // convert rs2 signal

// data select for operand a and b
assign operand_a[32:0] = (rs1_convert_ctrl == 1'b1) ? result_convert_rs1_adder[32:0] : {rs1_sign_neg, ip_rs1[31:0]}; // data select for operand a
assign operand_b[32:0] = (rs2_convert_ctrl == 1'b1) ? result_convert_rs2_adder[32:0] : {rs2_sign_neg, ip_rs2[31:0]}; // data select for operand b

// Layer 1 of data selection
assign layer_data_a[0][32:0] = (ip_funct_3[2] == 1'b1) ? {32'b0, operand_a[32]} : 33'b0; // input a of data selection for layer 1
assign layer_data_b[0][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[0] == 1'b1) ? operand_a[32:0] : 33'b0); // input a of data selection for layer 1

// Layer 2 - 33 of data selection
generate
	for (i = 1; i < 33; i = i + 1) begin
		assign layer_data_a[i][32:0] = (ip_funct_3[2] == 1'b1) ? ((result_layer_adder[i - 1][32] == 1'b1) ? {layer_data_a[i - 1][31:0], operand_a[32 - i]} : {result_layer_adder[i - 1][31:0], operand_a[32 - i]}) : {1'b0, result_layer_adder[i - 1][32:1]}; // data select for layer 2
		assign layer_data_b[i][32:0] = (ip_funct_3[2] == 1'b1) ? operand_b[32:0] : ((operand_b[i] == 1'b1) ? operand_a[32:0] : 33'b0); // data select for layer 2
	end
endgenerate

// Layer 1 - 33 adder
generate
	for (i = 0; i < 33; i = i + 1) begin
		assign result_layer_adder[i][0] = layer_data_a[i][0] ^ layer_data_b[i][0]; // calculation of add result
		assign carry_bit_layer_adder[i][0] = layer_data_a[i][0] & layer_data_b[i][0]; // calculation of carry bit of adder
		assign result_layer_adder[i][1] = layer_data_a[i][1] ^ layer_data_b[i][1] ^ carry_bit_layer_adder[i][0]; // calculation of add result
		for (j = 1; j < 32; j = j + 1) begin
			assign carry_bit_layer_adder[i][j] = (layer_data_a[i][j] & layer_data_b[i][j]) | (layer_data_a[i][j] & carry_bit_layer_adder[i][j - 1]) | (layer_data_b[i][j] & carry_bit_layer_adder[i][j - 1]); // calculation of carry bit of adder
			assign result_layer_adder[i][j + 1] = layer_data_a[i][j + 1] ^ layer_data_b[i][j + 1] ^ carry_bit_layer_adder[i][j]; // calculation of add result
		end
	end
endgenerate

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
assign result_convert_result_adder[0] = invert_result[0] ^ 1'b1; // calculation of add result
assign carry_bit_convert_result_adder[0] = invert_result[0] & 1'b1; // calculation of carry bit of adder
assign result_convert_result_adder[1] = invert_result[1] ^ carry_bit_convert_result_adder[0]; // calculation of add result
generate
	for (i = 1; i < 63; i = i + 1) begin
		assign carry_bit_convert_result_adder[i] = invert_result[i] & carry_bit_convert_result_adder[i - 1]; // calculation of carry bit of adder
		assign result_convert_result_adder[i + 1] = invert_result[i + 1] ^ carry_bit_convert_result_adder[i]; // calculation of add result
	end
endgenerate

// output final result control
assign multiplication_result_ctrl = (~ip_funct_3[2]) & (|ip_funct_3[1:0]); // output lower bit or higher bit of multiplication result
assign result_convert_ctrl = ((ip_rs1[31] ^ ip_rs2[31]) & (multiplication_fully_sign | (division_sign & (~ip_funct_3[1])))) | (ip_rs1[31] & (((~ip_funct_3[2]) & ip_funct_3[1] & (~ip_funct_3[0])) | (division_sign & ip_funct_3[1]))); // result convert control if result must be negative

// output result
assign op_result[31:0] = (multiplication_result_ctrl == 1'b1) ? ((result_convert_ctrl == 1'b1) ? result_convert_result_adder[63:32] : result[63:32]) : ((result_convert_ctrl == 1'b1) ? result_convert_result_adder[31:0] : result[31:0]); // output normal result or converted result
assign op_overflow = ip_funct_3[2] & ((~|ip_rs2[31:0]) | ((~ip_funct_3[0]) & ip_rs1[31] & (~|ip_rs1[30:0]) & (&ip_rs2[31:0]))); // overflow detection (if divide by 0 or largest negative number divide by -1)
endmodule