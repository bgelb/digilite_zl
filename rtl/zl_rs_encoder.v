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
//  Reed-Solomon Encoder. Processes one symbol per clock.
//
//------------------------------------------------------------------------------

`ifndef _ZL_RS_ENCODER_V_
`define _ZL_RS_ENCODER_V_

`include "zl_gf_mul.v"

module zl_rs_encoder #
(
    parameter N = 0, // codeword length
    parameter K = 0, // message length
    parameter M = 0, // symbol width
    parameter G_x = 0, // RS generator polynomial
    parameter Gf_poly = 0

)
(
    input clk,
    input rst_n,
    //
    input           data_in_req,
    output          data_in_ack,
    input  [M-1:0]  data_in,
    //
    output          data_out_req,
    input           data_out_ack,
    output [M-1:0]  data_out
);

localparam Gf_width = M;

// unpack G_x vector
reg [M-1:0] g [0:N-K-1];
wire [M*(N-K)-1:0] g_x_packed;

assign g_x_packed = G_x;

integer i;
always @(*) begin
    for(i=0;i<N-K;i=i+1) begin
        g[i] = g_x_packed[M*(i+1)-1-:M];
    end
end

reg [M-1:0] cur_sym_count;
wire cur_sym_is_data;

// stall logic
wire stall;
assign data_out_req = data_in_req;
assign data_in_ack = data_out_ack && cur_sym_is_data;
assign stall = !data_in_ack && !(data_out_ack && !cur_sym_is_data);

// keep symbol counter
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cur_sym_count <= {M{1'b0}};
    end
    else if(!stall && cur_sym_count == N-1) begin
        cur_sym_count <= {M{1'b0}};
    end
    else if(!stall) begin
        cur_sym_count <= cur_sym_count + 1'b1;
    end
end

// is output data or check symbols?
assign cur_sym_is_data = (cur_sym_count < K);

// encoder logic
wire [M-1:0] feedback;
wire [M-1:0] gf_mul_out [0:N-K-1];
reg [M-1:0] rs_check_reg [0:N-K-1];

genvar j;
generate
    for(j=0;j<N-K;j=j+1) begin : gf_mul_blocks
        zl_gf_mul #
        (
            .Gf_width(Gf_width),
            .Gf_poly(Gf_poly)
        )
        gf_mul
        (
            .a(feedback),
            .b(g[j]),
            .out(gf_mul_out[j])
        );
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<N-K;i=i+1) begin
            rs_check_reg[i] <= {M{1'b0}};
        end
    end
    else if(!stall) begin
        rs_check_reg[0] <= gf_mul_out[0];
        for(i=1;i<N-K;i=i+1) begin
            rs_check_reg[i] <= rs_check_reg[i-1] ^ gf_mul_out[i];
        end
    end
end

assign feedback = (cur_sym_is_data ? rs_check_reg[N-K-1] ^ data_in : {M{1'b0}});

// output assignment
assign data_out = (cur_sym_is_data ? data_in : rs_check_reg[N-K-1]);

endmodule // zl_rs_encoder

`endif // _ZL_RS_ENCODER_V_
