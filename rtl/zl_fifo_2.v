//------------------------------------------------------------------------------
//
// Author: Ben Gelb (ben@gelbnet.com)
//
// Brief Description:
//  Simple FIFO of depth 2.
//
//---- Detailed Description ----------------------------------------------------
//
//
//
//------------------------------------------------------------------------------

`ifndef _ZL_FIFO_2_V_
`define _ZL_FIFO_2_V_

module zl_fifo_2 #
(
    parameter Width = 0
)
(
    input clk,
    input rst_n,
    //
    input  data_in_req,
    output data_in_ack,
    input [Width-1:0] data_in,
    //
    output data_out_req,
    input  data_out_ack,
    output [Width-1:0] data_out
);

reg [Width-1:0] fifo_mem [0:1];

reg [1:0] used;
wire empty;
wire full;

assign empty = (used == 2'b00);
assign full = (used == 2'b10);

// assign outputs
assign data_out_req = (!empty);
assign data_in_ack = (!full && data_in_req);

assign data_out = (full ? fifo_mem[1] : fifo_mem[0]);

// keep used count
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        used <= 2'b00;
    end
    else if(data_in_ack && data_out_ack) begin
        used <= used;
    end
    else if(data_in_ack) begin
        used <= used + 1'b1;
    end
    else if(data_out_ack) begin
        used <= used - 1'b1;
    end
end

// fill fifo_mem
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fifo_mem[0] <= {Width{1'b0}};
        fifo_mem[1] <= {Width{1'b0}};
    end
    else if(data_in_ack) begin
        fifo_mem[0] <= data_in;
        fifo_mem[1] <= fifo_mem[0];
    end
end
endmodule // zl_fifo_2

`endif // _ZL_FIFO_2_V_
