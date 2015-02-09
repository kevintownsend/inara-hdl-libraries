all : work scratch_pad scratch_pad_tb reorder_queue cross_bar std_fifo arbiter simple_ram scratch_pad_gold

work :
	vlib work

compile_scratch_pad = work/scratch_pad

compile_scratch_pad_tb = work/scratch_pad_tb

compile_reorder_queue = work/reorder_queue

compile_cross_bar = work/cross_bar

compile_std_fifo = work/std_fifo

compile_arbiter = work/arbiter

compile_simple_ram = work/simple_ram

compile_scratch_pad_gold = work/scratch_pad_gold

scratch_pad : $(compile_scratch_pad)
scratch_pad_tb : $(compile_scratch_pad_tb)
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

synthesis :
	xst -ifn scratch_pad.xst > xst.out

clean :
	rm -rf work transcript *.lso *.out *.ngc *.xrpt *.srp _xmsgs xst
