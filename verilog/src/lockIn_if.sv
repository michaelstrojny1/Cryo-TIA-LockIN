import lockIn_pkg::*;

interface lockIn_if #(
    parameter int M         = 16;
    parameter int ADC_WIDTH = 16
);

    logic clkADC;
    logic clkSlow;
    logic rstN;

    logic       [ADC_WIDTH-1:0] adcData;
    phaseAngleT                 refPhase;

    accumT magnitude;
    accumT phase;
    accumT IOut;
    accumT QOut;

    logic dataValid;
    logic bufferFull;

    modport dut (
        input  clkADC, clkSlow, rstN, adcData, refPhase,
        output magnitude, phase, IOut, QOut, dataValid, bufferFull
    );
endinterface