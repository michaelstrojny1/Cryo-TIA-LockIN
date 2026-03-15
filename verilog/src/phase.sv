import lockIn_pkg::*;

module phase (
    input  accumT      I,
    input  accumT      Q,
    output phaseAngleT phaseOut
);

    // ------------------------------------------------------------
    // Extract sign bits (1 = negative, 0 = positive)
    // ------------------------------------------------------------

    logic signI;
    logic signQ;

    assign signI = I[$bits(I)-1];
    assign signQ = Q[$bits(Q)-1];

    // ------------------------------------------------------------
    // Determine quadrant of the I/Q vector
    // ------------------------------------------------------------

    always_comb begin
        case ({signI, signQ})

            2'b00: phaseOut = PHASE_0;     // I ≥ 0, Q ≥ 0
            2'b10: phaseOut = PHASE_90;    // I < 0, Q ≥ 0
            2'b11: phaseOut = PHASE_180;   // I < 0, Q < 0
            2'b01: phaseOut = PHASE_270;   // I ≥ 0, Q < 0

            default: phaseOut = '0;

        endcase
    end

endmodule