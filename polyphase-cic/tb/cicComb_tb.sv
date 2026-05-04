// vlog src/cicComb.sv
// vlog tb/cicComb_tb.sv
// vsim cicComb_tb
// run -all

`timescale 1ns/1ps

module cicComb_tb;

    // ------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------

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
    logic ce;
    logic [Width-1:0] dataIn;
    logic [Width-1:0] dataOut;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    cicComb #(
        .N(N),
        .M(M),
        .Width(Width)
    ) dut (
        .clk(clk),
        .rst(rst),
        .ce(ce),
        .dataIn(dataIn),
        .dataOut(dataOut)
    );

    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------

    initial begin

        $display("\n========================================");
        $display("CIC Comb Test");
        $display("========================================\n");

        rst    = 1;
        ce     = 0;
        dataIn = 0;

        repeat (3) @(posedge clk);

        rst = 0;

        $display("Applying CE-gated ramp...\n");

        for (int i = 0; i < 20; i++) begin

            @(posedge clk);

            dataIn = i;

            // Pulse CE every 4 cycles
            ce = (i % 4 == 0);

            $display("i=%2d in=%4d ce=%1b out=%6d",
                     i, dataIn, ce, dataOut);
        end

        $finish;
    end

endmodule