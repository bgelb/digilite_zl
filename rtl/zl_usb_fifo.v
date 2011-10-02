//------------------------------------------------------------------------------
//
// Author: Ben Gelb (ben@gelbnet.com)
//
// Brief Description:
//  Interface with the FT2232H USB device in async RS245 FIFO mode.
//
//---- Detailed Description ----------------------------------------------------
//
//
//
//------------------------------------------------------------------------------

`ifndef _ZL_USB_FIFO_V_
`define _ZL_USB_FIFO_V_

module zl_usb_fifo
(
    input clk,
    input rst_n,
    //
    input        usb_fifo_rxf_n,
    output reg   usb_fifo_rd_n,
    input  [7:0] usb_fifo_data,
    //
    output       usb_fifo_out_req,
    input        usb_fifo_out_ack,
    output [7:0] usb_fifo_out_data
);

reg usb_fifo_rxf_n_d1;
reg usb_fifo_rxf_n_d2;

reg [7:0] usb_fifo_data_d1;
reg [7:0] usb_fifo_data_d2;

// synchronize usb_fifo_rxf_n into main clk domain
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        usb_fifo_rxf_n_d1 <= 1'b1;
        usb_fifo_rxf_n_d2 <= 1'b1;
        //
        usb_fifo_data_d1 <= 8'b0;
        usb_fifo_data_d2 <= 8'b0;
    end
    else begin
        usb_fifo_rxf_n_d1 <= usb_fifo_rxf_n;
        usb_fifo_rxf_n_d2 <= usb_fifo_rxf_n_d1;
        //
        usb_fifo_data_d1 <= usb_fifo_data;
        usb_fifo_data_d2 <= usb_fifo_data_d1;
    end
end

// main state machine
localparam S_wait_for_rxf = 0;
localparam S_assert_rd = 1;
localparam S_data_sync_wait_1 = 2;
localparam S_data_sync_wait_2 = 3;
localparam S_capture_data = 4;
localparam S_wait_rxf_sync_flush_1 = 5;
localparam S_wait_rxf_sync_flush_2 = 6;

reg [2:0] fifo_state;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fifo_state <= S_wait_for_rxf;
    end
    else begin
        case (fifo_state)
            S_wait_for_rxf: begin
                if(!usb_fifo_rxf_n_d2) begin
                    fifo_state <= S_assert_rd;
                end
            end
            S_assert_rd: begin
                fifo_state <= S_data_sync_wait_1;
            end
            S_data_sync_wait_1: begin
                fifo_state <= S_data_sync_wait_2;
            end
            S_data_sync_wait_2: begin
                fifo_state <= S_capture_data;
            end
            S_capture_data: begin
                if(usb_fifo_out_ack) begin
                    fifo_state <= S_wait_rxf_sync_flush_1;
                end
            end
            S_wait_rxf_sync_flush_1: begin
                fifo_state <= S_wait_rxf_sync_flush_2;
            end
            S_wait_rxf_sync_flush_2: begin
                fifo_state <= S_wait_for_rxf;
            end
        endcase
    end
end

assign usb_fifo_out_req = (fifo_state == S_capture_data);
assign usb_fifo_out_data = usb_fifo_data_d2; 

// not really a fan of "stateful" FSM outputs - but in this case
// want to make sure that usb_fifo_rd_n is driven by a register
// so there aren't any glitches in the output
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        usb_fifo_rd_n <= 1'b1;
    end
    else begin
        if(fifo_state == S_wait_for_rxf && !usb_fifo_rxf_n_d2) begin
            usb_fifo_rd_n <= 1'b0;
        end
        else if(fifo_state == S_capture_data && usb_fifo_out_ack) begin
            usb_fifo_rd_n <= 1'b1;
        end
    end
end

endmodule // zl_usb_fifo

`endif // _ZL_USB_FIFO_V_
