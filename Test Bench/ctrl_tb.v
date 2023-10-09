/**********************************************************************
Project: Develop 32-bit RISC-V Processor 
Module: ctrl_tb.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: Control Unit Test Bench
**********************************************************************/

`include "macro.v"
`default_nettype none

module ctrl_tb
();

reg ip_clk_tb;
reg [6:0] ip_opcode_tb, ip_funct_7_tb;
reg [2:0] ip_funct_3_tb;
wire [1:0] op_load_store_bit_ctrl_tb;
wire op_reg_wr_en_tb, op_wb_ctrl_tb, op_jump_ctrl_tb, op_load_sign_ctrl_tb, op_store_en_tb;
wire [2:0] op_imm_ext_ctrl_tb, op_ALU_operation_ctrl_tb, op_ALU_branch_ctrl_tb;
wire [1:0] op_ALU_operand_a_ctrl_tb, op_ALU_operand_b_ctrl_tb, op_ALU_result_ctrl_tb;
wire op_ALU_sign_ctrl_tb, op_ALU_shift_direction_ctrl_tb, op_ALU_addr_ctrl_tb;
wire op_m_ext_wb_ctrl_tb;

ctrl
dut_ctrl(
	.ip_clk(ip_clk_tb),
	.ip_opcode(ip_opcode_tb),
	.ip_funct_7(ip_funct_7_tb),
	.ip_funct_3(ip_funct_3_tb),
	.op_load_store_bit_ctrl(op_load_store_bit_ctrl_tb),
	.op_reg_wr_en(op_reg_wr_en_tb),
	.op_wb_ctrl(op_wb_ctrl_tb),
	.op_jump_ctrl(op_jump_ctrl_tb),
	.op_load_sign_ctrl(op_load_sign_ctrl_tb),
	.op_store_en(op_store_en_tb),
	.op_imm_ext_ctrl(op_imm_ext_ctrl_tb),
	.op_ALU_operation_ctrl(op_ALU_operation_ctrl_tb),
	.op_ALU_branch_ctrl(op_ALU_branch_ctrl_tb),
	.op_ALU_operand_a_ctrl(op_ALU_operand_a_ctrl_tb),
	.op_ALU_operand_b_ctrl(op_ALU_operand_b_ctrl_tb),
	.op_ALU_result_ctrl(op_ALU_result_ctrl_tb),
	.op_ALU_sign_ctrl(op_ALU_sign_ctrl_tb),
	.op_ALU_shift_direction_ctrl(op_ALU_shift_direction_ctrl_tb),
	.op_ALU_addr_ctrl(op_ALU_addr_ctrl_tb),
	.op_m_ext_wb_ctrl(op_m_ext_wb_ctrl_tb)
);

initial ip_clk_tb <= 1'b1;
always #(`PERIOD_HALF) ip_clk_tb = ~ip_clk_tb;

