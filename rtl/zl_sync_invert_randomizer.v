//------------------------------------------------------------------------------
//
// Author: Ben Gelb (ben@gelbnet.com)
//
// Brief Description:
//  Performs "transport multiplex adaptation" and randomization for DVB-S.
//
//------------------------------------------------------------------------------

`ifndef _ZL_SYNC_INVERT_RANDOMIZER_V_
`define _ZL_SYNC_INVERT_RANDOMIZER_V_

`include "zl_lfsr.v"

module zl_sync_invert_randomizer
(
    input clk,
    input rst_n,
    //
    input               data_in_req,
    output reg          data_in_ack,
    input  [7:0]        data_in,
    //
    output reg          data_out_req,
    input               data_out_ack,
    output reg [7:0]    data_out
);

localparam S_sync_invert = 0;
localparam S_sync_passthru = 1;
localparam S_data = 2;

localparam Sync_byte = 8'h47;
localparam Packet_len = 188;
localparam Group_len = 8;
localparam Packet_len_width = 8;
localparam Group_len_width = 3;

reg [1:0] state_reg;
reg [Packet_len_width-1:0] byte_count;
reg [Group_len_width-1:0] packet_count;

wire prbs_stall;
wire prbs_clear;
wire [7:0] prbs;

zl_lfsr #
(
    .LFSR_poly(16'b1100000000000001),
    .LFSR_width(15),
    .LFSR_init_value(15'b000000010101001),
    .PRBS_width(8)
)
prbs_gen
(
    .clk(clk),
    .rst_n(rst_n),
    //
    .stall(prbs_stall),
    .clear(prbs_clear),
    .lfsr_state(),
    .prbs(prbs)
);

assign prbs_stall = !(data_in_req && data_out_ack &&
                            (state_reg != S_sync_invert));

assign prbs_clear = (byte_count == Packet_len-1)
                        && (packet_count == Group_len-1);


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_reg <= S_sync_invert;
        byte_count <= {Packet_len_width{1'b0}};
        packet_count <= {Group_len_width{1'b0}};
    end
    else begin
        case(state_reg)
            S_sync_invert: begin
                // only start a group of 8 packets if we see a sync byte
                if(data_in_req && data_out_ack && data_in == Sync_byte) begin
                    byte_count <= byte_count + 1'b1;
                    state_reg <= S_data;
                end
            end
            S_sync_passthru: begin
                if(data_in_req && data_out_ack) begin
                    byte_count <= byte_count + 1'b1;
                    state_reg <= S_data;
                end
            end
            S_data: begin
                if(data_in_req && data_out_ack) begin
                    if(byte_count == Packet_len-1) begin
                        if(packet_count == Group_len-1) begin
                            byte_count <= {Packet_len_width{1'b0}};
                            packet_count <= {Group_len_width{1'b0}};
                            state_reg <= S_sync_invert;
                        end
                        else begin
                            byte_count <= {Packet_len_width{1'b0}};
                            packet_count <= packet_count + 1'b1;
                            state_reg <= S_sync_passthru;
                        end
                    end
                    else begin
                        byte_count <= byte_count + 1'b1;
                    end
                end
            end
        endcase
    end
end

always @(*) begin
    case (state_reg)
        S_sync_invert: begin
            data_in_ack = (data_in_req && !(data_in == Sync_byte))
                            || (data_in_req && data_out_ack);
            data_out_req = (data_in_req && (data_in == Sync_byte));
            data_out = ~data_in;
        end
        S_sync_passthru: begin
            data_in_ack = data_in_req && data_out_ack;
            data_out_req = data_in_req;
            data_out = data_in;
        end
        S_data: begin
            data_in_ack = data_in_req && data_out_ack;
            data_out_req = data_in_req;
            data_out = data_in ^ prbs;
        end
    endcase
end

endmodule // zl_sync_invert_randomizer

`endif // _ZL_SYNC_INVERT_RANDOMIZER_V_
