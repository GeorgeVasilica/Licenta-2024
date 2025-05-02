
# Clock Constraints
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk -waveform {0.000 5.000} [get_ports clk]
set_clock_uncertainty 0.500 [get_clocks sys_clk]

# Reset Signal
set_property PACKAGE_PIN T18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property PULLUP true [get_ports reset]

# LED Outputs
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]
set_property DRIVE 8 [get_ports {led[*]}]
set_property SLEW SLOW [get_ports {led[*]}]

# Memory Interface
set_property IOSTANDARD LVCMOS33 [get_ports {inst_addr[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {inst_data[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_addr[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_write[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports data_we]

#Basic Timing Constraints
set_input_delay -clock sys_clk 2.000 [get_ports {inst_data[*]}]
set_output_delay -clock sys_clk 2.000 [get_ports {inst_addr[*]}]
set_output_delay -clock sys_clk 2.000 [get_ports {data_addr[*]}]
set_output_delay -clock sys_clk 2.000 [get_ports {data_write[*]}]
set_output_delay -clock sys_clk 2.000 [get_ports data_we]
set_input_delay -clock sys_clk 2.000 [get_ports {data_read[*]}]

# False Paths
set_false_path -from [get_ports reset] -to [all_registers]
