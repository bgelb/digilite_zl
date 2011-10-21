//------------------------------------------------------------------------------
//
// Author: Ben Gelb (ben@gelbnet.com)
//
// Brief Description:
//  DVB interleaver.
//
//------------------------------------------------------------------------------

`ifndef _ZL_INTERLEAVER_V_
`define _ZL_INTERLEAVER_V_

`include "zl_fifo_sc.v"
`include "zl_sdp_ram.v"

module zl_interleaver
(
    input clk,
    input rst_n,
    //
    input           data_in_req,
    output          data_in_ack,
    input  [7:0]    data_in,
    //
    output          data_out_req,
    input           data_out_ack,
    output [7:0]    data_out
);

localparam Ptr_width = 8; // max fifo size = 17x11=187
localparam N_ptrs = 12;
localparam N_ptrs_width = 4;
localparam Packet_len = 204;
localparam Packet_len_width = 8;

localparam Sync_byte = 8'h47;

reg [Packet_len_width-1:0] packet_byte_count;

reg [Ptr_width-1:0] rd_ptr [0:N_ptrs-1];
reg [Ptr_width-1:0] wr_ptr [0:N_ptrs-1];
reg [N_ptrs_width-1:0] ptr_select;

wire data_fifo_out_req;
wire token_fifo_out_req;

wire token_fifo_in_req;
wire token_fifo_in_ack;

wire data_fifo_in_req;
wire [7:0] data_fifo_in;

reg data_in_ack_d1;
reg data_in_ack_d2;
reg [7:0] data_in_d1;
reg [7:0] data_in_d2;

wire [(N_ptrs_width+Ptr_width)-1:0] mem_rd_addr;
wire [(N_ptrs_width+Ptr_width)-1:0] mem_wr_addr;

wire [7:0] mem_rd_data;
wire [7:0] mem_rd_data_fixed;

wire mem_wr_en;

wire rd_wr_conflict;
reg rd_wr_conflict_d1;
reg rd_wr_conflict_d2;

zl_fifo_sc #
(
    .Data_width(8),
    .Addr_width(2)
)
data_fifo
(
    .clk(clk),
    .rst_n(rst_n),
    //
    .in_req(data_fifo_in_req),
    .in_ack(),
    .in_data(data_fifo_in),
    //
    .out_req(data_fifo_out_req),
    .out_ack(data_out_ack),
    .out_data(data_out),
    //
    .full(),
    .empty(),
    .used()
);