//Signal initialization
initial begin
	@(posedge ip_clk_tb) // initialize the value (at sim time 1)
		ip_opcode_tb[6:0] = 7'b0;
		ip_funct_7_tb[6:0] = 7'b0;
		ip_funct_3_tb[2:0] = 3'b0;
	
	// test case 1 (LUI control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0110111;
		ip_funct_7_tb[6:0] = 7'b1001011;
		ip_funct_3_tb[2:0] = 3'b100;
	
	// test case 2 (AUIPC control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0010111;
		ip_funct_7_tb[6:0] = 7'b1011000;
		ip_funct_3_tb[2:0] = 3'b000;
	
	// test case 3 (JAL control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b1101111;
		ip_funct_7_tb[6:0] = 7'b0101111;
		ip_funct_3_tb[2:0] = 3'b011;
	
	// test case 4 (JALR control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b1100111;
		ip_funct_7_tb[6:0] = 7'b0111111;
		ip_funct_3_tb[2:0] = 3'b000;
	
	// test case 5 (BEQ control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b1100011;
		ip_funct_7_tb[6:0] = 7'b1011110;
		ip_funct_3_tb[2:0] = 3'b000;
	
	// test case 6 (BNE control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b1100011;
		ip_funct_7_tb[6:0] = 7'b0000111;
		ip_funct_3_tb[2:0] = 3'b001;
	
	// test case 7 (BLT control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b1100011;
		ip_funct_7_tb[6:0] = 7'b0100010;
		ip_funct_3_tb[2:0] = 3'b100;
	
	// test case 8 (BGE control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b1100011;
		ip_funct_7_tb[6:0] = 7'b0000100;
		ip_funct_3_tb[2:0] = 3'b101;
	
	// test case 9 (BLTU control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b1100011;
		ip_funct_7_tb[6:0] = 7'b1110100;
		ip_funct_3_tb[2:0] = 3'b110;
	
	// test case 10 (BGEU control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b1100011;
		ip_funct_7_tb[6:0] = 7'b0010101;
		ip_funct_3_tb[2:0] = 3'b111;
	
	// test case 11 (LB control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0000011;
		ip_funct_7_tb[6:0] = 7'b1010011;
		ip_funct_3_tb[2:0] = 3'b000;
	
	// test case 12 (LH control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0000011;
		ip_funct_7_tb[6:0] = 7'b0001110;
		ip_funct_3_tb[2:0] = 3'b001;
	
	// test case 13 (LW control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0000011;
		ip_funct_7_tb[6:0] = 7'b0011010;
		ip_funct_3_tb[2:0] = 3'b010;
	
	// test case 14 (LBU control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0000011;
		ip_funct_7_tb[6:0] = 7'b0010011;
		ip_funct_3_tb[2:0] = 3'b100;
	
	// test case 15 (LHU control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0000011;
		ip_funct_7_tb[6:0] = 7'b1001011;
		ip_funct_3_tb[2:0] = 3'b101;
	
	// test case 16 (SB control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0100011;
		ip_funct_7_tb[6:0] = 7'b1110011;
		ip_funct_3_tb[2:0] = 3'b000;
	
	// test case 17 (SH control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0100011;
		ip_funct_7_tb[6:0] = 7'b0011110;
		ip_funct_3_tb[2:0] = 3'b001;
	
	// test case 18 (SW control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0100011;
		ip_funct_7_tb[6:0] = 7'b1111001;
		ip_funct_3_tb[2:0] = 3'b010;
	
	// test case 19 (ADDI control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0010011;
		ip_funct_7_tb[6:0] = 7'b0000011;
		ip_funct_3_tb[2:0] = 3'b000;
	
	// test case 20 (SLTI control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0010011;
		ip_funct_7_tb[6:0] = 7'b0101010;
		ip_funct_3_tb[2:0] = 3'b010;
	
	// test case 21 (SLTIU control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0010011;
		ip_funct_7_tb[6:0] = 7'b1101101;
		ip_funct_3_tb[2:0] = 3'b011;
	
	// test case 22 (XORI control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0010011;
		ip_funct_7_tb[6:0] = 7'b1011000;
		ip_funct_3_tb[2:0] = 3'b100;
	
	// test case 23 (ORI control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0010011;
		ip_funct_7_tb[6:0] = 7'b1110000;
		ip_funct_3_tb[2:0] = 3'b110;
	
	// test case 24 (ANDI control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0010011;
		ip_funct_7_tb[6:0] = 7'b1100001;
		ip_funct_3_tb[2:0] = 3'b111;
	
	// test case 25 (SLLI control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0010011;
		ip_funct_7_tb[6:0] = 7'b0000000;
		ip_funct_3_tb[2:0] = 3'b001;
	
	// test case 26 (SRLI control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0010011;
		ip_funct_7_tb[6:0] = 7'b0000000;
		ip_funct_3_tb[2:0] = 3'b101;
	
	// test case 27 (SRLA control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0010011;
		ip_funct_7_tb[6:0] = 7'b0100000;
		ip_funct_3_tb[2:0] = 3'b101;
	
	// test case 28 (ADD control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0110011;
		ip_funct_7_tb[6:0] = 7'b0000000;
		ip_funct_3_tb[2:0] = 3'b000;
	
	// test case 29 (SUB control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0110011;
		ip_funct_7_tb[6:0] = 7'b0100000;
		ip_funct_3_tb[2:0] = 3'b000;
	
	// test case 30 (SLL control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0110011;
		ip_funct_7_tb[6:0] = 7'b0000000;
		ip_funct_3_tb[2:0] = 3'b001;
	
	// test case 31 (SLT control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0110011;
		ip_funct_7_tb[6:0] = 7'b0000000;
		ip_funct_3_tb[2:0] = 3'b010;
	
	// test case 32 (SLTU control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0110011;
		ip_funct_7_tb[6:0] = 7'b0000000;
		ip_funct_3_tb[2:0] = 3'b011;
	
	// test case 33 (XOR control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0110011;
		ip_funct_7_tb[6:0] = 7'b0000000;
		ip_funct_3_tb[2:0] = 3'b100;
	
	// test case 34 (SRA control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0110011;
		ip_funct_7_tb[6:0] = 7'b0000000;
		ip_funct_3_tb[2:0] = 3'b101;
	
	// test case 35 (SRA control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0110011;
		ip_funct_7_tb[6:0] = 7'b0100000;
		ip_funct_3_tb[2:0] = 3'b101;
	
	// test case 36 (OR control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0110011;
		ip_funct_7_tb[6:0] = 7'b0000000;
		ip_funct_3_tb[2:0] = 3'b110;
	
	// test case 37 (AND control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0110011;
		ip_funct_7_tb[6:0] = 7'b0000000;
		ip_funct_3_tb[2:0] = 3'b111;
	
	// test case 41 (MUL control)
	@(posedge ip_clk_tb) // insert value
		ip_opcode_tb[6:0] = 7'b0110011;
		ip_funct_7_tb[6:0] = 7'b0000001;
		ip_funct_3_tb[2:0] = 3'b000;
	
	repeat(2) @(posedge ip_clk_tb) begin // 1 cycle to compute the result
		ip_opcode_tb[6:0] = 7'b0;
		ip_funct_7_tb[6:0] = 7'b0;
		ip_funct_3_tb[2:0] = 3'b0;
	end
	
	$stop; //stop simulation
end
endmodule
