`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.10.2026 15:41:48
// Design Name: 
// Module Name: NEXTPC_Instruct
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


module NEXTPC_Instruct(
    input [15:0] PC,
    input control,
    output reg [15:0] NextPC
);

    wire [15:0] PC_PLUS_ONE;

    assign PC_PLUS_ONE = PC + 16'h0001;

    always @(*)
    begin
        if(control == 1'b1)
            NextPC = PC_PLUS_ONE;
        else
            NextPC = PC;
    end

endmodule
