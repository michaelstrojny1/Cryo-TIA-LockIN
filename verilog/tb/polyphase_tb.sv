import lockIn_pkg::*;

module polyphase_tb;

    // Clock
    logic clkADC    = 0;
    logic clkSlow   = 0;
    logic rstN      = 0;

    always #5 clkADC    = ~clkADC;   // 100 MHz (10ns period)
    always #20 clkSlow  = ~clkSlow;  // 25 MHz (40ns period) - CORRECT for R=4

    // Signals
    localparam R         = 4;
    localparam ADC_WIDTH = 16;

    logic       [ADC_WIDTH-1:0]   adcData;
    cicOutputT                    cicOut;
    logic                         cicReady;

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
        $display("=== Test 2: DC Input ===");
        rstN = 1;
        adcData = 16'h1000; // Constant input of 4096

        // DEBUG: Monitor internal signals
        $display("\n=== Debug: Monitoring Internal Signals ===");
        
        fork
            // Monitor clkADC domain
            begin
                forever begin
                    @(posedge clkADC);
                    $display("[%0t] ADC: inputPtr=%0d", $time, dut.inputPtr);
                    if ($time > 1000) disable fork;
                end
            end
            
            // Monitor clkSlow domain  
            begin
                forever begin
                    @(posedge clkSlow);
                    $display("[%0t] SLOW: combProcessing=%b, combPtr=%0d", 
                             $time, dut.combProcessing, dut.combPtr);
                    if ($time > 1000) disable fork;
                end
            end
            
            // Wait for output
            begin
                #10000;  // 10us timeout
                $display("\n[%0t] DEBUG DUMP:", $time);
                $display("  inputPtr = %0d", dut.inputPtr);
                $display("  combProcessing = %b", dut.combProcessing);
                $display("  combPtr = %0d", dut.combPtr);
                $display("  cicOut.valid = %b", cicOut.valid);
                $display("  cicReady = %b", cicReady);
                $display("\nERROR: No outputs after 10us!");
                $finish;
            end
        join
        
        // If we get here, we timed out
        $display("\n=== Simulation failed - no outputs ===");
        $finish;
    end

endmodule