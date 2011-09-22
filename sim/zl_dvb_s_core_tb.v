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

`ifndef _ZL_DVB_S_CORE_TB_V_
`define _ZL_DVB_S_CORE_TB_V_

`timescale 1ns/1ps

module zl_dvb_s_core_tb ();

reg clk;
reg rst_n;

reg [7:0] data_in;
reg       data_in_req;
wire      data_in_ack;

initial begin
    clk = 0;
    forever clk = #10 ~clk;
end

integer infile;
integer outfile;

wire data_out_req;
wire data_out_i;
wire data_out_q;

initial begin
    rst_n = 0;
    data_in_req = 0;
    wait(clk);
    wait(!clk);
    wait(clk);
    wait(!clk);
    wait(clk);
    wait(!clk);
    rst_n = 1;
    infile = $fopen("test.m2v","r");
    data_in = $fgetc(infile);
    while (!$feof(infile)) begin
        data_in_req = 1'b1;
        wait(data_in_ack && clk);
        wait(data_in_ack && !clk);
        data_in = $fgetc(infile);
    end
    data_in_req = 1'b0;
    wait(clk);
    wait(!clk);
    wait(clk);
    wait(!clk);
    wait(clk);
    wait(!clk);
    wait(clk);
    wait(!clk);
    wait(clk);
    wait(!clk);
    wait(clk);
    wait(!clk);
    wait(!data_out_req);
    wait(clk);
    wait(!clk);
    $fclose(infile);
    $fclose(outfile);
    $finish;
end

initial begin
    wait(!rst_n);
    wait(rst_n);
    outfile = $fopen("out.bin", "w");
    while(1) begin
        wait(!clk);
        wait(clk);
        if(data_out_req) begin
            $fwrite(outfile, "%c", data_out_i);
            $fwrite(outfile, "%c", data_out_q);
        end
    end
end

zl_dvb_s_core uut
(
    .clk(clk),
    .rst_n(rst_n),
    //
    .data_in(data_in),
    .data_in_req(data_in_req),
    .data_in_ack(data_in_ack),
    //
    .data_out_i(data_out_i),
    .data_out_q(data_out_q),
    .data_out_req(data_out_req),
    .data_out_ack(data_out_req)
);

endmodule // zl_dvb_s_core_tb

`endif // _ZL_DVB_S_CORE_TB_V_
