/**********************************************************************
Project: Develop 32-bit RISC-V Processor
Module: data_path.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: Datapath
**********************************************************************/

`default_nettype none // to catch typing errors due to typo of signal names

module data_path
( // declare all the input and output pin needed
	input wire [31:0] ip_wr_instr_mem_data, ip_wr_instr_mem_addr,
	input wire ip_clk, ip_rst, ip_wr_instr_mem_en, ip_stall_ctrl,
	output wire op_overflow
);

// Pipeline
// IF->ID pipeline
reg [31:0] reg_IF_ID_instr, reg_IF_ID_pc_addr;

// ID->EX pipeline
reg [31:0] reg_ID_EX_pc_addr;
reg [24:0] reg_ID_EX_imm;
reg [4:0] reg_ID_EX_rs1_addr, reg_ID_EX_rs2_addr, reg_ID_EX_rd_addr;
reg [2:0] reg_ID_EX_funct_3;
reg [31:0] reg_ID_EX_rs1, reg_ID_EX_rs2;
reg [1:0] reg_ID_EX_load_store_bit_ctrl;
reg reg_ID_EX_reg_wr_en, reg_ID_EX_wb_ctrl, reg_ID_EX_jump_ctrl, reg_ID_EX_load_sign_ctrl, reg_ID_EX_store_en, reg_ID_EX_m_ext_wb_ctrl;
reg [2:0] reg_ID_EX_imm_ext_ctrl, reg_ID_EX_ALU_operation_ctrl, reg_ID_EX_ALU_branch_ctrl;
reg [1:0] reg_ID_EX_ALU_operand_a_ctrl, reg_ID_EX_ALU_operand_b_ctrl, reg_ID_EX_ALU_result_ctrl;
reg reg_ID_EX_ALU_sign_ctrl, reg_ID_EX_ALU_shift_direction_ctrl, reg_ID_EX_ALU_addr_ctrl;

// EX->MEM pipeline
reg [4:0] reg_EX_MEM_rd_addr;
reg [31:0] reg_EX_MEM_rs2;
reg [1:0] reg_EX_MEM_load_store_bit_ctrl;
reg reg_EX_MEM_reg_wr_en, reg_EX_MEM_wb_ctrl, reg_EX_MEM_load_sign_ctrl, reg_EX_MEM_store_en;
reg [31:0] reg_EX_MEM_result;

// MEM->WB pipeline
reg [4:0] reg_MEM_WB_rd_addr;
reg reg_MEM_WB_reg_wr_en;
reg [31:0] reg_MEM_WB_wb_data;

// Wire
// IF stage
wire [31:0] w_IF_pc_addr, w_IF_instr;

// ID stage
wire [31:0] w_ID_pc_addr;
wire [24:0] w_ID_imm;
wire [4:0] w_ID_rs1_addr, w_ID_rs2_addr, w_ID_rd_addr;
wire [6:0] w_ID_opcode, w_ID_funct_7;
wire [2:0] w_ID_funct_3;
wire [31:0] w_ID_rs1, w_ID_rs2;
wire [1:0] w_ID_load_store_bit_ctrl;
wire w_ID_reg_wr_en, w_ID_wb_ctrl, w_ID_jump_ctrl, w_ID_load_sign_ctrl, w_ID_store_en, w_ID_m_ext_wb_ctrl;
wire [2:0] w_ID_imm_ext_ctrl, w_ID_ALU_operation_ctrl, w_ID_ALU_branch_ctrl;
wire [1:0] w_ID_ALU_operand_a_ctrl, w_ID_ALU_operand_b_ctrl, w_ID_ALU_result_ctrl;
wire w_ID_ALU_sign_ctrl, w_ID_ALU_shift_direction_ctrl, w_ID_ALU_addr_ctrl;

// EX stage
wire [31:0] w_EX_pc_addr;
wire [24:0] w_EX_imm;
wire [4:0] w_EX_rs1_addr, w_EX_rs2_addr, w_EX_rd_addr;
wire [2:0] w_EX_funct_3;
wire [31:0] w_EX_rs1_ID, w_EX_rs2_ID;
wire [1:0] w_EX_load_store_bit_ctrl;
wire w_EX_reg_wr_en, w_EX_wb_ctrl, w_EX_jump_ctrl, w_EX_load_sign_ctrl, w_EX_store_en, w_EX_m_ext_wb_ctrl;
wire [2:0] w_EX_imm_ext_ctrl, w_EX_ALU_operation_ctrl, w_EX_ALU_branch_ctrl;
wire [1:0] w_EX_ALU_operand_a_ctrl, w_EX_ALU_operand_b_ctrl, w_EX_ALU_result_ctrl;
wire w_EX_ALU_sign_ctrl, w_EX_ALU_shift_direction_ctrl, w_EX_ALU_addr_ctrl;
wire [31:0] w_EX_ALU_result, w_EX_target_addr;
wire w_EX_branch_addr_ctrl, w_EX_ALU_overflow;
wire [31:0] w_EX_m_ext_result;
wire w_EX_m_ext_overflow;
wire w_EX_jump_branch_ctrl;
wire [31:0] w_EX_result;

// MEM stage
wire [4:0] w_MEM_rd_addr;
wire [31:0] w_MEM_rs2;
wire [1:0] w_MEM_load_store_bit_ctrl;
wire w_MEM_reg_wr_en, w_MEM_wb_ctrl, w_MEM_load_sign_ctrl, w_MEM_store_en;
wire [31:0] w_MEM_result;
wire [31:0] w_MEM_read_data;
wire [31:0] w_MEM_wb_data;

// WB stage
wire [4:0] w_WB_rd_addr;
wire w_WB_reg_wr_en;
wire [31:0] w_WB_wb_data;

// data forward control
wire [1:0] forward_rs1_ctrl, forward_rs2_ctrl;
wire [31:0] w_EX_rs1, w_EX_rs2;

// IF stage
// instruction fetch unit connection
instr_fetch
instruction_fetch(
	.ip_wr_data(ip_wr_instr_mem_data),
	.ip_wr_addr(ip_wr_instr_mem_addr),
	.ip_target_addr(w_EX_target_addr),
	.ip_clk(ip_clk),
	.ip_rst(ip_rst),
	.ip_wr_en(ip_wr_instr_mem_en),
	.ip_jump_branch_ctrl(w_EX_jump_branch_ctrl),
	.ip_stall_ctrl(ip_stall_ctrl),
	.op_pc_addr(w_IF_pc_addr),
	.op_instr(w_IF_instr)
);

// IF->ID pipeline
always @(posedge ip_clk or posedge ip_rst) begin
	if(ip_rst == 1'b1) begin
		reg_IF_ID_pc_addr[31:0] = 32'b0;
		reg_IF_ID_instr[31:0] = 32'b0;
	end
	
	else if(ip_rst == 1'b0) begin
		if (ip_stall_ctrl == 1'b1) begin
			reg_IF_ID_pc_addr[31:0] <= reg_IF_ID_pc_addr[31:0];
			reg_IF_ID_instr[31:0] <= reg_IF_ID_instr[31:0];
		end
		
		else if (ip_stall_ctrl == 1'b0) begin
			reg_IF_ID_pc_addr[31:0] <= w_IF_pc_addr[31:0];
			reg_IF_ID_instr[31:0] <= w_IF_instr[31:0];
		end
	end
end

// ID stage
assign w_ID_pc_addr[31:0] = reg_IF_ID_pc_addr[31:0];
assign w_ID_imm[24:0] = reg_IF_ID_instr[31:7];
assign w_ID_rs1_addr[4:0] = reg_IF_ID_instr[19:15];
assign w_ID_rs2_addr[4:0] = reg_IF_ID_instr[24:20];
assign w_ID_rd_addr[4:0] = reg_IF_ID_instr[11:7];
assign w_ID_opcode[6:0] = reg_IF_ID_instr[6:0];
assign w_ID_funct_7[6:0] = reg_IF_ID_instr[31:25];
assign w_ID_funct_3[2:0] = reg_IF_ID_instr[14:12];

// register file connection
reg_file
register_file(
	.ip_wr_data(w_WB_wb_data),
	.ip_rd_addr(w_WB_rd_addr),
	.ip_rs1_addr(w_ID_rs1_addr),
	.ip_rs2_addr(w_ID_rs2_addr),
	.ip_clk(ip_clk),
	.ip_rst(ip_rst),
	.ip_wr_en(w_WB_reg_wr_en),
	.op_rs1(w_ID_rs1),
	.op_rs2(w_ID_rs2)
);

// control unit connection
ctrl
control_unit(
	.ip_opcode(w_ID_opcode),
	.ip_funct_7(w_ID_funct_7),
	.ip_funct_3(w_ID_funct_3),
	.ip_clk(ip_clk),
	.op_load_store_bit_ctrl(w_ID_load_store_bit_ctrl),
	.op_reg_wr_en(w_ID_reg_wr_en),
	.op_wb_ctrl(w_ID_wb_ctrl),
	.op_jump_ctrl(w_ID_jump_ctrl),
	.op_load_sign_ctrl(w_ID_load_sign_ctrl),
	.op_store_en(w_ID_store_en),
	.op_m_ext_wb_ctrl(w_ID_m_ext_wb_ctrl),
	.op_imm_ext_ctrl(w_ID_imm_ext_ctrl),
	.op_ALU_operation_ctrl(w_ID_ALU_operation_ctrl),
	.op_ALU_branch_ctrl(w_ID_ALU_branch_ctrl),
	.op_ALU_operand_a_ctrl(w_ID_ALU_operand_a_ctrl),
	.op_ALU_operand_b_ctrl(w_ID_ALU_operand_b_ctrl),
	.op_ALU_result_ctrl(w_ID_ALU_result_ctrl),
	.op_ALU_sign_ctrl(w_ID_ALU_sign_ctrl),
	.op_ALU_shift_direction_ctrl(w_ID_ALU_shift_direction_ctrl),
	.op_ALU_addr_ctrl(w_ID_ALU_addr_ctrl)
);

// ID->EX pipeline
always @(posedge ip_clk or posedge ip_rst) begin
	if(ip_rst == 1'b1) begin
		reg_ID_EX_pc_addr[31:0] = 32'b0;
		reg_ID_EX_imm[24:0] = 25'b0;
		reg_ID_EX_rs1_addr[4:0] = 5'b0;
		reg_ID_EX_rs2_addr[4:0] = 5'b0;
		reg_ID_EX_rd_addr[4:0] = 5'b0;
		reg_ID_EX_funct_3[2:0] = 3'b0;
		reg_ID_EX_rs1[31:0] = 32'b0;
		reg_ID_EX_rs2[31:0] = 32'b0;
		reg_ID_EX_load_store_bit_ctrl[1:0] = 2'b0;
		reg_ID_EX_reg_wr_en = 1'b0;
		reg_ID_EX_wb_ctrl = 1'b0;
		reg_ID_EX_jump_ctrl = 1'b0;
		reg_ID_EX_load_sign_ctrl = 1'b0;
		reg_ID_EX_store_en = 1'b0;
		reg_ID_EX_m_ext_wb_ctrl = 1'b0;
		reg_ID_EX_imm_ext_ctrl[2:0] = 3'b0;
		reg_ID_EX_ALU_operation_ctrl[2:0] = 3'b0;
		reg_ID_EX_ALU_branch_ctrl[2:0] = 3'b0;
		reg_ID_EX_ALU_operand_a_ctrl[1:0] = 2'b0;
		reg_ID_EX_ALU_operand_b_ctrl[1:0] = 2'b0;
		reg_ID_EX_ALU_result_ctrl[1:0] = 2'b0;
		reg_ID_EX_ALU_sign_ctrl = 1'b0;
		reg_ID_EX_ALU_shift_direction_ctrl = 1'b0;
		reg_ID_EX_ALU_addr_ctrl = 1'b0;
	end
	
	else if(ip_rst == 1'b0) begin
		if (ip_stall_ctrl == 1'b1) begin
			reg_ID_EX_pc_addr[31:0] <= reg_ID_EX_pc_addr[31:0];
			reg_ID_EX_imm[24:0] <= reg_ID_EX_imm[24:0];
			reg_ID_EX_rs1_addr[4:0] = reg_ID_EX_rs1_addr[4:0];
			reg_ID_EX_rs2_addr[4:0] = reg_ID_EX_rs2_addr[4:0];
			reg_ID_EX_rd_addr[4:0] <= reg_ID_EX_rd_addr[4:0];
			reg_ID_EX_funct_3[2:0] <= reg_ID_EX_funct_3[2:0];
			reg_ID_EX_rs1[31:0] <= reg_ID_EX_rs1[31:0];
			reg_ID_EX_rs2[31:0] <= reg_ID_EX_rs2[31:0];
			reg_ID_EX_load_store_bit_ctrl[1:0] <= reg_ID_EX_load_store_bit_ctrl[1:0];
			reg_ID_EX_reg_wr_en <= reg_ID_EX_reg_wr_en;
			reg_ID_EX_wb_ctrl <= reg_ID_EX_wb_ctrl;
			reg_ID_EX_jump_ctrl <= reg_ID_EX_jump_ctrl;
			reg_ID_EX_load_sign_ctrl <= reg_ID_EX_load_sign_ctrl;
			reg_ID_EX_store_en <= reg_ID_EX_store_en;
			reg_ID_EX_m_ext_wb_ctrl <= reg_ID_EX_m_ext_wb_ctrl;
			reg_ID_EX_imm_ext_ctrl[2:0] <= reg_ID_EX_imm_ext_ctrl[2:0];
			reg_ID_EX_ALU_operation_ctrl[2:0] <= reg_ID_EX_ALU_operation_ctrl[2:0];
			reg_ID_EX_ALU_branch_ctrl[2:0] <= reg_ID_EX_ALU_branch_ctrl[2:0];
			reg_ID_EX_ALU_operand_a_ctrl[1:0] <= reg_ID_EX_ALU_operand_a_ctrl[1:0];
			reg_ID_EX_ALU_operand_b_ctrl[1:0] <= reg_ID_EX_ALU_operand_b_ctrl[1:0];
			reg_ID_EX_ALU_result_ctrl[1:0] <= reg_ID_EX_ALU_result_ctrl[1:0];
			reg_ID_EX_ALU_sign_ctrl <= reg_ID_EX_ALU_sign_ctrl;
			reg_ID_EX_ALU_shift_direction_ctrl <= reg_ID_EX_ALU_shift_direction_ctrl;
			reg_ID_EX_ALU_addr_ctrl <= reg_ID_EX_ALU_addr_ctrl;
		end
		
		else if (ip_stall_ctrl == 1'b0) begin
			reg_ID_EX_pc_addr[31:0] <= w_ID_pc_addr[31:0];
			reg_ID_EX_imm[24:0] <= w_ID_imm[24:0];
			reg_ID_EX_rs1_addr[4:0] = w_ID_rs1_addr[4:0];
			reg_ID_EX_rs2_addr[4:0] = w_ID_rs2_addr[4:0];
			reg_ID_EX_rd_addr[4:0] <= w_ID_rd_addr[4:0];
			reg_ID_EX_funct_3[2:0] <= w_ID_funct_3[2:0];
			reg_ID_EX_rs1[31:0] <= w_ID_rs1[31:0];
			reg_ID_EX_rs2[31:0] <= w_ID_rs2[31:0];
			reg_ID_EX_load_store_bit_ctrl[1:0] = w_ID_load_store_bit_ctrl[1:0];
			reg_ID_EX_reg_wr_en <= w_ID_reg_wr_en;
			reg_ID_EX_wb_ctrl <= w_ID_wb_ctrl;
			reg_ID_EX_jump_ctrl <= w_ID_jump_ctrl;
			reg_ID_EX_load_sign_ctrl <= w_ID_load_sign_ctrl;
			reg_ID_EX_store_en <= w_ID_store_en;
			reg_ID_EX_m_ext_wb_ctrl <= w_ID_m_ext_wb_ctrl;
			reg_ID_EX_imm_ext_ctrl[2:0] <= w_ID_imm_ext_ctrl[2:0];
			reg_ID_EX_ALU_operation_ctrl[2:0] <= w_ID_ALU_operation_ctrl[2:0];
			reg_ID_EX_ALU_branch_ctrl[2:0] <= w_ID_ALU_branch_ctrl[2:0];
			reg_ID_EX_ALU_operand_a_ctrl[1:0] <= w_ID_ALU_operand_a_ctrl[1:0];
			reg_ID_EX_ALU_operand_b_ctrl[1:0] <= w_ID_ALU_operand_b_ctrl[1:0];
			reg_ID_EX_ALU_result_ctrl[1:0] <= w_ID_ALU_result_ctrl[1:0];
			reg_ID_EX_ALU_sign_ctrl <= w_ID_ALU_sign_ctrl;
			reg_ID_EX_ALU_shift_direction_ctrl <= w_ID_ALU_shift_direction_ctrl;
			reg_ID_EX_ALU_addr_ctrl <= w_ID_ALU_addr_ctrl;
		end
	end
end

// EX stage
assign w_EX_pc_addr[31:0] = reg_ID_EX_pc_addr[31:0];
assign w_EX_imm[24:0] = reg_ID_EX_imm[24:0];
assign w_EX_rs1_addr[4:0] = reg_ID_EX_rs1_addr[4:0];
assign w_EX_rs2_addr[4:0] = reg_ID_EX_rs2_addr[4:0];
assign w_EX_rd_addr[4:0] = reg_ID_EX_rd_addr[4:0];
assign w_EX_funct_3[2:0] = reg_ID_EX_funct_3[2:0];
assign w_EX_rs1_ID[31:0] = reg_ID_EX_rs1[31:0];
assign w_EX_rs2_ID[31:0] = reg_ID_EX_rs2[31:0];
assign w_EX_load_store_bit_ctrl[1:0] = reg_ID_EX_load_store_bit_ctrl[1:0];
assign w_EX_reg_wr_en = reg_ID_EX_reg_wr_en;
assign w_EX_wb_ctrl = reg_ID_EX_wb_ctrl;
assign w_EX_jump_ctrl = reg_ID_EX_jump_ctrl;
assign w_EX_load_sign_ctrl = reg_ID_EX_load_sign_ctrl;
assign w_EX_store_en = reg_ID_EX_store_en;
assign w_EX_m_ext_wb_ctrl = reg_ID_EX_m_ext_wb_ctrl;
assign w_EX_imm_ext_ctrl[2:0] = reg_ID_EX_imm_ext_ctrl[2:0];
assign w_EX_ALU_operation_ctrl[2:0] = reg_ID_EX_ALU_operation_ctrl[2:0];
assign w_EX_ALU_branch_ctrl[2:0] = reg_ID_EX_ALU_branch_ctrl[2:0];
assign w_EX_ALU_operand_a_ctrl[1:0] = reg_ID_EX_ALU_operand_a_ctrl[1:0];
assign w_EX_ALU_operand_b_ctrl[1:0] = reg_ID_EX_ALU_operand_b_ctrl[1:0];
assign w_EX_ALU_result_ctrl[1:0] = reg_ID_EX_ALU_result_ctrl[1:0];
assign w_EX_ALU_sign_ctrl = reg_ID_EX_ALU_sign_ctrl;
assign w_EX_ALU_shift_direction_ctrl = reg_ID_EX_ALU_shift_direction_ctrl;
assign w_EX_ALU_addr_ctrl = reg_ID_EX_ALU_addr_ctrl;

// data forward control
assign forward_rs1_ctrl[0] = w_MEM_reg_wr_en & (~|(w_EX_rs1_addr[4:0] ^ w_MEM_rd_addr[4:0])) & (|w_EX_rs1_addr[4:0]); // rs1 = MEM stage rd
assign forward_rs1_ctrl[1] = w_WB_reg_wr_en & (~|(w_EX_rs1_addr[4:0] ^ w_WB_rd_addr[4:0])) & (|w_EX_rs1_addr[4:0]); // rs1 = WB stage rd
assign forward_rs2_ctrl[0] = w_MEM_reg_wr_en & (~|(w_EX_rs2_addr[4:0] ^ w_MEM_rd_addr[4:0])) & (|w_EX_rs2_addr[4:0]); // rs2 = MEM stage rd
assign forward_rs2_ctrl[1] = w_WB_reg_wr_en & (~|(w_EX_rs2_addr[4:0] ^ w_WB_rd_addr[4:0])) & (|w_EX_rs2_addr[4:0]); // rs2 = WB stage rd

// data forward assignment
assign w_EX_rs1[31:0] = (forward_rs1_ctrl[1:0] == 2'b01) ? w_MEM_wb_data[31:0] : ((forward_rs1_ctrl[1:0] == 2'b10) ? reg_MEM_WB_wb_data : w_EX_rs1_ID[31:0]); // data select for rs1
assign w_EX_rs2[31:0] = (forward_rs2_ctrl[1:0] == 2'b01) ? w_MEM_wb_data[31:0] : ((forward_rs2_ctrl[1:0] == 2'b10) ? reg_MEM_WB_wb_data : w_EX_rs2_ID[31:0]); // data select for rs1

// ALU connection
ALU
ahrithmetic_logical_unit(
	.ip_rs1(w_EX_rs1),
	.ip_rs2(w_EX_rs2),
	.ip_pc_addr(w_EX_pc_addr),
	.ip_imm(w_EX_imm),
	.ip_imm_ext_ctrl(w_EX_imm_ext_ctrl),
	.ip_ALU_operation_ctrl(w_EX_ALU_operation_ctrl),
	.ip_branch_ctrl(w_EX_ALU_branch_ctrl),
	.ip_operand_a_ctrl(w_EX_ALU_operand_a_ctrl),
	.ip_operand_b_ctrl(w_EX_ALU_operand_b_ctrl),
	.ip_result_ctrl(w_EX_ALU_result_ctrl),
	.ip_clk(ip_clk),
	.ip_sign_ctrl(w_EX_ALU_sign_ctrl),
	.ip_shift_direction_ctrl(w_EX_ALU_shift_direction_ctrl),
	.ip_addr_ctrl(w_EX_ALU_addr_ctrl),
	.op_result(w_EX_ALU_result),
	.op_target_addr(w_EX_target_addr),
	.op_overflow(w_EX_ALU_overflow),
	.op_branch_ctrl(w_EX_branch_addr_ctrl)
);

// M extension connection
m_ext
multiplication_extention(
	.ip_rs1(w_EX_rs1),
	.ip_rs2(w_EX_rs2),
	.ip_funct_3(w_EX_funct_3),
	.ip_clk(ip_clk),
	.op_result(w_EX_m_ext_result),
	.op_overflow(w_EX_m_ext_overflow)
);

// EX stage wire assignment
assign w_EX_jump_branch_ctrl = w_EX_jump_ctrl | w_EX_branch_addr_ctrl; // if jump or branch
assign w_EX_result[31:0] = (w_EX_m_ext_wb_ctrl == 1'b1) ? w_EX_m_ext_result[31:0] : w_EX_ALU_result[31:0]; // EX stage result selection

// EX->MEM pipeline
always @(posedge ip_clk or posedge ip_rst) begin
	if(ip_rst == 1'b1) begin
		reg_EX_MEM_rd_addr[4:0] = 5'b0;
		reg_EX_MEM_rs2[31:0] = 32'b0;
		reg_EX_MEM_load_store_bit_ctrl[1:0] = 2'b0;
		reg_EX_MEM_reg_wr_en = 1'b0;
		reg_EX_MEM_wb_ctrl = 1'b0;
		reg_EX_MEM_load_sign_ctrl = 1'b0;
		reg_EX_MEM_store_en = 1'b0;
		reg_EX_MEM_result[31:0] = 32'b0;
	end
	
	else if(ip_rst == 1'b0) begin
		if (ip_stall_ctrl == 1'b1) begin
			reg_EX_MEM_rd_addr[4:0] <= reg_EX_MEM_rd_addr[4:0];
			reg_EX_MEM_rs2[31:0] <= reg_EX_MEM_rs2[31:0];
			reg_EX_MEM_load_store_bit_ctrl[1:0] <= reg_EX_MEM_load_store_bit_ctrl[1:0];
			reg_EX_MEM_reg_wr_en <= reg_EX_MEM_reg_wr_en;
			reg_EX_MEM_wb_ctrl <= reg_EX_MEM_wb_ctrl;
			reg_EX_MEM_load_sign_ctrl <= reg_EX_MEM_load_sign_ctrl;
			reg_EX_MEM_store_en <= reg_EX_MEM_store_en;
			reg_EX_MEM_result[31:0] <= reg_EX_MEM_result[31:0];
		end
		
		else if (ip_stall_ctrl == 1'b0) begin
			reg_EX_MEM_rd_addr[4:0] <= w_EX_rd_addr[4:0];
			reg_EX_MEM_rs2[31:0] <= w_EX_rs2[31:0];
			reg_EX_MEM_load_store_bit_ctrl[1:0] <= w_EX_load_store_bit_ctrl[1:0];
			reg_EX_MEM_reg_wr_en <= w_EX_reg_wr_en;
			reg_EX_MEM_wb_ctrl <= w_EX_wb_ctrl;
			reg_EX_MEM_load_sign_ctrl <= w_EX_load_sign_ctrl;
			reg_EX_MEM_store_en <= w_EX_store_en;
			reg_EX_MEM_result[31:0] <= w_EX_result[31:0];
		end
	end
end

// MEM stage
assign w_MEM_rd_addr[4:0] = reg_EX_MEM_rd_addr[4:0];
assign w_MEM_rs2[31:0] = reg_EX_MEM_rs2[31:0];
assign w_MEM_load_store_bit_ctrl[1:0] = reg_EX_MEM_load_store_bit_ctrl[1:0];
assign w_MEM_reg_wr_en = reg_EX_MEM_reg_wr_en;
assign w_MEM_wb_ctrl = reg_EX_MEM_wb_ctrl;
assign w_MEM_load_sign_ctrl = reg_EX_MEM_load_sign_ctrl;
assign w_MEM_store_en = reg_EX_MEM_store_en;
assign w_MEM_result[31:0] = reg_EX_MEM_result[31:0];

// data memory connection
data_mem
data_memory(
	.ip_addr(w_MEM_result),
	.ip_store_data(w_MEM_rs2),
	.ip_load_store_bit_ctrl(w_MEM_load_store_bit_ctrl),
	.ip_clk(ip_clk),
	.ip_rst(ip_rst),
	.ip_load_sign_ctrl(w_MEM_load_sign_ctrl),
	.ip_store_en(w_MEM_store_en),
	.op_read_data(w_MEM_read_data)
);

// write back data wire assignment
assign w_MEM_wb_data[31:0] = (w_MEM_wb_ctrl == 1'b1) ? w_MEM_read_data[31:0] : w_MEM_result[31:0]; // data from EX stage or data memory


// MEM->WB pipeline
always @(posedge ip_clk or posedge ip_rst) begin
	if(ip_rst == 1'b1) begin
		reg_MEM_WB_rd_addr[4:0] = 5'b0;
		reg_MEM_WB_reg_wr_en = 1'b0;
		reg_MEM_WB_wb_data[31:0] = 32'b0;
	end
	
	else if(ip_rst == 1'b0) begin
		if (ip_stall_ctrl == 1'b1) begin
			reg_MEM_WB_rd_addr[4:0] <= reg_MEM_WB_rd_addr[4:0];
			reg_MEM_WB_reg_wr_en <= reg_MEM_WB_reg_wr_en;
			reg_MEM_WB_wb_data[31:0] <= reg_MEM_WB_wb_data[31:0];
		end
		
		else if (ip_stall_ctrl == 1'b0) begin
			reg_MEM_WB_rd_addr[4:0] <= w_MEM_rd_addr[4:0];
			reg_MEM_WB_reg_wr_en <= w_MEM_reg_wr_en;
			reg_MEM_WB_wb_data[31:0] <= w_MEM_wb_data[31:0];
		end
	end
end

// WB stage
assign w_WB_rd_addr[4:0] = reg_MEM_WB_rd_addr[4:0];
assign w_WB_reg_wr_en = reg_MEM_WB_reg_wr_en;
assign w_WB_wb_data[31:0] = reg_MEM_WB_wb_data[31:0];

// output overflow
assign op_overflow = w_EX_ALU_overflow | (w_EX_m_ext_overflow & w_EX_m_ext_wb_ctrl);

endmodule
