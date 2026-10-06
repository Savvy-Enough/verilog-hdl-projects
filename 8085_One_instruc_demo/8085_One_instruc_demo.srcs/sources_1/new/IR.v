`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module: Register_8bit
// Project: 8085-compatible CPU
//
// Description:
// 8-bit register constructed from eight individual D flip-flops.
// All flip-flops share the same clock, synchronous reset, and enable.
//
// Inputs:
// IN      - 8-bit data input
// CLK     - Rising-edge triggered clock
// RST     - Synchronous active-high reset
// EN      - Clock enable
//
// Output:
// OUT     - 8-bit registered output
//
// Operation:
// On the rising edge of CLK:
//   - If RST = 1, OUT is cleared to 8'b00000000.
//   - If RST = 0 and EN = 1, OUT captures IN.
//   - If RST = 0 and EN = 0, OUT retains its previous value.
//
// Implementation:
// The register is built structurally using eight instances of D_ff.
// Each D_ff stores one bit of the 8-bit register.
//////////////////////////////////////////////////////////////////////////////////


module Instruction_Register_8bit(
    input [7:0]in ,
    input clk ,
    input rst ,
    input en ,   
    output wire [7:0]ou
    );
    D_ff  F0(.clk(clk) , .rst( rst) , .en(en) , .d(in[0]) , .q(ou[0]) );
    D_ff  F1(.clk(clk) , .rst( rst) , .en(en) , .d(in[1]) , .q(ou[1]) );
    D_ff  F2(.clk(clk) , .rst( rst) , .en(en) , .d(in[2]) , .q(ou[2]) );
    D_ff  F3(.clk(clk) , .rst( rst) , .en(en) , .d(in[3]) , .q(ou[3]) );
    D_ff  F4(.clk(clk) , .rst( rst) , .en(en) , .d(in[4]) , .q(ou[4]) );
    D_ff  F5(.clk(clk) , .rst( rst) , .en(en) , .d(in[5]) , .q(ou[5]) );
    D_ff  F6(.clk(clk) , .rst( rst) , .en(en) , .d(in[6]) , .q(ou[6]) );
    D_ff  F7(.clk(clk) , .rst( rst) , .en(en) , .d(in[7]) , .q(ou[7]) );
    
endmodule
