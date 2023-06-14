module top
(
    input         clk,
    input         rst,
    input  [3 :0] clkDivide,
    input         clkEnable,
    input  [4 :0] regAddress,
    output        clkOut,
    output [31:0] regData
);

    wire [3:0] divide;
    wire       enable;
    wire [4:0] regAddr;

    metastability_debouncer #(.SIZE(4)) meta_deb4(.clk(clk), .rst(rst), .D(clkDivide),  .Q(divide)   );
    metastability_debouncer #(.SIZE(1)) meta_deb1(.clk(clk), .rst(rst), .D(clkEnable),  .Q(enable)   );
    metastability_debouncer #(.SIZE(5)) meta_deb5(.clk(clk), .rst(rst), .D(regAddress), .Q(regAddr)  );

    clock_divider cpu_clk_div
    (
        .clk                  ( clk                  ),
        .rst                  ( rst                  ),
        .divide               ( divide               ),
        .enable               ( enable               ),
        .clkOut               ( clkOut               )
    );

    cpu cpu_entity
    (
        .clk                  ( clkOut               ),
        .rst                  ( rst                  ),
        .regAddress           ( regAddr              ),
        .regData              ( regData              )
    );

endmodule


//--------------------------------------------------------------------


module metastability_debouncer #(parameter SIZE = 1)
(
    input                   clk, rst,
    input      [SIZE - 1:0] D,
    output reg [SIZE - 1:0] Q
);

    reg [SIZE - 1:0] data;

    always @ (posedge clk or negedge rst)
        if (~ rst)
            begin
                data <= {SIZE{1'b0}};
                Q    <= {SIZE{1'b0}};
            end
        else
            begin
                data <= D;
                Q    <= data;
            end

endmodule


//--------------------------------------------------------------------


module clock_divider #(parameter shift  = 16, bypass = 0)
(
    input       clk,
    input       rst,
    input [3:0] divide,
    input       enable,
    output      clkOut
);

    reg [31:0] cntr;

    assign clkOut = bypass ? clk : cntr[shift + divide];

    always @ (posedge clk or negedge rst)
        if (~ rst)
            cntr <= 32'b0;
        else if (enable)
            cntr <= cntr + 32'b1;

endmodule
