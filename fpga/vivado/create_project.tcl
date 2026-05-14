set proj_name tinycpu_pynq_v0_3_open_rv32im
set proj_dir  ./build/vivado/$proj_name

# PYNQ-Z2 commonly uses xc7z020clg400-1. Confirm this for your board revision.
create_project $proj_name $proj_dir -part xc7z020clg400-1 -force

set_property target_language Verilog [current_project]

add_files [glob ./rtl/core/*.sv]
add_files [glob ./rtl/axil/*.sv]
add_files ./rtl/soc/tinycpu_soc.sv
add_files ./rtl/board/pynqz2_top.sv
add_files -fileset constrs_1 ./fpga/vivado/pynqz2.xdc

set_property top pynqz2_top [current_fileset]
update_compile_order -fileset sources_1

puts "Created Vivado project at $proj_dir"
