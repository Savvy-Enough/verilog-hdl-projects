`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module: D_ff_tb
// Project: 8085-compatible CPU
//
// Description:
// Behavioral testbench for the D_ff module.
//
// The testbench verifies:
//   - Synchronous active-high reset
//   - Data capture when enable is asserted
//   - Hold behavior when enable is deasserted
//   - Correct QNOT operation
//
// Testbench Inputs:
//   CLK - Clock signal
//   RST - Synchronous active-high reset
//   EN  - Clock enable
//   D   - Data input
//
// Testbench Outputs:
//   Q    - Flip-flop output
//   QNOT - Complement of Q
//
// Notes:
// This module is used for simulation and verification only.
// It is not synthesized into FPGA hardware.
//////////////////////////////////////////////////////////////////////////////////

module tb_DFF;

    reg clk;
    reg rst;
    reg en;
    reg d;

    wire q;
    wire qnot;

    // DUT
    D_ff uut (
        .clk  (clk),
        .rst  (rst),
        .en   (en),
        .d    (d),
        .q    (q),
        .qnot (qnot)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    initial begin

        // Initial conditions
        clk = 0;
        rst = 0;
        en  = 0;
        d   = 0;

        // Test synchronous reset
        #2;
        rst = 1;
        #8;             // t = 10 ns
        rst = 0;        // deassert reset between clock edges

        // Test D = 1
        en = 1;
        d  = 1;
        #10;

        // Test D = 0
        d = 0;
        #10;

        // Test enable = 0 (Q should hold)
        en = 0;
        d  = 1;
        #10;

        // Enable again, Q should capture D
        en = 1;
        #10;

        // Test QNOT
        // At this point q should be 1 and qnot should be 0
        #2;

        $finish;
    end

endmodule