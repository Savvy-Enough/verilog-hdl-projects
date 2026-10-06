`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.10.2026 16:28:36
// Design Name: 
// Module Name: SUPER_REG_BLOCK
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


module SUPER_REG_BLOCK(

input    [7:0]Data,
input    clk,
input    rst,
input    enA,
input    enB,
input    enC,
input    enD,
input    enE,
input    enH,
input    enL,

output [7:0] A,
output [7:0] B,
output [7:0] C,
output [7:0] D,
output [7:0] E,
output [7:0] H,
output [7:0] L
    );
   
REGISTER_8BIT A_reg(.in(Data), .clk(clk),  .rst(rst),  .en(enA), .ou(A[7:0]));
REGISTER_8BIT B_reg(.in(Data), .clk(clk),  .rst(rst),  .en(enB), .ou(B[7:0]));
REGISTER_8BIT C_reg(.in(Data), .clk(clk),  .rst(rst),  .en(enC), .ou(C[7:0]));
REGISTER_8BIT D_reg(.in(Data), .clk(clk),  .rst(rst),  .en(enD), .ou(D[7:0]));
REGISTER_8BIT E_reg(.in(Data), .clk(clk),  .rst(rst),  .en(enE), .ou(E[7:0]));
REGISTER_8BIT H_reg(.in(Data), .clk(clk),  .rst(rst),  .en(enH), .ou(H[7:0]));
REGISTER_8BIT L_reg(.in(Data), .clk(clk),  .rst(rst),  .en(enL), .ou(L[7:0]));

   
endmodule
