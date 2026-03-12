module integrate #(
    parameter int WIDTH   = 16,
    parameter int SAMPLES = 1024
)(
    input  logic                     clk,
    input  logic                     reset,
    input  logic signed [WIDTH-1:0]  dataIn,

    output logic signed [WIDTH-1:0]  dataOut,
    output logic                     valid
);

    // ------------------------------------------------------------
    // Derived parameters
    // ------------------------------------------------------------

    localparam int EXTRA_BITS = $clog2(SAMPLES);
    localparam int ACC_WIDTH  = WIDTH + EXTRA_BITS;

    // ------------------------------------------------------------
    // Internal state
    // ------------------------------------------------------------

    logic signed [ACC_WIDTH-1:0] accumulate;
    logic signed [ACC_WIDTH-1:0] next_accumulate;
    logic [EXTRA_BITS-1:0]       count;

    // ------------------------------------------------------------
    // Boxcar integration / averaging
    //
    // Computes:
    //      y = (1/N) * Σ x[n]
    //
    // Output is produced once every SAMPLES clock cycles.
    // ------------------------------------------------------------

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            accumulate <= 0;
            count      <= 0;
            dataOut    <= 0;
            valid      <= 0;
        end
        else begin

            // Compute next accumulation
            next_accumulate = accumulate + dataIn;

            if (count == SAMPLES-1) begin

                // Average result
                dataOut <= next_accumulate >>> EXTRA_BITS;
                valid   <= 1;

                // Reset window
                accumulate <= 0;
                count      <= 0;

            end
            else begin

                accumulate <= next_accumulate;
                count      <= count + 1;
                valid      <= 0;

            end
        end
    end

endmodule