// vlog pkg/lockIn_pkg.sv
// vlog src/mixer.sv
// vlog src/integrate.sv
// vlog src/magnitude.sv
// vlog src/phase.sv
// vlog src/lockIn.sv
// vlog tb/lockIn_tbNoise.sv
// vsim lockIn_tbNoise
// run -all

`timescale 1ns/1ps

import lockIn_pkg::*;

module lockIn_tbNoise;

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

    real phase1, phase2, phase3;
    real freq1, freq2, freq3;
    real sample;

    int amplitude1 = 100;  // target signal (6000 Hz)
    int amplitude2 = 300;  // interferer 1
    int amplitude3 = 200;  // interferer 2

    initial begin
        $display("\n==============================================");
        $display("Lock-in Amplifier Testbench Starting");
        $display("==============================================\n");

        $display("time\tinput\tI\tQ\tmag\tphase\tvalid");

        reset    = 1;
        sampleIn = 0;
        validIn  = 0;

        // Initialize phases
        phase1 = 0;
        phase2 = 0;
        phase3 = 0;

        // Frequencies
        freq1 = 6000.0;   // lock-in reference frequency
        freq2 = 9000.0;   // interferer
        freq3 = 12345.0;  // interferer

        // Apply reset
        repeat (10) @(posedge clk);
        reset = 0;

        // Run simulation
        repeat (800000) begin
            @(posedge clk);

            // Update phases
            phase1 += 2.0 * 3.1415926535 * freq1 / CLK_FREQ;
            phase2 += 2.0 * 3.1415926535 * freq2 / CLK_FREQ;
            phase3 += 2.0 * 3.1415926535 * freq3 / CLK_FREQ;

            // Generate composite signal
            sample = amplitude1 * $sin(phase1)
                + amplitude2 * $sin(phase2)
                + amplitude3 * $sin(phase3);

            sampleIn = $rtoi(sample);

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
