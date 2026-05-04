// vlog pkg/lockIn_pkg.sv
// vlog src/cicIntegrator.sv
// vlog src/cicDecimator.sv
// vlog src/cicComb.sv
// vlog src/cic.sv
// vlog tb/cic_tb.sv
// vsim cic_tb
// run -all

`timescale 1ns/1ps

import lockIn_pkg::*;

module cic_tb;

    // ------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------

    localparam int R          = 4;
    localparam int N          = 2;
    localparam int M          = 1;
    localparam int Width      = 16;
    localparam int CLK_PERIOD = 10;

    // ------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------

    logic clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ------------------------------------------------------------
    // DUT signals
    // ------------------------------------------------------------

    logic rst;
    logic validIn;
    logic [Width-1:0] dataIn;

    sampleT dataOut;
    logic   validOut;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    cic #(
        .R(R),
        .N(N),
        .M(M),
        .ADCWidth(Width)
    ) dut (
        .clk(clk),
        .rst(rst),
        .validIn(validIn),
        .dataIn(dataIn),
        .dataOut(dataOut),
        .validOut(validOut)
    );

    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------

    initial begin

        $display("\n========================================");
        $display("Full CIC Test");
        $display("========================================\n");

        rst     = 1;
        validIn = 0;
        dataIn  = 0;

        repeat (3) @(posedge clk);

        rst = 0;
        validIn = 1;

        $display("Applying ramp input...\n");

        for (int i = 0; i < 40; i++) begin

            @(posedge clk);

            dataIn = i;

            $display("i=%2d in=%4d validOut=%1b out=%6d",
                     i, dataIn, validOut, dataOut.data);
        end

        $finish;
    end

endmodule