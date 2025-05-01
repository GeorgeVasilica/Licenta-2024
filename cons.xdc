## Clock Signal (example for Basys3 board)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clk]

## Reset Button (example for Basys3)
set_property PACKAGE_PIN T18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## Example output pin constraints (adjust for your board)
set_property PACKAGE_PIN M14 [get_ports {data_addr[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_addr[0]}]

## Verify ports exist before applying timing constraints
if {[llength [get_ports {inst_data[*]}]] > 0} {
    set_input_delay -clock [get_clocks sys_clk_pin] 2.000 [get_ports {inst_data[*]}]
}

if {[llength [get_ports {inst_addr[*]}]] > 0} {
    set_output_delay -clock [get_clocks sys_clk_pin] 2.000 [get_ports {inst_addr[*]}]
}
