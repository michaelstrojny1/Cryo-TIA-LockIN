// vlog pkg/lockIn_pkg.sv
// vlog src/mixer.sv
// vlog tb/mixer_tb.sv
// vsim mixer_tb
// run -all

`timescale 1ns/1ps

import lockIn_pkg::*;

module mixer_tb;

    // ------------------------------------------------------------
    // Parameters (match DUT defaults)
    // ------------------------------------------------------------

    localparam CLK_FREQ = 100_000_000;
    localparam MIX_FREQ = 6000;
    localparam WIDTH    = 32;

    // Clock period (100 MHz simulation clock)
    localparam CLK_PERIOD = 10;

    // ------------------------------------------------------------
    // DUT Signals
    // ------------------------------------------------------------

    logic clk;
    logic reset;
    sampleT dataIn;

    mixerOutputT dataOut;

    // ------------------------------------------------------------
    // DUT Instantiation
    // ------------------------------------------------------------

    mixer #(
        .CLK_FREQ(CLK_FREQ),
        .MIX_FREQ(MIX_FREQ),
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .dataIn(dataIn),
        .dataOut(dataOut)
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

    int amplitude = 10000;

    initial begin

        $display("\n==============================================");
        $display("Mixer Testbench Starting");
        $display("==============================================\n");

        $display("time\tinput\tI\tQ\tphaseIdx\tclkDiv\tmultI\tmultQ");

        reset = 1;
        dataIn = 0;
        phase  = 0;

        freq = 6000.0;

        repeat (10) @(posedge clk);
        reset = 0;

        // Run simulation for many cycles
        repeat (200) begin

            @(posedge clk);

            // Generate test sine input
            phase += 2.0 * 3.1415926535 * freq / CLK_FREQ;

            sample = amplitude * $sin(phase);

            dataIn = $rtoi(sample);

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
                "%0t\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d",
                $time,
                dataIn,
                dataOut.I,
                dataOut.Q,
                dut.phaseIndex,
                dut.clkDivide,
                dut.multI,
                dut.multQ
            );

        end
    end

endmodule
