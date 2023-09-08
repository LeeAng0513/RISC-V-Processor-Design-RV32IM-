/**********************************************************************
Project: Develop 32-bit RISC-V Processor
Module: core.v
Version: 1
Date Created: 1/7/2023
Created By: Lee Ang
Code Type: Verilog
Description: Top Level Core
**********************************************************************/

`default_nettype none // to catch typing errors due to typo of signal names

module RISCV_core
#( // declare all the parameter needed
) 
( // declare all the input and output pin needed
	input wire ip_clk, ip_rst
);

data_path
data_path(
	.ip_clk(ip_clk),
	.ip_rst(ip_rst)
);
endmodule