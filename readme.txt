RISC-V Single-Clock Processor (RV32I).
15 June 2023.
----------------------------------------------------------
Implements a subset of the base integer instructions:
add, sub, xor, or, and, sll, srl, sra, slt, sltu,
addi, xori, ori, andi, slli, srli, srai, slti, sltiu, lw,
sw,
beq, bne,
lui,
jal.
Exceptions, traps, and interrupts not implemented.
----------------------------------------------------------
The doc/       folder contains necessary documentation.
The omdazz/    folder contains Quartus configuration files and source file of design top entity.
The program/   folder contains RARS simulator, assembly test program and dump of its machine code, script file for running Icarus Verilog under Windows.
The source/    folder contains all source files.
The testbench/ folder contains testbench file.
----------------------------------------------------------
Boards support:
Omdazz (Altera Cyclone IV FPGA).
----------------------------------------------------------
Plans:
Adding a multi-stage pipeline.
----------------------------------------------------------