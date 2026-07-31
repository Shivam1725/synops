# Template SDC for a single functional mode.
# Replace placeholder port names and timing budgets with project-specific values.

# Define the primary clock.
create_clock -name core_clk -period 1.000 [get_ports clk]
set_clock_uncertainty 0.050 [get_clocks core_clk]

# Model synchronous input and output timing.
set_input_delay 0.100 -clock [get_clocks core_clk] [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 0.100 -clock [get_clocks core_clk] [all_outputs]

# Example false-path declaration for asynchronous or test-only signals.
# set_false_path -from [get_ports async_status_in] -to [get_ports async_status_out]

# Example multicycle path for architecturally relaxed logic.
# set_multicycle_path 2 -setup -from [get_pins u_slow_block/*] -to [get_pins u_accum/*]
# set_multicycle_path 1 -hold  -from [get_pins u_slow_block/*] -to [get_pins u_accum/*]
