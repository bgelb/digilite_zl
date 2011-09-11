//------------------------------------------------------------------------------
//
// Author: Ben Gelb (ben@gelbnet.com)
//
// Brief Description:
//  Dual-clock FIFO (using Altera dcfifo IP).
//
//---- Detailed Description ----------------------------------------------------
//
//
//
//------------------------------------------------------------------------------

`ifndef _ZL_FIFO_DC_V_
`define _ZL_FIFO_DC_V_

module zl_fifo_dc #
(
    parameter Data_width = 0,
    parameter Addr_width = 0
)
(
    input clk_in,
    input rst_in_n,
    input clk_out,
    //
    input in_req,
    output in_ack,
    input [Data_width-1:0] in_data,
    output in_full,
    output in_empty,
    output [Addr_width-1:0] in_used,
    //
    output out_req,
    input out_ack,
    output [Data_width-1:0] out_data,
    output out_full,
    output out_empty,
    output [Addr_width-1:0] out_used
);

dcfifo #
(
    .intended_device_family("Cyclone IV E"),
    .lpm_numwords(2**Addr_width),
    .lpm_showahead("ON"),
    .lpm_type("dcfifo"),
    .lpm_width(Data_width),
    .lpm_widthu(Data_width),
    .overflow_checking("ON"),
    .rdsync_delaypipe = 4,
    .underflow_checking("ON"),
    .use_eab("ON"),
    .write_aclr_synch("OFF"),
    .wrsync_delaypipe(4)
)
dcfifo_component
(
    .rdclk (clk_out),
    .wrclk (clk_in),
    .wrreq (in_ack),
    .aclr (~rst_n),
    .data (in_data),
    .rdreq (out_ack),
    .wrfull (in_full),
    .q (out_data),
    .rdempty (out_empty),
    .wrusedw (in_used),
    .rdusedw (out_used),
    .rdfull (out_full),
    .wrempty (in_empty)
);

assign in_ack = in_req && !in_full;
assign out_req = !out_empty;

endmodule // zl_fifo_dc

`endif // _ZL_FIFO_DC_V_
