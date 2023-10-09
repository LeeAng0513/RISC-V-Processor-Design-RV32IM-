/**********************************************************************
Project: Develop 32-bit RISC-V Processor
Module: ALU_tb.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: ALU Test Bench
**********************************************************************/

`include "macro.v"
`default_nettype none

module ALU_tb
#(
parameter AND = 3'b000,
parameter OR = 3'b001,
parameter XOR = 3'b010,
parameter ADD = 3'b011,
parameter SUB = 3'b111
)
();

reg ip_clk_tb;
reg [31:0] ip_rs1_tb, ip_rs2_tb, ip_pc_tb, ip_imm_ext_tb;
reg [2:0] ip_ALU_operation_ctrl_tb, ip_branch_ctrl_tb;
reg [1:0] ip_operand_a_ctrl_tb, ip_operand_b_ctrl_tb, ip_result_ctrl_tb;
reg ip_sign_ctrl_tb, ip_shift_direction_ctrl_tb, ip_addr_ctrl_tb;
wire [31:0] op_result_tb, op_target_addr_tb;
wire op_overflow_tb, op_branch_ctrl_tb;

ALU
dut_ALU(
	.ip_clk(ip_clk_tb),
	.ip_rs1(ip_rs1_tb),
	.ip_rs2(ip_rs2_tb),
	.ip_pc(ip_pc_tb),
	.ip_imm_ext(ip_imm_ext_tb),
	.ip_ALU_operation_ctrl(ip_ALU_operation_ctrl_tb),
	.ip_branch_ctrl(ip_branch_ctrl_tb),
	.ip_operand_a_ctrl(ip_operand_a_ctrl_tb),
	.ip_operand_b_ctrl(ip_operand_b_ctrl_tb),
	.ip_result_ctrl(ip_result_ctrl_tb),
	.ip_sign_ctrl(ip_sign_ctrl_tb),
	.ip_shift_direction_ctrl(ip_shift_direction_ctrl_tb),
	.ip_addr_ctrl(ip_addr_ctrl_tb),
	.op_result(op_result_tb),
	.op_target_addr(op_target_addr_tb),
	.op_overflow(op_overflow_tb),
	.op_branch_ctrl(op_branch_ctrl_tb)
);

initial ip_clk_tb <= 1'b1;
always #(`PERIOD_HALF) ip_clk_tb = ~ip_clk_tb;

