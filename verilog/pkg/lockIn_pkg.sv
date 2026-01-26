package lockIn_pkg;

    typedef logic signed [15:0] sampleT;
    typedef logic signed [31:0] accumT;
    typedef logic signed [63:0] longAccumT;

    // CIC Parameters
    typedef struct packed {
        int R;      // Decimation factor
        int N;      // Number of stages
        int M;      // Differential delay
    } cicParamsT;

    // Polyphase branch structure
    typedef struct {
        accumT intState;    // Integrator state for this branch
        accumT combState;   // Comb state for this branch
    }
    
    // Phase for square mixing
    typedef enum logic [1:0] {
        PHASE_0     = 2'b00,
        PHASE_90    = 2'b01.
        PHASE_180   = 2'b10,
        PHASE_270   = 2'b11
    } phaseAngleT;

    // Interface between CIC and Mixer
    typedef struct {
        accumT      data;
        logic       valid;
        phaseAngleT phase;
    } cicOutputT;

    // Mixer Output
    typedef struct {
        accumT  I;
        accumT  Q;
        logic   valid;
    } mixerOutputT;

    // Lock-in Output
    typedef struct {
        accumT  magnitude;
        accumT  phase;
        accumT  I;
        accumT  Q;
        logic   valid;
    } lockInOutputT

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