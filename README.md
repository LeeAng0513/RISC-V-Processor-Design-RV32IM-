# RISC-V Processor Design (RV32IM)
A 32-bit RISC-V core is designed by written in Verilog. <br>
The core has been tested the functionality by Verilog testbench.

# Feature
- 32-bit base RISC-V Core
- in-order execution
- Support RV32I instructions except for FENCE instructions and ECALL/EBREAK
- Suport M extension.
- With 5 stage pipeline (ID :arrow_right: IF :arrow_right: EX :arrow_right: MEM :arrow_right: WB)
- Support data forward control
- 32 bytes per block, 8-way associative, 16kb each for I-cache and D-cache, total 32kb cache

# Memory Map
| Range                     | Description                  |
| ------------------------- | ---------------------------- |
| 0x0000 0000 - 0x0000 3FFF | Instruction Memory (I-cache) |
| 0x0000 4000 - 0x0000 7FFF | Data Memory (D-cache)        |

:warning:: you can adjust the range as you like, it is just an assumption.

# Testbench
A basic Verilog based testbench for each module is provided to test the functionality only, not the performance. <br>
Insert the test bench file into your simulator to simulate the **data path** test bench to observe the waveform.

# Remark
- M extension only needs only clock cycle to compute the result in the EX stage.
- The project development will be separated into two directions, high-performance design (multicore, multithread, support more extension) and low performance (like microcontroller, support various I/O devices).
- Currently, I am learning: out-order execution, FENCE, ECALL, EBREAK, CSR instruction, multiple HART design, I/O communication and design, and superscalar design.
- - It is functional. However, it is an incomplete project, It will support more instructions, extensions, and functions in a later update. Stay tuned.
