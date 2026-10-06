`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.10.2026 15:55:30
// Design Name: 
// Module Name: NEXTPC_Instruct_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module NEXTPC_Instruct_tb;

    reg [15:0] PC;
    reg control;
    wire [15:0] NextPC;

    NEXTPC_Instruct DUT (
        .PC(PC),
        .control(control),
        .NextPC(NextPC)
    );

    initial begin
        // Test 1: Hold
        PC = 16'h0000;
        control = 1'b0;
        #10;

        if (NextPC !== 16'h0000)
            $display("ERROR: Test 1 failed. NextPC = %h", NextPC);
        else
            $display("PASS: Test 1");

        // Test 2: Increment
        control = 1'b1;
        #10;

        if (NextPC !== 16'h0001)
            $display("ERROR: Test 2 failed. NextPC = %h", NextPC);
        else
            $display("PASS: Test 2");

        // Test 3: Increment across lower-byte boundary
        PC = 16'h00FF;
        control = 1'b1;
        #10;

        if (NextPC !== 16'h0100)
            $display("ERROR: Test 3 failed. NextPC = %h", NextPC);
        else
            $display("PASS: Test 3");

        // Test 4: Hold at arbitrary address
        PC = 16'h2050;
        control = 1'b0;
        #10;

        if (NextPC !== 16'h2050)
            $display("ERROR: Test 4 failed. NextPC = %h", NextPC);
        else
            $display("PASS: Test 4");

        // Test 5: Increment at arbitrary address
        control = 1'b1;
        #10;

        if (NextPC !== 16'h2051)
            $display("ERROR: Test 5 failed. NextPC = %h", NextPC);
        else
            $display("PASS: Test 5");

        // Test 6: 16-bit wraparound
        PC = 16'hFFFF;
        control = 1'b1;
        #10;

        if (NextPC !== 16'h0000)
            $display("ERROR: Test 6 failed. NextPC = %h", NextPC);
        else
            $display("PASS: Test 6");

        $display("All NEXT_PC tests completed.");
        $finish;
    end

endmodule
