/**********************************************************************
Project: Develop 32-bit RISC-V Processor
Module: data_path_tb.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: Datapath Test Bench
**********************************************************************/

`include "macro.v"
`default_nettype none

module data_path_tb
();

reg [31:0] ip_wr_instr_mem_data_tb, ip_wr_instr_mem_addr_tb;
reg ip_clk_tb, ip_rst_tb, ip_wr_instr_mem_en_tb, ip_stall_ctrl_tb;
wire op_overflow_tb;

data_path
dut_data_path(
	.ip_wr_instr_mem_data(ip_wr_instr_mem_data_tb),
	.ip_wr_instr_mem_addr(ip_wr_instr_mem_addr_tb),
	.ip_clk(ip_clk_tb),
	.ip_rst(ip_rst_tb),
	.ip_wr_instr_mem_en(ip_wr_instr_mem_en_tb),
	.ip_stall_ctrl(ip_stall_ctrl_tb),
	.op_overflow(op_overflow_tb)
);

initial ip_clk_tb <= 1'b1;
always #(`PERIOD_HALF) ip_clk_tb = ~ip_clk_tb;

//Signal initialization
initial begin	
	@(posedge ip_clk_tb) // initialize the value (at sim time 1)
		ip_wr_instr_mem_data_tb[31:0] = 32'b0;
		ip_wr_instr_mem_addr_tb[31:0] = 32'b0;
		ip_wr_instr_mem_en_tb = 1'b0;
		ip_stall_ctrl_tb = 1'b1;
		ip_rst_tb = 1'b1;
	
	// test case 1 (write data into instrcution and data memory)
	@(posedge ip_clk_tb) // insert value
		$readmemh("data_memory_machine_code.txt", data_path_tb.dut_data_path.data_memory.data_mem); // load data into data_mem
		ip_wr_instr_mem_data_tb[31:0] = 32'h020002B7; // LUI x5, 0x02000 # load initial address in register
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008000;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
		ip_rst_tb = 1'b0;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h0002A303; // LW x6, x5, 0x000 # i = 1
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008004;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h0042A383; // LW x7, x5, 0x004 # a = 2
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008008;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h0082AE03; // LW x28, x5, 0x008 # b = 3
		ip_wr_instr_mem_addr_tb[31:0] = 32'h0000800C;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00C2AE83; // LW x29, x5, 0x00C # c = 4
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008010;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h0102AF03; // LW x30, x5, 0x010 # d = 5
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008014;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00006313; // ORI x6, x0, 0x000 # i = 0
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008018;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00A06493; // ORI x9, x0, 0x00A # 10
		ip_wr_instr_mem_addr_tb[31:0] = 32'h0000801C;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00506913; // ORI x18, x0, 0x005 # 5
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008020;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00935F63; // BGE x6, x9, loop_end
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008024;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00000000; // NOP
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008028;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00000000; // NOP
		ip_wr_instr_mem_addr_tb[31:0] = 32'h0000802C;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00694763; // BLT x18, x6, greater_5 # if i > 5
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008030;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00000000; // NOP
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008034;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00000000; // NOP
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008038;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h01EE8EB3; // ADD x29, x29, x30 # c += d
		ip_wr_instr_mem_addr_tb[31:0] = 32'h0000803C;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h000080EF; // JAL x1, if_end
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008040;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00000000; // NOP
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008044;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00000000; // NOP
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008048;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h01C383B3; // ADD x7, x7, x28 # a += b
		ip_wr_instr_mem_addr_tb[31:0] = 32'h0000804C;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00130313; // ADDI x6, x6, 0x001 # i++
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008050;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'hFFFE80EF; // JAL x1, loop
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008054;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00000000; // NOP
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008058;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00000000; // NOP
		ip_wr_instr_mem_addr_tb[31:0] = 32'h0000805C;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h0000A0EF; // JAL x1, multiplication
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008060;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00000000; // NOP
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008064;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00000000; // NOP
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008068;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00056313; // ORI x6, x10, 0x000
		ip_wr_instr_mem_addr_tb[31:0] = 32'h0000806C;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h0000E0EF; // JAL x1, exit
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008070;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h0003E613; // ORI x12, x7, 0x000
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008074;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h000EE693; // ORI x13, x29, 0x000
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008078;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h02D60533; // MUL x10, x12, x13
		ip_wr_instr_mem_addr_tb[31:0] = 32'h0000807C;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h000080E7; // JALR x1, x1, 0x000
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008080;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00000000; // NOP
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008084;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;
	
	@(posedge ip_clk_tb) // insert value
		ip_wr_instr_mem_data_tb[31:0] = 32'h00000000; // NOP
		ip_wr_instr_mem_addr_tb[31:0] = 32'h00008088;
		ip_wr_instr_mem_en_tb = 1'b1;
		ip_stall_ctrl_tb = 1'b1;

	repeat(180) @(posedge ip_clk_tb) begin // 1 cycle to compute the result
		ip_wr_instr_mem_data_tb[31:0] = 32'h0;
		ip_wr_instr_mem_addr_tb[31:0] = 32'h0;
		ip_wr_instr_mem_en_tb = 1'b0;
		ip_stall_ctrl_tb = 1'b0;
	end

	$stop; //stop simulation
end
endmodule