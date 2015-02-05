all : work scratch_pad scratch_pad_tb reorder_queue

work :
	source ~/Xilinx_Env
	vlib work

compile_scratch_pad = work/scratch_pad

compile_scratch_pad_tb = work/scratch_pad_tb

compile_reorder_queue = work/reorder_queue

scratch_pad : $(compile_scratch_pad)
scratch_pad_tb : $(compile_scratch_pad_tb)
reorder_queue : $(compile_reorder_queue)

$(compile_scratch_pad) : scratch_pad.v
	vlog -work work scratch_pad.v +incdir+./..

$(compile_scratch_pad_tb) : scratch_pad_tb.v
	vlog -work work scratch_pad_tb.v +incdir+./..

$(compile_reorder_queue) : ../reorder_queue/reorder_queue.v
	vlog -work work ../reorder_queue/reorder_queue.v

clean :
	rm -rf work transcript *.lso *.out *.ngc *.xrpt *.srp _xmsgs xst

check : all
	echo -e "vsim work.scratch_pad_tb\nrun -all" | vsim
