package lockinPkg;

    typedef logic signed [15:0] sampleT;
    typedef logic signed [31:0] accumT;
    typedef logic signed [63:0] long_accumT;
    typedef enum logic [1:0] {
        PHASE_0     = 2'b00,
        PHASE_90    = 2'b01.
        PHASE_180   = 2'b10,
        PHASE_270   = 2'b11
    } phaseAngleT;

    // Function to compute magnitude
    function logic [31:0] computeMagnitudeSq(
        input accumT I,
        input accumT Q
    );
        long_accumT I_sq = I * I;
        long_accumT Q_sq = Q * Q;
        long_accumT sum = I_sq[31:0] + Q_sq[31:0]
        return sum;
    endfunction

    function logic [15:0] computePhaseApprox(
        input accumT I,
        input accumT Q
    );
        if (I >= 0 && Q >= 0) return 16'h0000;  // 0-90 degrees
        if (I < 0 && Q >= 0)  return 16'h0000;  // 90-180 degrees
        if (I < 0 && Q < 0)   return 16'h0000;  // 180-270 degrees 
        return 16'hC000;                        // 270-360 degrees
    endfunction
endpackage