`timescale 1ns/1ps

module integrate_tb;

    // Testbench parameters
    localparam int WIDTH        = 32;
    localparam int SAMPLES      = 1024;
    localparam int CLK_PERIOD   = 10;

    // Clock generation
    logic clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // DUT signals
    logic               reset;
    logic [WIDTH-1:0]   dataIn;
    logic [WIDTH-1:0]   dataOut;

    // Internal signals for monitoring
    logic [WIDTH + $clog2(SAMPLES)-1:0] accumulate;
    logic [$clog2(SAMPLES)-1:0]         count;

    // DUT instantiation
    integrate #(
        .WIDTH(WIDTH),
        .SAMPLES(SAMPLES)
    ) dut (
        .clk(clk),
        .reset(reset),
        .dataIn(dataIn),
        .dataOut(dataOut)
    );

    // Connect internal signals
    assign accumulate = dut.accumulate;
    assign count = dut.count;

    // Test variables
    int error_count = 0;
    logic [WIDTH-1:0] expected_avg;
    logic [WIDTH + $clog2(SAMPLES)-1:0] expected_accum;

    // Test sequence
    initial begin
        $display("\n========================================");
        $display("Testing Integrator Module");
        $display("Samples: %0d, Width: %0d bits", SAMPLES, WIDTH);
        $display("========================================\n");

        // Initialize
        reset = 0;
        dataIn = 0;
        
        // Apply reset
        repeat (2) @(posedge clk);
        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);
        
        $display("Reset complete. Starting test with DC + 1-bit variation...\n");

        // Single test: 64 samples alternating between 0x100 and 0x101
        // This gives an average of (0x100 + 0x101)/2 = 0x100.5 = 256.5
        // For 64 samples, total accumulate should be 64 * 256.5 = 16416 (0x4020)
        // Shift right by 6 (log2(64)) gives 16416/64 = 256.5, but integer output will be 256 or 257
        
        $display("Input pattern: Alternating between 0x100 (256) and 0x101 (257)");
        $display("Expected average: 256.5 (rounded to nearest integer by shift)\n");
        
        $display("Sample-by-sample accumulation:");
        $display("-------------------------------");
        
        for (int i = 0; i < SAMPLES; i++) begin
            @(posedge clk);
            
            // Generate alternating pattern
            dataIn = 32'h00000100 + (i % 2);
            
            // Display progress
            $display("Sample %2d: dataIn=0x%0h (%3d) | count=%2d | accumulate=0x%0h (%5d)", 
                    i, dataIn, dataIn, count, accumulate, accumulate);
        end
        
        // Wait for output to be calculated (the output is updated on the same clock
        // edge as the last sample, but we need to wait one more cycle to see it)
        @(posedge clk);
        
        $display("\n-------------------------------");
        $display("\n=== Results ===");
        $display("Final accumulate before output = 0x%0h (%0d)", accumulate, accumulate);
        $display("Final count = %0d", count);
        $display("dataOut = 0x%0h (%0d)", dataOut, dataOut);
        
        // Calculate expected values
        expected_accum = 0;
        for (int i = 0; i < SAMPLES; i++) begin
            expected_accum += 32'h00000100 + (i % 2);
        end
        
        $display("\n=== Expected Calculations ===");
        $display("Expected accumulate total = 0x%0h (%0d)", expected_accum, expected_accum);
        
        // Right shift by log2(SAMPLES) = 6 for 64 samples
        expected_avg = expected_accum >>> $clog2(SAMPLES);
        $display("Expected average (accumulate >> %0d) = 0x%0h (%0d)", 
                $clog2(SAMPLES), expected_avg, expected_avg);
                
        $finish;
    end
    
endmodule