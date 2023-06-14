`include "cpu.vh"

module cpu
(
    input         clk, rst,
    input  [4 :0] regAddress,            // Debug access to register address
    output [31:0] regData                // Debug access to register data
);

    // Debug access to register data
    assign regData = (regAddress != 0) ? rd0 : pc;

    wire [31:0] instruction_address = pc;
    wire [31:0] instruction_data;

    wire [31:0] read_data;

    wire [6:0]  cmdOp;
    wire [6:0]  cmdF7;
    wire [2:0]  cmdF3;
    wire [4:0]  rs1;
    wire [4:0]  rs2;
    wire [4:0]  rd;
    wire [31:0] immI;
    wire [31:0] immS;
    wire [31:0] immB;
    wire [31:0] immU;
    wire [31:0] immJ;

    wire       aluZero;
    wire [1:0] pcMux;
    wire       write_enable_rd;
    wire       write_enable_mem;
    wire       wdMux;
    wire [1:0] aluMux;
    wire [1:0] resultMux;
    wire [3:0] aluControl;

    wire [31:0] result;

    wire [31:0] rd0;
    wire [31:0] rd1;
    wire [31:0] rd2;

    wire [31:0] pcBranch_1 = pc + immB;
    wire [31:0] pcBranch_2 = pc + immJ;
    wire [31:0] pcPlus4    = pc + 4;
    wire [31:0] pc;

    wire [31:0] opB             = aluMux [1] ? (aluMux [0] ? 32'b0 : immS) : (aluMux [0] ? immI : rd2);
    wire [31:0] write_data_rd_1 = resultMux [1] ? (resultMux [0] ? 32'b0 : result) : (resultMux [0] ? read_data : pcPlus4);
    wire [31:0] write_data_rd_2 = wdMux ? immU : write_data_rd_1;
    wire [31:0] pcNext          = pcMux [1] ? (pcMux [0] ? 32'b0 : pcBranch_2) : (pcMux [0] ? pcBranch_1 : pcPlus4);

    instruction_decoder instruction_decoder_instance
    (
        .instr               ( instruction_data    ),
        .cmdOp               ( cmdOp               ),
        .cmdF7               ( cmdF7               ),
        .cmdF3               ( cmdF3               ),
        .rs1                 ( rs1                 ),
        .rs2                 ( rs2                 ),
        .rd                  ( rd                  ),
        .immI                ( immI                ),
        .immS                ( immS                ),
        .immB                ( immB                ),
        .immU                ( immU                ),
        .immJ                ( immJ                )
    );

    control_unit control_unit_instance
    (
        .cmdOp               ( cmdOp               ),
        .cmdF7               ( cmdF7               ),
        .cmdF3               ( cmdF3               ),
        .aluZero             ( aluZero             ),
        .pcMux               ( pcMux               ),
        .write_enable_mem    ( write_enable_mem    ),
        .write_enable_rd     ( write_enable_rd     ),
        .wdMux               ( wdMux               ),
        .aluMux              ( aluMux              ),
        .resultMux           ( resultMux           ),
        .aluControl          ( aluControl          )
    );

    arithmetic_logic_unit arithmetic_logic_unit_instance
    (
        .opA                 ( rd1                 ),
        .opB                 ( opB                 ),
        .control             ( aluControl          ),
        .zero                ( aluZero             ),
        .result              ( result              )
    );

    register_file register_file_instance
    (
        .clk                 ( clk                 ),
        .write_enable        ( write_enable_rd     ),
        .rs0                 ( regAddress          ),
        .rs1                 ( rs1                 ),
        .rs2                 ( rs2                 ),
        .rd                  ( rd                  ),
        .write_data          ( write_data_rd_2     ),
        .rd0                 ( rd0                 ),
        .rd1                 ( rd1                 ),
        .rd2                 ( rd2                 )
    );

    program_counter program_counter_instance
    (
        .clk                 ( clk                 ),
        .rst                 ( rst                 ),
        .D                   ( pcNext              ),
        .Q                   ( pc                  )
    );

    instruction_memory instruction_memory_instance
    (
        .instruction_address ( instruction_address ),
        .instruction_data    ( instruction_data    )
    );

    data_memory data_memory_instance
    (
        .clk                 ( clk                 ),		
        .write_enable        ( write_enable_mem    ),
        .data_address        ( result              ), 
        .write_data          ( rd2                 ),
        .read_data           ( read_data           )
    );

endmodule


//--------------------------------------------------------------------


module instruction_decoder
(
    input      [31:0] instr,
    output     [6 :0] cmdOp, cmdF7,
    output     [2 :0] cmdF3,
    output     [4 :0] rs1, rs2, rd,
    output reg [31:0] immI, immS, immB, immU, immJ
);

    assign cmdOp = instr [6 : 0];
    assign cmdF3 = instr [14:12];
    assign cmdF7 = instr [31:25];
    assign rs1   = instr [19:15];
    assign rs2   = instr [24:20];
    assign rd    = instr [11: 7];

    // I-immediate
    always @ (*) begin
        immI [10: 0] = instr [30:20];
        immI [31:11] = { 21 {instr [31]} };
    end

    // S-immediate
    always @ (*) begin
        immS [4 : 0] = instr [11: 7];
        immS [11: 5] = instr [31:25];
        immS [31:12] = { 20 {instr [31]} };
    end

    // B-immediate
    always @ (*) begin
        immB[0]     = 1'b0;
        immB[4 :1]  = instr [11: 8];
        immB[10:5]  = instr [30:25];
        immB[11]    = instr [7];
        immB[31:12] = { 20 {instr [31]} };
    end

    // U-immediate
    always @ (*) begin
        immU[11: 0] = 12'b0;
        immU[31:12] = instr [31:12];
    end

    // J-immediate
    always @ (*) begin
          immJ[0]     = 1'b0;
          immJ[10: 1] = instr [30:21];
		  immJ[11]    = instr [20];
          immJ[19:12] = instr [19:12];
          immJ[31:20] = { 12 {instr [31]} };
    end

endmodule


//--------------------------------------------------------------------


module control_unit
(
    input      [6:0] cmdOp, cmdF7,
    input      [2:0] cmdF3,
    input            aluZero,
    output     [1:0] pcMux,
    output reg       write_enable_mem, write_enable_rd, wdMux,
    output reg [1:0] aluMux, resultMux,
    output reg [3:0] aluControl
);

    reg branch;
    reg condZero;
    reg condJump;

    assign pcMux [1] = condJump;
    assign pcMux [0] = branch & (aluZero == condZero);

    always @ (*) begin

        branch            = 1'b0;
        condZero          = 1'b0;
        condJump          = 1'b0;

        write_enable_mem  = 1'b0;
        write_enable_rd   = 1'b0;

        wdMux             = 1'b0;

        aluMux            = 2'b00;
        resultMux         = 2'b00;
        aluControl        = `ALU_ADD;

        casez ( {cmdF7, cmdF3, cmdOp} )
            // R-type
            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD  } : begin write_enable_rd = 1'b1; resultMux  = 2'b10; aluControl = `ALU_ADD;  end
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB  } : begin write_enable_rd = 1'b1; resultMux  = 2'b10; aluControl = `ALU_SUB;  end
            { `RVF7_XOR,  `RVF3_XOR,  `RVOP_XOR  } : begin write_enable_rd = 1'b1; resultMux  = 2'b10; aluControl = `ALU_XOR;  end
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR   } : begin write_enable_rd = 1'b1; resultMux  = 2'b10; aluControl = `ALU_OR;   end
            { `RVF7_AND,  `RVF3_AND,  `RVOP_AND  } : begin write_enable_rd = 1'b1; resultMux  = 2'b10; aluControl = `ALU_AND;  end
            { `RVF7_SLL,  `RVF3_SLL,  `RVOP_SLL  } : begin write_enable_rd = 1'b1; resultMux  = 2'b10; aluControl = `ALU_SLL;  end
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL  } : begin write_enable_rd = 1'b1; resultMux  = 2'b10; aluControl = `ALU_SRL;  end
            { `RVF7_SRA,  `RVF3_SRA,  `RVOP_SRA  } : begin write_enable_rd = 1'b1; resultMux  = 2'b10; aluControl = `ALU_SRA;  end
            { `RVF7_SLT,  `RVF3_SLT,  `RVOP_SLT  } : begin write_enable_rd = 1'b1; resultMux  = 2'b10; aluControl = `ALU_SLT;  end
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU } : begin write_enable_rd = 1'b1; resultMux  = 2'b10; aluControl = `ALU_SLTU; end

            // I-type
            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI } : begin write_enable_rd = 1'b1; aluMux = 2'b01; resultMux  = 2'b10; aluControl = `ALU_ADD; end
            { `RVF7_ANY,  `RVF3_XORI, `RVOP_XORI } : begin write_enable_rd = 1'b1; aluMux = 2'b01; resultMux  = 2'b10; aluControl = `ALU_XOR; end
            { `RVF7_ANY,  `RVF3_ORI,  `RVOP_ORI  } : begin write_enable_rd = 1'b1; aluMux = 2'b01; resultMux  = 2'b10; aluControl = `ALU_OR;  end
            { `RVF7_ANY,  `RVF3_ANDI, `RVOP_ANDI } : begin write_enable_rd = 1'b1; aluMux = 2'b01; resultMux  = 2'b10; aluControl = `ALU_AND; end
            { `RVF7_SLLI, `RVF3_SLLI, `RVOP_SLLI } : begin write_enable_rd = 1'b1; aluMux = 2'b01; resultMux  = 2'b10; aluControl = `ALU_SLL; end
            { `RVF7_SRLI, `RVF3_SRLI, `RVOP_SRLI } : begin write_enable_rd = 1'b1; aluMux = 2'b01; resultMux  = 2'b10; aluControl = `ALU_SRL; end
            { `RVF7_SRAI, `RVF3_SRAI, `RVOP_SRAI } : begin write_enable_rd = 1'b1; aluMux = 2'b01; resultMux  = 2'b10; aluControl = `ALU_SRA; end
            { `RVF7_ANY,  `RVF3_SLTI, `RVOP_SLTI } : begin write_enable_rd = 1'b1; aluMux = 2'b01; resultMux  = 2'b10; aluControl = `ALU_SLT; end
            { `RVF7_ANY,  `RVF3_SLTIU,`RVOP_SLTIU} : begin write_enable_rd = 1'b1; aluMux = 2'b01; resultMux  = 2'b10; aluControl = `ALU_SLTU;end
            { `RVF7_ANY,  `RVF3_LW,   `RVOP_LW   } : begin write_enable_rd = 1'b1; aluMux = 2'b01; resultMux  = 2'b01; aluControl = `ALU_ADD; end

            // S-type
            { `RVF7_ANY,  `RVF3_SW,  `RVOP_SW    } : begin write_enable_mem = 1'b1; aluMux = 2'b10; aluControl = `ALU_ADD; end

            // B-type
            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ  } : begin branch = 1'b1; condZero = 1'b1; aluControl = `ALU_SUB; end
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNE  } : begin branch = 1'b1; aluControl = `ALU_SUB; end

            // U-type
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI  } : begin write_enable_rd = 1'b1; wdMux  = 1'b1; end

            // J-type
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_JAL  } : begin condJump = 1'b1; write_enable_rd = 1'b1; end

            default   :;
        endcase
    end

endmodule


//--------------------------------------------------------------------


module arithmetic_logic_unit
(
    input      [31:0] opA, opB,
    input      [3 :0] control,
    output            zero,
    output reg [31:0] result
);

    always @ (*) begin
        case (control)
            `ALU_ADD  : result = opA + opB;
            `ALU_SUB  : result = opA - opB;
            `ALU_XOR  : result = opA ^ opB;
            `ALU_OR   : result = opA | opB;
            `ALU_AND  : result = opA & opB;
            `ALU_SLL  : result = opA << opB [4:0];
            `ALU_SRL  : result = opA >> opB [4:0];
            `ALU_SRA  : result = { 32 {opA [31]} } << (31 - opB [4:0]) | opA >> opB [4:0]; // $signed(opA) >>> opB [4:0]
            `ALU_SLT  : result = $signed(opA) < $signed(opB) ? 32'b1 : 32'b0;
            `ALU_SLTU : result = $unsigned(opA) < $unsigned(opB) ? 32'b1 : 32'b0;
            default   : result = 32'b0;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule


//--------------------------------------------------------------------


module register_file
(
    input         clk, write_enable,
    input  [4 :0] rs0, rs1, rs2, rd,
    input  [31:0] write_data,
    output [31:0] rd0, rd1, rd2
);

    reg [31:0] rf [31:0]; // To dump an array word Icarus needs to escape the name so it is compatible with the VCD dump format

    assign rd0 = (rs0 != 5'b0) ? rf [rs0] : 32'b0;
    assign rd1 = (rs1 != 5'b0) ? rf [rs1] : 32'b0;
    assign rd2 = (rs2 != 5'b0) ? rf [rs2] : 32'b0;

    always @ (posedge clk)
        if (write_enable)
            rf [rd] <= write_data;

endmodule


//--------------------------------------------------------------------


module program_counter
(
    input             clk, rst,
    input      [31:0] D,
    output reg [31:0] Q
);

    always @ (posedge clk or negedge rst)
        if (~ rst)
            Q <= 32'b0;
        else
            Q <= D;

endmodule


//--------------------------------------------------------------------


module instruction_memory
(
    input  [31:0] instruction_address,
    output [31:0] instruction_data
);

    reg [31:0] ROM [63:0];

    assign instruction_data = ROM [instruction_address [31:2]]; // Word aligned

    initial begin
        $readmemh ("program.hex", ROM);
    end

endmodule


//--------------------------------------------------------------------


module data_memory
(
    input         clk, write_enable,
    input  [31:0] data_address, write_data,
    output [31:0] read_data
);

    reg [31:0] RAM [63:0];

    assign read_data = RAM [data_address [31:2]];

    always @ (posedge clk)
        if (write_enable) 
            RAM [data_address [31:2]] <= write_data;

endmodule
