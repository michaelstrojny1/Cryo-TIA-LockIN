// vlog pkg/lockIn_pkg.sv
// vlog src/mixer.sv
// vlog src/integrate.sv
// vlog src/magnitude.sv
// vlog src/phase.sv
// vlog src/lockIn.sv
// vlog tb/lockIn_tb.sv
// vsim lockIn_tb
// run -all

`timescale 1ns/1ps

import lockIn_pkg::*;

module lockIn_tb;

    // ------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------

    localparam CLK_FREQ = 100_000_000; // 100 MHz simulation clock
    localparam WIDTH    = 32;

    // Clock period
    localparam CLK_PERIOD = 10;

    // ------------------------------------------------------------
    // DUT Signals
    // ------------------------------------------------------------

    logic clk;
    logic reset;

    sampleT sampleIn;
    logic   validIn;

    lockInOutputT dataOut;

    // ------------------------------------------------------------
    // DUT Instantiation
    // ------------------------------------------------------------

    lockIn dut (
        .clk      (clk),
        .reset    (reset),
        .dataIn   (sampleIn),
        .validIn  (validIn),
        .dataOut  (dataOut)
    );

    // ------------------------------------------------------------
    // Clock Generator
    // ------------------------------------------------------------

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ------------------------------------------------------------
    // Stimulus
    // ------------------------------------------------------------

    real phase;
    real freq;
    real sample;
    int  amplitude = 100;

    initial begin
        $display("\n==============================================");
        $display("Lock-in Amplifier Testbench Starting");
        $display("==============================================\n");

        $display("time\tinput\tI\tQ\tmag\tphase\tvalid");

        reset   = 1;
        sampleIn = 0;
        validIn = 0;
        phase   = 0;
        freq    = 6000.0; // Test frequency

        // Apply reset for a few cycles
        repeat (10) @(posedge clk);
        reset = 0;

        // Run simulation for multiple cycles
        repeat (16000000) begin
            @(posedge clk);

            // Generate test sine input
            phase += 2.0 * 3.1415926535 * freq / CLK_FREQ;
            sample = amplitude * $sin(phase);
            sampleIn = $rtoi(sample);

            // Mark input valid every cycle
            validIn = 1;
        end

        $display("\nSimulation Finished\n");
        $finish;
    end

    // ------------------------------------------------------------
    // Output Monitor
    // ------------------------------------------------------------

    always @(posedge clk) begin
        if (dataOut.valid) begin
            $display(
                "%0t\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d",
                $time,
                sampleIn,
                dataOut.I,
                dataOut.Q,
                dataOut.magnitude,
                dataOut.phase,
                dataOut.valid
            );
        end
    end

endmodule
