import lockIn_pkg::*;

module cicPolyphase #(
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

    logic [$clog2(R)-1:0] phaseIndex;

    logic [AccumWidth-1:0] phaseData   [R];
    logic [AccumWidth-1:0] alignedData [R];

    logic [AccumWidth-1:0] sumOut;

    logic                  decimationStrobe;
    logic                  validInternal;

    // ------------------------------------------------------------
    // Phase Controller
    // ------------------------------------------------------------

    cicPhaseCtrl #(
        .R(R)
    ) uPhaseCtrl (
        .clk   (clk),
        .rst   (rst),
        .validIn(validIn),

        .phaseIndex(phaseIndex),
        .ce(decimationStrobe)
    );

    // ------------------------------------------------------------
    // Delay Line
    // ------------------------------------------------------------

    cicDelayLine #(
        .Depth(R*M),
        .Width(ADCWidth)
    ) uDelayLine (
        .clk    (clk),
        .rst    (rst),

        .dataIn (dataIn),
        .validIn(validIn),

        .dataOutArray(phaseData)
    );

    // ------------------------------------------------------------
    // Polyphase Filter Bank
    // ------------------------------------------------------------

    genvar i;
    generate
        for (i = 0; i < R; i++) begin : PhaseFilters

            cicPhaseFilter #(
                .N(N),
                .M(M),
                .Width(AccumWidth)
            ) uPhaseFilter (
                .clk    (clk),
                .rst    (rst),

                .phaseIndex(phaseIndex),
                .index(i),

                .dataIn (phaseData[i]),
                .dataOut(alignedData[i])
            );

        end
    endgenerate

    // ------------------------------------------------------------
    // Adder Tree
    // ------------------------------------------------------------

    cicAdderTree #(
        .R(R),
        .Width(AccumWidth)
    ) uAdderTree (
        .dataIn (alignedData),
        .dataOut(sumOut)
    );

    // ------------------------------------------------------------
    // Output
    // ------------------------------------------------------------

    assign validInternal = decimationStrobe;

    assign dataOut.data  = sumOut;
    assign dataOut.valid = validInternal;
    assign validOut      = validInternal;

endmodule