source ./fpga/vivado/create_project.tcl

set bitstream_path \
    "./build/vivado/${proj_name}/${proj_name}.runs/impl_1/pynqz2_top.bit"

launch_runs synth_1 -jobs 8
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

puts "============================================================"
puts "tinycpu v0.6-pipeline-bram-loader bitstream generated"
puts "Project: ${proj_name}"
puts "Bitstream: ${bitstream_path}"
puts "============================================================"
