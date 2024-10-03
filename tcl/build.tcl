# Set message mode to all for detailed output (optional)
set message_mode all

# Define project parameters
set project_name "bcd_counter"
set project_dir "./${project_name}" 
set design_name "Top"        
set board_name "Nexys4" 
set fpga_part "xc7a100tcsg324-1"

# Set reference directories for source files and constraints
set constraints_dir [file normalize "./constraints"]
set source_dir [file normalize "./rtl"]
set bitstream_dir [file normalize "./bitstream"]

# Create the Vivado project
if {[file exists $project_dir]} {
    file delete -force $project_dir
}
create_project $project_name $project_dir -part $fpga_part

# Create bitstream directory if it doesn't exist
file mkdir $bitstream_dir

# Read design sources
read_verilog -sv "${source_dir}/Clock_Generator/Clock_Generator.sv"
read_verilog -v "${source_dir}/Clock_Generator/debouncer.v"
read_verilog -sv "${source_dir}/Counter/Counter.sv"
read_verilog -v "${source_dir}/Seven_Seg/Seven_Seg_Nexys.v"
read_verilog -v "${source_dir}/Top/Top_Nexys.v"

# Read constraints
set constraint_file "${constraints_dir}/TOP_${board_name}.xdc"
read_xdc $constraint_file

# Synthesize design
puts "Starting synthesis..."
synth_design -top $design_name -part $fpga_part -verbose

# Implement design (place and route)
puts "Starting implementation..."
opt_design -verbose
place_design -verbose
route_design -verbose

# Write the bitstream
write_bitstream -force "${bitstream_dir}/${design_name}.bit" -verbose

# Close the project
close_project