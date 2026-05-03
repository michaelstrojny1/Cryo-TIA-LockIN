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

    logic [Width-1:0] stage [N];
    logic [Width-1:0] delayLine [N][M];

    integer i, j;

    // ------------------------------------------------------------
    // Comb Chain
    // ------------------------------------------------------------

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < N; i++) begin
                stage[i] <= '0;
                for (j = 0; j < M; j++) begin
                    delayLine[i][j] <= '0;
                end
            end
        end
        else if (ce) begin

            // ---- Stage 0 ----
            stage[0] <= dataIn - delayLine[0][M-1];

            // Shift delay line
            delayLine[0][0] <= dataIn;
            for (j = 1; j < M; j++) begin
                delayLine[0][j] <= delayLine[0][j-1];
            end

            // ---- Remaining stages ----
            for (i = 1; i < N; i++) begin

                stage[i] <= stage[i-1] - delayLine[i][M-1];

                delayLine[i][0] <= stage[i-1];
                for (j = 1; j < M; j++) begin
                    delayLine[i][j] <= delayLine[i][j-1];
                end

            end
        end
    end

    assign dataOut = stage[N-1];

endmodule