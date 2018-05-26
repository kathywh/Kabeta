## Generated SDC file "F:/Workspace/Kabeta/proj/Quartus_Prime_16.1/scripts/SystemChip.sdc"

## Copyright (C) 2017  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Intel and sold by Intel or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 16.1.2 Build 203 01/18/2017 SJ Standard Edition"

## DATE    "Sat May 26 11:06:28 2018"

##
## DEVICE  "EP4CE6F17C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {CLOCK} -period 20.000 -waveform { 0.000 10.000 } [get_ports {Clock}]


#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty


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

set_false_path -from [get_ports {Reset}]
set_false_path -from [get_ports {Keys[*]}]
set_false_path -to [get_ports {Dout}]

# IACK (ACK) Sys->I/O
set_false_path -from [get_pins {KAB_CORE|KIU|EIC_IntAck|clk}] -to [get_pins {KAB_IO|EIC|IACK_SYNC|SyncData1|*}]

# IOIF (ACK): I/O->Sys
set_false_path -from [get_pins {KAB_IO|IOIF|HSHK|R_Ack|clk}] -to [get_pins {KAB_IO|IOIF|HSHK|ACK_SYNC|SyncData1|*}]

# EIC write INR (ACK) Sys->I/O
set_false_path -from [get_pins {KAB_IO|EIC|INR|HSHK|R_Ack|clk}] -to [get_pins {KAB_IO|EIC|INR|HSHK|ACK_SYNC|SyncData1|*}]


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



#**************************************************************
# Set Max Skew
#**************************************************************

# IRQ (REQ): I/O->Sys
set_max_skew -from [get_pins {KAB_IO|EIC|EIC_IntReq|clk KAB_IO|EIC|EIC_IntId|clk}] -to [get_pins {KAB_CORE|KIU|SYNC_IRQ|SyncData1|* KAB_CORE|KIU|SYNC_IID|SyncData1|*}] -exclude {from_clock to_clock clock_uncertainty} -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.8

# IOIF (REQ): Sys->I/O
set_max_skew -from [get_pins {KAB_IO|IOIF|HSHK|T_Req|clk KAB_IO|IOIF|HSHK|T_DataReg[*]|clk}] -to [get_pins {KAB_IO|IOIF|HSHK|REQ_SYNC|SyncData1|* KAB_IO|IOIF|HSHK|DATA_BIT[0].SYNC|SyncData1|*}] -exclude {from_clock to_clock clock_uncertainty} -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.8

# EIC write INR (REQ): I/O->Sys
set_max_skew -from [get_pins {KAB_IO|EIC|INR|HSHK|T_Req|clk KAB_IO|EIC|INR|HSHK|T_DataReg[*]|clk}] -to [get_pins {KAB_IO|EIC|INR|HSHK|REQ_SYNC|SyncData1|* KAB_IO|EIC|INR|HSHK|DATA_BIT[*].SYNC|SyncData1|*}] -exclude {from_clock to_clock clock_uncertainty} -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.8