/**********************************************************************
Project: 32-bit RISC-V Processor
Module: data_mem.v
Version: 1
Date Created: 1/7/2022
Created By: Lee Ang
Code Type: Verilog
Description: Data Memory
**********************************************************************/

`default_nettype none  // to catch typing errors due to typo of signal names

module data_mem
#( // declare all the parameter needed
parameter initial_addr = 32'h02000000, // initial static data address
parameter last_addr = 32'h02000FFF // last data memory address
) 
( // declare all the input and output pin needed
	input wire [31:0] ip_addr, ip_store_data,
	input wire [1:0] ip_load_store_bit_ctrl,
	input wire ip_clk, ip_rst, ip_load_sign_ctrl, ip_store_en,
	output wire [31:0] op_read_data
);

// register
reg [7:0] data_mem [initial_addr:last_addr]; // data memory (static + dynamic + stack)

// wire
wire [31:0] read_data; // data after bit extend

// variable
reg [31:0] i; // for reset

// data memory
always @(posedge ip_clk or posedge ip_rst) begin
	if(ip_rst == 1'b1) begin // if reset
		// reset to default value
		for(i[31:0] = initial_addr; i[31:0] <= last_addr; i[31:0] = i[31:0] + 32'h1) begin
			data_mem[i[31:0]] = 8'b0;
		end
	end
end

always @(*) begin
	if((ip_rst == 1'b0) && (ip_store_en == 1'b1))begin // if store data
		if(ip_load_store_bit_ctrl[1:0] == 2'b00) begin // if SB
			data_mem[ip_addr[31:0]] = ip_store_data[7:0];
		end
		
		if(ip_load_store_bit_ctrl[1:0] == 2'b01) begin // if SH
			data_mem[ip_addr[31:0]] = ip_store_data[7:0];
			data_mem[ip_addr[31:0] + 32'h1] = ip_store_data[15:8];
		end
		
		if(ip_load_store_bit_ctrl[1:0] == 2'b10) begin // if SW
			// write data in to data memory
			data_mem[ip_addr[31:0]] = ip_store_data[7:0];
			data_mem[ip_addr[31:0] + 32'h1] = ip_store_data[15:8];
			data_mem[ip_addr[31:0] + 32'h2] = ip_store_data[23:16];
			data_mem[ip_addr[31:0] + 32'h3] = ip_store_data[31:24];
		end
	end
end

// bit extend for output
assign read_data[7:0] = data_mem[ip_addr[31:0]];
assign read_data[15:8] = ((ip_load_store_bit_ctrl[1] == 1'b1) || (ip_load_store_bit_ctrl[0] == 1'b1)) ? data_mem[ip_addr[31:0] + 32'h1] : (((ip_load_sign_ctrl == 1'b0) && (read_data[7] == 1'b1)) ? 8'b11111111 : 8'b0);
assign read_data[31:16] = (ip_load_store_bit_ctrl[1] == 1'b1) ? {data_mem[ip_addr[31:0] + 32'h3], data_mem[ip_addr[31:0] + 32'h2]} : (((read_data[15] == 1'b1) && ((ip_load_store_bit_ctrl[0] == 1'b0) || ((ip_load_store_bit_ctrl[0] == 1'b1) && (ip_load_sign_ctrl == 1'b0)))) ? 16'b1111111111111111 : 16'b0);

// output data
assign op_read_data[31:0] = read_data[31:0];
endmodule