initial begin
	@(posedge ip_clk_tb) // initialize the value (at sim time 1)
		ip_rs1_tb[31:0] = 32'b0;
		ip_rs2_tb[31:0] = 32'b0;
		ip_pc_tb[31:0] = 32'b0;
		ip_imm_ext_tb[31:0] = 32'b0;
		ip_ALU_operation_ctrl_tb[2:0] = 3'b000;
		ip_branch_ctrl_tb[2:0] = 3'b000;
		ip_operand_a_ctrl_tb[1:0] = 2'b00;
		ip_operand_b_ctrl_tb[1:0] = 2'b00;
		ip_result_ctrl_tb[1:0] = 2'b00;
		ip_sign_ctrl_tb = 1'b0;
		ip_shift_direction_ctrl_tb = 1'b0;
		ip_addr_ctrl_tb = 1'b0;
	
	// test case 1 (LUI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_imm_ext_tb[31:0] = 32'h0C7C8000; // 00001100011111001000000000000000
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using add
		ip_operand_a_ctrl_tb[1:0] = 2'b10; // select 32'b0 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // seelct immediate data as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 2 (AUIPC with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_pc_tb[31:0] = 32'h00001000; // starting address
		ip_imm_ext_tb[31:0] = 32'h0044E000; // offset (0044E000)
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using add
		ip_operand_a_ctrl_tb[1:0] = 2'b01; // select pc address as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // seelct immediate data as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 3 (JAL with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_pc_tb[31:0] = 32'h00001400; // instruction address
		ip_imm_ext_tb[31:0] = 32'h00000128; // offset (128)
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using add
		ip_operand_a_ctrl_tb[1:0] = 2'b01; // select pc address as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b10; // select 32'h00000004 as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address
	
	// test case 4 (JALR with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h00000100; // address
		ip_pc_tb[31:0] = 32'h00001020; // instruction address
		ip_imm_ext_tb[31:0] = 32'h0000014C; // offset (14C)
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using add
		ip_operand_a_ctrl_tb[1:0] = 2'b01; // select pc address as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b10; // select 32'h00000004 as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b1; // select rs1 as address
	
	// test case 5 (BEQ with two signed value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h00006457; // 6613016
		ip_rs2_tb[31:0] = 32'h00006457; // 6613016
		ip_pc_tb[31:0] = 32'h00000400; // instruction address
		ip_imm_ext_tb[31:0] = 32'h00000670; // offset (670)
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b100; // BEQ
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address

	// test case 6 (BEQ with two signed value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFFF1CE; // -3634
		ip_rs2_tb[31:0] = 32'hFFFF577B; // -43141
		ip_pc_tb[31:0] = 32'h00000560; // instruction address
		ip_imm_ext_tb[31:0] = 32'h00000F08; // offset (F08)
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b100; // BEQ
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address
	
	// test case 7 (BNE with two signed value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFF9C6C; // -25492
		ip_rs2_tb[31:0] = 32'hFFF482E3; // -752925
		ip_pc_tb[31:0] = 32'h0000348C; // instruction address
		ip_imm_ext_tb[31:0] = 32'hFFFFF2B0; // offset (F2B0, negetive offset)
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b101; // BNE
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address
	
	// test case 8 (BNE with two signed value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFF332EC; // -838932
		ip_rs2_tb[31:0] = 32'hFFF332EC; // -838932
		ip_pc_tb[31:0] = 32'h00002D20; // instruction address
		ip_imm_ext_tb[31:0] = 32'hFFFFF644; // offset (F644, negetive offset)
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b101; // BNE
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address
	
	// test case 9 (BLT with two signed value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h80000000; // -2147483648
		ip_rs2_tb[31:0] = 32'h7FFFFFFF; // 2147483647
		ip_pc_tb[31:0] = 32'h00003000; // instruction address
		ip_imm_ext_tb[31:0] = 32'h0000011E; // offset (11E)
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b110; // BLT
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address
	
	// test case 10 (BLT with two signed value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h7FFFFFFF; // 2147483647
		ip_rs2_tb[31:0] = 32'h80000000; // -2147483648
		ip_pc_tb[31:0] = 32'h00001A00; // instruction address
		ip_imm_ext_tb[31:0] = 32'h00000A62; // offset (A62)
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b110; // BLT
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address
	
	// test case 11 (BGE with two signed value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h7FFFFFFF; // 2147483647
		ip_rs2_tb[31:0] = 32'h7FFFFFFE; // 2147483646
		ip_pc_tb[31:0] = 32'h00000C70; // instruction address
		ip_imm_ext_tb[31:0] = 32'h00000584; // offset (584)
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b111; // BGE
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address
	
	// test case 12 (BGE with two signed value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h80000000; // -2147483648
		ip_rs2_tb[31:0] = 32'h80000001; // -2147483647
		ip_pc_tb[31:0] = 32'h00002D00; // instruction address
		ip_imm_ext_tb[31:0] = 32'hFFFFF5BC; // offset (F5BC, negetive offset)
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b111; // BGE
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address
	
	// test case 13 (BLTU with two unsigned value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hAAAAFFFE; // 2863333374
		ip_rs2_tb[31:0] = 32'hAAAAFFFF; // 2863333375
		ip_pc_tb[31:0] = 32'h00000040; // instruction address
		ip_imm_ext_tb[31:0] = 32'h00000126; // offset (126)
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b110; // BLT
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b1; // unsigned
		ip_addr_ctrl_tb = 1'b0; // select pc address
	
	// test case 14 (BLTU with two unsigned value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFFFFFF; // 4294967295
		ip_rs2_tb[31:0] = 32'hFFFFFFFF; // 4294967295
		ip_pc_tb[31:0] = 32'h00001240; // instruction address
		ip_imm_ext_tb[31:0] = 32'h00000394; // offset (394)
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b110; // BLT
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b1; // unsigned
		ip_addr_ctrl_tb = 1'b0; // select pc address
	
	// test case 15 (BGEU with two unsigned value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h80008000; // 2147516416
		ip_rs2_tb[31:0] = 32'h80008000; // 2147516416
		ip_pc_tb[31:0] = 32'h00001EE0; // instruction address
		ip_imm_ext_tb[31:0] = 32'h00000C38; // offset (C38)
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b111; // BGE
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b1; // unsigned
		ip_addr_ctrl_tb = 1'b0; // select pc address
	
	// test case 16 (BGEU with two unsigned value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h12345678; // 305419896
		ip_rs2_tb[31:0] = 32'hFEDCBA98; // 4275878552
		ip_pc_tb[31:0] = 32'h000005A0; // instruction address
		ip_imm_ext_tb[31:0] = 32'h00000B2C; // offset (B2C)
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b111; // BGE
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b1; // unsigned
		ip_addr_ctrl_tb = 1'b0; // select pc address
	
	// test case 17 (load instruction with one immediate value, LW)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h00004000; // address
		ip_rs2_tb[31:0] = 32'h00000000;
		ip_pc_tb[31:0] = 32'h0;
		ip_imm_ext_tb[31:0] = 32'h000001F4; // offset (1F4)
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using addition
		ip_branch_ctrl_tb[2:0] = 3'b000;
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 18 (store instruction with one immediate value, SW)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h000054C0; // address
		ip_rs2_tb[31:0] = 32'h00000ABC; // data to store
		ip_imm_ext_tb[31:0] = 32'h000002A9; // offset (2A9)
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using addition
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 19 (ADDI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h00015C7B; // 89211
		ip_rs2_tb[31:0] = 32'h00000000;
		ip_imm_ext_tb[31:0] = 32'h000006C3; // 6C3, 1731
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using addition
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 20 (SLTI with one immediate value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h000002B4; // 692
		ip_imm_ext_tb[31:0] = 32'h00000451; // 451, 1105
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b01; // output from SLT result
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 21 (SLTI with one immediate value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFFFFBA; // -70
		ip_imm_ext_tb[31:0] = 32'hFFFFFDA9; // DA9, -599
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b01; // output from SLT result
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 22 (SLTIU with one immediate unsigned value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h0000033A; // 826
		ip_imm_ext_tb[31:0] = 32'h00000FFF; // FFF, 4095
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b01; // output from SLT result
		ip_sign_ctrl_tb = 1'b1; // unsigned
	
	// test case 23 (SLTIU with one immediate unsigned value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFFFFFF; // 4294967295
		ip_imm_ext_tb[31:0] = 32'h000007FF; // 7FF, 2047
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b01; // output from SLT result
		ip_sign_ctrl_tb = 1'b1; // unsigned
	
	// test case 24 (XORI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFF0000; // -65536
		ip_imm_ext_tb[31:0] = 32'h00000555; // 555, 1356
		ip_ALU_operation_ctrl_tb[2:0] = XOR; // using XOR
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 25 (ORI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h33333333; // 858993459
		ip_imm_ext_tb[31:0] = 32'h00000666; // 666, 1638
		ip_ALU_operation_ctrl_tb[2:0] = OR; // using OR
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 26 (ANDI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h99999999; // -1717986919
		ip_imm_ext_tb[31:0] = 32'hFFFFFCCC; // CCC, -820
		ip_ALU_operation_ctrl_tb[2:0] = AND; // using AND
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 27 (SLLI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hF0F0F0F0; // 4042322160
		ip_imm_ext_tb[31:0] = 32'h00000014; // 14, 20
		ip_ALU_operation_ctrl_tb[2:0] = 3'b000;
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b10; // output from barrel shifter
		ip_sign_ctrl_tb = 1'b1; // logical
		ip_shift_direction_ctrl_tb = 1'b0; // shift left

	// test case 28 (SRLI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h0F0F0F0F; // 252645135
		ip_imm_ext_tb[31:0] = 32'h00000009; // 9, 9
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b10; // output from barrel shifter
		ip_sign_ctrl_tb = 1'b1; // logical
		ip_shift_direction_ctrl_tb = 1'b1; // shift right

	// test case 29 (SRAI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFF00FF00; // 4278255360
		ip_imm_ext_tb[31:0] = 32'h00000012; // 12, 18
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b10; // output from barrel shifter
		ip_sign_ctrl_tb = 1'b0; // arithmetic
		ip_shift_direction_ctrl_tb = 1'b1; // shift right
	
	// test case 30 (ADD with two signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h00015C7B; // 89211
		ip_rs2_tb[31:0] = 32'hFF695C16; // -9872362
		ip_imm_ext_tb[31:0] = 32'h0;
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using addition
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_shift_direction_ctrl_tb = 1'b0;
	
	// test case 31 (SUB with two signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h0009B52D; // 636205
		ip_rs2_tb[31:0] = 32'hFFFF4CDA; // -45862
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 32 (SLL with two signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hF0F0F0F0; // 4042322160
		ip_rs2_tb[31:0] = 32'h0000000C; // 12
		ip_ALU_operation_ctrl_tb[2:0] = 3'b000;
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b10; // output from barrel shifter
		ip_sign_ctrl_tb = 1'b1; // logical
		ip_shift_direction_ctrl_tb = 1'b0; // shift left
	
	// test case 33 (SLT with two signed value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h000A7B97; // 686999
		ip_rs2_tb[31:0] = 32'h005B4C8F; // 65983375
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b01; // output from SLT result
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 34 (SLT with two signed value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFFFFBA; // -70
		ip_rs2_tb[31:0] = 32'hFFD534E9; // -2804503
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b01; // output from SLT result
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 35 (SLTU with two unsigned value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h0000033A; // 826
		ip_rs2_tb[31:0] = 32'hFFD534EB; // 4292162795
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b01; // output from SLT result
		ip_sign_ctrl_tb = 1'b1; // unsigned
	
	// test case 36 (SLTU with two unsigned value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFFFFFF; // 4294967295
		ip_rs2_tb[31:0] = 32'h00000001; // 1
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b01; // output from SLT result
		ip_sign_ctrl_tb = 1'b1; // unsigned
	
	// test case 37 (XOR with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFF0000; // -65536
		ip_rs2_tb[31:0] = 32'hFF00FF00; // -16711936
		ip_ALU_operation_ctrl_tb[2:0] = XOR; // using XOR
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 38 (SRL with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h00FF00FF; // 16711935
		ip_rs2_tb[31:0] = 32'h00000004; // 4
		ip_ALU_operation_ctrl_tb[2:0] = 3'b000;
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b10; // output from barrel shifter
		ip_sign_ctrl_tb = 1'b1; // logical
		ip_shift_direction_ctrl_tb = 1'b1; // shift right

	// test case 39 (SRA with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h000CCCCC; // 838860
		ip_rs2_tb[31:0] = 32'h0000000A; // 10
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b10; // output from barrel shifter
		ip_sign_ctrl_tb = 1'b0; // arithmetic
		ip_shift_direction_ctrl_tb = 1'b1; // shift right
	
	// test case 40 (OR with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h33333333; // 858993459
		ip_rs2_tb[31:0] = 32'h0000FFFF; // 65535
		ip_ALU_operation_ctrl_tb[2:0] = OR; // using OR
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 41 (AND with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h99999999; // -1717986919
		ip_rs2_tb[31:0] = 32'h44444444; // 1145324612
		ip_ALU_operation_ctrl_tb[2:0] = AND; // using AND
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 42 (ADD with overflow condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h7FFFFFFF; // 2147483647
		ip_rs2_tb[31:0] = 32'h00000001; // 1
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using addition
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 42 (SUB with overflow condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hF0000000; // -268435456
		ip_rs2_tb[31:0] = 32'h7FFFFFFF; // 2147483647
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 43 (SRA with overflow condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h000CCCCC; // 838860
		ip_rs2_tb[31:0] = 32'h00000030; // 48
		ip_ALU_operation_ctrl_tb[2:0] = 3'b000;
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_result_ctrl_tb[1:0] = 2'b10; // output from barrel shifter
		ip_sign_ctrl_tb = 1'b0; // arithmetic
		ip_shift_direction_ctrl_tb = 1'b1; // shift right
	
	repeat(2) @(posedge ip_clk_tb) begin // 1 cycle to compute the result
		ip_rs1_tb[31:0] = 32'h0;
		ip_rs2_tb[31:0] = 32'h0;
		ip_result_ctrl_tb[1:0] = 2'b00;
		ip_shift_direction_ctrl_tb = 1'b0;
	end
	
	$stop; // To stop simulation.
end
endmodule