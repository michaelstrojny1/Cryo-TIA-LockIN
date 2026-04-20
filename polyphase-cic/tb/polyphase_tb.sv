import lockIn_pkg::*;

`timescale 1ns/1ps

module polyphase_tb;

    // Testbench parameters
    localparam int R             = 4;        // Must match DUT
    localparam int N             = 4;        // Must match DUT
    localparam int M             = 1;        // Must match DUT
    localparam int ADC_WIDTH     = 16;       // Must match DUT
    localparam int ACCUM_WIDTH   = 32;       // Must match DUT
    
    // Clock periods
    localparam real CLK_ADC_PERIOD = 10.0;   // 100 MHz
    localparam real CLK_SLOW_PERIOD = CLK_ADC_PERIOD * R;  // Decimated clock
    
    // Signals
    logic clkADC, clkSlow, rstN;
    logic [ADC_WIDTH-1:0] adcData;
    cicOutputT cicOut;
    logic cicReady;
    
    // Internal tracking variable for previous output
    logic [31:0] cicOut_prev;
    
    // Clock generators
    initial begin
        clkADC = 0;
        forever #(CLK_ADC_PERIOD/2.0) clkADC = ~clkADC;
    end
    
    initial begin
        clkSlow = 0;
        forever #(CLK_SLOW_PERIOD/2.0) clkSlow = ~clkSlow;
    end
    
    // Instantiate DUT
    polyphase #(
        .R(R),
        .N(N),
        .M(M),
        .ADC_WIDTH(ADC_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) dut (
        .clkADC(clkADC),
        .clkSlow(clkSlow),
        .rstN(rstN),
        .adcData(adcData),
        .cicOut(cicOut),
        .cicReady(cicReady)
    );

    // STEP 2: DEFINE TEST SEQUENCE
    
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, polyphase_tb);
        
        // Initialize
        rstN = 0;
        adcData = 0;
        cicOut_prev = 0;
        
        // ========== TEST 1: RESET ==========
        $display("\n==================================================");
        $display("TEST 1: RESET");
        $display("==================================================");
        
        repeat(5) @(posedge clkADC);
        
        if (cicOut.valid == 0 && cicReady == 0) begin
            $display("Reset test PASSED");
        end else begin
            $display("Reset test FAILED");
            $finish;
        end
        
        // ========== TEST 2: CONSTANT DC INPUT ==========
        $display("\n==================================================");
        $display("TEST 2: CONSTANT DC INPUT (0x1000)");
        $display("==================================================");
        
        $display("Input: 16'h1000 = %0d decimal", 16'h1000);
        $display("Expected gain: (R*M)^N = (%0d*%0d)^%0d = %0d^%0d = %0d", 
                 R, M, N, R*M, N, (R*M)**N);
        $display("Expected output: %0d x %0d = %0d", 
                 16'h1000, (R*M)**N, 16'h1000 * (R*M)**N);
        $display("Expected hex: 0x%08h", 16'h1000 * (R*M)**N);
        
        rstN = 1;
        adcData = 16'h1000;  // 4096 decimal
        
        // Wait a few cycles for CIC to start
        repeat(5) @(posedge clkADC);
        
        // Display header
        $display("\n-------------------------------------------------------");
        $display("CONSTANT WAVE OUTPUT DATA");
        $display("-------------------------------------------------------");
        $display("clkSlow | Time(ns) | cicOut.data (hex) | cicOut.data (dec) | Valid | Ready");
        $display("--------|----------|-------------------|-------------------|-------|------");
        
        // Capture and display outputs for 40 clkSlow cycles
        for (int i = 0; i < 40; i++) begin
            @(posedge clkSlow);
            
            // Display output when valid
            $display("%7d | %8t | 0x%08h         | %19d | %1b     | %1b",
                    i, $time, cicOut.data, cicOut.data, cicOut.valid, cicReady);
            
            // Check when output stabilizes
            if (i > 20 && cicOut.data == cicOut_prev && cicOut.valid) begin
                $display("Output stabilized at 0x%08h (%0d)", cicOut.data, cicOut.data);
            end
            cicOut_prev = cicOut.data;
        end
        
        // Display final summary
        $display("\n-------------------------------------------------------");
        $display("FINAL ANALYSIS");
        $display("-------------------------------------------------------");
        $display("Final output value: 0x%08h (%0d)", cicOut.data, cicOut.data);
        $display("Expected value:     0x%08h (%0d)", 
                 (16'h1000 * (R*M)**N), (16'h1000 * (R*M)**N));
        
        if (cicOut.data == (16'h1000 * (R*M)**N)) begin
            $display("TEST PASSED: Output matches expected value!");
        end else begin
            $display("TEST FAILED: Output differs from expected value");
            $display(" Difference: %0d", cicOut.data - (16'h1000 * (R*M)**N));
        end
        
        // Wait a bit more then finish
        repeat(20) @(posedge clkADC);
        $finish;
    end

endmodule