// vlog src/cicDecimator.sv
// vlog tb/cicDecimator_tb.sv
// vsim cicDecimator_tb
// run -all

`timescale 1ns/1ps

module cicDecimator_tb;

    // ------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------

    localparam int R          = 4;
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
    logic ce;

    // ------------------------------------------------------------
    // Monitor internal
    // ------------------------------------------------------------

    logic [$clog2(R)-1:0] count;
    assign count = dut.count;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    cicDecimator #(
        .R(R)
    ) dut (
        .clk(clk),
        .rst(rst),
        .validIn(validIn),
        .ce(ce)
    );

    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------

    initial begin

        $display("\n========================================");
        $display("CIC Decimator Test");
        $display("========================================\n");

        rst     = 1;
        validIn = 0;

        repeat (3) @(posedge clk);

        rst = 0;
        validIn = 1;

        $display("Counting and generating CE...\n");

        for (int i = 0; i < 20; i++) begin
            @(posedge clk);

            $display("i=%2d count=%2d ce=%1b",
                     i, count, ce);
        end

        $finish;
    end

endmodule