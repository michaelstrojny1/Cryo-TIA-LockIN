`timescale 1ns/1ps

import lockIn_pkg::*;

module mixer_tb;

    // ------------------------------------------------------------
    // Parameters (match DUT defaults)
    // ------------------------------------------------------------

    localparam CLK_FREQ = 10_000_000;
    localparam MIX_FREQ = 6000;
    localparam WIDTH    = 32;

    // Clock period (100 MHz example simulation clock)
    localparam CLK_PERIOD = 100;

    // ------------------------------------------------------------
    // DUT Signals
    // ------------------------------------------------------------

    logic clk;
    logic reset;
    logic signed [WIDTH-1:0] dataIn;

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
    int  amplitude = 10000;

    initial begin

        $display("\n===============================");
        $display("Mixer Testbench Starting");
        $display("===============================\n");

        reset = 1;
        dataIn = 0;
        phase  = 0;

        freq = 6000.0;

        repeat (10) @(posedge clk);
        reset = 0;

        // Run simulation for many cycles
        repeat (20000) begin

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
                "t=%0t | In=%0d | I=%0d | Q=%0d",
                $time,
                dataIn,
                dataOut.I,
                dataOut.Q
            );

        end
    end

endmodule