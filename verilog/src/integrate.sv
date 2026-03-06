module integrate #(
    parameter WIDTH     = 32, 
    parameter SAMPLES   = 1024
)(
    input   logic               clk,
    input   logic               reset,
    input   logic [WIDTH-1:0]   dataIn,
    output  logic [WIDTH-1:0]   dataOut
);

    // Set up accumulation registers
    logic [WIDTH + $clog2(SAMPLES)-1:0] accumulate;
    logic [$clog2(SAMPLES)-1:0]         count;

    // Accumulate input mixed signal
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            accumulate  <= 0;
            count       <= 0;
        end else begin
            accumulate  <= accumulate + dataIn;
            count       <= count + 1;
        
            // Output average when count == samples
            if (count == SAMPLES - 1) begin
                
                // Divide by number of samples to compute average
                dataOut     <= accumulate >>> $clog2(SAMPLES);
                accumulate  <= 0;
                count       <= 0;
            end
        end
    end

endmodule