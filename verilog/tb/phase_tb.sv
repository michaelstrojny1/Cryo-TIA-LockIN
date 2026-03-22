// vlog pkg/lockIn_pkg.sv
// vlog src/phase.sv
// vlog tb/phase_tb.sv
// vsim phase_tb
// run -all

`timescale 1ns/1ps

import lockIn_pkg::*;

module phase_tb;

    // ------------------------------------------------------------
    // DUT Signals
    // ------------------------------------------------------------

    accumT      I;
    accumT      Q;
    phaseAngleT phaseOut;

    // ------------------------------------------------------------
    // DUT Instantiation
    // ------------------------------------------------------------

    phase dut (
        .I(I),
        .Q(Q),
        .phaseOut(phaseOut)
    );

    // ------------------------------------------------------------
    // Test helper task
    // ------------------------------------------------------------

    task run_test(
        input accumT testI,
        input accumT testQ,
        input phaseAngleT expected
    );
        begin
            I = testI;
            Q = testQ;
            #1;

            $display("I=%4d | Q=%4d | phase=%s (%2b)",
                     I, Q, phaseOut.name(), phaseOut);

            if (phaseOut !== expected) begin
                $display("ERROR: Expected %s but got %s\n",
                         expected.name(), phaseOut.name());
            end
        end
    endtask

    // ------------------------------------------------------------
    // Test sequence
    // ------------------------------------------------------------

    initial begin

        $display("\n========================================");
        $display("        Testing Phase Module");
        $display("========================================\n");

        // --------------------------------------------------------
        // Quadrant tests
        // --------------------------------------------------------

        $display("---- Quadrant Tests ----");

        run_test(10,   5,  PHASE_0);
        run_test(-10,  5,  PHASE_90);
        run_test(-10, -5,  PHASE_180);
        run_test(10,  -5,  PHASE_270);

        // --------------------------------------------------------
        // Edge cases
        // --------------------------------------------------------

        $display("\n---- Edge Cases ----");

        run_test(0,  5, PHASE_0);
        run_test(5,  0, PHASE_0);
        run_test(0,  0, PHASE_0);

        // --------------------------------------------------------
        // Randomized tests
        // --------------------------------------------------------

        $display("\n---- Random Tests ----");

        repeat (10) begin
            I = $urandom_range(-100,100);
            Q = $urandom_range(-100,100);
            #1;

            $display("I=%4d | Q=%4d | phase=%s (%2b)",
                     I, Q, phaseOut.name(), phaseOut);
        end

        // --------------------------------------------------------
        // End simulation
        // --------------------------------------------------------

        $display("\n========================================");
        $display("        Phase Test Complete");
        $display("========================================\n");

        $finish;

    end

endmodule