source ./fpga/vivado/create_project.tcl

launch_runs synth_1 -jobs 8
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

puts "============================================================"
puts "tinycpu-pynq v0.3-open-rv32im bitstream generated:"
puts "./build/vivado/tinycpu_pynq_v0_3_open_rv32im/tinycpu_pynq_v0_3_open_rv32im.runs/impl_1/pynqz2_top.bit"
puts "============================================================"
