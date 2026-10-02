`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module: Register_8bit_tb
// Project: 8085-compatible CPU
//
// Description:
// Behavioral testbench for the Register_8bit module.
//
// Verification:
// - Synchronous reset
// - Loading an 8-bit value when enable is asserted
// - Holding the previous value when enable is deasserted
// - Loading a new 8-bit value after re-enabling
//
// Notes:
// This module is used for simulation and verification only.
// It is not synthesized into FPGA hardware.
//////////////////////////////////////////////////////////////////////////////////

module Register_8bit_tb;

    reg [7:0] in;
    reg clk;
    reg rst;
    reg en;

    wire [7:0] ou;

    // Device Under Test
    Register_8bit uut (
        .in  (in),
        .clk (clk),
        .rst (rst),
        .en  (en),
        .ou  (ou)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    initial begin

        // Initial conditions
        clk = 0;
        rst = 0;
        en  = 0;
        in  = 8'b00000000;

        // -------------------------------------------------
        // Test 1: Synchronous reset
        // -------------------------------------------------
        rst = 1;
        #10;            // rising edge at 5 ns
        rst = 0;

        // -------------------------------------------------
        // Test 2: Load 10101010
        // -------------------------------------------------
        en = 1;
        in = 8'b10101010;
        #10;

        // -------------------------------------------------
        // Test 3: Load 01010101
        // -------------------------------------------------
        in = 8'b01010101;
        #10;

        // -------------------------------------------------
        // Test 4: Disable enable and change input
        // Output should HOLD previous value
        // -------------------------------------------------
        en = 0;
        in = 8'b11110000;
        #10;

        // -------------------------------------------------
        // Test 5: Re-enable and load new value
        // -------------------------------------------------
        en = 1;
        #10;

        // -------------------------------------------------
        // End simulation
        // -------------------------------------------------
        $finish;

    end

endmodule