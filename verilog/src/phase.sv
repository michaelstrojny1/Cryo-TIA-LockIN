import lockIn_pkg::*;

module phase (
    input   accumT      I,
    input   accumT      Q,
    output  phaseAngleT phaseOut
);

    always_comb begin
        if (I >= 0 && Q >= 0) begin
            phaseOut = PHASE_0;
        end
        else if (I < 0 && Q >= 0) begin
            phaseOut = PHASE_90;
        end
        else if (I < 0 && Q < 0) begin
            phaseOut = PHASE_180;
        end
        else begin
            phaseOut = PHASE_270;
        end
    end

endmodule