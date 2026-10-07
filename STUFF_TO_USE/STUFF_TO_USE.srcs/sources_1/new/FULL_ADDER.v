`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.10.2026 21:35:18
// Design Name: 
// Module Name: FULL_ADDER
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


module FULL_ADDER(
input A , B , Cin,
output S , C
    );
    assign S = A ^ B ^ Cin;
    assign C = (A&B) + (Cin&(A^B));
endmodule
