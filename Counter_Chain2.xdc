create_clock -period 5 -name clk_gen -add [get_ports clk]


set_property LOCK_PINS I4:CASC [get_cells Counter_Chain2_inst/Counter_223_inst0/LUT6CY_inst1/LUTCY1_INST]
set_property LOCK_PINS I4:CASC [get_cells Counter_Chain2_inst/Counter_223_inst0/LUT6CY_inst1/LUTCY2_INST]

set_property LOCK_PINS I4:CASC [get_cells Counter_Chain2_inst/Counter_223_inst1/LUT6CY_inst1/LUTCY1_INST]
set_property LOCK_PINS I4:CASC [get_cells Counter_Chain2_inst/Counter_223_inst1/LUT6CY_inst1/LUTCY2_INST]