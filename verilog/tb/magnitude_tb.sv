// vlog pkg/lockIn_pkg.sv
// vlog src/magnitude.sv
// vlog tb/magnitude_tb.sv
// vsim magnitude_tb
// run -all

`timescale 1ns/1ps

import lockIn_pkg::*;

module magnitude_tb;

    // ------------------------------------------------------------
    // DUT signals
    // ------------------------------------------------------------
    
    accumT      I;
    accumT      Q;
    longAccumT  magOut;

    // ------------------------------------------------------------
    // DUT Instantiation
    // ------------------------------------------------------------

    magnitude dut (
        .I(I),
        .Q(Q),
        .magOut(magOut)
    );

    // ------------------------------------------------------------
    // Test sequence
    // ------------------------------------------------------------

    initial begin
        $display("\n========================================");
        $display("Testing Magnitude Module");
        $display("========================================\n");

        I = 10;
        Q = 5;
        #1;
        $display("I = %4d | Q = %4d | magOut = (%3d)",
                 I, Q, magOut);
        
        // Quadrant II (-,+)
        I = -10;
        Q = 5;
        #1;
        $display("I = %4d | Q = %4d | magOut = (%3d)",
                 I, Q, magOut);

        // Quadrant III (-,-)
        I = -10;
        Q = -5;
        #1;
        $display("I = %4d | Q = %4d | magOut = (%3d)",
                 I, Q, magOut);

        // Quadrant IV (+,-)
        I = 10;
        Q = -5;
        #1;
        $display("I = %4d | Q = %4d | magOut = (%3d)",
                 I, Q, magOut);

        // Edge cases
        $display("\n--- Edge Cases ---");

        I = 0; Q = 5;
        #1;
        $display("I = %4d | Q = %4d | magOut = (%3d)",
                 I, Q, magOut);

        I = 5; Q = 0;
        #1;
        $display("I = %4d | Q = %4d | magOut = (%3d)",
                 I, Q, magOut);

        I = 0; Q = 0;
        #1;
        $display("I = %4d | Q = %4d | magOut = (%3d)",
                 I, Q, magOut);

        $display("\n========================================");
        $display("Magnitude Test Complete");
        $display("========================================\n");

        $finish;
    end

endmodule