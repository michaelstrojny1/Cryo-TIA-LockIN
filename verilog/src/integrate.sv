module integrate #(
    parameter int SAMPLES = 1024
)(
    input  logic  clk,
    input  logic  reset,
    input  logic  validIn,

    input  accumT dataIn,

    output accumT dataOut,
    output logic  validOut
);

    // ------------------------------------------------------------
    // Constants
    // ------------------------------------------------------------

    localparam int DATA_WIDTH = 32;
    localparam int EXTRA_BITS = $clog2(SAMPLES);
    localparam int ACC_WIDTH  = DATA_WIDTH + EXTRA_BITS;

    // ------------------------------------------------------------
    // Internal state
    // ------------------------------------------------------------

    logic signed [ACC_WIDTH-1:0] accumulate;
    logic signed [ACC_WIDTH-1:0] next_accumulate;
    logic [EXTRA_BITS-1:0]       count;

    // ------------------------------------------------------------
    // Boxcar Integrator
    //
    // y = (1/N) Σ x[n]
    // ------------------------------------------------------------

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            accumulate <= '0;
            count      <= '0;
            dataOut    <= '0;
            validOut   <= 0;
        end

        else if (validIn) begin

            next_accumulate = accumulate + dataIn;

            if (count == SAMPLES-1) begin

                // average
                dataOut  <= next_accumulate >>> EXTRA_BITS;
                validOut <= 1;

                accumulate <= '0;
                count      <= '0;

            end
            else begin

                accumulate <= next_accumulate;
                count      <= count + 1;
                validOut   <= 0;

            end
        end
    end

endmodule