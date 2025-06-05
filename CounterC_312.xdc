create_clock -period 5 -name clk_gen -add [get_ports clk]

set_property BEL A6LUT [get_cells CounterC_312_inst/LUT6_inst0]

set_property BEL AFF2 [get_cells CounterC_312_inst/O_reg_reg]