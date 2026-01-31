import lockIn_pkg::*;

module polyphase_tb;

    // STEP 1: SET UP DUT

    // Clock
    logic clkADC    = 0;
    logic clkSlow   = 0;
    logic rstN      = 0;

    always #5 clkADC    = ~clkADC;   // 100 MHz
    always #80 clkSlow  = ~clkSlow;  // 100 Mhz/16 

    // Signals
    localparam ADC_WIDTH = 16;

    logic       [ADC_WIDTH-1:0]   adcData;
    cicOutputT                    cicOut;
    logic                         cicReady;

    polyphase dut (
        .clkADC(clkADC),
        .clkSlow(clkSlow),
        .rstN(rstN),
        .adcData(adcData),
        .cicOut(cicOut),
        .cicReady(cicReady)
    );

    // STEP 2: DEFINE TEST SEQUENCE
    
    initial begin
        // Test 1: Reset
        $display("=== Test 1: Reset Test ===");
        rstN = 0;
        adcData = 0;
        repeat(10) @(posedge clkADC);

        // Check all outputs are zero
        assert(cicOut.valid == 0);
        assert(cicReady == 0);
        $display("Reset test PASSED");
    end

endmodule