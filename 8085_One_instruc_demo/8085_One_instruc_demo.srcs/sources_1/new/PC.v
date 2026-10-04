`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: PC
// Project: 8085-compatible CPU
//
// Description:
// 16-bit Program Counter constructed from sixteen individual D flip-flops.
// All flip-flops share the same clock, synchronous reset, and enable.
//
// Inputs:
// Load    - 16-bit value to be loaded into the Program Counter
// clk     - Rising-edge triggered clock
// rst     - Synchronous active-high reset
// en      - Clock enable
//
// Output:
// ou      - Current 16-bit Program Counter value
//
// Operation:
// On the rising edge of clk:
//   - If rst = 1, PC is cleared to 0000H.
//   - If rst = 0 and en = 1, PC captures Load.
//   - If rst = 0 and en = 0, PC retains its previous value.
//
// Implementation:
// The Program Counter is built structurally using sixteen instances
// of D_ff. Each D_ff stores one bit of the 16-bit Program Counter.
//
// Note:
// The logic responsible for generating the next PC value
// (increment, jump, call, return, etc.) is external to this module.
//////////////////////////////////////////////////////////////////////////////////



module PC(
    input [15:0]Load ,
    input clk ,
    input rst ,
    input en ,   
    output wire [15:0]ou
    );
    D_ff  F0(.clk(clk) , .rst( rst) , .en(en) , .d(Load[0]) , .q(ou[0]) );
    D_ff  F1(.clk(clk) , .rst( rst) , .en(en) , .d(Load[1]) , .q(ou[1]) );
    D_ff  F2(.clk(clk) , .rst( rst) , .en(en) , .d(Load[2]) , .q(ou[2]) );
    D_ff  F3(.clk(clk) , .rst( rst) , .en(en) , .d(Load[3]) , .q(ou[3]) );
    D_ff  F4(.clk(clk) , .rst( rst) , .en(en) , .d(Load[4]) , .q(ou[4]) );
    D_ff  F5(.clk(clk) , .rst( rst) , .en(en) , .d(Load[5]) , .q(ou[5]) );
    D_ff  F6(.clk(clk) , .rst( rst) , .en(en) , .d(Load[6]) , .q(ou[6]) );
    D_ff  F7(.clk(clk) , .rst( rst) , .en(en) , .d(Load[7]) , .q(ou[7]) );
    D_ff  F8(.clk(clk) , .rst( rst) , .en(en) , .d(Load[8]) , .q(ou[8]) );
    D_ff  F9(.clk(clk) , .rst( rst) , .en(en) , .d(Load[9]) , .q(ou[9]) );
    D_ff  Fa(.clk(clk) , .rst( rst) , .en(en) , .d(Load[10]) , .q(ou[10]) );
    D_ff  Fb(.clk(clk) , .rst( rst) , .en(en) , .d(Load[11]) , .q(ou[11]) );
    D_ff  Fc(.clk(clk) , .rst( rst) , .en(en) , .d(Load[12]) , .q(ou[12]) );
    D_ff  Fd(.clk(clk) , .rst( rst) , .en(en) , .d(Load[13]) , .q(ou[13]) );
    D_ff  Fe(.clk(clk) , .rst( rst) , .en(en) , .d(Load[14]) , .q(ou[14]) );
    D_ff  Ff(.clk(clk) , .rst( rst) , .en(en) , .d(Load[15]) , .q(ou[15]) );
    
endmodule

