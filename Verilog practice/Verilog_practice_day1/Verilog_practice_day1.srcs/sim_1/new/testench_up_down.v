`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2026 15:37:08
// Design Name: 
// Module Name: testench_up_down
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

module tb;

    // Inputs to DUT → reg
    reg clk;
    reg rst;
    reg Mode;

    // Outputs from DUT → wire
    wire [3:0] y;

    // Instantiate DUT
    up_counter uut (
        .clk(clk),
        .rst(rst),
        .Mode(Mode),
        .y(y)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        clk = 0;
        rst = 1;
        Mode = 0;

        #10;
        rst = 0;

        #50;
        Mode = 1;

        #50;
        $finish;
    end

endmodule
