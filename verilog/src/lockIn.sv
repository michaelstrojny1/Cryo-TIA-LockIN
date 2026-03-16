import lockIn_pkg::*;

module lockIn (

    input  logic          clk,
    input  logic          reset,

    input  sampleT        dataIn,
    input  logic          validIn,

    output lockInOutputT  dataOut

);

    // ------------------------------------------------------------
    // Inter-Module Signals
    // ------------------------------------------------------------

    mixerOutputT mixerOut;

    accumT I_int;
    accumT Q_int;

    logic  I_validOut;
    logic  Q_validOut;

    longAccumT  magnitude_val;
    phaseAngleT phase_val;

    logic valid_int;

    // ------------------------------------------------------------
    // Mixer Stage
    // ------------------------------------------------------------

    mixer u_mixer (
        .clk    (clk),
        .reset  (reset),

        .dataIn (dataIn),
        .dataOut(mixerOut)
    );

    // ------------------------------------------------------------
    // Integration Stage
    // ------------------------------------------------------------

    integrate integrate_cos (

        .clk     (clk),
        .reset   (reset),

        .validIn (mixerOut.valid),
        .dataIn  (mixerOut.I),

        .dataOut (I_int),
        .validOut(I_validOut)

    );

    integrate integrate_sin (

        .clk     (clk),
        .reset   (reset),

        .validIn (mixerOut.valid),
        .dataIn  (mixerOut.Q),

        .dataOut (Q_int),
        .validOut(Q_validOut)

    );

    // ------------------------------------------------------------
    // Magnitude Computation
    // ------------------------------------------------------------

    magnitude u_mag (

        .I          (I_int),
        .Q          (Q_int),
        .magOut     (magnitude_val)

    );

    // ------------------------------------------------------------
    // Phase Computation
    // ------------------------------------------------------------

    phase u_phase (

        .I        (I_int),
        .Q        (Q_int),
        .phaseOut (phase_val)

    );

    // ------------------------------------------------------------
    // Output Valid
    // ------------------------------------------------------------

    assign valid_int = I_validOut & Q_validOut;

    // ------------------------------------------------------------
    // Output Assignment
    // ------------------------------------------------------------

    assign dataOut.magnitude = magnitude_val;
    assign dataOut.phase     = phase_val;

    assign dataOut.I         = I_int;
    assign dataOut.Q         = Q_int;

    assign dataOut.valid     = valid_int;

endmodule