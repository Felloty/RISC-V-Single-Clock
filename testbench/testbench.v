`timescale 1 ns / 100 ps

`include "cpu.vh"

`ifndef SIMULATION_CYCLES
    `define SIMULATION_CYCLES 120
`endif

module testbench;

    // Simulation options
    parameter Tt = 20;

    reg        clk;
    reg        rst_n;

    // ***** DUT start ************************

    top top_entity
    (
        .clk            ( clk     ),
        .rst            ( rst_n   ),
        .clkDivide      (         ),
        .clkEnable      (         ),
        .regAddress     (         ),
        .clkOut         (         ),
        .regData        (         )
    );

    defparam top_entity.cpu_clk_div.bypass = 1;

    // ***** DUT  end  ************************

`ifdef ICARUS
    // Iverilog memory dump init workaround
    initial $dumpvars;
    genvar k;
    for (k = 0; k < 32; k = k + 1) begin
        initial $dumpvars(0, top_entity.cpu_entity.register_file_instance.rf[k]);
    end
`endif

    // Simulation init
    initial begin
        clk = 0;
        forever clk = #(Tt/2) ~clk;
    end

    initial begin
        rst_n   = 0;
        repeat (4)  @(posedge clk);
        rst_n   = 1;
    end

    // Simulation debug output
    integer cycle; initial cycle = 0;

    always @ (posedge clk)
    begin
        $write ("%5d   pc = %2h   instruction_data = %h   x10 = %1d", cycle, top_entity.cpu_entity.pc, top_entity.cpu_entity.instruction_data, top_entity.cpu_entity.register_file_instance.rf[10]);
        $write("\n");
        cycle = cycle + 1;
        if (cycle > `SIMULATION_CYCLES)
        begin
            cycle = 0;
            $display ("Timeout");
            $stop;
        end
    end

endmodule
