all : work arbiter std_fifo cross_bar cross_bar_tb check

compile_arbiter = work/arbiter
compile_std_fifo = work/std_fifo
compile_cross_bar = work/cross_bar
compile_cross_bar_tb = work/cross_bar_tb

arbiter : $(compile_arbiter)
std_fifo : $(compile_std_fifo)
cross_bar : $(compile_cross_bar)
cross_bar_tb : $(compile_cross_bar_tb)

work :
	vlib work

$(compile_arbiter) : ../arbiter/arbiter.v 
	vlog -work work ../arbiter/arbiter.v

$(compile_std_fifo): ../std_fifo/std_fifo.v 
	vlog -work work ../std_fifo/std_fifo.v

$(compile_cross_bar): cross_bar.v 
	vlog -work work cross_bar.v

$(compile_cross_bar_tb): cross_bar_tb.v
	vlog -work work cross_bar_tb.v

check : $(compile_cross_bar) $(compile_cross_bar_tb)
	vsim < test.do

synthesis :
	xst -ifn cross_bar.xst

clean :
	rm -rf work transcript *.lso *.out *.ngc *.xrpt *.srp _xmsgs xst
