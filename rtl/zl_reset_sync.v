//------------------------------------------------------------------------------
//
// Copyright 2011, Benjamin Gelb. All Rights Reserved.
// See LICENSE file for copying permission.
//
//------------------------------------------------------------------------------
//
// Author: Ben Gelb (ben@gelbnet.com)
//
// Brief Description:
//   Basic reset synchronizer, w/ async assert and sync de-assert. 
//
//---- Detailed Description ----------------------------------------------------
//
//  See:
//
//  C. Cummings, D. Mills, and S. Golson, “Asynchronous & synchronous reset 
//   design techniques - Part deux,”  Synopsys User Group (SNUG), User papers,
//   Boston, USA, Sept. 2003.
//
//------------------------------------------------------------------------------

`ifndef _ZL_RESET_SYNC_V_
`define _ZL_RESET_SYNC_V_

module zl_reset_sync
(
    input  clk,
    input  in_rst_n,
    output out_rst_n
);

reg [1:0] ff;

always @(posedge clk or negedge in_rst_n) begin
    if(!in_rst_n) begin
        ff[1] <= 1'b0;
        ff[0] <= 1'b0;
    end
    else begin
        ff[1] <= 1'b1;
        ff[0] <= ff[1];
    end
end

assign out_rst_n = ff[0];

endmodule // zl_reset_sync

`endif // _ZL_RESET_SYNC_V_
