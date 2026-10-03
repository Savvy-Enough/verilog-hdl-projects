`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Create Date: 03.10.2026
// Design Name: 8085 CPU
// Module Name: Instruction_Rom_Tb
// Project Name: 8085_One_instruc_demo
// Target Devices:
// Tool Versions:
// Description:
//
//     Testbench for Instruction_Rom.
//
//     The testbench verifies that:
//
//         1. program.mem is loaded correctly.
//         2. Each address returns the expected byte.
//         3. The ROM behaves as an asynchronous read-only memory.
//
//     No clock is required because the ROM itself is asynchronous.
//     The testbench changes the PC and observes the resulting Data.
//
//
// Expected program.mem:
//
//         Address     Data
//         0000H       06H
//         0001H       02H
//         0002H       0EH
//         0003H       08H
//         0004H       16H
//         0005H       44H
//
//     These bytes correspond to the assembled program:
//
//         MVI B,02H
//         MVI C,08H
//         MVI D,44H
//
//     The ROM itself does NOT interpret these instructions. The testbench
//     only verifies the byte values stored at the corresponding addresses.
//
//
// Verification Approach:
//
//     For each test address:
//
//         1. Drive PC with the address.
//         2. Wait for the combinational output to settle.
//         3. Compare Data with the expected byte.
//         4. Record a failure if the values do not match.
//
//     A final PASS/FAIL result is printed after all tests.
//
//
// Architectural Learning:
//
//     - A testbench is not part of the synthesized CPU hardware.
//     - It provides stimulus to the design and checks its response.
//     - The ROM has no clock, so the testbench does not need a clock either.
//     - Simulation delays (#1) are used only to allow the testbench to
//       observe the result of the combinational read.
//
//
// Revision:
// Revision 0.01 - File Created
//
// Additional Comments:
//     This is intentionally a simple verification environment.
//     More systematic verification will be introduced later when the
//     CPU contains multiple interacting blocks.
//
//
//////////////////////////////////////////////////////////////////////////////////


module Instruction_Rom_tb;

    reg  [15:0] PC;
    wire [7:0]  Data;

    integer errors;

    // Instantiate the ROM
    Instruction_Rom DUT (
        .PC(PC),
        .Data(Data)
    );

    initial begin
        errors = 0;

        // Give the ROM time to initialize from program.mem
        #1;

        // -------------------------
        // Address 0000H
        // -------------------------
        PC = 16'h0000;
        #1;

        if (Data !== 8'h06) begin
            $display("FAIL: PC=%h | Expected=%h | Got=%h",
                     PC, 8'h06, Data);
            errors = errors + 1;
        end
        else begin
            $display("PASS: PC=%h | Data=%h", PC, Data);
        end

        // -------------------------
        // Address 0001H
        // -------------------------
        PC = 16'h0001;
        #1;

        if (Data !== 8'h02) begin
            $display("FAIL: PC=%h | Expected=%h | Got=%h",
                     PC, 8'h02, Data);
            errors = errors + 1;
        end
        else begin
            $display("PASS: PC=%h | Data=%h", PC, Data);
        end

        // -------------------------
        // Address 0002H
        // -------------------------
        PC = 16'h0002;
        #1;

        if (Data !== 8'h0E) begin
            $display("FAIL: PC=%h | Expected=%h | Got=%h",
                     PC, 8'h0E, Data);
            errors = errors + 1;
        end
        else begin
            $display("PASS: PC=%h | Data=%h", PC, Data);
        end

        // -------------------------
        // Address 0003H
        // -------------------------
        PC = 16'h0003;
        #1;

        if (Data !== 8'h08) begin
            $display("FAIL: PC=%h | Expected=%h | Got=%h",
                     PC, 8'h08, Data);
            errors = errors + 1;
        end
        else begin
            $display("PASS: PC=%h | Data=%h", PC, Data);
        end

        // -------------------------
        // Address 0004H
        // -------------------------
        PC = 16'h0004;
        #1;

        if (Data !== 8'h16) begin
            $display("FAIL: PC=%h | Expected=%h | Got=%h",
                     PC, 8'h16, Data);
            errors = errors + 1;
        end
        else begin
            $display("PASS: PC=%h | Data=%h", PC, Data);
        end

        // -------------------------
        // Address 0005H
        // -------------------------
        PC = 16'h0005;
        #1;

        if (Data !== 8'h44) begin
            $display("FAIL: PC=%h | Expected=%h | Got=%h",
                     PC, 8'h44, Data);
            errors = errors + 1;
        end
        else begin
            $display("PASS: PC=%h | Data=%h", PC, Data);
        end

        // -------------------------
        // Final result
        // -------------------------
        if (errors == 0) begin
            $display("================================");
            $display("ROM TEST PASSED");
            $display("================================");
        end
        else begin
            $display("================================");
            $display("ROM TEST FAILED: %0d error(s)", errors);
            $display("================================");
        end

        $finish;
    end

endmodule
