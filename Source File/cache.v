/**********************************************************************
Project: 32-bit RISC-V Processor
Module: cache.v
Version: 1
Date Created: 1/7/2022
Created By: Lee Ang
Code Type: Verilog
Description: Cache Unit
**********************************************************************/

`default_nettype none  // to catch typing errors due to typo of signal names

module cache
#( // declare all the parameter needed
parameter initial_I_cache_addr = 32'h00000000, // initial I-cache address
parameter last_I_cache_addr = 32'h00003FFF, // last I-cache address
parameter initial_D_cache_addr = 32'h00004000, // initial D-cache address
parameter last_D_cache_addr = 32'h00007FFF // last D-cache address
) 
( // declare all the input and output pin needed
	input wire ip_clk, ip_rst,
	input wire [31:0] ip_wr_addr, ip_wr_data,
	input wire ip_wr_en, ip_wr_done_ctrl,
	input wire [31:0] ip_pc,
	input wire [31:0] ip_load_store_addr, ip_store_data,
	input wire [1:0] ip_load_store_bit_ctrl,
	input wire ip_load_sign_ctrl, ip_store_en,
	input wire ip_done_execute_ctrl,
	output wire [31:0] op_instr, op_data,
	output wire op_valid_ctrl
);

// cache
reg [7:0] cache [0:31][0:7][0:127]; // 32 byte per block, 8-way associative, 128 set, 32 kb

// register
reg valid; // validation of executing program

// wire
wire wr_cache_ctrl; // write cache from I/O detetction
wire store_ctrl; // store data into cache detection
wire [31:0] cache_addr; // address selection for write cache
wire [31:0] cache_data; // data selection for write cache 
wire [31:0] read_data; // data after read out and bit extend

// variable
integer i;
integer j;
integer k;

// wire assignment
assign wr_cache_ctrl = (~valid) & ip_wr_en; // write cache from I/O detetction
assign store_ctrl = valid & ip_store_en; // store data into cache detection
assign cache_addr[31:0] = (wr_cache_ctrl == 1'b1) ? ip_wr_addr[31:0] : ip_load_store_addr[31:0]; // address selection for write cache
assign cache_data[31:0] = (wr_cache_ctrl == 1'b1) ? ip_wr_data[31:0] : ip_store_data[31:0]; // data selection for write cache 

// cache
always @(posedge ip_clk or posedge ip_rst) begin
	if (ip_rst == 1'b1) begin // if reset
		// reset to default value
		for (i = 0; i < 128; i = i + 1) begin
			for (j = 0; j < 8; j = j + 1) begin
				for (k = 0; k < 32; k = k + 1) begin
					cache[k][j][i][7:0] = 8'b0;
				end
			end
		end
	end

	if (ip_rst == 1'b0) begin // if no reset
		if ((wr_cache_ctrl == 1'b1) || (store_ctrl == 1'b1)) begin // if write data into cache
			cache[cache_addr[4:0]][cache_addr[14:12]][cache_addr[11:5]][7:0] <= cache_data[7:0]; // SB / SH / SW or write data from I/O
			
			if ((wr_cache_ctrl == 1'b1) || (ip_load_store_bit_ctrl[1] == 1'b1) || (ip_load_store_bit_ctrl[0] == 1'b1)) begin // if SH / SW or write data from I/O
				cache[cache_addr[4:0] + 5'h1][cache_addr[14:12]][cache_addr[11:5]][7:0] <= cache_data[15:8];
			end
			
			if ((wr_cache_ctrl == 1'b1) || (ip_load_store_bit_ctrl[1] == 1'b1)) begin // if SW or write data from I/O
				cache[cache_addr[4:0] + 5'h2][cache_addr[14:12]][cache_addr[11:5]][7:0] <= cache_data[23:16];
				cache[cache_addr[4:0] + 5'h3][cache_addr[14:12]][cache_addr[11:5]][7:0] <= cache_data[31:24];
			end
		end
	end
end

// cache control
always @(posedge ip_clk or posedge ip_rst) begin
	if (ip_rst == 1'b1) begin // if reset
		valid = 1'b0; // set to invalid to execute program and request to write in data from I/O
	end
	
	else if (ip_rst == 1'b0) begin // if no reset
		if ((valid == 1'b0) && (ip_wr_done_ctrl == 1'b1)) begin // if done writing data from I/O
			valid <= 1'b1; // set to valid for executing program
		end
		
		if ((valid == 1'b1) && (ip_done_execute_ctrl == 1'b1)) begin // if done writing data from I/O
			valid <= 1'b0; // set to invalid to execute program and request to access / write in data from I/O
		end
	end
end

// bit extend for output
assign read_data[7:0] = cache[cache_addr[4:0]][cache_addr[14:12]][cache_addr[11:5]][7:0];
assign read_data[15:8] = ((ip_load_store_bit_ctrl[1] == 1'b1) || (ip_load_store_bit_ctrl[0] == 1'b1)) ? cache[cache_addr[4:0] + 5'h1][cache_addr[14:12]][cache_addr[11:5]][7:0] : (((ip_load_sign_ctrl == 1'b0) && (read_data[7] == 1'b1)) ? 8'b11111111 : 8'b0);
assign read_data[31:16] = (ip_load_store_bit_ctrl[1] == 1'b1) ? {cache[cache_addr[4:0] + 5'h3][cache_addr[14:12]][cache_addr[11:5]][7:0], cache[cache_addr[4:0] + 5'h2][cache_addr[14:12]][cache_addr[11:5]][7:0]} : (((read_data[15] == 1'b1) && ((ip_load_store_bit_ctrl[0] == 1'b0) || ((ip_load_store_bit_ctrl[0] == 1'b1) && (ip_load_sign_ctrl == 1'b0)))) ? 16'b1111111111111111 : 16'b0000000000000000);

// output data
assign op_instr[7:0] = cache[ip_pc[4:0]][ip_pc[14:12]][ip_pc[11:5]][7:0];
assign op_instr[15:8] = cache[ip_pc[4:0] + 5'h1][ip_pc[14:12]][ip_pc[11:5]][7:0];
assign op_instr[23:16] = cache[ip_pc[4:0] + 5'h2][ip_pc[14:12]][ip_pc[11:5]][7:0];
assign op_instr[31:24] = cache[ip_pc[4:0] + 5'h3][ip_pc[14:12]][ip_pc[11:5]][7:0];
assign op_data[31:0] = read_data[31:0];
assign op_valid_ctrl = ~valid;
endmodule