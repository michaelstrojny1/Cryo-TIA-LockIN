`timescale 1ns/1ps

import lockIn_pkg::*;

module phase_tb;

    // DUT signals
    accumT      I;
    accumT      Q;
    phaseAngleT phaseOut;

    // DUT Instantiation
    phase dut (
        .I(I),
        .Q(Q),
        .phaseOut(phaseOut)
    );

    // Test sequence
    initial begin
        $display("\n========================================");
        $display("Testing Phase Module");
        $display("========================================\n");

        // Quadrant I (+,+)
        I = 10;
        Q = 5;
        #1;
        $display("I = %4d | Q = %4d | phaseOut = %s (%2b)",
                 I, Q, phaseOut.name(), phaseOut);

        // Quadrant II (-,+)
        I = -10;
        Q = 5;
        #1;
        $display("I = %4d | Q = %4d | phaseOut = %s (%2b)",
                 I, Q, phaseOut.name(), phaseOut);

        // Quadrant III (-,-)
        I = -10;
        Q = -5;
        #1;
        $display("I = %4d | Q = %4d | phaseOut = %s (%2b)",
                 I, Q, phaseOut.name(), phaseOut);

        // Quadrant IV (+,-)
        I = 10;
        Q = -5;
        #1;
        $display("I = %4d | Q = %4d | phaseOut = %s (%2b)",
                 I, Q, phaseOut.name(), phaseOut);

        // Edge cases
        $display("\n--- Edge Cases ---");

        I = 0; Q = 5;
        #1;
        $display("I = %4d | Q = %4d | phaseOut = %s (%2b)",
                 I, Q, phaseOut.name(), phaseOut);

        I = 5; Q = 0;
        #1;
        $display("I = %4d | Q = %4d | phaseOut = %s (%2b)",
                 I, Q, phaseOut.name(), phaseOut);

        I = 0; Q = 0;
        #1;
        $display("I = %4d | Q = %4d | phaseOut = %s (%2b)",
                 I, Q, phaseOut.name(), phaseOut);

        $display("\n========================================");
        $display("Phase Test Complete");
        $display("========================================\n");

        $finish;
    end

endmodule