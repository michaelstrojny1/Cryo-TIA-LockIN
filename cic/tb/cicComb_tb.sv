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

    logic               rst;
    logic               ce;
    logic   [Width-1:0] dataIn;
    logic   [Width-1:0] dataOut;

    // ------------------------------------------------------------
    // Monitor internal DUT signals
    // ------------------------------------------------------------

    logic [Width-1:0] stage0;
    logic [Width-1:0] stage1;

    logic [Width-1:0] prev0;
    logic [Width-1:0] prev1;

    assign stage0 = dut.stage[0];
    assign stage1 = dut.stage[1];

    assign prev0  = dut.prevValue[0];
    assign prev1  = dut.prevValue[1];

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    cicComb #(

        .N          (N),
        .M          (M),
        .Width      (Width)

    ) dut (

        .clk        (clk),
        .rst        (rst),

        .ce         (ce),
        .dataIn     (dataIn),

        .dataOut    (dataOut)

    );

    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------

    initial begin

        $display("\n======================================================");
        $display("CIC Comb Test (with internal signals)");
        $display("======================================================\n");

        rst    = 1;
        ce     = 0;
        dataIn = 0;

        repeat (3) @(posedge clk);

        rst = 0;

        $display("Applying CE-gated ramp...\n");

        $display(" i | in | ce | stage0 | prev0 | stage1 | prev1 | out");
        $display("------------------------------------------------------");

        for (int i = 0; i < 20; i++) begin

            @(posedge clk);

            dataIn = i;
            ce     = (i % 4 == 0);

            $display("%2d | %3d | %1b  | %6d | %6d | %6d | %6d | %6d",
                     i, dataIn, ce,
                     stage0, prev0,
                     stage1, prev1,
                     dataOut);
        end

        $finish;
    end

endmodule