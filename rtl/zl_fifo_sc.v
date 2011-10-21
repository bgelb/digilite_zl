//------------------------------------------------------------------------------
//
// Author: Ben Gelb (ben@gelbnet.com)
//
// Brief Description:
//  Single-clock FIFO (using Altera scfifo IP).
//
//------------------------------------------------------------------------------

`ifndef _ZL_FIFO_SC_V_
`define _ZL_FIFO_SC_V_

module zl_fifo_sc #
(
    parameter Data_width = 0,
    parameter Addr_width = 0
)
(
    input clk,
    input rst_n,
    //
    input in_req,
    output in_ack,
    input [Data_width-1:0] in_data,
    //
    output out_req,
    input out_ack,
    output [Data_width-1:0] out_data,
    //
    output full,
    output empty,
    output [Addr_width-1:0] used
);

scfifo #
(
    .add_ram_output_register("ON"),
    .intended_device_family("Cyclone IV E"),
    .lpm_numwords(2**Addr_width),
    .lpm_showahead("ON"),
    .lpm_type("scfifo"),
    .lpm_width(Data_width),
    .lpm_widthu(Addr_width),
    .overflow_checking("ON"),
    .underflow_checking("ON"),
    .use_eab("ON")
)
scfifo_component
(
    .clock (clk),
    .wrreq (in_ack),
    .aclr (~rst_n),
    .data (in_data),
    .rdreq (out_ack),
    .full (full),
    .q (out_data),
    .empty (empty),
    .usedw (used),
    .almost_full(),
    .almost_empty(),
    .sclr()
);

assign in_ack = in_req && !full;
assign out_req = !empty;

endmodule // zl_fifo_sc

`endif // _ZL_FIFO_SC_V_
