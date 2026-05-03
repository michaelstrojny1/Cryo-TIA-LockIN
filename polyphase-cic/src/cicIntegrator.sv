module cicIntegrator #(
    parameter int N,
    parameter int Width
) (
    input  logic                 clk,
    input  logic                 rst,

    input  logic                 validIn,
    input  logic [Width-1:0]     dataIn,

    output logic [Width-1:0]     dataOut
);

    // ------------------------------------------------------------
    // Internal Signals
    // ------------------------------------------------------------

    logic [Width-1:0] stage [N];

    integer i;

    // ------------------------------------------------------------
    // Integrator Chain
    // ------------------------------------------------------------

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < N; i++) begin
                stage[i] <= '0;
            end
        end
        else if (validIn) begin
            // First stage
            stage[0] <= stage[0] + dataIn;

            // Remaining stages
            for (i = 1; i < N; i++) begin
                stage[i] <= stage[i] + stage[i-1];
            end
        end
    end

    assign dataOut = stage[N-1];

endmodule