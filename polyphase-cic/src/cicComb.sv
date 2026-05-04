module cicComb #(
    parameter int N,
    parameter int M,
    parameter int Width
) (
    input  logic                 clk,
    input  logic                 rst,

    input  logic                 ce,
    input  logic [Width-1:0]     dataIn,

    output logic [Width-1:0]     dataOut
);

    // ------------------------------------------------------------
    // Internal Signals
    // ------------------------------------------------------------

    logic [Width-1:0] stage     [N];
    logic [Width-1:0] prevValue [N];

    integer i;

    // ------------------------------------------------------------
    // Comb Chain
    // ------------------------------------------------------------

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < N; i++) begin
                stage[i]     <= '0;
                prevValue[i] <= '0;
            end
        end
        else if (ce) begin

            // ---- Stage 0 ----
            stage[0]     <= dataIn - prevValue[0];
            prevValue[0] <= dataIn;

            // ---- Remaining stages ----
            for (i = 1; i < N; i++) begin
                stage[i]     <= stage[i-1] - prevValue[i];
                prevValue[i] <= stage[i-1];
            end

        end
    end

    assign dataOut = stage[N-1];

endmodule