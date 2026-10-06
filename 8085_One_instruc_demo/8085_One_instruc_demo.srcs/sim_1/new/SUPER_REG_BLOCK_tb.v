`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.10.2026 16:40:35
// Design Name: 
// Module Name: SUPER_REG_BLOCK_tb
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

module SUPER_REG_BLOCK_tb;

    reg [7:0] Data;
    reg clk;
    reg rst;
    reg enA, enB, enC, enD, enE, enH, enL;

    wire [7:0] A, B, C, D, E, H, L;

    SUPER_REG_BLOCK DUT (
        .Data(Data),
        .clk(clk),
        .rst(rst),
        .enA(enA),
        .enB(enB),
        .enC(enC),
        .enD(enD),
        .enE(enE),
        .enH(enH),
        .enL(enL),
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .E(E),
        .H(H),
        .L(L)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    initial begin

        clk = 1'b0;
        rst = 1'b1;
        Data = 8'h00;

        enA = 1'b0;
        enB = 1'b0;
        enC = 1'b0;
        enD = 1'b0;
        enE = 1'b0;
        enH = 1'b0;
        enL = 1'b0;

        // Reset
        #10;

        if (A !== 8'h00 || B !== 8'h00 || C !== 8'h00 ||
            D !== 8'h00 || E !== 8'h00 || H !== 8'h00 ||
            L !== 8'h00)
            $display("ERROR: Reset failed");
        else
            $display("PASS: Reset");

        rst = 1'b0;

        // A
        Data = 8'h11;
        enA = 1'b1;
        #10;
        enA = 1'b0;

        if (A !== 8'h11)
            $display("ERROR: A register failed");
        else
            $display("PASS: A = 11H");

        // B
        Data = 8'h22;
        enB = 1'b1;
        #10;
        enB = 1'b0;

        if (B !== 8'h22)
            $display("ERROR: B register failed");
        else
            $display("PASS: B = 22H");

        // C
        Data = 8'h33;
        enC = 1'b1;
        #10;
        enC = 1'b0;

        if (C !== 8'h33)
            $display("ERROR: C register failed");
        else
            $display("PASS: C = 33H");

        // D
        Data = 8'h44;
        enD = 1'b1;
        #10;
        enD = 1'b0;

        if (D !== 8'h44)
            $display("ERROR: D register failed");
        else
            $display("PASS: D = 44H");

        // E
        Data = 8'h55;
        enE = 1'b1;
        #10;
        enE = 1'b0;

        if (E !== 8'h55)
            $display("ERROR: E register failed");
        else
            $display("PASS: E = 55H");

        // H
        Data = 8'h66;
        enH = 1'b1;
        #10;
        enH = 1'b0;

        if (H !== 8'h66)
            $display("ERROR: H register failed");
        else
            $display("PASS: H = 66H");

        // L
        Data = 8'h77;
        enL = 1'b1;
        #10;
        enL = 1'b0;

        if (L !== 8'h77)
            $display("ERROR: L register failed");
        else
            $display("PASS: L = 77H");

        // Final check: all registers retained their values
        #10;

        if (A !== 8'h11 || B !== 8'h22 || C !== 8'h33 ||
            D !== 8'h44 || E !== 8'h55 || H !== 8'h66 ||
            L !== 8'h77)
            $display("ERROR: Register hold behavior failed");
        else
            $display("PASS: All registers retain values");

        $display("SUPER_REG_BLOCK test completed.");
        $finish;
    end

endmodule
