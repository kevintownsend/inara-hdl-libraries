set outputDir ./vivado
file mkdir $outputDir
read_verilog ./scratch_pad.v
read_verilog ./scratch_pad_synthesis.v
read_verilog ../std_fifo/std_fifo.v
read_verilog ../arbiter/arbiter.v
read_verilog ../reorder_queue/reorder_queue.v
read_verilog ../cross_bar/cross_bar.v
read_verilog ../common/simple_ram.v
read_xdc ./top.xdc
#synth_design -no_iobuf -include_dirs ../. -top scratch_pad -part xc7v2000t
synth_design -include_dirs ../. -top scratch_pad -max_bram 32 -generic PORTS=4 -part xc7v2000t
create_clock -period 6.667 clk
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
#synth_design -include_dirs ../. -top scratch_pad_synthesis -max_bram 12 -part xc7a200t
write_checkpoint -force $outputDir/post_synth.dcp
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_utilization -file $outputDir/post_synth_util.rpt
opt_design
place_design
route_design
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_utilization -file $outputDir/post_route_util.rpt

write_checkpoint -force $outputDir/post_route.dcp
report_drc -file $outputDir/post_imp_drc.rpt
write_verilog -force $outputDir/cpu_impl_netlist.v -mode timesim -sdf_anno true

write_bitstream -force $outputDir/cpu.bit
