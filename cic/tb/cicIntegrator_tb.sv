// vlog src/cicIntegrator.sv
// vlog tb/cicIntegrator_tb.sv
// vsim cicIntegrator_tb
// run -all

`timescale 1ns/1ps

module cicIntegrator_tb;

    // ------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------

    localparam int N          = 2;
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
    logic [Width-1:0] dataOut;

    // ------------------------------------------------------------
    // Monitor internal signals
    // ------------------------------------------------------------

    logic [Width-1:0] stage0;
    logic [Width-1:0] stage1;

    assign stage0 = dut.stage[0];
    assign stage1 = dut.stage[1];

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    cicIntegrator #(
        .N(N),
        .Width(Width)
    ) dut (
        .clk(clk),
        .rst(rst),
        .validIn(validIn),
        .dataIn(dataIn),
        .dataOut(dataOut)
    );

    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------

    initial begin

        $display("\n========================================");
        $display("CIC Integrator Test");
        $display("========================================\n");

        rst     = 1;
        validIn = 0;
        dataIn  = 0;

        repeat (3) @(posedge clk);

        rst = 0;
        validIn = 1;

        $display("Applying ramp input...\n");

        for (int i = 0; i < 10; i++) begin
            dataIn = i;
            @(posedge clk);

            $display("i=%2d in=%4d stage0=%6d stage1=%6d out=%6d",
                     i, dataIn, stage0, stage1, dataOut);
        end

        $finish;
    end

endmodule