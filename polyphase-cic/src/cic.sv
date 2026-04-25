import lockIn_pkg::*;

module cic #(
    parameter int R           = 4,
    parameter int N           = 4,
    parameter int M           = 1,
    parameter int ADCWidth    = 16,
    parameter int AccumWidth  = ADCWidth + N * $clog2(R*M)
) (
    input  logic                 clk,
    input  logic                 rst,

    input  logic [ADCWidth-1:0]  dataIn,
    input  logic                 validIn,

    output sampleT               dataOut,
    output logic                 validOut
);

    // ------------------------------------------------------------
    // Inter-Module Signals
    // ------------------------------------------------------------

    logic [AccumWidth-1:0] integratorOut;
    logic [AccumWidth-1:0] combOut;

    logic                  decimationStrobe;
    logic                  validInternal;

    // ------------------------------------------------------------
    // Integrator Chain
    // ------------------------------------------------------------

    cicIntegrator #(
        .N(N),
        .Width(AccumWidth)
    ) uIntegrator (
        .clk     (clk),
        .rst     (rst),

        .validIn (validIn),
        .dataIn  (dataIn),

        .dataOut (integratorOut)
    );

    // ------------------------------------------------------------
    // Decimator (R counter → strobe)
    // ------------------------------------------------------------

    cicDecimator #(
        .R(R)
    ) uDecimator (
        .clk (clk),
        .rst (rst),

        .validIn (validIn),
        .ce      (decimationStrobe)
    );

    // ------------------------------------------------------------
    // Comb Chain
    // ------------------------------------------------------------

    cicComb #(
        .N(N),
        .M(M),
        .Width(AccumWidth)
    ) uComb (
        .clk     (clk),
        .rst     (rst),

        .ce      (decimationStrobe),
        .dataIn  (integratorOut),

        .dataOut (combOut)
    );

    // ------------------------------------------------------------
    // Output
    // ------------------------------------------------------------

    assign validInternal   = decimationStrobe;

    assign dataOut.data    = combOut;
    assign dataOut.valid   = validInternal;
    assign validOut        = validInternal;

endmodule