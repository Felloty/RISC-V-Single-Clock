create_clock -period "50.0 MHz" [get_ports clk]

derive_clock_uncertainty

create_generated_clock -name {clk_cpu} -divide_by 2 -source [get_ports {clk}] [get_registers {top:top_entity|clock_divider:cpu_clk_div|cntr[24]}]
create_generated_clock -name {clk_hex} -divide_by 2 -source [get_ports {clk}] [get_registers {clock_divider:hex_clk_div|cntr[16]}]

set_false_path -from [get_ports {key[*]}] -to [all_clocks]

set_false_path -from * -to [get_ports {led[*]}]
set_false_path -from * -to [get_ports {hex[*]}]
set_false_path -from * -to [get_ports {digit[*]}]
set_false_path -from * -to buzzer