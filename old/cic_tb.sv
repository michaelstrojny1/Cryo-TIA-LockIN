import lockIn_pkg::*;

`timescale 1ns/1ps

module cic_tb;

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
    cic #(
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
        $dumpvars(0, cic_tb);
        
        // Initialize
        rstN = 0;
        adcData = 0;
        
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
        
        rstN = 1;
        adcData = 16'h1000;
        
        // Wait for steady state
        repeat(100) @(posedge clkADC);
        
        // ========== TEST 3: SINE WAVE ==========
        $display("\n==================================================");
        $display("TEST 3: SINE WAVE INPUT");
        $display("==================================================");
        
        $display("\nParameters:");
        $display("  DC Offset: 2048 (0x0800)");
        $display("  Amplitude: 1000");
        $display("  Period: 32 samples");
        $display("  Sampling rate: %0d ns period", CLK_ADC_PERIOD);
        $display("  Decimation: R = %0d", R);
        $display("  CIC gain: (R*M)^N = %0d", (R*M)**N);
        
        // Reset filter for clean start
        rstN = 0;
        repeat(5) @(posedge clkADC);
        rstN = 1;
        repeat(20) @(posedge clkADC);
        
        // Display header
        $display("\n------------------------------------------------------------");
        $display("SINE WAVE OUTPUT DATA");
        $display("------------------------------------------------------------");
        $display("clkSlow | Time(ns) | Input(hex) | Input(dec) | Output(hex)   | Output(dec)   | Valid");
        $display("------------------------------------------------------------");
        
        // Apply sine wave and capture outputs
        for (int cycle = 0; cycle < 3; cycle++) begin  // 3 full cycles
            for (int phase = 0; phase < 32; phase++) begin  // 32 samples per cycle
                real angle, sine_value;
                integer input_value;
                
                // Calculate sine wave sample
                angle = 2.0 * 3.1415926535 * phase / 32.0;
                sine_value = 2048.0 + 1000.0 * $sin(angle);
                input_value = $rtoi(sine_value);
                
                // Ensure within 16-bit range
                if (input_value > 65535) input_value = 65535;
                if (input_value < 0) input_value = 0;
                
                adcData = input_value;
                @(posedge clkADC);
                
                // Wait for and display output when available
                if (cicOut.valid) begin
                    $display("clkSlow | %8t | 0x%04h      | %5d       | 0x%08h     | %10d     | %1b",
                            $time, adcData, adcData, cicOut.data, cicOut.data, cicOut.valid);
                end
            end
        end
    end

endmodule