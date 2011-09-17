//------------------------------------------------------------------------------
//
// Author: Ben Gelb (ben@gelbnet.com)
//
// Brief Description:
//  Simple 1/2 rate convolutional encoder.
//
//---- Detailed Description ----------------------------------------------------
//
//
//
//------------------------------------------------------------------------------

`ifndef _ZL_CONV_ENCODER_V_
`define _ZL_CONV_ENCODER_V_

module zl_conv_encoder #
(
    parameter I_poly = 0,
    parameter Q_poly = 0,
    parameter K = 0
)
(
    input clk,
    input rst_n,
    //
    input  [7:0]    data_in,
    input           data_in_req,
    output          data_in_ack,
    //
    output data_out_i,
    output data_out_q,
    output data_out_req,
    input  data_out_ack
);

reg [2:0] in_bit_sel;
wire stall;

reg [K-1:0] shift_reg;

always @(*) begin
    shift_reg[K-1] = data_in[in_bit_sel];
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(integer i=0;i<K-1;i=i+1) begin
            shift_reg[i] <= 1'b0;
        end
    end
    else if(!stall) begin
        for(integer i=0;i<K-1;i=i+1) begin
            shift_reg[i] <= shift_reg[i+1];
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        in_bit_sel <= 3'b111; // MSB first
    end
    else if(!stall) begin
        in_bit_sel <= in_bit_sel - 1'b1;
    end
end

assign data_out_req = data_in_req;
assign data_in_ack = data_in_req && (in_bit_sel == 3'b000) && data_out_ack;
assign stall = !(data_in_req && data_out_ack);

assign data_out_i = ^(shift_reg & I_poly);
assign data_out_q = ^(shift_reg & Q_poly);

endmodule // zl_conv_encoder

`endif // _ZL_CONV_ENCODER_V_
