module polyphase_tb;

    import lockIn_pkg::*;

    // STEP 1: SET UP DUT

    // Clock
    logic clkADC    = 0;
    logic clkSlow   = 0;
    logic rstN      = 0;

    always #5 clkAdc    = ~clkADC;   // 100 MHz
    always #80 clkSlow  = ~clkSlow;  // 100 Mhz/16 

    // Signals

    localparam ADC_WIDTH = 32;

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

endmodule