# build settings
set design_name "bcd_counter"
set board_name "Nexys4"
set fpga_part "xc7a100tcsg324-1"

# set reference directories for source files
set constraints_dir [file normalize "./constraints"]
set source_dir [file normalize "./rtl"]
set bitstream_dir [file normalize "./bitstream"]

# read design sources
read_verilog -sv "${source_dir}/Clock_Generator/Clock_Generator.sv"
read_verilog -v "${source_dir}/Clock_Generator/debouncer.v"
read_verilog -sv "${source_dir}/Counter/Counter.sv"
read_verilog -v "${source_dir}/Seven_Seg/Seven_Seg_Nexys.v"
read_verilog -v "${source_dir}/Top/Top_Nexys.v"

# read constraints
set constraint_file "${constraints_dir}/TOP_${board_name}.xdc"
read_xdc $constraint_file

# synth
synth_design -top "Top" -part ${fpga_part} -verbose

# place and route
opt_design -verbose
place_design -verbose
route_design -verbose

# write bitstream
write_bitstream -force "${bitstream_dir}/${design_name}.bit" -verbose