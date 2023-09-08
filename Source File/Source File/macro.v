/*********************************************************************************
Project: MIPS 5-stage pipeline
Module: macro.v [global]
Version: 1
Date Created: 16/08/2021
Created By: Lee Ang
Code Type: Verilog
Description: -
*********************************************************************************/

// Clock period and its derivatives.
`define PERIOD_CLK 2
`define PERIOD_HALF (`PERIOD_CLK/2)
`define PERIOD_QUAT (`PERIOD_HALF/2)
`define PERIOD_QUAT3 (`PERIOD_HALF + `PERIOD_QUAT)
`define PERIOD_ONEnQUAT (`PERIOD_CLK + `PERIOD_QUAT)

// Following are based on constant in percentage-based
`define END_OF_CYCLE (0.9 * `PERIOD_CLK)
`define START_OF_CYCLE (0.1 * `PERIOD_CLK)