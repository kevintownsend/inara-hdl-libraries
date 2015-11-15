all : work scratch_pad scratch_pad_tb reorder_queue

vim:
	vim -p makefile ../linked_list_fifo/linked_list_fifo.v scratch_pad.v

work :
	source ~/Xilinx_Env
	vlib work

compile_scratch_pad = work/scratch_pad

compile_scratch_pad_tb = work/scratch_pad_tb

compile_reorder_queue = work/reorder_queue
compile_scratch_pad_gold = work/scratch_pad_gold
compile_linked_fifo = work/linked_fifo
compile_linked_list_fifo = work/linked_list_fifo
compile_omega_network_ff = work/omega_network_ff
compile_basic_switch_ff = work/basic_switch_ff
compile_simple_ram = work/simple_ram

scratch_pad : $(compile_scratch_pad)
scratch_pad_tb : $(compile_scratch_pad_tb)
reorder_queue : $(compile_reorder_queue)
linked_fifo : $(compile_linked_fifo)
omega_network_ff : $(compile_omega_network_ff)
basic_switch_ff : $(compile_basic_switch_ff)
simple_ram : $(compile_simple_ram)

$(compile_scratch_pad_tb) : scratch_pad_tb.v $(compile_scratch_pad_gold)
	vlog -work work scratch_pad_tb.v +incdir+./..
$(compile_scratch_pad) : scratch_pad.v $(compile_linked_fifo) omega_network_ff simple_ram
	vlog -work work scratch_pad.v +incdir+./..
$(compile_scratch_pad_gold) : ../scratch_pad_gold/scratch_pad_gold.v
	vlog -work work ../scratch_pad_gold/scratch_pad_gold.v +incdir+./..
$(compile_linked_fifo) : ../linked_fifo/linked_fifo.v
	vlog -work work ../linked_fifo/linked_fifo.v +incdir+./..
$(compile_linked_list_fifo) : ../linked_list_fifo/linked_list_fifo.v
	vlog -work work ../linked_list_fifo/linked_list_fifo.v +incdir+./..
$(compile_omega_network_ff) : ../multistage_interconnect_network/omega_network_ff.v $(compile_basic_switch_ff)
	vlog -work work ../multistage_interconnect_network/omega_network_ff.v +incdir+./..
$(compile_basic_switch_ff) : ../multistage_interconnect_network/basic_switch_ff.v
	vlog -work work ../multistage_interconnect_network/basic_switch_ff.v +incdir+./..
$(compile_simple_ram) : ../common/simple_ram.v
	vlog -work work ../common/simple_ram.v +incdir+./..
$(compile_reorder_queue) : ../reorder_queue/reorder_queue.v
	vlog -work work ../reorder_queue/reorder_queue.v +incdir+./..

synthesis :
	xst -ifn scratch_pad.xst > xst.out

clean :
	rm -rf work transcript *.lso *.out *.ngc *.xrpt *.srp _xmsgs xst

check : all $(compile_linked_list_fifo)
	echo -e "vsim work.scratch_pad_tb\nrun -all" | vsim

xst : scratch_pad.prj
	echo "run -ifn scratch_pad.prj -ifmt mixed -top scratch_pad -ofn scratch_pad.ngc -ofmt NGC -p xc7v2000t -iobuf NO -bufg 0 -iob false -bram_utilization_ratio -1 -generics {WIDTH=64 | PORTS=16 | REORDER_DEPTH=64} -opt_mode Speed -opt_level 1 -vlgincdir ../." | xst > xst.out

rexst : cleanXst xst

scratch_pad.prj :
	echo -e "verilog work scratch_pad.v\n\
	verilog work ../linked_fifo/linked_fifo.v\n\
	verilog work ../linked_list_fifo/linked_list_fifo.v\n\
	verilog work ../reorder_queue/reorder_queue.v\n\
	verilog work ../multistage_interconnect_network/basic_switch_ff.v\n\
	verilog work ../multistage_interconnect_network/omega_network_ff.v\n\
	verilog work ../common/simple_ram.v" > scratch_pad.prj

cleanXst :
	rm -rf xst *.prj

tcl:
	vivado -mode tcl < compile.tcl
