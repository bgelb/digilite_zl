## Generated SDC file "zl_top.sdc"

## Copyright (C) 1991-2011 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 11.0 Build 208 07/03/2011 Service Pack 1 SJ Web Edition"

## DATE    "Sat Oct  1 23:13:12 2011"

##
## DEVICE  "EP4CE22F17C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {ext_clk_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {ext_clk_50}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {sys_pll|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {sys_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {ext_clk_50} [get_pins {sys_pll|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {sys_pll|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {sys_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -divide_by 25 -master_clock {ext_clk_50} [get_pins {sys_pll|altpll_component|auto_generated|pll1|clk[1]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {sys_pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020 


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_cd9:dffpipe14|dffe15a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_bd9:dffpipe11|dffe12a*}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

