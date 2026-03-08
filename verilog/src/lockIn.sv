import lockIn_pkg::*;

module lockIn #(

) (
    input   logic           clk,
    input   logic           reset,

    input   sampleT         sampleIn,
    input   logic           validIn,

    output  lockInOutputT   Out
);

    // Inter-module signals
    mixerOutputT mixerOut;

    accumT I_int;
    accumT Q_int;

    accumT magnitude_val;
    accumT phase_val;

    logic  valid_int;

    // Mixer
    mixer u1 (
        .clk    (clk),
        .reset  (reset),

        .sample (sampleIn),
        .valid  (validIn),

        .I      (mixerOut.I),
        .Q      (mixerOut.Q),
        .validOut(mixerOut.valid)
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
    assign Out.magnitude = magnitude_val;
    assign Out.phase     = phase_val;
    assign Out.I         = I_int;
    assign Out.Q         = Q_int;
    assign Out.valid     = valid_int;

endmodule