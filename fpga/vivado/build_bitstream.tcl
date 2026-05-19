source ./fpga/vivado/create_project.tcl

launch_runs synth_1 -jobs 8
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

puts "============================================================"
puts "tinycpu-pynq v0.5-rv32im-m-extension bitstream generated:"
puts "./build/vivado/tinycpu_pynq_v0_5_rv32im_m_extension/tinycpu_pynq_v0_5_rv32im_m_extension.runs/impl_1/pynqz2_top.bit"
puts "============================================================"
