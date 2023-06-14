module omdazz
(
    input        clk,
    input        rst,
    input  [3:0] key,
    output [3:0] led,
    output [7:0] hex,
    output [3:0] digit,
    output       buzzer
);

    wire        clkHex;
    wire        clkCpu;
    wire        clkEnable   =  key [1];
    wire [4 :0] regAddress  =  key [2] ? 5'ha : 5'h0;
    wire [3 :0] clkDivide   =  4'b1000;
    wire [7 :0] digits;
    wire [31:0] regData;

    assign led   [3:0] = { 4 {~ clkCpu} };
    assign digit [3:0] = key [3] ? digits [3:0] : digits [7:4];
    assign buzzer      = 1'b1;

    seven_segments seven_segments_entity
    (
         .clk             ( clkHex         ),
         .rst             ( rst            ),
         .number          ( regData        ),
         .seven_seg       ( hex [6:0]      ),
         .digits          ( digits         ),
         .dot             ( hex [7]        )
    );

    clock_divider hex_clk_div
    (
         .clk             ( clk            ),
         .rst             ( rst            ),
         .divide          ( 4'b0000        ),
         .enable          ( 1'b1           ),
         .clkOut          ( clkHex         )
    );

    top top_entity 
    (
         .clk             ( clk            ),
         .rst             ( rst            ),
         .clkDivide       ( clkDivide      ),
         .clkEnable       ( clkEnable      ),
         .regAddress      ( regAddress     ),
         .clkOut          ( clkCpu         ),
         .regData         ( regData        )
    );

endmodule


//--------------------------------------------------------------------


module seven_segments
(
    input             clk,
    input             rst,
    input      [31:0] number,
    output reg [6 :0] seven_seg,
    output reg [7 :0] digits,
    output reg        dot
);

    function [6:0] dig_to_seg (input [3:0] dig);
        case (dig)
        4'h0: dig_to_seg = 7'b1000000;  // g f e d c b a
        4'h1: dig_to_seg = 7'b1111001;
        4'h2: dig_to_seg = 7'b0100100;  //   --a--
        4'h3: dig_to_seg = 7'b0110000;  //  |     |
        4'h4: dig_to_seg = 7'b0011001;  //  f     b
        4'h5: dig_to_seg = 7'b0010010;  //  |     |
        4'h6: dig_to_seg = 7'b0000010;  //   --g--
        4'h7: dig_to_seg = 7'b1111000;  //  |     |
        4'h8: dig_to_seg = 7'b0000000;  //  e     c
        4'h9: dig_to_seg = 7'b0011000;  //  |     |
        4'ha: dig_to_seg = 7'b0001000;  //   --d-- 
        4'hb: dig_to_seg = 7'b0000011;
        4'hc: dig_to_seg = 7'b1000110;
        4'hd: dig_to_seg = 7'b0100001;
        4'he: dig_to_seg = 7'b0000110;
        4'hf: dig_to_seg = 7'b0001110;
        endcase
    endfunction

    reg [2:0] i;

    always @ (posedge clk or negedge rst)
        begin
            if (~ rst)
		        begin
                    seven_seg   <=   dig_to_seg (4'h0);
                    dot         <=   1'b1;
                    digits      <=   8'b11111110;
                    i           <=   3'b000;
		        end
            else
                begin
                    seven_seg   <=   dig_to_seg (number [i * 4 +: 4]); // Indexed vector part-select: number[3 + (i * 4):(i * 4)]
                    dot         <=   1'b1;
                    digits      <=   ~ (8'b00000001 << i);
                    i           <=   i + 3'b001;
                end
        end

endmodule
