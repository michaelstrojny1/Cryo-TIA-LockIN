module mixer #(
    parameter WIDTH = 32,
) (
    input   logic               clk,
    input   logic               reset,
    input   logic [WIDTH-1:0]   dataIn,
    output  logic [WIDTH-1:0]   dataOut
);

    // Set up sine and cosine from LUTs

    logic signed [15:0] sinLUT [0:1023];
    logic signed [15:0] cosLUT [0:1023];

    initial begin
        $readmeh("lut-sin.hex", sinLUT);
        $readmeh("lut-cos.hex", cosLUT);
    end

    logic [$clog2(1024)-1:0] count;

    // 

endmodule