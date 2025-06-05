create_clock -period 5 -name clk_gen -add [get_ports clk]

# set_property LOCK_PINS I4:CASC [get_cells Counter_Chain_inst/Counter_15_inst_tail/LUT6CY_inst0/LUTCY1_INST]
# set_property LOCK_PINS I4:CASC [get_cells Counter_Chain_inst/Counter_15_inst_tail/LUT6CY_inst0/LUTCY2_INST]

# set_property BEL A5LUT [get_cells Counter_Chain_inst/Counter_15_inst_tail/LUT6CY_inst0/LUTCY1_INST]
# set_property BEL A5LUT [get_cells Counter_Chain_inst/Counter_15_inst_tail/LUT6CY_inst0/LUTCY2_INST]
# set_property BEL B5LUT [get_cells Counter_Chain_inst/Counter_15_inst_tail/LUT6CY_inst1/LUTCY1_INST]
# set_property BEL B5LUT [get_cells Counter_Chain_inst/Counter_15_inst_tail/LUT6CY_inst1/LUTCY2_INST]