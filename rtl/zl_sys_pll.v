//------------------------------------------------------------------------------
//
// Author: Ben Gelb (ben@gelbnet.com)
//
// Brief Description:
//  PLL for generating system and TX sample clocks.
//
//------------------------------------------------------------------------------

`ifndef _ZL_SYS_PLL_V_
`define _ZL_SYS_PLL_V_

module zl_sys_pll
(
    input clk_ref,
    input rst_n,
    //
    output clk_sys,
    output clk_sample,
    //
    output lock
);

wire [4:0] pll_out;

assign clk_sys = pll_out[0];
assign clk_sample = pll_out[1];

altpll #
(
    .bandwidth_type("AUTO"),
    .clk0_divide_by(1),
    .clk0_duty_cycle(50),
    .clk0_multiply_by(1),
    .clk0_phase_shift("0"),
    .clk1_divide_by(25),
    .clk1_duty_cycle(50),
    .clk1_multiply_by(2),
    .clk1_phase_shift("0"),
    .compensate_clock("CLK0"),
    .inclk0_input_frequency(20000),
    .intended_device_family("Cyclone IV E"),
    .lpm_type("altpll"),
    .operation_mode("NORMAL"),
    .pll_type("AUTO"),
    .port_activeclock("PORT_UNUSED"),
    .port_areset("PORT_USED"),
    .port_clkbad0("PORT_UNUSED"),
    .port_clkbad1("PORT_UNUSED"),
    .port_clkloss("PORT_UNUSED"),
    .port_clkswitch("PORT_UNUSED"),
    .port_configupdate("PORT_UNUSED"),
    .port_fbin("PORT_UNUSED"),
    .port_inclk0("PORT_USED"),
    .port_inclk1("PORT_UNUSED"),
    .port_locked("PORT_USED"),
    .port_pfdena("PORT_UNUSED"),
    .port_phasecounterselect("PORT_UNUSED"),
    .port_phasedone("PORT_UNUSED"),
    .port_phasestep("PORT_UNUSED"),
    .port_phaseupdown("PORT_UNUSED"),
    .port_pllena("PORT_UNUSED"),
    .port_scanaclr("PORT_UNUSED"),
    .port_scanclk("PORT_UNUSED"),
    .port_scanclkena("PORT_UNUSED"),
    .port_scandata("PORT_UNUSED"),
    .port_scandataout("PORT_UNUSED"),
    .port_scandone("PORT_UNUSED"),
    .port_scanread("PORT_UNUSED"),
    .port_scanwrite("PORT_UNUSED"),
    .port_clk0("PORT_USED"),
    .port_clk1("PORT_USED"),
    .port_clk2("PORT_UNUSED"),
    .port_clk3("PORT_UNUSED"),
    .port_clk4("PORT_UNUSED"),
    .port_clk5("PORT_UNUSED"),
    .port_clkena0("PORT_UNUSED"),
    .port_clkena1("PORT_UNUSED"),
    .port_clkena2("PORT_UNUSED"),
    .port_clkena3("PORT_UNUSED"),
    .port_clkena4("PORT_UNUSED"),
    .port_clkena5("PORT_UNUSED"),
    .port_extclk0("PORT_UNUSED"),
    .port_extclk1("PORT_UNUSED"),
    .port_extclk2("PORT_UNUSED"),
    .port_extclk3("PORT_UNUSED"),
    .self_reset_on_loss_lock("OFF"),
    .width_clock(5)
)
zl_sys_pll_inst
(
    .areset (~rst_n),
    .inclk ({1'b0, clk_ref}),
    .clk (pll_out),
    .locked (lock),
    .activeclock (),
    .clkbad (),
    .clkena ({6{1'b1}}),
    .clkloss (),
    .clkswitch (1'b0),
    .configupdate (1'b0),
    .enable0 (),
    .enable1 (),
    .extclk (),
    .extclkena ({4{1'b1}}),
    .fbin (1'b1),
    .fbmimicbidir (),
    .fbout (),
    .fref (),
    .icdrclk (),
    .pfdena (1'b1),
    .phasecounterselect ({4{1'b1}}),
    .phasedone (),
    .phasestep (1'b1),
    .phaseupdown (1'b1),
    .pllena (1'b1),
    .scanaclr (1'b0),
    .scanclk (1'b0),
    .scanclkena (1'b1),
    .scandata (1'b0),
    .scandataout (),
    .scandone (),
    .scanread (1'b0),
    .scanwrite (1'b0),
    .sclkout0 (),
    .sclkout1 (),
    .vcooverrange (),
    .vcounderrange ()
);

endmodule // zl_sys_pll

`endif // _ZL_SYS_PLL_V_
