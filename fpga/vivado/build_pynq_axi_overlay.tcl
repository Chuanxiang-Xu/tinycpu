set proj_name tinycpu_pynq_v0_9_jupyter_axi_overlay
set proj_dir  ./build/vivado/$proj_name
set bd_name   tinycpu_pynq_system
set ram_hex   programs/led_switch_demo.hex
set ram_words 4
set loader_base 0x43C00000
set loader_range 0x00020000
set fclk_mhz 25.000000
set fclk_hz  25000000

if {[info exists ::env(TINYCPU_RAM_HEX)]} {
    set ram_hex $::env(TINYCPU_RAM_HEX)
}

if {[info exists ::env(TINYCPU_RAM_INIT_WORDS)]} {
    set ram_words $::env(TINYCPU_RAM_INIT_WORDS)
}

set ram_hex_abs [file normalize $ram_hex]

create_project $proj_name $proj_dir -part xc7z020clg400-1 -force
set_property target_language Verilog [current_project]

set pynq_board_parts [get_board_parts -quiet *pynq-z2*]
if {[llength $pynq_board_parts] > 0} {
    set_property board_part [lindex $pynq_board_parts 0] [current_project]
}

add_files [glob ./rtl/core/*.sv]
add_files [glob ./rtl/bus/*.sv]
add_files [glob ./rtl/mem/*.sv]
add_files [glob ./rtl/soc/*.sv]
add_files ./rtl/board/tinycpu_pynq_axi_overlay.sv
add_files ./rtl/board/tinycpu_pynq_axi_overlay_bd.v
add_files -fileset sources_1 $ram_hex_abs
set_property file_type {Memory Initialization Files} [get_files $ram_hex_abs]
add_files -fileset constrs_1 ./fpga/vivado/pynqz2_axi_overlay.xdc
update_compile_order -fileset sources_1

create_bd_design $bd_name

set ps7 [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps7]
set_property -dict [list \
    CONFIG.PCW_USE_M_AXI_GP0 {1} \
    CONFIG.PCW_EN_CLK0_PORT {1} \
] $ps7

if {[catch {
    apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
        -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable"} \
        $ps7
} automation_msg]} {
    puts "PS7 board-preset automation failed; retrying without board preset."
    puts $automation_msg
    apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
        -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable"} \
        $ps7
}

set_property -dict [list \
    CONFIG.PCW_CLK0_FREQ $fclk_hz \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ $fclk_mhz \
] $ps7

set axi_interconnect [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0]
set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1}] $axi_interconnect

set tinycpu [create_bd_cell -type module -reference tinycpu_pynq_axi_overlay_bd tinycpu_0]
set_property -dict [list \
    CONFIG.RAM_HEX $ram_hex_abs \
    CONFIG.RAM_INIT_WORDS $ram_words \
] $tinycpu

connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins ps7/M_AXI_GP0_ACLK]
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins axi_interconnect_0/ACLK]
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins axi_interconnect_0/S00_ACLK]
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins axi_interconnect_0/M00_ACLK]
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins tinycpu_0/s_axi_aclk]

connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins axi_interconnect_0/ARESETN]
connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins axi_interconnect_0/S00_ARESETN]
connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins axi_interconnect_0/M00_ARESETN]
connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins tinycpu_0/s_axi_aresetn]

connect_bd_intf_net [get_bd_intf_pins ps7/M_AXI_GP0] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins tinycpu_0/S_AXI]

make_bd_pins_external [get_bd_pins tinycpu_0/btn]
make_bd_pins_external [get_bd_pins tinycpu_0/sw]
make_bd_pins_external [get_bd_pins tinycpu_0/led]
set_property name btn [get_bd_ports btn_0]
set_property name sw  [get_bd_ports sw_0]
set_property name led [get_bd_ports led_0]

set tinycpu_seg [get_bd_addr_segs -quiet tinycpu_0/S_AXI/reg0]
if {[llength $tinycpu_seg] == 0} {
    set tinycpu_seg [get_bd_addr_segs -quiet tinycpu_0/s_axi/reg0]
}
if {[llength $tinycpu_seg] == 0} {
    set tinycpu_seg [get_bd_addr_segs -of_objects [get_bd_intf_pins tinycpu_0/S_AXI]]
}
if {[llength $tinycpu_seg] == 0} {
    error "Could not find tinycpu S_AXI address segment"
}

assign_bd_address \
    -target_address_space [get_bd_addr_spaces ps7/Data] \
    -offset $loader_base \
    -range $loader_range \
    $tinycpu_seg

validate_bd_design
save_bd_design

make_wrapper -files [get_files $proj_dir/$proj_name.srcs/sources_1/bd/$bd_name/$bd_name.bd] -top
add_files $proj_dir/$proj_name.gen/sources_1/bd/$bd_name/hdl/${bd_name}_wrapper.v

set_property top ${bd_name}_wrapper [current_fileset]
update_compile_order -fileset sources_1

launch_runs synth_1 -jobs 8
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

set bitstream_path \
    "./build/vivado/${proj_name}/${proj_name}.runs/impl_1/${bd_name}_wrapper.bit"
set hwh_path \
    "./build/vivado/${proj_name}/${proj_name}.gen/sources_1/bd/${bd_name}/hw_handoff/${bd_name}.hwh"

puts "============================================================"
puts "tinycpu v0.9 Jupyter AXI overlay generated"
puts "Project: ${proj_name}"
puts "Loader base: ${loader_base}"
puts "FCLK0 MHz: ${fclk_mhz}"
puts "Bitstream: ${bitstream_path}"
puts "HWH: ${hwh_path}"
puts "============================================================"
