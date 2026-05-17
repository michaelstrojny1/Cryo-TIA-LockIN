package lockIn_pkg;

    // ------------------------------------------------------------
    // Fundamental Signal Types
    // ------------------------------------------------------------

    typedef logic signed [15:0] sampleT;
    typedef logic signed [31:0] accumT;
    typedef logic signed [63:0] longAccumT;

    // ------------------------------------------------------------
    // Mixer Phase Enumeration
    // ------------------------------------------------------------

    typedef enum logic [1:0] {

        PHASE_0   = 2'b00,
        PHASE_90  = 2'b01,
        PHASE_180 = 2'b10,
        PHASE_270 = 2'b11

    } phaseAngleT;

    // ------------------------------------------------------------
    // Mixer Output
    // ------------------------------------------------------------

    typedef struct {

        accumT  I;
        accumT  Q;
        logic   valid;

    } mixerOutputT;

    // ------------------------------------------------------------
    // Lock-in Amplifier Output
    // ------------------------------------------------------------

    typedef struct {

        longAccumT  magnitude;
        phaseAngleT phase;

        accumT      I;
        accumT      Q;

        logic       valid;

    } lockInOutputT;

endpackage