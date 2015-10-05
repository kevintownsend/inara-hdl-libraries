set outputDir ./vivado
file mkdir $outputDir
read_verilog ./std_fifo.v
synth_design -no_iobuf -include_dirs ../. -top std_fifo -part xc7v2000t
#synth_design -include_dirs ../. -top std_fifo -part xc7v2000t
write_checkpoint -force $outputDir/post_synth.dcp
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_utilization -file $outputDir/post_synth_util.rpt
opt_design
place_design
route_design
