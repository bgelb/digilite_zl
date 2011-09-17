//------------------------------------------------------------------------------
//
// Author: Ben Gelb (ben@gelbnet.com)
//
// Brief Description:
//  DVB-S encoding pipeline.
//
//---- Detailed Description ----------------------------------------------------
//
//
//
//------------------------------------------------------------------------------

`ifndef _ZL_DVB_S_CORE_V_
`define _ZL_DVB_S_CORE_V_

`include "zl_fifo_sc.v"
`include "zl_sync_invert_randomizer.v"
`include "zl_fifo_2.v"
`include "zl_rs_encoder.v"
`include "zl_interleaver.v"
`include "zl_conv_encoder.v"

module zl_dvb_s_core
(
    input clk,
    input rst_n,
    //
    input [7:0] data_in,
    input       data_in_req,
    output      data_in_ack,
    //
    output data_out_i,
    output data_out_q,
    output data_out_req,
    input  data_out_ack
);

wire input_buffer_req;
wire input_buffer_ack;
wire [7:0] input_buffer_data;

zl_fifo_sc #
(
    .Data_width(8),
    .Addr_width(8), // 256 bytes
)
input_buffer
(
    .clk(clk),
    .rst_n(rst_n),
    //
    .in_req(data_in_req),
    .in_ack(data_in_ack),
    .in_data(data_in),
    //
    .out_req(input_buffer_req),
    .out_ack(input_buffer_ack),
    .out_data(input_buffer_data),
    //
    .full(),
    .empty(),
    .used()
    
);

wire randomizer_req;
wire randomizer_ack;
wire [7:0] randomizer_data;

zl_sync_invert_randomizer sync_invert_randomizer
(
    .clk(clk),
    .rst_n(rst_n),
    //
    .data_in_req(input_buffer_req),
    .data_in_ack(input_buffer_ack),
    .data_in(input_buffer_data),
    //
    .data_out_req(randomizer_req),
    .data_out_ack(randomizer_ack),
    .data_out(randomizer_data)
);

wire randomizer_req;
wire randomizer_ack;
wire [7:0] randomizer_data;

zl_fifo_2 #
(
    .Width(8)
)
randomizer_fifo
(
    .clk(clk),
    .rst_n(rst_n),
    //
    .data_in_req(randomizer_req),
    .data_in_ack(randomizer_ack),
    .data_in(randomizer_data),
    //
    .data_out_req(randomizer_fifo_req),
    .data_out_ack(randomizer_fifo_ack),
    .data_out(randomizer_fifo_data)
);

wire rs_encoder_req;
wire rs_encoder_ack;
wire [7:0] rs_encoder_data;

zl_rs_encoder #
(
    .N(204),
    .K(188),
    .M(8),
    .G_x({
        8'd118,
        8'd52,
        8'd103,
        8'd31,
        8'd104,
        8'd126,
        8'd187,
        8'd232,
        8'd17,
        8'd56,
        8'd100,
        8'd81,
        8'd44,
        8'd79
    }),
    .Gf_poly(9'd285)
)
rs_encoder
(
    .clk(clk),
    .rst_n(rst_n),
    //
    .data_in_req(randomizer_fifo_req),
    .data_in_ack(randomizer_fifo_ack),
    .data_in(randomizer_fifo_data),
    //
    .data_out_req(rs_encoder_req),
    .data_out_ack(rs_encoder_ack),
    .data_out(rs_encoder_data)
);

wire rs_encoder_fifo_req;
wire rs_encoder_fifo_ack;
wire [7:0] rs_encoder_fifo_data;

zl_fifo_2 #
(
    .Width(8)
)
rs_encoder_fifo
(
    .clk(clk),
    .rst_n(rst_n),
    //
    .data_in_req(rs_encoder_req),
    .data_in_ack(rs_encoder_ack),
    .data_in(rs_encoder_data),
    //
    .data_out_req(rs_encoder_fifo_req),
    .data_out_ack(rs_encoder_fifo_ack),
    .data_out(rs_encoder_fifo_data)
);

wire interleaver_req;
wire interleaver_ack;
wire [7:0] interleaver_data;

zl_interleaver interleaver
(
    .clk(clk),
    .rst_n(rst_n),
    //
    .data_in_req(rs_encoder_fifo_req),
    .data_in_ack(rs_encoder_fifo_ack),
    .data_in(rs_encoder_fifo_data),
    //
    .data_out_req(interleaver_req),
    .data_out_ack(interleaver_ack),
    .data_out(interleaver_data)
);

wire interleaver_fifo_req;
wire interleaver_fifo_ack;
wire [7:0] interleaver_fifo_data;

zl_fifo_2 #
(
    .Width(8)
)
interleaver_fifo
(
    .clk(clk),
    .rst_n(rst_n),
    //
    .data_in_req(interleaver_req),
    .data_in_ack(interleaver_ack),
    .data_in(interleaver_data),
    //
    .data_out_req(interleaver_fifo_req),
    .data_out_ack(interleaver_fifo_ack),
    .data_out(interleaver_fifo_data)
);

wire conv_encoder_req;
wire conv_encoder_ack;
wire conv_encoder_data_i;
wire conv_encoder_data_q;

zl_conv_encoder #
(
    .I_poly(7'o171),
    .Q_poly(7'o133),
    .K(7)
)
conv_encoder
(
    .clk(clk),
    .rst_n(rst_n),
    //
    .data_in_req(interleaver_fifo_req),
    .data_in_ack(interleaver_fifo_ack),
    .data_in(interleaver_fifo_data),
    //
    .data_out_req(conv_encoder_req),
    .data_out_ack(conv_encoder_ack),
    .data_out_i(conv_encoder_data_i),
    .data_out_q(conv_encoder_data_q)
);

zl_fifo_2 #
(
    .Width(2)
)
conv_encoder_fifo
(
    .clk(clk),
    .rst_n(rst_n),
    //
    .data_in_req(conv_encoder_req),
    .data_in_ack(conv_encoder_ack),
    .data_in({conv_encoder_data_i,
                conv_encoder_data_q}),
    //
    .data_out_req(data_out_req),
    .data_out_ack(data_out_ack),
    .data_out({data_out_i,
                data_out_q})
);

endmodule // zl_dvb_s_core

`endif // _ZL_DVB_S_CORE_V_
