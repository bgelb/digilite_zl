//------------------------------------------------------------------------------
//
// Author: Ben Gelb (ben@gelbnet.com)
//
// Brief Description:
//  Parallelized LFSR w/ PRBS vector. PRBS goes from MSb -> LSb.
//
//------------------------------------------------------------------------------

`ifndef _ZL_LFSR_V_
`define _ZL_LFSR_V_

module zl_lfsr #
(
    parameter LFSR_poly = 0,
    parameter LFSR_width = 0,
    parameter LFSR_init_value = 0,
    parameter PRBS_width = 0
)
(
    input clk,
    input rst_n,
    //
    input stall,
    input clear,
    output [LFSR_width-1:0] lfsr_state,
    output [PRBS_width-1:0] prbs
);

reg [LFSR_width-1:0] state_reg;
reg [LFSR_width-1:0] state_next;
reg [PRBS_width-1:0] prbs_internal;

integer i;

function [LFSR_width-1:0] lfsr_state_next_serial;
    input [LFSR_width-1:0] cur_state;
    begin
        lfsr_state_next_serial = {cur_state[LFSR_width-2:0],
                                    ^(cur_state & LFSR_poly[LFSR_width:1])};
    end
endfunction

always @(*) begin
    state_next = state_reg;
    for(i=0;i<PRBS_width;i=i+1) begin
       state_next = lfsr_state_next_serial(state_next);
        prbs_internal[PRBS_width-i-1] = state_next[0]; 
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_reg <= LFSR_init_value;
    end
    else if (clear && !stall) begin
        state_reg <= LFSR_init_value;
    end
    else if (!stall) begin
        state_reg <= state_next;
    end
end

assign lfsr_state = state_reg;
assign prbs = prbs_internal;

endmodule // zl_lfsr

`endif // _ZL_LFSR_V_
