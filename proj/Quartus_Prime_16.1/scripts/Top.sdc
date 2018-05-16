create_clock -name CLOCK -period 20.000 [get_ports {Clock}]
derive_pll_clocks
derive_clock_uncertainty
set_false_path -from [get_ports {Reset}]
set_false_path -to [get_ports {Dout}]