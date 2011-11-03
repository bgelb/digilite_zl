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
//  Simple-dual-port block memory (using Altera block memory).
//  2-cycle pipeline delay on reads.
//
//------------------------------------------------------------------------------

`ifndef _ZL_SDP_RAM_V_
`define _ZL_SDP_RAM_V_

module zl_sdp_ram #
(
    parameter Write_data_width = 0,
    parameter Write_addr_width = 0,
    parameter Read_data_width = 0,
    parameter Read_addr_width = 0
)
(
    input clk_wr,
    input clk_rd,
    //
    input [Write_addr_width-1:0] wr_addr,
    input [Write_data_width-1:0] wr_data,
    input wr_en,
    //
    input [Read_addr_width-1:0] rd_addr,
    output [Read_data_width-1:0] rd_data
);

altsyncram #
(
    .address_aclr_b("NONE"),
    .address_reg_b("CLOCK1"),
    .clock_enable_input_a("BYPASS"),
    .clock_enable_input_b("BYPASS"),
    .clock_enable_output_b("BYPASS"),
    .intended_device_family("Cyclone IV E"),
    .lpm_type("altsyncram"),
    .numwords_a(2**Write_addr_width),
    .numwords_b(2**Read_addr_width),
    .operation_mode("DUAL_PORT"),
    .outdata_aclr_b("NONE"),
    .outdata_reg_b("CLOCK1"),
    .power_up_uninitialized("FALSE"),
    .ram_block_type("M9K"),
    .widthad_a(Write_addr_width),
    .widthad_b(Read_addr_width),
    .width_a(Write_data_width),
    .width_b(Read_data_width),
    .width_byteena_a(1)
)
altsyncram_component
(
    .address_a (wr_addr),
    .clock0 (clk_wr),
    .data_a (wr_data),
    .wren_a (wr_en),
    .address_b (rd_addr),
    .clock1 (clk_rd),
    .q_b (rd_data),
    .aclr0 (1'b0),
    .aclr1 (1'b0),
    .addressstall_a (1'b0),
    .addressstall_b (1'b0),
    .byteena_a (1'b1),
    .byteena_b (1'b1),
    .clocken0 (1'b1),
    .clocken1 (1'b1),
    .clocken2 (1'b1),
    .clocken3 (1'b1),
    .data_b ({8{1'b1}}),
    .eccstatus (),
    .q_a (),
    .rden_a (1'b1),
    .rden_b (1'b1),
    .wren_b (1'b0)
);

endmodule // zl_sdp_ram

`endif // _ZL_SDP_RAM_V_
