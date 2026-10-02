`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module: D_ff
// Project: 8085-compatible CPU
//
// Description:
// Synchronous-reset D flip-flop with clock enable.
// The flip-flop captures the input D on the rising edge of CLK when EN is high.
// When EN is low, Q retains its previous value.
//
// Reset:
// RST is synchronous and active-high.
// When RST is high at a rising edge of CLK, Q is cleared to 0.
//
// Outputs:
// Q    - Stored flip-flop value
// QNOT - Complement of Q
//////////////////////////////////////////////////////////////////////////////////

module D_ff(
    input clk , rst , en , d , 
    output reg q , 
    output wire qnot);
    
assign qnot = ~(q);
    always @(posedge clk)
        begin  
        if(rst)
            q <= 1'b0; 
        else if (en)
            q <= d; 
        end
        
endmodule
