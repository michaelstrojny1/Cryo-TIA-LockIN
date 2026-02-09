import lockIn_pkg::*;

module polyphase #(
    parameter int R             = 4,                // Decimation factor
    parameter int N             = 4,                // Number of CIC stages (order)
    parameter int M             = 1,                // Differential delay (usually 1)
    parameter int ADC_WIDTH     = 16,
    parameter int ACCUM_WIDTH   = 32                // ADC_WIDTH + $clog2(R^N)
) (
    input  logic                        clkADC,         // ADC sample clock (fast)
    input  logic                        clkSlow,        // Processing clock (f_adc/R)
    input  logic                        rstN,
    
    input  logic        [ADC_WIDTH-1:0] adcData,
    
    output cicOutputT                   cicOut,
    output logic                        cicReady
);

    // POLYPHASE CIC DECOMPOSITION

    // R parallel integrators
    accumT polyIntegrators[0:R-1][0:N-1];
    accumT polyCombs[0:R-1][0:N-1];

    // Write pointer for distribution
    logic [$clog2(R)-1:0] inputPtr;
    
    // Clock domain crossing synchronization
    accumT syncIntegrators[0:R-1][0:N-1];

    // POLYPHASE INTEGRATORS (Sync to clkADC)
    always_ff @(posedge clkADC or negedge rstN) begin
        if (!rstN) begin
            for (int b = 0; b < R; b++) begin
                for (int s = 0; s < N; s++) begin
                    polyIntegrators[b][s] <= '0;
                end
            end
            inputPtr <= '0;
        end else begin
            // Update appropriate polyphase branch
            for (int s = 0; s < N; s++) begin
                if (s == 0) begin
                    // First integrator stage: add input
                    polyIntegrators[inputPtr][0] <= polyIntegrators[inputPtr][0] + 
                                                   accumT'(signed'(adcData));
                end else begin
                    // Subsequent stages: cascade
                    polyIntegrators[inputPtr][s] <= polyIntegrators[inputPtr][s] + 
                                                   polyIntegrators[inputPtr][s-1];
                end
            end

            // Move to next phase
            inputPtr <= (inputPtr == R-1) ? '0 : inputPtr + 1;
        end
    end

    // Synchronize integrator outputs to clkSlow domain
    always_ff @(posedge clkSlow or negedge rstN) begin
        if (!rstN) begin
            for (int b = 0; b < R; b++) begin
                for (int s = 0; s < N; s++) begin
                    syncIntegrators[b][s] <= '0;
                end
            end
        end else begin
            for (int b = 0; b < R; b++) begin
                for (int s = 0; s < N; s++) begin
                    syncIntegrators[b][s] <= polyIntegrators[b][s];
                end
            end
        end
    end

    // CIC COMB SECTION (Sync to clkSlow)
    logic combProcessing;
    logic [$clog2(R)-1:0] combPtr;
    
    // R-cycle delay memory for each comb stage
    accumT combDelayMem[0:R-1][0:N-1][0:R-1];  // [branch][stage][delay_slot]
    logic [$clog2(R)-1:0] writePtr[0:R-1][0:N-1];
    logic [$clog2(R)-1:0] readPtr[0:R-1][0:N-1];
    logic initialized[0:R-1][0:N-1];

    always_ff @(posedge clkSlow or negedge rstN) begin
        if (!rstN) begin
            // Reset all comb states
            for (int b = 0; b < R; b++) begin
                for (int s = 0; s < N; s++) begin
                    polyCombs[b][s] <= '0;
                    writePtr[b][s] <= '0;
                    readPtr[b][s] <= '0;
                    initialized[b][s] <= 1'b0;
                    for (int d = 0; d < R; d++) begin
                        combDelayMem[b][s][d] <= '0;
                    end
                end
            end
            combProcessing <= 1'b0;
            combPtr <= '0;
            cicOut.valid <= 1'b0;
            cicReady <= 1'b0;
            
        end else begin
            cicOut.valid <= 1'b0;
            cicReady <= 1'b0;
            
            // Process one polyphase branch per clkSlow cycle
            if (combProcessing) begin
                for (int s = 0; s < N; s++) begin
                    // Get current input for this comb stage
                    accumT currentInput;
                    if (s == 0) begin
                        currentInput = syncIntegrators[combPtr][N-1];
                    end else begin
                        currentInput = polyCombs[combPtr][s-1];
                    end
                    
                    // Read delayed value from R cycles ago
                    accumT delayedInput = combDelayMem[combPtr][s][readPtr[combPtr][s]];
                    
                    // Compute comb output
                    polyCombs[combPtr][s] <= currentInput - delayedInput;
                    
                    // Store current value in delay line
                    combDelayMem[combPtr][s][writePtr[combPtr][s]] <= currentInput;
                    
                    // Update pointers (circular buffer)
                    writePtr[combPtr][s] <= (writePtr[combPtr][s] == R-1) ? '0 : 
                                           writePtr[combPtr][s] + 1;
                    
                    // Read pointer trails write pointer by R positions
                    readPtr[combPtr][s] <= (readPtr[combPtr][s] == R-1) ? '0 : 
                                          readPtr[combPtr][s] + 1;
                    
                    // Mark as initialized after R cycles
                    if (!initialized[combPtr][s] && writePtr[combPtr][s] == R-1) begin
                        initialized[combPtr][s] <= 1'b1;
                    end
                end
                
                // Output the result for this phase
                cicOut.data <= polyCombs[combPtr][N-1];
                cicOut.phase <= phaseAngleT'(combPtr % 4);
                cicOut.valid <= 1'b1;
                
                // Move to next phase
                if (combPtr == R-1) begin
                    combPtr <= '0;
                    combProcessing <= 1'b0;
                    cicReady <= 1'b1;
                end else begin
                    combPtr <= combPtr + 1;
                end
            end
        end
    end

    // Start comb processing periodically
    logic [$clog2(R):0] sampleCounter;
    
    always_ff @(posedge clkSlow or negedge rstN) begin
        if (!rstN) begin
            sampleCounter <= '0;
        end else begin
            // Count R samples then trigger comb processing
            if (sampleCounter == R-1) begin
                sampleCounter <= '0;
                combProcessing <= 1'b1;
            end else begin
                sampleCounter <= sampleCounter + 1;
                combProcessing <= 1'b0;
            end
        end
    end

endmodule