zl_fifo_sc #
(
    .Data_width(1),
    .Addr_width(2)
)
token_fifo
(
    .clk(clk),
    .rst_n(rst_n),
    //
    .in_req(token_fifo_in_req),
    .in_ack(token_fifo_in_ack),
    .in_data(1'b0),
    //
    .out_req(token_fifo_out_req),
    .out_ack(data_out_ack),
    .out_data(),
    //
    .full(),
    .empty(),
    .used()
);

zl_sdp_ram #
(
    .Write_data_width(8),
    .Write_addr_width(N_ptrs_width+Ptr_width),
    .Read_data_width(8),
    .Read_addr_width(N_ptrs_width+Ptr_width)
)
interleave_mem
(
    .clk_wr(clk),
    .clk_rd(clk),
    //
    .wr_addr(mem_wr_addr),
    .wr_data(data_in),
    .wr_en(mem_wr_en),
    //
    .rd_addr(mem_rd_addr),
    .rd_data(mem_rd_data)
);

// delayed copies of signals to align with BRAM read latency
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_in_ack_d1 <= 1'b0;
        data_in_ack_d2 <= 1'b0;
        //
        data_in_d1 <= 8'b0;
        data_in_d2 <= 8'b0;
        //
        rd_wr_conflict_d1 <= 1'b0;
        rd_wr_conflict_d2 <= 1'b0;
    end
    else begin
        data_in_ack_d1 <= data_in_ack;
        data_in_ack_d2 <= data_in_ack_d1;
        //
        data_in_d1 <= data_in;
        data_in_d2 <= data_in_d1;
        //
        rd_wr_conflict_d1 <= rd_wr_conflict;
        rd_wr_conflict_d2 <= rd_wr_conflict_d1;
    end
end

// addressing into the memory
assign mem_wr_addr = {ptr_select, wr_ptr[ptr_select]};
assign mem_rd_addr = {ptr_select, rd_ptr[ptr_select]};
assign mem_wr_en = data_in_ack;

// if we read the same location we are writing, we want to new value
// this logic bypasses the memory in this case
assign rd_wr_conflict = mem_wr_en && (mem_wr_addr == mem_rd_addr);
assign mem_rd_data_fixed = (rd_wr_conflict_d2 ? data_in_d2 : mem_rd_data);

// two output of the same depth - a data fifo and a token fifo
// the token fifo gets a "token" placed in it when new data_in
// is accepted, and is responsible for providing backpressure.
assign data_out_req = token_fifo_out_req && data_fifo_out_req;
assign token_fifo_in_req = data_in_req;
assign data_in_ack = token_fifo_in_ack;

// the data fifo gets data placed in it 2 cycles after the token
// fifo (BRAM read latency).
assign data_fifo_in_req = data_in_ack_d2;
assign data_fifo_in = mem_rd_data_fixed;

// keep track of the pointers - rd and wr pointers are kept a fixed
// distance apart to create the necessary delay in the arm of the
// interleaver. Note that the size of the ring buffer (256) is the same
// in all cases - what matters is the delta between pointers, not the buffer
// size (as long as it is larger than the desired delay).
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ptr_select <= {N_ptrs_width{1'b0}};

        rd_ptr[0] <= {Ptr_width{1'b0}};
        rd_ptr[1] <= {Ptr_width{1'b0}};
        rd_ptr[2] <= {Ptr_width{1'b0}};
        rd_ptr[3] <= {Ptr_width{1'b0}};
        rd_ptr[4] <= {Ptr_width{1'b0}};
        rd_ptr[5] <= {Ptr_width{1'b0}};
        rd_ptr[6] <= {Ptr_width{1'b0}};
        rd_ptr[7] <= {Ptr_width{1'b0}};
        rd_ptr[8] <= {Ptr_width{1'b0}};
        rd_ptr[9] <= {Ptr_width{1'b0}};
        rd_ptr[10] <= {Ptr_width{1'b0}};
        rd_ptr[11] <= {Ptr_width{1'b0}};

        wr_ptr[0] <= 0;
        wr_ptr[1] <= 17;
        wr_ptr[2] <= 17*2;
        wr_ptr[3] <= 17*3;
        wr_ptr[4] <= 17*4;
        wr_ptr[5] <= 17*5;
        wr_ptr[6] <= 17*6;
        wr_ptr[7] <= 17*7;
        wr_ptr[8] <= 17*8;
        wr_ptr[9] <= 17*9;
        wr_ptr[10] <= 17*10;
        wr_ptr[11] <= 17*11;
        
        packet_byte_count <= {Packet_len_width{1'b0}}; 
    end
    else if(data_in_ack) begin
        if(packet_byte_count == 0 &&
            !(data_in == Sync_byte || data_in == ~Sync_byte)) begin
            // if we get off sync (datastream got messed up)
            // then wait here and make sure the next sync byte
            // ends up in the 0th arm of the interleaver
            ptr_select <= {N_ptrs_width{1'b0}};
        end
        else begin
            if(packet_byte_count == Packet_len-1) begin
                packet_byte_count <= {Packet_len_width{1'b0}};
            end
            else begin
                packet_byte_count <= packet_byte_count + 1'b1;
            end
            //
            if(ptr_select == N_ptrs-1) begin
                ptr_select <= {N_ptrs_width{1'b0}};
            end
            else begin
                ptr_select <= ptr_select + 1'b1;
            end
            //
            rd_ptr[ptr_select] <= rd_ptr[ptr_select] + 1'b1;
            wr_ptr[ptr_select] <= wr_ptr[ptr_select] + 1'b1;
        end
    end
end

endmodule // zl_interleaver

`endif // _ZL_INTERLEAVER_V_
