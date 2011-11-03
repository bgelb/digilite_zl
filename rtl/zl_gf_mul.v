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
//  Galois Field multiplier.
//
//------------------------------------------------------------------------------

`ifndef _ZL_GF_MUL_V_
`define _ZL_GF_MUL_V_

module zl_gf_mul #
(
    parameter Gf_width = 0,
    parameter Gf_poly = 0
)
(
    input  [Gf_width-1:0] a,
    input  [Gf_width-1:0] b,
    output [Gf_width-1:0] out
);

// compute a*b
function [Gf_width*2-2:0] a_conv_b;
    input [Gf_width-1:0] a;
    input [Gf_width-1:0] b;
    //
    reg [Gf_width*2-2:0] retval;
    integer i,j;
    begin
        retval = 0;
        for(i=0;i<Gf_width*2-1;i=i+1) begin
            for(j=0;j<Gf_width;j=j+1) begin
                if(i>=j && i-j<Gf_width) begin
                    retval[i] = retval[i] ^ (a[j]&b[i-j]);
                end
            end
        end
        a_conv_b = retval;
    end
endfunction

// mod by gf poly
function [Gf_width-1:0] mod_gf;
    input [Gf_width*2-2:0] f;
    //
    reg [Gf_width-1:0] retval;
    integer i;
    begin
        retval = 0;
        for(i=0;i<Gf_width*2-1;i=i+1) begin
            retval =
                {retval[Gf_width-2:0], f[Gf_width*2-2-i]}
                    ^ ({Gf_width{retval[Gf_width-1]}}
                        & Gf_poly[Gf_width-1:0]);
        end

        mod_gf = retval;
    end
endfunction

assign out = mod_gf(a_conv_b(a,b));

endmodule // zl_gf_mul

`endif // _ZL_GF_MUL_V_
