`timescale 1ns/1ps

module integrate_tb;

    // ------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------

    localparam int WIDTH      = 16;
    localparam int SAMPLES    = 1024;
    localparam int CLK_PERIOD = 10;

    // ------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------

    logic clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ------------------------------------------------------------
    // DUT signals
    // ------------------------------------------------------------

    logic                     reset;
    logic                     validIn;
    logic signed [WIDTH-1:0]  dataIn;

    logic signed [WIDTH-1:0]  dataOut;
    logic                     validOut;

    // ------------------------------------------------------------
    // Monitor internal DUT signals
    // ------------------------------------------------------------

    logic signed [WIDTH + $clog2(SAMPLES)-1:0] accumulate;
    logic [$clog2(SAMPLES)-1:0] count;

    assign accumulate = dut.accumulate;
    assign count      = dut.count;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    integrate #(
        .WIDTH(WIDTH),
        .SAMPLES(SAMPLES)
    ) dut (
        .clk        (clk),
        .reset      (reset),
        .validIn    (validIn),
        .dataIn     (dataIn),
        .dataOut    (dataOut),
        .validOut   (validOut)
    );

    // ------------------------------------------------------------
    // Test variables
    // ------------------------------------------------------------

    logic signed [WIDTH-1:0] expected_avg;
    logic signed [WIDTH + $clog2(SAMPLES)-1:0] expected_accum;

    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------

    initial begin

        $display("\n========================================");
        $display("Integrator Test");
        $display("WIDTH=%0d SAMPLES=%0d", WIDTH, SAMPLES);
        $display("========================================\n");

        reset   = 1;
        validIn = 0;
        dataIn  = 0;

        repeat (3) @(posedge clk);

        reset = 0;
        @(posedge clk);

        validIn = 1;

        $display("Applying alternating inputs...\n");

        for (int i = 0; i < SAMPLES; i++) begin

            dataIn = 16'sh0100 + (i % 2);

            @(posedge clk);

            $display("i=%4d data=%4d count=%4d accum=%8d",
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
        // Expected value calculation
        // ------------------------------------------------------------

        expected_accum = 0;

        for (int i = 0; i < SAMPLES; i++)
            expected_accum += 16'sh0100 + (i % 2);

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