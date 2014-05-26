all : work reorder_queue reorder_queue_tb 

work :
	vlib work

compile_reorder_queue = work/reorder_queue

reorder_queue : $(compile_reorder_queue)

$(compile_reorder_queue) : reorder_queue.v
	vlog -work work reorder_queue.v +incdir+../.

compile_reorder_queue_tb = work/reorder_queue_tb

reorder_queue_tb : $(compile_reorder_queue_tb) $(compile_reorder_queue)

$(compile_reorder_queue_tb) : reorder_queue_tb.v 
	vlog -work work reorder_queue_tb.v +incdir+../.

test : reorder_queue_tb
	vsim < test.do

clean :
	rm -rf work transcript *.lso *.out *.ngc *.xrpt *.srp _xmsgs xst

synthesis : 
	xst -ifn reorder_queue.xst
