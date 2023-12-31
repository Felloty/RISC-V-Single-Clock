// ALU instructions
// Number of instructions: 10
`define ALU_ADD    4'b0000
`define ALU_SUB    4'b0001
`define ALU_XOR    4'b0010
`define ALU_OR     4'b0011
`define ALU_AND    4'b0100
`define ALU_SLL    4'b0101
`define ALU_SRL    4'b0110
`define ALU_SRA    4'b0111
`define ALU_SLT    4'b1000
`define ALU_SLTU   4'b1001

// Unused funct3 and funct7
`define RVF3_ANY    3'b???
`define RVF7_ANY    7'b???????

// R-type
// Number of instructions: 10
`define RVOP_ADD    7'b0110011
`define RVF3_ADD    3'b000
`define RVF7_ADD    7'b0000000
`define RVOP_SUB    7'b0110011
`define RVF3_SUB    3'b000
`define RVF7_SUB    7'b0100000
`define RVOP_XOR    7'b0110011
`define RVF3_XOR    3'b100
`define RVF7_XOR    7'b0000000
`define RVOP_OR     7'b0110011
`define RVF3_OR     3'b110
`define RVF7_OR     7'b0000000
`define RVOP_AND    7'b0110011
`define RVF3_AND    3'b111
`define RVF7_AND    7'b0000000
`define RVOP_SLL    7'b0110011
`define RVF3_SLL    3'b001
`define RVF7_SLL    7'b0000000
`define RVOP_SRL    7'b0110011
`define RVF3_SRL    3'b101
`define RVF7_SRL    7'b0000000
`define RVOP_SRA    7'b0110011
`define RVF3_SRA    3'b101
`define RVF7_SRA    7'b0100000
`define RVOP_SLT    7'b0110011
`define RVF3_SLT    3'b010
`define RVF7_SLT    7'b0000000
`define RVOP_SLTU   7'b0110011
`define RVF3_SLTU   3'b011
`define RVF7_SLTU   7'b0000000

// I-type
// Number of instructions: 10
`define RVOP_ADDI   7'b0010011
`define RVF3_ADDI   3'b000
`define RVOP_XORI   7'b0010011
`define RVF3_XORI   3'b100
`define RVOP_ORI    7'b0010011
`define RVF3_ORI    3'b110
`define RVOP_ANDI   7'b0010011
`define RVF3_ANDI   3'b111
`define RVOP_SLLI   7'b0010011
`define RVF3_SLLI   3'b001
`define RVF7_SLLI   7'b0000000
`define RVOP_SRLI   7'b0010011
`define RVF3_SRLI   3'b101
`define RVF7_SRLI   7'b0000000
`define RVOP_SRAI   7'b0010011
`define RVF3_SRAI   3'b101
`define RVF7_SRAI   7'b0100000
`define RVOP_SLTI   7'b0010011
`define RVF3_SLTI   3'b010
`define RVOP_SLTIU  7'b0010011
`define RVF3_SLTIU  3'b011
`define RVOP_LW     7'b0000011
`define RVF3_LW     3'b010

// S-type
// Number of instructions: 1
`define RVOP_SW     7'b0100011
`define RVF3_SW     3'b010

// B-type
// Number of instructions: 2
`define RVOP_BEQ    7'b1100011
`define RVF3_BEQ    3'b000
`define RVOP_BNE    7'b1100011
`define RVF3_BNE    3'b001

// U-type
// Number of instructions: 1
`define RVOP_LUI    7'b0110111

// J-type
// Number of instructions: 1
`define RVOP_JAL    7'b1101111