import lockIn_pkg::*;

module polyphase_tb;

    // Clock
    logic clkADC    = 0;
    logic clkSlow   = 0;
    logic rstN      = 0;

    always #5 clkADC    = ~clkADC;   // 100 MHz (10ns period)
    always #20 clkSlow  = ~clkSlow;  // 25 MHz (40ns period)

    // Signals
    localparam R         = 4;
    localparam ADC_WIDTH = 16;

    logic       [ADC_WIDTH-1:0]   adcData;
    cicOutputT                    cicOut;
    logic                         cicReady;

    int iteration = 0;
    int sample_count = 0;

    // Testing with R = 4 for faster simulations
    polyphase #(.R(4)) dut (.*);

    // STEP 2: DEFINE TEST SEQUENCE
    
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, polyphase_tb);
        
        // Test 1: Reset
        $display("=== Test 1: Reset Test ===");
        rstN = 0;
        adcData = 0;
        repeat(10) @(posedge clkADC);

        // Check all outputs are zero
        if (cicOut.valid == 0 && cicReady == 0) begin
            $display("Reset test PASSED");
        end else begin
            $display("Reset test FAILED");
            $finish;
        end

        // Test 2: DC Input
        $display("\n=== Test 2: DC Input ===");
        $display("Applying constant DC input = 16'h1000 (4096 decimal)");
        rstN = 1;
        adcData = 16'h1000; // Constant input of 4096
        
        // Wait a few cycles for CIC to start processing
        repeat(5) @(posedge clkADC);
        
        // Loop based on clkSlow (output rate) and display values
        $display("\nMonitoring CIC outputs on clkSlow edges:");
        $display("Clock   | Time(ns) | cicOut.data  | cicOut.valid | cicReady");
        $display("--------|----------|--------------|--------------|---------");
        
        for (iteration = 0; iteration < 20; iteration++) begin
            @(posedge clkSlow);  // Wait for output clock edge
            
            // Display all relevant signals
            $display("clkSlow | %8t | %12h | %12b | %8b",
                    $time, cicOut.data, cicOut.valid, cicReady);
            
            // Optional: Also display ADC data at this time
            $display("  ADC Data: %h (%0d decimal)", adcData, adcData);
            
            // Count valid outputs
            if (cicOut.valid) begin
                sample_count++;
                $display("  Valid sample #%0d received", sample_count);
            end
        end
    end

endmodule