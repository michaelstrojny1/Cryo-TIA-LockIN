package lockIn_pkg;

    // ------------------------------------------------------------
    // Fundamental Signal Types
    // ------------------------------------------------------------

    typedef logic signed [15:0] sampleT;
    typedef logic signed [31:0] accumT;
    typedef logic signed [63:0] longAccumT;

    // ------------------------------------------------------------
    // CIC Filter Parameters
    // ------------------------------------------------------------

    typedef struct packed {

        int R;      // Decimation factor
        int N;      // Number of stages
        int M;      // Differential delay

    } cicParamsT;

    // ------------------------------------------------------------
    // Polyphase Branch State
    // ------------------------------------------------------------

    typedef struct {

        accumT intState;    // Integrator state
        accumT combState;   // Comb state

    } polyphaseBranchT;

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
    // Interface: CIC to Mixer
    // ------------------------------------------------------------

    typedef struct {

        accumT      data;
        logic       valid;
        phaseAngleT phase;

    } cicOutputT;

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