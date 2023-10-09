/**********************************************************************
Project: Develop 32-bit RISC-V Processor
Module: reg_file.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: 32 of 32-bits General Regsiters
**********************************************************************/

`default_nettype none // to catch typing errors due to typo of signal names

module reg_file
#( // declare all the parameter needed
)
( // declare all the input and output pin needed
	input wire ip_clk, ip_rst,
	input wire [31:0] ip_wr_data,
	input wire [4:0] ip_rs1_addr, ip_rs2_addr, ip_rd_addr,
	input wire ip_wr_en,
	output wire [31:0] op_rs1, op_rs2
);

// register
reg [31:0] reg_file [0:31]; // 32 of 32-bit general registers

// wire 
wire rs1_equal_rd; // rs1 address same with rd address detection
wire rs2_equal_rd; // rs2 address same with rd address detection

// variable
integer i;

// wire assignment
assign rs1_equal_rd = (~|(ip_rs1_addr ^ ip_rd_addr)) & ip_wr_en & (|ip_rd_addr); // if rs1 = rd, rd > 0
assign rs2_equal_rd = (~|(ip_rs2_addr ^ ip_rd_addr)) & ip_wr_en & (|ip_rd_addr); // if rs2 = rd, rd > 0

// 32 general registers
always @(posedge ip_clk or posedge ip_rst) begin
	reg_file[0][31:0] = 32'h0; // register zero (x0) always be 0

	if (ip_rst == 1'b1) begin // if reset
		// reset to default value
		for (i = 1; i < 32; i = i + 1) begin
			reg_file[i][31:0] = 32'b0;
		end
	end
	
	if ((ip_rst == 1'b0) && (ip_wr_en == 1'b1)) begin // if enable write data
		case(ip_rd_addr[4:0])
			5'b00001 : reg_file[1][31:0] <= ip_wr_data[31:0];
			5'b00010 : reg_file[2][31:0] <= ip_wr_data[31:0];
			5'b00011 : reg_file[3][31:0] <= ip_wr_data[31:0];
			5'b00100 : reg_file[4][31:0] <= ip_wr_data[31:0];
			5'b00101 : reg_file[5][31:0] <= ip_wr_data[31:0];
			5'b00110 : reg_file[6][31:0] <= ip_wr_data[31:0];
			5'b00111 : reg_file[7][31:0] <= ip_wr_data[31:0];
			5'b01000 : reg_file[8][31:0] <= ip_wr_data[31:0];
			5'b01001 : reg_file[9][31:0] <= ip_wr_data[31:0];
			5'b01010 : reg_file[10][31:0] <= ip_wr_data[31:0];
			5'b01011 : reg_file[11][31:0] <= ip_wr_data[31:0];
			5'b01100 : reg_file[12][31:0] <= ip_wr_data[31:0];
			5'b01101 : reg_file[13][31:0] <= ip_wr_data[31:0];
			5'b01110 : reg_file[14][31:0] <= ip_wr_data[31:0];
			5'b01111 : reg_file[15][31:0] <= ip_wr_data[31:0];
			5'b10000 : reg_file[16][31:0] <= ip_wr_data[31:0];
			5'b10001 : reg_file[17][31:0] <= ip_wr_data[31:0];
			5'b10010 : reg_file[18][31:0] <= ip_wr_data[31:0];
			5'b10011 : reg_file[19][31:0] <= ip_wr_data[31:0];
			5'b10100 : reg_file[20][31:0] <= ip_wr_data[31:0];
			5'b10101 : reg_file[21][31:0] <= ip_wr_data[31:0];
			5'b10110 : reg_file[22][31:0] <= ip_wr_data[31:0];
			5'b10111 : reg_file[23][31:0] <= ip_wr_data[31:0];
			5'b11000 : reg_file[24][31:0] <= ip_wr_data[31:0];
			5'b11001 : reg_file[25][31:0] <= ip_wr_data[31:0];
			5'b11010 : reg_file[26][31:0] <= ip_wr_data[31:0];
			5'b11011 : reg_file[27][31:0] <= ip_wr_data[31:0];
			5'b11100 : reg_file[28][31:0] <= ip_wr_data[31:0];
			5'b11101 : reg_file[29][31:0] <= ip_wr_data[31:0];
			5'b11110 : reg_file[30][31:0] <= ip_wr_data[31:0];
			5'b11111 : reg_file[31][31:0] <= ip_wr_data[31:0];
		endcase
	end
end

// output rs1 and rs2
assign op_rs1[31:0] = (rs1_equal_rd == 1'b1) ? ip_wr_data[31:0] : reg_file[ip_rs1_addr[4:0]]; // output rd data if rd = rs1 else output from register
assign op_rs2[31:0] = (rs2_equal_rd == 1'b1) ? ip_wr_data[31:0] : reg_file[ip_rs2_addr[4:0]]; // output rd data if rd = rs2 else output from register
endmodule