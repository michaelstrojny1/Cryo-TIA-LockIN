module polyphase #(
    parameter int R             = 64,                // Decimation factor
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
    
    import lockIn_pkg::*;

    // POLYPHASE CIC DECOMPOSITION

        // R parallel integrators
        accumT polyIntegrators[0:R-1][0:N-1];
        accumT polyCombs[0:R-1][0:N-1];

        // Write pointer for distribution
        logic [$clog2(R)-1:0] inputPhase;
        sampleT currentInput;

        // CIC Output Buffer
        accumT cicOutputBuffer[0:R-1];
        logic cicOutputValid[0:R-1];
        logic [$clog2(R)-1:0] cicReadPtr;
    
    // POLYPHASE INTEGRATORS

        always_ff @(posedge clkADC or negedge rstN) begin
            if (!rstN) begin
                // Reset all the integrators
                for (int b = 0; b < R; b++) begin
                    for (int s = 0; s < N; s++) begin
                        polyIntegrators[b][s] <= '0;
                    end
                end
                inputPhase      <= '0;
                currentInput    <= '0;

            end else begin
                // Store the current input
                currentInput <= sampleT'(adcData);

                // Update appropriate polyphase branch
                for (int s = 0; s < N; s++) begin
                    if (s == 0) begin
                        // Add the input
                        polyIntegrators[inputPhase][0] <=
                            polyIntegrators[inputPhase][s] +
                            polyIntegrators[inputPhase][s-1];
                    end
                end

                // Move to the next phase
                if (inputPhase == R-1) begin
                    inputPhase <= '0;
                end else begin
                    inputPhase <= inputPhase + 1;
                end
            end
        end

    // CIC COMB (Sync to clkSlow)

    logic combProcessing;
    logic [$clog2(R)-1:-] combPhase;
    accumT combDelay[0:R-1][0:N-1];

    always_ff @(posedge clkSlow or negedge rstN) begin
        if (!rstN) begin
            // Reset comb states
            for (int b = 0; b < R; b++) begin
                for (int s = 0; s < N; s++) begin
                    polyCombs[b][s] <= '0;
                    combDelay[b][s] <= '0;
                    cicOutputBuffer[b] <= '0;
                end
                cicOutputValid <= 1'b0;
            end
            combProcessing <= 1'b0;
            combPhase <= '0;
            cicReadPtr <= '0;
            cicReady <= 1'b0;

        end else begin
            // Process one polyphase branch per clkSlow cycle
            if (combPhase == R-1) begin
                combProcessing <= 1'b1;
            end

            if (combProcessing) begin
                // Apply comb filter to this phase's integrator output
                for (int s = 0; s < N; s++) begin
                    if (s == 0) begin
                        // First comb stage
                        polyCombs[combPhase][0] <=
                            polyIntegrators[combPhase][N-1] -
                            combDelay[combPhase][0];

    end


endmodule