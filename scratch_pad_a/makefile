all : work scratch_pad scratch_pad_tb reorder_queue cross_bar std_fifo arbiter simple_ram scratch_pad_gold

sim :
	iverilog -o std_fifo_tb.vvp -I.. simple_ram.v ../scratch_pad_gold/scratch_pad_gold.v scratch_pad_tb.v scratch_pad.v ../arbiter/arbiter.v ../std_fifo/std_fifo.v ../reorder_queue/reorder_queue.v ../cross_bar/cross_bar.v 
	std_fifo_tb.vvp

work :
	vlib work

common.vh :
	cp ../../common/common.vh .

compile_scratch_pad = work/scratch_pad

compile_scratch_pad_tb = work/scratch_pad_tb
compile_scratch_pad_tb2 = work/scratch_pad_tb2

compile_reorder_queue = work/reorder_queue

compile_cross_bar = work/cross_bar

compile_std_fifo = work/std_fifo

compile_arbiter = work/arbiter

compile_simple_ram = work/simple_ram

compile_scratch_pad_gold = work/scratch_pad_gold

scratch_pad : $(compile_scratch_pad)
scratch_pad_tb : $(compile_scratch_pad_tb)
scratch_pad_tb2 : $(compile_scratch_pad_tb2)
reorder_queue : $(compile_reorder_queue)
cross_bar : $(compile_cross_bar)
std_fifo : $(compile_std_fifo)
arbiter : $(compile_arbiter)
simple_ram : $(compile_simple_ram)
scratch_pad_gold : $(compile_scratch_pad_gold)

$(compile_scratch_pad) : scratch_pad.v $(compile_cross_bar) $(compile_reorder_queue) $(compile_simple_ram)
	vlog -work work scratch_pad.v +incdir+./..

$(compile_scratch_pad_tb) : scratch_pad_tb.v $(compile_scratch_pad_gold)
	vlog -work work scratch_pad_tb.v +incdir+./..

$(compile_scratch_pad_tb2) : scratch_pad_tb2.v $(compile_scratch_pad_gold)
	vlog -work work scratch_pad_tb2.v +incdir+./..
$(compile_reorder_queue) : ../reorder_queue/reorder_queue.v $(compile_arbiter)
	vlog -work work ../reorder_queue/reorder_queue.v +incdir+./..

$(compile_cross_bar) : ../cross_bar/cross_bar.v
	vlog -work work ../cross_bar/cross_bar.v +incdir+./..

$(compile_std_fifo) : ../std_fifo/std_fifo.v
	vlog -work work ../std_fifo/std_fifo.v +incdir+./..

$(compile_arbiter) : ../arbiter/arbiter.v $(compile_std_fifo)
	vlog -work work ../arbiter/arbiter.v +incdir+./..

$(compile_simple_ram) : simple_ram.v
	vlog -work work simple_ram.v

$(compile_scratch_pad_gold) : ../scratch_pad_gold/scratch_pad_gold.v
	vlog -work work ../scratch_pad_gold/scratch_pad_gold.v +incdir+./..

check : work $(compile_scratch_pad) $(compile_scratch_pad_tb)
	vsim < test.do

checkSynth : work $(compile_scratch_pad) $(compile_scratch_pad_tb)
	vlog -work work vivado/cpu_impl_netlist.v +incdir+./..
	vsim < test.do

check2 : work $(compile_scratch_pad) $(compile_scratch_pad_tb2)
	echo -e "vsim work.scratch_pad_tb\nrun -all" | vsim

synthesis :
	echo "run -ifn scratch_pad.prj -ifmt mixed -top scratch_pad -ofn scratch_pad.ngc -ofmt NGC -p xc7v2000t -iobuf NO -bufg 0 -iob false -bram_utilization_ratio 4# -generics {WIDTH=64 | PORTS=4 | REORDER_DEPTH=64} -opt_mode Speed -opt_level 1 -vlgincdir ../." | xst > xst.out

tcl : common.vh
	vivado -mode tcl < compile.tcl

clean :
	rm -rf work transcript *.lso *.out *.ngc *.xrpt *.srp _xmsgs xst *.log *.jou vivado

vim:
	vim -p makefile compile.tcl scratch_pad_synthesis.v scratch_pad.v



