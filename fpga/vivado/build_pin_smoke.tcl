set proj_name tinycpu_pynq_pin_smoke
set proj_dir  ./build/vivado/$proj_name

# PYNQ-Z2 commonly uses xc7z020clg400-1. Confirm this for your board revision.
create_project $proj_name $proj_dir -part xc7z020clg400-1 -force

set_property target_language Verilog [current_project]

add_files ./rtl/board/pynqz2_pin_smoke_top.sv
add_files -fileset constrs_1 ./fpga/vivado/pynqz2.xdc

set_property top pynqz2_pin_smoke_top [current_fileset]
update_compile_order -fileset sources_1

launch_runs synth_1 -jobs 8
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

puts "============================================================"
puts "PYNQ-Z2 pin smoke bitstream generated:"
puts "./build/vivado/tinycpu_pynq_pin_smoke/tinycpu_pynq_pin_smoke.runs/impl_1/pynqz2_pin_smoke_top.bit"
puts "Expected behavior:"
puts "  LED0 follows SW0"
puts "  LED1 follows SW1"
puts "  LED2 follows BTN0"
puts "  LED3 blinks from sysclk"
puts "============================================================"
