//------------------------------------------------------------------------------
//
// Author: Ben Gelb (ben@gelbnet.com)
//
// Brief Description:
//
//---- Detailed Description ----------------------------------------------------
//
//
//
//------------------------------------------------------------------------------

`ifndef _ZL_TOP_V_
`define _ZL_TOP_V_

`include "generated/zl_sys_pll.v"
`include "zl_dvb_s_core.v"
`include "zl_fifo_dc.v"
`include "zl_usb_fifo.v"
`include "zl_reset_sync.v"

module zl_top
(
    input           ext_clk_50,
    input           ext_rst_button_n,
    //
    input           usb_fifo_rxf_n,
    output          usb_fifo_rd_n,
    input  [7:0]    usb_fifo_data,
    //
    output          dac_clk,
    output          dac_i,
    output          dac_q,
    output          dac_i_pre,
    output          dac_q_pre,
    //
    output [7:0]    debug_led
);

wire clk_50;
wire rst_50_n;
wire clk_dac_tx;
wire sys_pll_locked;

zl_sys_pll sys_pll
(
    .areset(~ext_rst_button_n),
    .inclk0(ext_clk_50),
    .c0(clk_50),
    .c1(clk_dac_tx),
    .locked(sys_pll_locked)
);

zl_reset_sync sys_reset_sync
(
    .clk(clk_50),
    .in_rst_n(ext_rst_button_n & sys_pll_locked),
    .out_rst_n(rst_50_n)
);

// USB FIFO interface
wire usb_fifo_out_req;
wire usb_fifo_out_ack;
wire [7:0] usb_fifo_out_data;

zl_usb_fifo usb_fifo
(
    .clk(clk_50),
    .rst_n(rst_50_n),
    //
    .usb_fifo_rxf_n(usb_fifo_rxf_n),
    .usb_fifo_rd_n(usb_fifo_rd_n),
    .usb_fifo_data(usb_fifo_data),
    //
    .usb_fifo_out_req(usb_fifo_out_req),
    .usb_fifo_out_ack(usb_fifo_out_ack),
    .usb_fifo_out_data(usb_fifo_out_data)
);

// DVB-S core
wire core_data_out_i;
wire core_data_out_q;
wire core_data_out_req;
wire core_data_out_ack;

zl_dvb_s_core dvb_s_core
(
    .clk(clk_50),
    .rst_n(rst_50_n),
    //
    .data_in(usb_fifo_out_data),
    .data_in_req(usb_fifo_out_req),
    .data_in_ack(usb_fifo_out_ack),
    //
    .data_out_i(core_data_out_i),
    .data_out_q(core_data_out_q),
    .data_out_req(core_data_out_req),
    .data_out_ack(core_data_out_ack)
);

// system -> sample rate clock domain crossing
wire sample_out_valid;
wire sample_out_i;
wire sample_out_q;

zl_fifo_dc #
(
    .Data_width(2),
    .Addr_width(2)
)
sample_fifo
(
    .clk_in(clk_50),
    .rst_in_n(rst_50_n),
    .clk_out(clk_dac_tx),
    //
    .in_req(core_data_out_req),
    .in_ack(core_data_out_ack),
    .in_data({core_data_out_i,core_data_out_q}),
    .in_full(),
    .in_empty(),
    .in_used(),
    //
    .out_req(sample_out_valid),
    .out_ack(sample_out_valid),
    .out_data({sample_out_i,sample_out_q}),
    .out_full(),
    .out_empty(),
    .out_used()
);

// create 1-cycle delayed copy and assign outputs
reg sample_out_i_d1;
reg sample_out_q_d1;

always @(posedge clk_dac_tx) begin
    sample_out_i_d1 <= sample_out_i;
    sample_out_q_d1 <= sample_out_q;
end

assign dac_clk = ~clk_dac_tx; // (inverted to center-align clock w/ data)
assign dac_i_pre = sample_out_i;
assign dac_q_pre = sample_out_q;
assign dac_i = sample_out_i_d1;
assign dac_q = sample_out_q_d1;

// Debugging LEDs
localparam Heartbeat_period = 25000000; // 500ms @ 50 MHz
localparam Heartbeat_count_width = 25;
reg [Heartbeat_count_width-1:0] heartbeat_count;
reg heartbeat_state;

assign debug_led[7:2] = 6'b0;
assign debug_led[0] = heartbeat_state;
assign debug_led[1] = sample_out_valid;

always @(posedge clk_50 or negedge rst_50_n) begin
    if(!rst_50_n) begin
        heartbeat_state <= 1'b0;
        heartbeat_count <= {Heartbeat_count_width{1'b0}};
    end
    else begin
        if(heartbeat_count == Heartbeat_period-1) begin
            heartbeat_count <= {Heartbeat_count_width{1'b0}};
            heartbeat_state <= ~heartbeat_state;
        end
        else begin
            heartbeat_count <= heartbeat_count + 1'b1;
        end
    end
end

endmodule // zl_top

`endif // _ZL_TOP_V_
