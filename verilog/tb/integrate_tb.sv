`timescale 1ns/1ps

import lockIn_pkg::*;

module integrate_tb;

    // ------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------

    localparam int SAMPLES    = 1024;
    localparam int CLK_PERIOD = 10;

    localparam int DATA_WIDTH = 32;
    localparam int ACC_WIDTH  = DATA_WIDTH + $clog2(SAMPLES);

    // ------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------

    logic clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ------------------------------------------------------------
    // DUT signals
    // ------------------------------------------------------------

    logic  reset;
    logic  validIn;

    accumT dataIn;
    accumT dataOut;

    logic  validOut;

    // ------------------------------------------------------------
    // Monitor internal DUT signals
    // ------------------------------------------------------------

    logic signed [ACC_WIDTH-1:0] accumulate;
    logic [$clog2(SAMPLES)-1:0]  count;

    assign accumulate = dut.accumulate;
    assign count      = dut.count;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    integrate #(
        .SAMPLES(SAMPLES)
    ) dut (
        .clk      (clk),
        .reset    (reset),
        .validIn  (validIn),
        .dataIn   (dataIn),
        .dataOut  (dataOut),
        .validOut (validOut)
    );

    // ------------------------------------------------------------
    // Test variables
    // ------------------------------------------------------------

    accumT expected_avg;
    logic signed [ACC_WIDTH-1:0] expected_accum;

    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------

    initial begin

        $display("\n========================================");
        $display("Integrator Test");
        $display("SAMPLES=%0d", SAMPLES);
        $display("========================================\n");

        reset   = 1;
        validIn = 0;
        dataIn  = '0;

        repeat (3) @(posedge clk);

        reset = 0;
        @(posedge clk);

        validIn = 1;

        $display("Applying alternating inputs...\n");

        for (int i = 0; i < SAMPLES; i++) begin

            dataIn = 32'sh00000100 + (i % 2);

            @(posedge clk);

            $display("i=%4d data=%6d count=%4d accum=%10d",
                     i, dataIn, count, accumulate);
        end

        // Wait for output
        @(posedge clk);

        $display("\n===============================");
        $display("Integrator Output");
        $display("===============================");

        $display("dataOut  = %0d", dataOut);
        $display("validOut = %0d", validOut);

        // ------------------------------------------------------------
        // Expected calculation
        // ------------------------------------------------------------

        expected_accum = '0;

        for (int i = 0; i < SAMPLES; i++)
            expected_accum += 32'sh00000100 + (i % 2);

        expected_avg = expected_accum >>> $clog2(SAMPLES);

        $display("\nExpected:");
        $display("accum = %0d", expected_accum);
        $display("avg   = %0d", expected_avg);

        if (dataOut == expected_avg)
            $display("\nTEST PASSED");
        else
            $display("\nTEST FAILED");

        $finish;
    end

endmodule