/**********************************************************************
Project: Develop 32-bit RISC-V Processor 
Module: ctrl.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: Control Unit
**********************************************************************/

`default_nettype none // to catch typing errors due to typo of signal names

module ctrl
#( // declare all the parameter needed
parameter AND = 3'b000,
parameter OR = 3'b001,
parameter XOR = 3'b010,
parameter ADD = 3'b011,
parameter SUB = 3'b111
) 
( // declare all the input and output pin needed
	input wire ip_clk,
	input wire [6:0] ip_opcode, ip_funct_7,
	input wire [2:0] ip_funct_3,
	output wire [1:0] op_load_store_bit_ctrl,
	output wire op_reg_wr_en, op_wb_ctrl, op_jump_ctrl, op_store_en, op_load_sign_ctrl,
	output wire [2:0] op_imm_ext_ctrl, op_ALU_operation_ctrl, op_ALU_branch_ctrl,
	output wire [1:0] op_ALU_operand_a_ctrl, op_ALU_operand_b_ctrl, op_ALU_result_ctrl,
	output wire op_ALU_sign_ctrl, op_ALU_shift_direction_ctrl, op_ALU_addr_ctrl,
	output wire op_m_ext_wb_ctrl
);

// wire
wire opcode_upper, opcode_jump, opcode_branch, opcode_load_store, opcode_imm_reg;
wire opcode_LUI, opcode_AUIPC, opcode_JAL, opcode_JALR, opcode_load, opcode_store, opcode_imm, opcode_reg, opcode_ADD_SUB, opcode_SLT, opcode_shift, opcode_m_ext;

// control unit
// level 1 wire assignment
assign opcode_upper = (~ip_opcode[6]) & ip_opcode[4] & (~ip_opcode[3]) & (&ip_opcode[2:0]); // upper instruction (LUI / AUIPC)
assign opcode_jump = (&ip_opcode[6:5]) & (~ip_opcode[4]) & (&ip_opcode[2:0]); // jump instruction (JAL / JALR)
assign opcode_branch = (&ip_opcode[6:5]) & (~|ip_opcode[4:2]) & (&ip_opcode[1:0]); // branch instruction
assign opcode_load_store = (~ip_opcode[6]) & (~|ip_opcode[4:2]) & (&ip_opcode[1:0]); // load / store instruction
assign opcode_imm_reg = (~ip_opcode[6]) & ip_opcode[4] & (~|ip_opcode[3:2]) & (&ip_opcode[1:0]); // immediate / register instruction

// level 2 wire assignment
assign opcode_LUI = opcode_upper & ip_opcode[5]; // LUI
assign opcode_AUIPC = opcode_upper & (~ip_opcode[5]); // AUIPC
assign opcode_JAL = opcode_jump & ip_opcode[3]; // JAL
assign opcode_JALR = opcode_jump & (~ip_opcode[3]); // JALR
assign opcode_load = opcode_load_store & (~ip_opcode[5]); // load instruction
assign opcode_store = opcode_load_store & ip_opcode[5]; // store instruction
assign opcode_imm = opcode_imm_reg & (~ip_opcode[5]); // immediate instruction
assign opcode_ADD_SUB = opcode_imm_reg & (~|ip_funct_3[2:0]); // ADD / SUB instruction
assign opcode_SLT = opcode_imm_reg & ip_funct_3[1] & (~ip_funct_3[2]); // SLT
assign opcode_shift = opcode_imm_reg & ip_funct_3[0] & (~ip_funct_3[1]); // shift instruction
assign opcode_m_ext = opcode_imm_reg & ip_opcode[5] & (~|ip_funct_7[6:1]) & ip_funct_7[0]; // m extenstion instruction


// output data path control
assign op_reg_wr_en = opcode_upper | opcode_jump | opcode_load | opcode_imm_reg; // if instruction required write back to register
assign op_jump_ctrl = opcode_jump; // control PC to change to target address
assign op_wb_ctrl = opcode_load; // control data from data memory write into register
assign op_load_sign_ctrl = ip_funct_3[2]; // signed bit extend for load instruction
assign op_store_en = opcode_store; // enable to store data into data memory
assign op_load_store_bit_ctrl[1:0] = ip_funct_3[1:0]; // load / store bit width
assign op_m_ext_wb_ctrl = opcode_m_ext; // control to let result from m extention write back to register

// output ALU control
assign op_imm_ext_ctrl[2:0] = ((opcode_JALR == 1'b1) || (opcode_load == 1'b1) || ((opcode_imm == 1'b1) && (opcode_shift == 1'b0))) ? 3'b001 : (((opcode_imm == 1'b1) && (opcode_shift == 1'b1)) ? 3'b010 : ((opcode_store == 1'b1) ? 3'b011 : ((opcode_branch == 1'b1) ? 3'b100 : ((opcode_upper == 1'b1) ? 3'b101 : ((opcode_JAL == 1'b1) ? 3'b110 : 3'b000))))) ; // immediate extend control
assign op_ALU_operand_a_ctrl[1:0] = ((opcode_AUIPC == 1'b1) || (opcode_jump == 1'b1)) ? 2'b01 : ((opcode_LUI == 1'b1) ? 2'b10 : 2'b00); // data select for operand a control
assign op_ALU_operand_b_ctrl[1:0] = ((opcode_upper == 1'b1) || (opcode_load_store == 1'b1) || (opcode_imm == 1'b1)) ? 2'b01 : ((opcode_jump == 1'b1) ? 2'b10 : 2'b00); // data select for operand b control
assign op_ALU_operation_ctrl[2:0] = ((opcode_imm_reg == 1'b1) && (ip_funct_3[2:0] == 3'b110)) ? OR : (((opcode_imm_reg == 1'b1) && (ip_funct_3[2:0] == 3'b100)) ? XOR : (((opcode_upper == 1'b1) || (opcode_jump == 1'b1) || (opcode_load_store == 1'b1) || ((opcode_ADD_SUB == 1'b1) && ((ip_opcode[5] == 1'b0) || ((ip_opcode[5] == 1'b1) && (ip_funct_7[6:0] == 7'b0000000))))) ? ADD : (((opcode_branch == 1'b1) || (opcode_SLT == 1'b1) || ((opcode_ADD_SUB == 1'b1) && (ip_opcode[5] == 1'b1) && (ip_funct_7[6:0] == 7'b0100000))) ? SUB : AND))); // ALU operation control
assign op_ALU_result_ctrl[1:0] = (opcode_SLT == 1'b1) ?  2'b01 : ((opcode_shift == 1'b1) ? 2'b10 : 2'b00); // ALU result selection control
assign op_ALU_sign_ctrl = (opcode_branch & ip_funct_3[1]) | (opcode_SLT & ip_funct_3[0]) | (opcode_shift & (~|ip_funct_7[6:0])); // data sign control
assign op_ALU_branch_ctrl[2] = opcode_branch; // branch enable control
assign op_ALU_branch_ctrl[1] = ip_funct_3[2]; // branch instruction result control
assign op_ALU_branch_ctrl[0] = ip_funct_3[0]; // branch instruction result control
assign op_ALU_shift_direction_ctrl = ip_funct_3[2]; // output shift direction control
assign op_ALU_addr_ctrl = opcode_JALR; // address selection for branch adder (rs1)
endmodule