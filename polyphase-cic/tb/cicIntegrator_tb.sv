`timescale 1ns/1ps

module cicIntegrator_tb;

    // ------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------

    localparam int N        = 81536;
    localparam int Width    = 10;

    localparam int CLK_PERIOD = ;

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
    logic dataIn;

    logic [Width-1:0] integratorOut;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    cicIntegrator #(
        .N      (N),
        .Width  (Width)
    ) dut (
        .clk            (clk),
        .rst            (rst),
        .validIn        (validIn),
        .dataIn         (dataIn),
        .integratorOut  (integratorOut)
    );

    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------

    initial begin

        $display("\n========================================");
        $display("Integrator Test");
        $display("SAMPLES=%0d", SAMPLES);
        $display("========================================\n");

        rst     = 1;
        validIn = 0;
        dataIn  = '0;

        repeat (3) @(posedge clk);

        

    end



endmodule