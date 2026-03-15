import lockIn_pkg::*;

module lockIn #(

) (
    input   logic           clk,
    input   logic           reset,

    input   sampleT         dataIn,
    input   logic           validIn,

    output  lockInOutputT   dataOut
);

    // Inter-module signals
    mixerOutputT mixerOut;

    accumT I_int;
    accumT Q_int;

    accumT      magnitude_val;
    phaseAngleT phase_val;

    logic  valid_int;

    // Mixer
    mixer u1 (
        .clk    (clk),
        .reset  (reset),

        .dataIn (sampleIn),
        .dataOut(mixerOut)
    );

    // Integrate I
    integrate #(
        .WIDTH   ($bits(accumT)),
        .SAMPLES ()
    ) integrate_cos (
        .clk     (clk),
        .reset   (reset),
        .validIn (mixerOut.valid),
        .dataIn  (mixerOut.I),

        .validOut(valid_int),
        .dataOut (I_int)
    );

    // Integrate Q
    integrate #(
        .WIDTH   ($bits(accumT)),
        .SAMPLES ()
    ) integrate_sin (
        .clk     (clk),
        .reset   (reset),
        .validIn (mixerOut.valid),
        .dataIn  (mixerOut.Q),

        .validOut(),
        .dataOut (Q_int)
    );

    // Magnitude
    magnitude u_mag (
        .I      (I_int),
        .Q      (Q_int),
        .magOut (magnitude_val)
    );

    // Phase
    phase u_phase (
        .I        (I_int),
        .Q        (Q_int),
        .phaseOut (phase_val)
    );

    // Output assignment
    assign dataOut.magnitude = magnitude_val;
    assign dataOut.phase     = phase_val;
    assign dataOut.I         = I_int;
    assign dataOut.Q         = Q_int;
    assign dataOut.valid     = valid_int;

endmodule