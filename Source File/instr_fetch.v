/**********************************************************************
Project: Develop 32-bit RISC-V Processor
Module: instr_fetch.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: Instruction Fetch Unit
**********************************************************************/

`default_nettype none // to catch typing errors due to typo of signal names

module instr_fetch
#( // declare all the parameter needed
parameter initial_addr = 32'h00008000, // initial pc address
parameter last_addr = 32'h00008FFF, // last pc address
parameter size = 6'b100000 // 32
) 
( // declare all the input and output pin needed
	input wire [31:0] ip_wr_data, ip_wr_addr, ip_target_addr,
	input wire ip_clk, ip_rst, ip_wr_en, ip_jump_branch_ctrl, ip_stall_ctrl,
	output wire [31:0] op_pc_addr, op_instr
);

// register
reg [31:0] pc; // program counter
reg [7:0] instr_mem [initial_addr:last_addr]; // instruction memory

// wire
reg [31:0] next_pc;  // offset of next address (4 byte)
reg [32:0] carry_bit; // carry bit of pc + 4 adder

// variable
reg [31:0] i; // for loop

// program counter
always @(posedge ip_clk or posedge ip_rst) begin
	// assignment
	next_pc[31:0] = 32'h00000004;  // offset of next address (4 byte)
	carry_bit[0] = 1'b0; // 0 carry bit for first digit addition
	
	if (ip_rst == 1'b1) begin // if reset
		pc[31:0] = initial_addr; // reset to default value
	end

	else if (ip_rst == 1'b0) begin // if no reset
		if (ip_stall_ctrl == 1'b1) begin // if stalling
			pc[31:0] <= pc[31:0];
		end
		
		else if (ip_stall_ctrl == 1'b0) begin // if not stalling
			if (ip_jump_branch_ctrl == 1'b1) begin // if jump or branch to target instruction address
				pc[31:0] <= ip_target_addr[31:0]; // update pc to target address
			end
			
			else if (ip_jump_branch_ctrl == 1'b0) begin // if branch to next instruction address
				// instruction address + 4 in 32-bit Adder
				for (i[5:0] = 6'b0; i[5:0] < size; i[5:0] = i[5:0] + 6'b1) begin
					pc[i[5:0]] <= pc[i[5:0]] ^ next_pc[i[5:0]] ^ carry_bit[i[5:0]]; // calculation of add result
					carry_bit[i[5:0] + 1'b1] = (pc[i[5:0]] & next_pc[i[5:0]]) | (pc[i[5:0]] & carry_bit[i[5:0]]) | (next_pc[i[5:0]] & carry_bit[i[5:0]]); // calculation of carry bit
				end
			end
		end
	end
end

// output current pc
assign op_pc_addr[31:0] = pc[31:0];

// instruction memory
always @(posedge ip_clk or posedge ip_rst) begin
	if (ip_rst == 1'b1) begin // if reset
		// reset to default value
		for (i[31:0] = initial_addr; i[31:0] <= last_addr; i[31:0] = i[31:0] + 32'h1) begin
			instr_mem[i[31:0]] = 8'b0;
		end
	end
end

always @(*) begin
	if ((ip_rst == 1'b0) && (ip_wr_en == 1'b1)) begin // // if enable to flash data in instruction memory
		instr_mem[ip_wr_addr[31:0]] = ip_wr_data[7:0];
		instr_mem[ip_wr_addr[31:0] + 32'h1] = ip_wr_data[15:8];
		instr_mem[ip_wr_addr[31:0] + 32'h2] = ip_wr_data[23:16];
		instr_mem[ip_wr_addr[31:0] + 32'h3] = ip_wr_data[31:24];
	end
end

// output the instruction
assign op_instr[7:0] = instr_mem[pc[31:0]];
assign op_instr[15:8] = instr_mem[pc[31:0] + 32'h1];
assign op_instr[23:16] = instr_mem[pc[31:0] + 32'h2];
assign op_instr[31:24] = instr_mem[pc[31:0] + 32'h3];

endmodule