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
//  Quick and dirty test harness for zl_top (including FT2232 interfacing).
//
//------------------------------------------------------------------------------

`ifndef _ZL_TOP_TB_V_
`define _ZL_TOP_TB_V_

`timescale 1ns/1ps

module zl_top_tb ();

reg clk;
reg rst_n;

initial begin
    clk = 0;
    forever clk = #10 ~clk;
end

integer infile;
integer outfile;

reg usb_fifo_rxf_n;
reg [7:0] usb_fifo_data;
wire usb_fifo_rd_n;

reg [7:0] next_data;

wire dac_clk;
wire dac_i_pre;
wire dac_q_pre;

initial begin
    rst_n = 0;
    usb_fifo_rxf_n = 1;
    usb_fifo_data = 8'bx;
    wait(clk);
    wait(!clk);
    wait(clk);
    wait(!clk);
    wait(clk);
    wait(!clk);
    rst_n = 1;
    outfile = $fopen("out.bin", "w");
    infile = $fopen("test.m2v","r");
    next_data = $fgetc(infile);
    while (!$feof(infile)) begin
        usb_fifo_rxf_n = 1'b0;
        wait(!usb_fifo_rd_n);
        #1;
        usb_fifo_data = next_data;
        wait(usb_fifo_rd_n);
        #1;
        usb_fifo_data = 8'bx;
        usb_fifo_rxf_n = 1'b1;
        #49;
        next_data = $fgetc(infile);
    end
    wait(!uut.sample_out_valid);
    wait(clk);
    wait(!clk);
    wait(clk);
    $fclose(infile);
    $fclose(outfile);
    $finish;
end

always @(posedge dac_clk) begin
    if(uut.sample_out_valid) begin
        $fwrite(outfile, "%c", dac_i_pre);
        $fwrite(outfile, "%c", dac_q_pre);
    end
end

zl_top uut
(
    .ext_clk_50(clk),
    .ext_rst_button_n(rst_n),
    //
    .usb_fifo_rxf_n(usb_fifo_rxf_n),
    .usb_fifo_rd_n(usb_fifo_rd_n),
    .usb_fifo_data(usb_fifo_data),
    //
    .dac_clk(dac_clk),
    .dac_i(),
    .dac_q(),
    .dac_i_pre(dac_i_pre),
    .dac_q_pre(dac_q_pre),
    //
    .debug_led()
);

endmodule // zl_top_tb

`endif // _ZL_TOP_TB_V_
