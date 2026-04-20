import lockIn_pkg::*;

module cic #(
    parameter int R             = 4,                // Decimation factor
    parameter int N             = 4,                // Number of CIC stages (order)
    parameter int M             = 1,                // Differential delay (usually 1)
    parameter int ADC_WIDTH     = 16,
    parameter int ACCUM_WIDTH   = ADC_WIDTH + N * $clog2(R*M)  // Proper width to prevent overflow
) (
    input  logic                        clkADC,         // ADC sample clock (fast)
    input  logic                        clkSlow,        // Processing clock (f_adc/R)
    input  logic                        rstN,
    
    input  logic        [ADC_WIDTH-1:0] adcData,        // Input sample at clkADC rate
    
    output cicOutputT                   cicOut,         // Decimated output at clkSlow rate
    output logic                        cicReady        // Output valid pulse
);

    // ==================== INTEGRATOR SECTION ====================
    // Runs at high-speed clkADC
    
    // Integrator registers (N stages)
    accumT integrators[0:N-1];
    
    always_ff @(posedge clkADC or negedge rstN) begin
        if (!rstN) begin
            for (int i = 0; i < N; i++) begin
                integrators[i] <= '0;
            end
        end else begin
            // Stage 0: add input
            integrators[0] <= integrators[0] + accumT'(signed'(adcData));
            
            // Subsequent stages: cascade
            for (int i = 1; i < N; i++) begin
                integrators[i] <= integrators[i] + integrators[i-1];
            end
        end
    end
    
    // ==================== CLOCK DOMAIN CROSSING ====================
    // Transfer integrator output from clkADC to clkSlow domain
    
    accumT syncIntegratorOut;
    logic  syncValid;
    logic  [$clog2(R)-1:0] sampleCounter;
    
    // Sample counter for decimation
    always_ff @(posedge clkADC or negedge rstN) begin
        if (!rstN) begin
            sampleCounter <= '0;
            syncValid <= 1'b0;
            syncIntegratorOut <= '0;
        end else begin
            syncValid <= 1'b0;
            
            // Count R samples, then take one for processing
            if (sampleCounter == R-1) begin
                sampleCounter <= '0;
                syncIntegratorOut <= integrators[N-1];  // Take output of last integrator
                syncValid <= 1'b1;                     // Valid every R cycles
            end else begin
                sampleCounter <= sampleCounter + 1;
            end
        end
    end
    
    // ==================== COMB SECTION ====================
    // Runs at clkSlow (decimated rate)
    
    // Comb delay lines (N stages, each with M*R delay)
    localparam int DELAY = R * M;  // Total comb delay
    accumT combDelay[0:N-1][0:DELAY-1];  // Delay line for each stage
    logic [$clog2(DELAY)-1:0] wrPtr[0:N-1];  // Write pointers
    
    // Current comb outputs
    accumT combOut[0:N-1];
    
    // Sync valid pulse to clkSlow domain (2-stage synchronizer)
    logic  syncValid_slow, syncValid_slow_prev;
    
    always_ff @(posedge clkSlow or negedge rstN) begin
        if (!rstN) begin
            syncValid_slow <= 1'b0;
            syncValid_slow_prev <= 1'b0;
        end else begin
            syncValid_slow_prev <= syncValid;        // First stage
            syncValid_slow <= syncValid_slow_prev;   // Second stage
        end
    end
    
    always_ff @(posedge clkSlow or negedge rstN) begin
        logic [$clog2(DELAY)-1:0] rdPtr;
        accumT currentInput;
        accumT delayedInput;
        int s; 
        
        if (!rstN) begin
            // Reset all comb states
            for (s = 0; s < N; s++) begin
                combOut[s] <= '0;
                wrPtr[s] <= '0;
                for (int d = 0; d < DELAY; d++) begin
                    combDelay[s][d] <= '0;
                end
            end
            cicOut.valid <= 1'b0;
            cicReady <= 1'b0;
            
        end else begin
            cicOut.valid <= 1'b0;
            cicReady <= 1'b0;
            
            // Process when a new decimated sample is available
            if (syncValid_slow) begin
                // Process all comb stages
                for (s = 0; s < N; s++) begin
                    // Determine input for this stage
                    if (s == 0) begin
                        currentInput = syncIntegratorOut;  // From integrator section
                    end else begin
                        currentInput = combOut[s-1];       // From previous comb stage
                    end
                    
                    // Calculate read pointer (DELAY samples behind write pointer)
                    // This gives us value from DELAY cycles ago
                    if (wrPtr[s] >= DELAY-1) begin
                        rdPtr = '0;  // Wrap around
                    end else begin
                        rdPtr = wrPtr[s] + 1;
                    end
                    
                    // Get delayed value
                    delayedInput = combDelay[s][wrPtr[s]];
                    
                    // Compute comb output
                    combOut[s] <= currentInput - delayedInput;
                    
                    // Store current value in delay line
                    combDelay[s][wrPtr[s]] <= currentInput;
                    
                    // Update write pointer (circular buffer)
                    if (wrPtr[s] == DELAY-1) begin
                        wrPtr[s] <= '0;
                    end else begin
                        wrPtr[s] <= wrPtr[s] + 1;
                    end
                end
                
                // Output the final comb stage
                cicOut.data <= combOut[N-1];
                cicOut.phase <= phaseAngleT'(sampleCounter % 4); 
                cicOut.valid <= 1'b1;
                cicReady <= 1'b1;  // Pulse for one cycle
            end
        end
    end

endmodule