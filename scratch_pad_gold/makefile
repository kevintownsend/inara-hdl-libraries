all : work scratch_pad_gold scratch_pad_gold_tb reorder_queue

work :
	source ~/Xilinx_Env
	vlib work

compile_scratch_pad_gold = work/scratch_pad_gold

compile_scratch_pad_gold_tb = work/scratch_pad_gold_tb

compile_reorder_queue = work/reorder_queue

scratch_pad_gold : $(compile_scratch_pad_gold)
scratch_pad_gold_tb : $(compile_scratch_pad_gold_tb)
reorder_queue : $(compile_reorder_queue)

$(compile_scratch_pad_gold) : scratch_pad_gold.v
	vlog -work work scratch_pad_gold.v +incdir+./..

$(compile_scratch_pad_gold_tb) : scratch_pad_gold_tb.v
	vlog -work work scratch_pad_gold_tb.v +incdir+./..

$(compile_reorder_queue) : ../reorder_queue/reorder_queue.v
	vlog -work work ../reorder_queue/reorder_queue.v +incdir+./..

clean :
	rm -rf work transcript

check : all
	echo -e "vsim work.scratch_pad_gold_tb\nrun -all" | vsim
