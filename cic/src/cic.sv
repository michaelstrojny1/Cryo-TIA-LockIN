module cic #(

    parameter int R           = 4,
    parameter int N           = 4,
    parameter int M           = 1,

    parameter int ADCWidth    = 16,
    parameter int AccumWidth  = ADCWidth + N * $clog2(R*M)

) (

    input  logic                    clk,
    input  logic                    rst,

    input  logic [ADCWidth-1:0]     dataIn,
    input  logic                    validIn,

    output logic [AccumWidth-1:0]   dataOut,
    output logic                    validOut

);

    // ------------------------------------------------------------
    // Inter-Module Signals
    // ------------------------------------------------------------

    logic [AccumWidth-1:0] integratorOut;
    logic [AccumWidth-1:0] combOut;
    logic                  decimationStrobe;

    // ------------------------------------------------------------
    // Integrator Chain
    // ------------------------------------------------------------

    // Pass AccumWidth to integrator for output, ADCWidth for input

    cicIntegrator #(

        .InputWidth     (ADCWidth),
        .AccumWidth     (AccumWidth),
        .N              (N)

    ) uIntegrator (

        .clk            (clk),
        .rst            (rst),

        .validIn        (validIn),
        .dataIn         (dataIn),

        .dataOut        (integratorOut)

    );

    // ------------------------------------------------------------
    // Decimator (R counter -> strobe)
    // ------------------------------------------------------------

    cicDecimator #(

        .R(R)

    ) uDecimator (
        
        .clk        (clk),
        .rst        (rst),

        .validIn    (validIn),

        .ce         (decimationStrobe)

    );

    // ------------------------------------------------------------
    // Comb Chain
    // ------------------------------------------------------------

    cicComb #(

        .N          (N),
        .M          (M),
        .Width      (AccumWidth)

    ) uComb (

        .clk        (clk),
        .rst        (rst),

        .ce         (decimationStrobe),
        .dataIn     (integratorOut),

        .dataOut    (combOut)

    );

    // ------------------------------------------------------------
    // Output
    // ------------------------------------------------------------

    assign dataOut  = combOut;
    assign validOut = decimationStrobe;

endmodule