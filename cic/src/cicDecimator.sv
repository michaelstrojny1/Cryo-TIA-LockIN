module cicDecimator #(

    parameter int R

) (
    
    input  logic clk,
    input  logic rst,

    input  logic validIn,

    output logic ce
    
);

    // ------------------------------------------------------------
    // Internal Counter
    // ------------------------------------------------------------

    logic [$clog2(R)-1:0] count;

    // ------------------------------------------------------------
    // Counter Logic
    // ------------------------------------------------------------

    always_ff @(posedge clk or posedge rst) begin
        
        if (rst) begin
            count <= '0;
            ce    <= 1'b0;
        end

        else if (validIn) begin

            if (count == R-1) begin
                count <= '0;
                ce    <= 1'b1;
            end

            else begin
                count <= count + 1;
                ce    <= 1'b0;
            end
        end

        else begin
            ce <= 1'b0;
        end

    end

endmodule