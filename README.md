# RISC-V Processor Design (RV32IM)
A 32-bit RISC-V core is designed by written in Verilog. <br>
The core has been tested the functionality by Verilog testbench.

# Overview
![Graph/Data Path.png](https://github.com/LeeAng0513/RISC-V-Processor-Design-RV32IM-/blob/main/Graph/Data%20Path.png?raw=true)

# Feature
- 32-bit base RISC-V Core
- Support RV32I instructions except for FENCE instructions and ECALL/EBREAK
- Suport M extension.
- With 5 stage pipeline (ID :arrow_right: IF :arrow_right: EX :arrow_right: MEM :arrow_right: WB)
- Support data forward control

# Memory Map
| Range                     | Description                  |
| ------------------------- | ---------------------------- |
| 0x0000 8000 - 0x0000 8FFF | Instruction Memory (I-cache) |
| 0x0200 0000 - 0x0200 0FFF | Data Memory (D-cache)        |

:warning:: you can adjust the range as you like, it is just an assumption.

# Testbench
A basic Verilog based testbench for each module is provided to test the functionality only, not the performance. <br>
You can just insert the test bench file into your simulator to simulate the **data path** test bench to observe the waveform.

# Remark
- M extension only needs only clock cycle to compute the result in the EX stage.
- The "**reg**" actually treats like a register, and the "**wire**" is actually used for logic combination, so it is nearly pure logic design.
- The project development will be separated into two directions, high-performance design (multicore, multithread, support more extension) and low performance (like microcontroller, support various I/O devices).
- Currently, I am learning: FENCE, ECALL, EBREAK, CSR instruction, FENCE.I, multiple HART design, I/O communication and design, and superscalar design.
- - It is functional. However, it is an incomplete project, It will support more instructions, extensions, and functions in a later update. Stay tuned.
