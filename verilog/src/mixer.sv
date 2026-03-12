module mixer #(
    parameter integer CLK_FREQ  = 10_000_000,  // 10 MHz system clock
    parameter integer MIX_FREQ  = 6000,        // desired mixing frequency
    parameter integer WIDTH     = 32,          // input data width
    parameter integer LUT_SIZE  = 1024,        // sine/cos LUT size
    parameter integer LUT_WIDTH = 16           // LUT sample width
) (
    input  logic                     clk,
    input  logic                     reset,
    input  logic signed [WIDTH-1:0]  dataIn,
    output mixerOutputT              dataOut
);

    // ------------------------------------------------------------
    // Derived parameters
    // ------------------------------------------------------------

    localparam integer PHASE_WIDTH = $clog2(LUT_SIZE);
    localparam integer DIV = CLK_FREQ / (MIX_FREQ * LUT_SIZE);

    // ------------------------------------------------------------
    // LUT storage
    // ------------------------------------------------------------

    logic signed [LUT_WIDTH-1:0] sinLUT [0:LUT_SIZE-1];
    logic signed [LUT_WIDTH-1:0] cosLUT [0:LUT_SIZE-1];

    initial begin
        $readmemh("lut-sin.hex", sinLUT);
        $readmemh("lut-cos.hex", cosLUT);
    end

    // ------------------------------------------------------------
    // Internal signals
    // ------------------------------------------------------------

    logic [PHASE_WIDTH-1:0] phaseIndex;
    logic [$clog2(DIV)-1:0] clkDivide;

    logic signed [WIDTH+LUT_WIDTH-1:0] multI;
    logic signed [WIDTH+LUT_WIDTH-1:0] multQ;

    // ------------------------------------------------------------
    // Mixer logic
    // ------------------------------------------------------------

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin

            phaseIndex       <= 0;
            clkDivide        <= DIV-1;

            dataOut.I        <= 0;
            dataOut.Q        <= 0;
            dataOut.valid    <= 0;

        end 
        else begin

            if (clkDivide == 0) begin

                clkDivide <= DIV-1;

                // Multiply input by reference sin/cos
                multI = dataIn * sinLUT[phaseIndex];
                multQ = dataIn * cosLUT[phaseIndex];

                // Scale result back down
                dataOut.I <= multI[WIDTH+LUT_WIDTH-1:LUT_WIDTH];
                dataOut.Q <= multQ[WIDTH+LUT_WIDTH-1:LUT_WIDTH];

                dataOut.valid <= 1;

                // Advance LUT phase
                if (phaseIndex == LUT_SIZE-1)
                    phaseIndex <= 0;
                else
                    phaseIndex <= phaseIndex + 1;

            end
            else begin

                clkDivide <= clkDivide - 1;
                dataOut.valid <= 0;

            end
        end
    end

endmodule