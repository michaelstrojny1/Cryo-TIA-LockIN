module polyphase #(
    parameter int M             = 16
    parameter int OVERSAMPLE    = 4
    parameter int ADC_WIDTH     = 16
    parameter int ACCUM_WIDTH   = 32
)(
    input   logic                       clkADC,     // ADC Sample Clock (Fast)
    input   logic                       clkSlow,    // Processing clock (freqADC/M)
    input   logic                       rstN,       // Active-low reset

    input   logic       [ADC_WIDTH-1:0] adcData,    // Serial from ADC
    input   phaseAngleT                 refPhase,   // Quadrature phase indicator

    output  accumT                      magnitude,  // Output signal
    output  accumT                      phaseOut,   // Phase angle
    output  accumT                      IOut,       // In-phase component
    output  accumT                      QOut,       // Quadrature component
    output  logic                       dataValid,  // Pulse when outputs are valid
    output  logic                       bufferFull  // Parallel buffer is full
);

endmodule