create_clock -period 5 -name clk_gen -add [get_ports clk]

set_property LOCK_PINS I4:CASC [get_cells Counter_123_inst/LUT6_2_inst1/LUT5]
set_property LOCK_PINS I4:CASC [get_cells Counter_123_inst/LUT6_2_inst1/LUT6]

set_property BEL A5LUT [get_cells Counter_123_inst/LUT6_2_inst0/LUT5]
set_property BEL A6LUT [get_cells Counter_123_inst/LUT6_2_inst0/LUT6]
set_property BEL B5LUT [get_cells Counter_123_inst/LUT6_2_inst1/LUT5]
set_property BEL B6LUT [get_cells Counter_123_inst/LUT6_2_inst1/LUT6]

set_property BEL AFF  [get_cells Counter_123_inst/O_reg_reg[0]]
set_property BEL AFF2 [get_cells Counter_123_inst/O_reg_reg[1]]
set_property BEL BFF  [get_cells Counter_123_inst/O_reg_reg[2]]
set_property BEL BFF2 [get_cells Counter_123_inst/O_reg_reg[3]]