
vsim_std_fifo = work/std_fifo

vsim_std_fifo_tb = work/std_fifo_tb

work :
	vlib work

$(vsim_std_fifo) : std_fifo.v work
	vlog std_fifo.v +incdir+./..

$(vsim_std_fifo_tb) : std_fifo_tb.v work
	vlog std_fifo_tb.v +incdir+./..

cleanVsim :
	rm -rf work transcript

checkVsim : work $(vsim_std_fifo_tb) $(vsim_std_fifo)
	echo -e "vsim work.std_fifo_tb\nrun -all" | vsim
