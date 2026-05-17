module cicIntegrator #(
    parameter int InputWidth  = 16,
    parameter int AccumWidth  = 24,
    parameter int N           = 4
) (
    input  logic                    clk,
    input  logic                    rst,
    input  logic                    validIn,
    input  logic [InputWidth-1:0]   dataIn,
    output logic [AccumWidth-1:0]   dataOut
);

    // ------------------------------------------------------------
    // Internal Signals
    // ------------------------------------------------------------

    logic [AccumWidth-1:0] stage [N];
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
            // First stage: add input (properly extended to AccumWidth)
            stage[0] <= stage[0] + {{(AccumWidth-InputWidth){dataIn[InputWidth-1]}}, dataIn};
            
            // Remaining stages
            for (i = 1; i < N; i++) begin
                stage[i] <= stage[i] + stage[i-1];
            end
        end
    end

    assign dataOut = stage[N-1];

endmodule