set outputDir ./vivado
file mkdir $outputDir
read_verilog ./scratch_pad.v
read_verilog ../reorder_queue/reorder_queue.v
read_verilog ../linked_fifo/linked_fifo.v
read_verilog ../multistage_interconnect_network/basic_switch_ff.v
read_verilog ../multistage_interconnect_network/omega_network_ff.v
read_verilog ../common/simple_ram.v
synth_design -no_iobuf -include_dirs ../. -top scratch_pad -part xc7v2000t
write_checkpoint -force $outputDir/post_synth.dcp
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_utilization -file $outputDir/post_synth_util.rpt
