/**********************************************************************
Project: 32-bit RISC-V Processor 
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
reg [31:0] ip_rs1_tb, ip_rs2_tb, ip_pc_addr_tb;
reg [24:0] ip_imm_tb;
reg [2:0] ip_imm_ext_ctrl_tb, ip_ALU_operation_ctrl_tb, ip_branch_ctrl_tb;
reg [1:0] ip_operand_a_ctrl_tb, ip_operand_b_ctrl_tb, ip_result_ctrl_tb;
reg ip_clk_tb, ip_sign_ctrl_tb, ip_shift_direction_ctrl_tb, ip_addr_ctrl_tb;
wire [31:0] op_result_tb, op_target_addr_tb;
wire op_overflow_tb, op_branch_ctrl_tb;

ALU
dut_ALU(
	.ip_rs1(ip_rs1_tb),
	.ip_rs2(ip_rs2_tb),
	.ip_pc_addr(ip_pc_addr_tb),
	.ip_imm(ip_imm_tb),
	.ip_imm_ext_ctrl(ip_imm_ext_ctrl_tb),
	.ip_ALU_operation_ctrl(ip_ALU_operation_ctrl_tb),
	.ip_branch_ctrl(ip_branch_ctrl_tb),
	.ip_operand_a_ctrl(ip_operand_a_ctrl_tb),
	.ip_operand_b_ctrl(ip_operand_b_ctrl_tb),
	.ip_result_ctrl(ip_result_ctrl_tb),
	.ip_clk(ip_clk_tb),
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
		ip_pc_addr_tb[31:0] = 32'b0;
		ip_imm_tb[24:0] = 25'b0;
		ip_imm_ext_ctrl_tb[2:0] = 3'b000;
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
		ip_imm_tb[24:0] = 25'h018F900; // 0 0001 1000 1111 1001 0000 0000
		ip_imm_ext_ctrl_tb[2:0] = 3'b001; // upper immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using add
		ip_operand_a_ctrl_tb[1:0] = 2'b10; // select 32'b0 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // seelct immediate data as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 2 (AUIPC with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_pc_addr_tb[31:0] = 32'h00008000; // starting address
		ip_imm_tb[24:0] = 25'h00089C0; // offset (0044E000)
		ip_imm_ext_ctrl_tb[2:0] = 3'b001; // upper immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using add
		ip_operand_a_ctrl_tb[1:0] = 2'b01; // select pc address as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // seelct immediate data as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 3 (JAL with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_pc_addr_tb[31:0] = 32'h00008400; // instruction address
		ip_imm_tb[24:0] = 25'h0001280; // offset (94 x 2 = 128)
		ip_imm_ext_ctrl_tb[2:0] = 3'b010; // JAL immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using add
		ip_operand_a_ctrl_tb[1:0] = 2'b01; // select pc address as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b10; // select 32'b00000004 as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address
	
	// test case 4 (JALR with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h00010000; // address
		ip_pc_addr_tb[31:0] = 32'h00008020; // instruction address
		ip_imm_tb[24:0] = 25'h014C202; // offset (A6 x 2 = 14C)
		ip_imm_ext_ctrl_tb[2:0] = 3'b011; // immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using add
		ip_operand_a_ctrl_tb[1:0] = 2'b01; // select pc address as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b10; // select 32'b00000004 as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b1; // select rs1 as address
	
	// test case 5 (BEQ with two signed value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h00006457; // 6613016
		ip_rs2_tb[31:0] = 32'h00006457; // 6613016
		ip_pc_addr_tb[31:0] = 32'h00024000; // instruction address
		ip_imm_tb[24:0] = 25'h064E818; // offset (338 x 2 = 670)
		ip_imm_ext_ctrl_tb[2:0] = 3'b100; // branch / store immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b100; // BEQ
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address as address

	// test case 6 (BEQ with two signed value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFFF1CE; // -3634
		ip_rs2_tb[31:0] = 32'hFFFF577B; // -43141
		ip_pc_addr_tb[31:0] = 32'h0008560; // instruction address
		ip_imm_tb[24:0] = 25'h0F0E804; // offset (784 x 2 = F08)
		ip_imm_ext_ctrl_tb[2:0] = 3'b100; // branch / store immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b100; // BEQ
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address as address
	
	// test case 7 (BNE with two signed value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFF9C6C; // -25492
		ip_rs2_tb[31:0] = 32'hFFF482E3; // -752925
		ip_pc_addr_tb[31:0] = 32'h0097AC00; // instruction address
		ip_imm_tb[24:0] = 25'h128E838; // offset (F958 x 2 = F2B0, negetive offset)
		ip_imm_ext_ctrl_tb[2:0] = 3'b100; // branch / store immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b101; // BNE
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address as address
	
	// test case 8 (BNE with two signed value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFF332EC; // -838932
		ip_rs2_tb[31:0] = 32'hFFF332EC; // -838932
		ip_pc_addr_tb[31:0] = 32'h001BD00; // instruction address
		ip_imm_tb[24:0] = 25'h164E822; // offset (B22 x 2 = F644, negetive offset)
		ip_imm_ext_ctrl_tb[2:0] = 3'b100; // branch / store immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b101; // BNE
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address as address
	
	// test case 9 (BLT with two signed value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h80000000; // -2147483648
		ip_rs2_tb[31:0] = 32'h7FFFFFFF; // 2147483647
		ip_pc_addr_tb[31:0] = 32'h000F4000; // instruction address
		ip_imm_tb[24:0] = 25'h010E84F; // offset (8F x 2 = 11E)
		ip_imm_ext_ctrl_tb[2:0] = 3'b100; // branch / store immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b110; // BLT
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address as address
	
	// test case 10 (BLT with two signed value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h7FFFFFFF; // 2147483647
		ip_rs2_tb[31:0] = 32'h80000000; // -2147483648
		ip_pc_addr_tb[31:0] = 32'h00301000; // instruction address
		ip_imm_tb[24:0] = 25'h0A4E891; // offset (531 x 2 = A62)
		ip_imm_ext_ctrl_tb[2:0] = 3'b100; // branch / store immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b110; // BLT
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address as address
	
	// test case 11 (BGE with two signed value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h7FFFFFFF; // 2147483647
		ip_rs2_tb[31:0] = 32'h7FFFFFFE; // 2147483646
		ip_pc_addr_tb[31:0] = 32'h00A08000; // instruction address
		ip_imm_tb[24:0] = 25'h058E8A2; // offset (2C2 x 2 = 584)
		ip_imm_ext_ctrl_tb[2:0] = 3'b100; // branch / store immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b111; // BGE
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address as address
	
	// test case 12 (BGE with two signed value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h80000000; // -2147483648
		ip_rs2_tb[31:0] = 32'h80000001; // -2147483647
		ip_pc_addr_tb[31:0] = 32'h015C9000; // instruction address
		ip_imm_tb[24:0] = 25'h158E8BE; // offset (ADE x 2 = F5BC, negetive offset)
		ip_imm_ext_ctrl_tb[2:0] = 3'b100; // branch / store immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b111; // BGE
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b0; // signed
		ip_addr_ctrl_tb = 1'b0; // select pc address as address
	
	// test case 13 (BLTU with two unsigned value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hAAAAFFFE; // 2863333374
		ip_rs2_tb[31:0] = 32'hAAAAFFFF; // 2863333375
		ip_pc_addr_tb[31:0] = 32'h000FDF70; // instruction address
		ip_imm_tb[24:0] = 25'h010E8D3; // offset (93 x 2 = 126)
		ip_imm_ext_ctrl_tb[2:0] = 3'b100; // branch / store immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b110; // BLT
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b1; // unsigned
		ip_addr_ctrl_tb = 1'b0; // select pc address as address
	
	// test case 14 (BLTU with two unsigned value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFFFFFF; // 4294967295
		ip_rs2_tb[31:0] = 32'hFFFFFFFF; // 4294967295
		ip_pc_addr_tb[31:0] = 32'h00EE5900; // instruction address
		ip_imm_tb[24:0] = 25'h038E8CA; // offset (1CA x 2 = 394)
		ip_imm_ext_ctrl_tb[2:0] = 3'b100; // branch / store immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b110; // BLT
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b1; // unsigned
		ip_addr_ctrl_tb = 1'b0; // select pc address as address
	
	// test case 15 (BGEU with two unsigned value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h80008000; // 2147516416
		ip_rs2_tb[31:0] = 32'h80008000; // 2147516416
		ip_pc_addr_tb[31:0] = 32'h00704EA0; // instruction address
		ip_imm_tb[24:0] = 25'h0C0E8FC; // offset (61C x 2 = C38)
		ip_imm_ext_ctrl_tb[2:0] = 3'b100; // branch / store immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b111; // BGE
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b1; // unsigned
		ip_addr_ctrl_tb = 1'b0; // select pc address as address
	
	// test case 16 (BGEU with two unsigned value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h12345678; // 305419896
		ip_rs2_tb[31:0] = 32'hFEDCBA98; // 4275878552
		ip_pc_addr_tb[31:0] = 32'h00A90050; // instruction address
		ip_imm_tb[24:0] = 25'h0B0E8F6; // offset (596 x 2 = B2C)
		ip_imm_ext_ctrl_tb[2:0] = 3'b100; // branch / store immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_branch_ctrl_tb[2:0] = 3'b111; // BGE
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b00; // select rs2 as operand b
		ip_sign_ctrl_tb = 1'b1; // unsigned
		ip_addr_ctrl_tb = 1'b0; // select pc address as address
	
	// test case 17 (load instruction with one immediate value, LW)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h02000000; // address
		ip_rs2_tb[31:0] = 32'h00000000;
		ip_pc_addr_tb[31:0] = 32'h0;
		ip_imm_tb[24:0] = 25'h03E8748; // offset (1F4)
		ip_imm_ext_ctrl_tb[2:0] = 3'b011; // immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using addition
		ip_branch_ctrl_tb[2:0] = 3'b000;
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 18 (store instruction with one immediate value, SW)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h02468AC0; // address
		ip_rs2_tb[31:0] = 32'h00000ABC; // data to store
		ip_imm_tb[24:0] = 25'h06D0748; // offset (1F4)
		ip_imm_ext_ctrl_tb[2:0] = 3'b100; // branch / store immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using addition
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 19 (ADDI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h00015C7B; // 89211
		ip_rs2_tb[31:0] = 32'h00000000;
		ip_imm_tb[24:0] = 25'h06C3384; // 6C3, 1731
		ip_imm_ext_ctrl_tb[2:0] = 3'b011; // immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = ADD; // using addition
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 20 (SLTI with one immediate value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h000002B4; // 692
		ip_imm_tb[24:0] = 25'h08A2748; // 451, 1105
		ip_imm_ext_ctrl_tb[2:0] = 3'b011; // immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b01; // output from SLT result
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 21 (SLTI with one immediate value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFFFFBA; // -70
		ip_imm_tb[24:0] = 25'h1B52748; // DA9, -599
		ip_imm_ext_ctrl_tb[2:0] = 3'b011; // immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b01; // output from SLT result
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 22 (SLTIU with one immediate unsigned value and true condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h0000033A; // 826
		ip_imm_tb[24:0] = 25'h1FFE768; // FFF, 4095
		ip_imm_ext_ctrl_tb[2:0] = 3'b011; // immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b01; // output from SLT result
		ip_sign_ctrl_tb = 1'b1; // unsigned
	
	// test case 23 (SLTIU with one immediate unsigned value and false condition)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFFFFFF; // 4294967295
		ip_imm_tb[24:0] = 25'h0FFE768; // 7FF, 2047
		ip_imm_ext_ctrl_tb[2:0] = 3'b011; // immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = SUB; // using subtraction
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b01; // output from SLT result
		ip_sign_ctrl_tb = 1'b1; // unsigned
	
	// test case 24 (XORI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hFFFF0000; // -65536
		ip_imm_tb[24:0] = 25'h0AAA788; // 555, 1356
		ip_imm_ext_ctrl_tb[2:0] = 3'b011; // immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = XOR; // using XOR
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 25 (ORI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h33333333; // 858993459
		ip_imm_tb[24:0] = 25'h0AAA7C8; // 555, 1356
		ip_imm_ext_ctrl_tb[2:0] = 3'b011; // immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = OR; // using OR
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 26 (ANDI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h99999999; // -1717986919
		ip_imm_tb[24:0] = 25'h19987E8; // CCC, -820
		ip_imm_ext_ctrl_tb[2:0] = 3'b011; // immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = AND; // using AND
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b00; // output from ALU
		ip_sign_ctrl_tb = 1'b0; // signed
	
	// test case 27 (SLLI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hF0F0F0F0; // 4042322160
		ip_imm_tb[24:0] = 25'h028728; // 20
		ip_imm_ext_ctrl_tb[2:0] = 3'b101; // shifting immediate extend
		ip_ALU_operation_ctrl_tb[2:0] = 3'b000;
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b10; // output from barrel shifter
		ip_sign_ctrl_tb = 1'b1; // logical
		ip_shift_direction_ctrl_tb = 1'b0; // shift left

	// test case 28 (SRLI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hF0F0F0F0; // 4042322160
		ip_imm_tb[24:0] = 25'h028728; // 20
		ip_imm_ext_ctrl_tb[2:0] = 3'b101; // shifting immediate extend
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b10; // output from barrel shifter
		ip_sign_ctrl_tb = 1'b1; // logical
		ip_shift_direction_ctrl_tb = 1'b1; // shift right

	// test case 29 (SRAI with one immediate value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'hF0F0F0F0; // 4042322160
		ip_imm_tb[24:0] = 25'h028728; // 20
		ip_imm_ext_ctrl_tb[2:0] = 3'b101; // shifting immediate extend
		ip_operand_a_ctrl_tb[1:0] = 2'b00; // select rs1 as operand a
		ip_operand_b_ctrl_tb[1:0] = 2'b01; // select immediate as operand b
		ip_result_ctrl_tb[1:0] = 2'b10; // output from barrel shifter
		ip_sign_ctrl_tb = 1'b0; // arithmetic
		ip_shift_direction_ctrl_tb = 1'b1; // shift right
	
	// test case 30 (ADD with two signed value)
	@(posedge ip_clk_tb) // insert value
		ip_rs1_tb[31:0] = 32'h00015C7B; // 89211
		ip_rs2_tb[31:0] = 32'hFF695C16; // -9872362
		ip_imm_tb[24:0] = 25'h0;
		ip_imm_ext_ctrl_tb[2:0] = 3'b000;
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
		ip_rs1_tb[31:0] = 32'hF0F0F0F0; // 4042322160
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