import lockIn_pkg::*;

module polyphase #(
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

    accumT polyintegrators[0:R-1][0:N-1];
    logic [$clog2(R)-1:0] wrtPtr;
    
    // Store old values for proper cascading - MOVED OUTSIDE always block
    accumT old_vals[0:N-1];

    always_ff @(posedge clkADC or negedge rstN) begin
        if (!rstN) begin
            // Reset ALL integrators for ALL branches and stages
            for (int branch = 0; branch < R; branch++) begin
                for (int stage = 0; stage < N; stage++) begin
                    polyintegrators[branch][stage] <= '0;
                end
            end
            wrtPtr <= '0;
            
        end else begin
            // Store OLD values of current branch's integrators
            for (int stage = 0; stage < N; stage++) begin
                old_vals[stage] = polyintegrators[wrtPtr][stage];
            end
            
            // Stage 0: integrate input
            polyintegrators[wrtPtr][0] <= old_vals[0] + accumT'(signed'(adcData));
            
            // Subsequent stages: integrate OLD value of previous stage
            for (int stage = 1; stage < N; stage++) begin
                polyintegrators[wrtPtr][stage] <= old_vals[stage] + old_vals[stage-1];
            end
            
            // Move to next branch (circular buffer)
            if (wrtPtr == R-1) begin
                wrtPtr <= '0;
            end else begin
                wrtPtr <= wrtPtr + 1;
            end
        end
    end

    // ==================== CLOCK DOMAIN CROSSING ====================
    // Transfer integrator outputs from clkADC to clkSlow domain
    
    accumT sync_integrators[0:R-1][0:N-1];
    
    always_ff @(posedge clkSlow or negedge rstN) begin
        if (!rstN) begin
            for (int branch = 0; branch < R; branch++) begin
                for (int stage = 0; stage < N; stage++) begin
                    sync_integrators[branch][stage] <= '0;
                end
            end
        end else begin
            // Simple synchronization (all values transferred)
            for (int branch = 0; branch < R; branch++) begin
                for (int stage = 0; stage < N; stage++) begin
                    sync_integrators[branch][stage] <= polyintegrators[branch][stage];
                end
            end
        end
    end

    // ==================== COMB SECTION ====================
    // Runs at clkSlow (decimated rate)
    
    accumT polycombs[0:R-1][0:N-1];
    
    // R-cycle delay memory for each branch and stage
    localparam int DELAY = R * M;  // Total comb delay
    accumT comb_delay[0:R-1][0:N-1][0:DELAY-1];  // [branch][stage][delay_slot]
    
    // Write pointers for each branch and stage
    logic [$clog2(DELAY)-1:0] wr_ptr[0:R-1][0:N-1];
    
    // Comb processing control
    logic comb_processing;
    logic [$clog2(R)-1:0] comb_ptr;  // Which branch being processed
    
    always_ff @(posedge clkSlow or negedge rstN) begin
        // DECLARE ALL LOCAL VARIABLES AT THE BEGINNING
        accumT current_input;
        accumT delayed_input;
        logic [$clog2(DELAY)-1:0] rd_ptr;
        int stage;  // Loop variable
        
        if (!rstN) begin
            // Reset all comb states
            for (int branch = 0; branch < R; branch++) begin
                for (int stage = 0; stage < N; stage++) begin
                    polycombs[branch][stage] <= '0;
                    wr_ptr[branch][stage] <= '0;
                    for (int d = 0; d < DELAY; d++) begin
                        comb_delay[branch][stage][d] <= '0;
                    end
                end
            end
            comb_processing <= 1'b0;
            comb_ptr <= '0;
            cicOut.valid <= 1'b0;
            cicReady <= 1'b0;
            
        end else begin
            // Default outputs
            cicOut.data <= cicOut.data // Maintain data while not processing
            cicOut.valid <= 1'b0;
            cicOut.phase <= cicOut.phase
            cicReady <= 1'b0;
            
            // Process one polyphase branch per clkSlow cycle
            if (comb_processing) begin
                // Process all N comb stages for current branch
                for (stage = 0; stage < N; stage++) begin
                    // Get current input for this stage
                    if (stage == 0) begin
                        // First comb stage: takes output of last integrator
                        current_input = sync_integrators[comb_ptr][N-1];
                    end else begin
                        // Subsequent stages: take output of previous comb stage
                        current_input = polycombs[comb_ptr][stage-1];
                    end
                    
                    // Calculate read pointer (R cycles behind write pointer)
                    if (wr_ptr[comb_ptr][stage] == 0) begin
                        rd_ptr = DELAY - 1;  // Wrap around
                    end else begin
                        rd_ptr = wr_ptr[comb_ptr][stage] - 1;
                    end
                    
                    // Read delayed value (from R cycles ago)
                    delayed_input = comb_delay[comb_ptr][stage][rd_ptr];
                    
                    // Compute comb output
                    polycombs[comb_ptr][stage] <= current_input - delayed_input;
                    
                    // Store current value in delay line
                    comb_delay[comb_ptr][stage][wr_ptr[comb_ptr][stage]] <= current_input;
                    
                    // Update write pointer (circular buffer)
                    if (wr_ptr[comb_ptr][stage] == DELAY-1) begin
                        wr_ptr[comb_ptr][stage] <= '0;
                    end else begin
                        wr_ptr[comb_ptr][stage] <= wr_ptr[comb_ptr][stage] + 1;
                    end
                end
                
                // Output the result for this phase
                cicOut.data <= polycombs[comb_ptr][N-1];
                cicOut.phase <= phaseAngleT'(comb_ptr % 4);  // Adjust for your needs
                cicOut.valid <= 1'b1;
                
                // Move to next branch
                if (comb_ptr == R-1) begin
                    comb_ptr <= '0;
                    comb_processing <= 1'b0;
                    cicReady <= 1'b1;  // All R branches processed
                end else begin
                    comb_ptr <= comb_ptr + 1;
                end
            end
        end
    end

    // ==================== COMB PROCESSING SCHEDULER ====================
    // Start comb processing after every R samples
    
    logic [$clog2(R):0] sample_counter;
    
    always_ff @(posedge clkADC or negedge rstN) begin
        if (!rstN) begin
            sample_counter <= '0;
        end else begin
            // Count R input samples
            if (sample_counter == R-1) begin
                sample_counter <= '0;
            end else begin
                sample_counter <= sample_counter + 1;
            end
        end
    end
    
    // Synchronize sample counter to clkSlow domain
    logic sample_counter_sync;
    always_ff @(posedge clkSlow) begin
        sample_counter_sync <= (sample_counter == R-1);
    end
    
    // Start comb processing when all branches have new data
    always_ff @(posedge clkSlow) begin
        if (!comb_processing && sample_counter_sync && wrtPtr == 0) begin
            comb_processing <= 1'b1;
        end
    end

endmodule