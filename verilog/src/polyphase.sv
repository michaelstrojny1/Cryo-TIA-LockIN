import lockIn_pkg::*;

module polyphase #(
    parameter int R             = 4,                // Decimation factor
    parameter int N             = 4,                 // Number of CIC stages (order)
    parameter int M             = 1,                 // Differential delay (usually 1)
    parameter int ADC_WIDTH     = 16,
    parameter int ACCUM_WIDTH   = 32                 // ADC_WIDTH + $clog2(R^N)
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
    
    // POLYPHASE INTEGRATORS (Sync to clkADC)

        always_ff @(posedge clkADC or negedge rstN) begin
            if (!rstN) begin
                // Reset all the integrators
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
                        // Add the input
                        polyIntegrators[inputPtr][0] <=
                            polyIntegrators[inputPtr][0] +
                            sampleT'(adcData);
                    end else begin
                        // Cascade subsequent stages
                        polyIntegrators[inputPtr][s] <=
                            polyIntegrators[inputPtr][s] +
                            polyIntegrators[inputPtr][s-1];
                    end
                end

                // Move to the next phase
                if (inputPtr == R-1) begin
                    inputPtr <= '0;
                end else begin
                    inputPtr <= inputPtr + 1;
                end
            end
        end

    // CIC COMB (Sync to clkSlow)

    logic combProcessing;
    logic [$clog2(R)-1:0] combPtr;
    accumT combDelay[0:R-1][0:N-1];

    always_ff @(posedge clkSlow or negedge rstN) begin
        if (!rstN) begin
            // Reset comb states
            for (int b = 0; b < R; b++) begin
                for (int s = 0; s < N; s++) begin
                    polyCombs[b][s] <= '0;
                    combDelay[b][s] <= '0;
                end
            end
            combProcessing <= 1'b0;
            combPtr <= '0;
            cicOut.valid <= 1'b0;
            cicReady <= 1'b0;

        end else begin
            // Process one polyphase branch per clkSlow cycle
            if(combProcessing) begin
                for (int s = 0; s < N; s++) begin
                    if (s == 0) begin
                        // First comb stage
                        polyCombs[combPtr][0] <= 
                            polyIntegrators[combPtr][N-1] -                     // Final output from integrator chain
                            combDelay[combPtr][0];                              // Value stored from R cycles ago
                        combDelay[combPtr][0] <= polyIntegrators[combPtr][N-1]; // Save value for next cycle
                    
                    end else begin
                        // Subsequent comb stages
                        polyCombs[combPtr][s] <= 
                            polyIntegrators[combPtr][s-1] -                     // Output from previous comb stage
                            combDelay[combPtr][s];                              // Value stored from R cycles ago
                        combDelay[combPtr][s] <= polyIntegrators[combPtr][s-1]; // Save value for next cycle
                    end
                end

                // Output this phase's result
                cicOut.data <= polyCombs[combPtr][N-1];
                cicOut.phase <= phaseAngleT'(combPtr % 4);  // For quadrature
                cicOut.valid <= 1'b1;

                // Move to the next phase
                if (combPtr == R - 1) begin
                    combPtr <= '0;
                    combProcessing <= 1'b0;
                    cicReady <= 1'b1;                       // Ie. All outputs are done

                end else begin
                    combPtr <= combPtr + 1;
                end

            end else begin
                cicOut.valid <= 1'b0;
                cicReady <= 1'b0;
            end
        end
    end

    // Start comb processing once integrators have enough data
    always_ff @(posedge clkSlow) begin
        if (!combProcessing && inputPtr == 0) begin
            combProcessing <= 1'b1;
        end
    end

endmodule