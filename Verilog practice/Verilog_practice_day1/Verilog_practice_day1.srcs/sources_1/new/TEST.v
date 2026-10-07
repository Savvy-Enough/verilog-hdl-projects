`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2026 14:42:35
// Design Name: 
// Module Name: Test
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

//4:1 Multiplexer
/*module Mux(input [3:0]a, [1:0]s , output reg y);
always @(*)
    begin
    case(s)
        2'b00: y = a[0];
        2'b01: y = a[1];
        2'b10: y = a[2];
        2'b11: y = a[3];
    endcase
    end
endmodule*/

//Synchronous up counter
module up_down_counter(input clk, rst ,Mode, output reg [3:0]y);
  
    always @(posedge clk) //posedge clk or posedge rst for asynchronous
        begin
            if(rst)
                y <= 4'b0000;
            else if(Mode == 0)
                y <= y + 1; 
            else if(Mode == 1)
                y <= y - 1;
        end
endmodule 