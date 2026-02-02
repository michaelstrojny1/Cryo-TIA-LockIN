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


    end

endmodule