set proj_name tinycpu_pynq_v0_4_fuller_rv32i_c_support
set proj_dir  ./build/vivado/$proj_name
set ram_hex   programs/led_switch_demo.hex
set ram_words 4

if {[info exists ::env(TINYCPU_RAM_HEX)]} {
    set ram_hex $::env(TINYCPU_RAM_HEX)
}

if {[info exists ::env(TINYCPU_RAM_INIT_WORDS)]} {
    set ram_words $::env(TINYCPU_RAM_INIT_WORDS)
}

set ram_hex_abs [file normalize $ram_hex]

# PYNQ-Z2 commonly uses xc7z020clg400-1. Confirm this for your board revision.
create_project $proj_name $proj_dir -part xc7z020clg400-1 -force

set_property target_language Verilog [current_project]

add_files [glob ./rtl/core/*.sv]
add_files [glob ./rtl/axil/*.sv]
add_files ./rtl/soc/tinycpu_soc.sv
add_files ./rtl/board/pynqz2_top.sv
add_files -fileset sources_1 $ram_hex_abs
set_property file_type {Memory Initialization Files} [get_files $ram_hex_abs]
add_files -fileset constrs_1 ./fpga/vivado/pynqz2.xdc

set_property top pynqz2_top [current_fileset]
set_property generic "RAM_HEX=$ram_hex_abs RAM_INIT_WORDS=$ram_words" [current_fileset]
update_compile_order -fileset sources_1

puts "Created Vivado project at $proj_dir"
puts "RAM_HEX=$ram_hex_abs RAM_INIT_WORDS=$ram_words"
