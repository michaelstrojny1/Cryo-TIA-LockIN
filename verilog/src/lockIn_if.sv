import lockIn_pkg::*;

interface lockIn_if #(
    parameter int R         = 16;   // Decimation Factor
    parameter int N         = 4;    // CIC stages
    parameter int ADC_WIDTH = 16
);

    logic clkADC;
    logic clkSlow;
    logic rstN;

    logic       [ADC_WIDTH-1:0] adcData;

    // Outputs
    accumT magnitude;
    accumT phase;
    accumT IOut;
    accumT QOut;

    logic dataValid;
    logic cicReady;

    modport dut (
        input  clkADC, clkSlow, rstN, adcData,
        output magnitude, phase, IOut, QOut, dataValid, cicReady
    );
endinterface