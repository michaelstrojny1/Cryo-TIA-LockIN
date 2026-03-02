`timescale 1ns/1ps

module integrate_tb 

    // STEP 1: SET UP DUT

    // Testbench parameters
    localparam WIDTH        = 32;
    localparam SAMPLES      = 1024;
    localparam CLK_PERIOD   = 10;

    // Generate clock
    always #(CLK_PERIOD/2) clk = ~clk;

    logic               reset;
    logic [WIDTH-1:0]   dataIn;
    logic [WIDTH-1:0]   dataOut;

    integrate #(
        .WIDTH(WIDTH),
        .SAMPLES(SAMPLES)
    ) dut (
        .clk(),
        .reset(reset),
        .dataIn(dataIn),
        .dataOut(dataOut)
    );

    // STEP 2: TEST DUT
    initial begin
        
        // Initialize input signals
        clk     = 0;
        reset   = 0;
        dataIn  = 0;

        // Apply reset
        @(posedge clk);
        reset = 1;
        @(posedge clk);
        reset = 0;

        // Test with near-DC signal
        for (int i = 0; i < SAMPLES * 3; i++) begin
            @(posedge clk)

            // Near-DC signal: 0x100 + small variation
            dataIn = 32'h00000100 + (i % 2);

            // Monitor output when i equal multiple of SAMPLES
            if (i > - && ( i % SAMPLES) == 0) begin
                $display("Time: %0t, Sample block %0d complete, dataOut = 0x%0h (%0d)",
                $time, i/SAMPLES, dataOut, dataOut);
            end
        end

        // Test with pure DC signal
        $display("Test with pure DC signal");
        dataIn = 32'h0000100;

        for (int i = 0; i < SAMPLES; i++) begin
            @(posedge clk);
        end

        $display("After DC block, dataOut = 0x%0h (%0d)",
                dataOut, dataOut);

            // Expected value: 0x100 * SAMPLES / SAMPLES = 0x100
            if (dataOut == 32'h00000100)
                $display("Test PASSED");
            else
                $display("Test FAILED: Expected 0x100, got 0x%0h", dataOut);
            
            $finish;
    end

endmodule